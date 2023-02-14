use criterion::{criterion_group, criterion_main, Criterion};
use packed_simd::Simd;
use std::time::Duration;
use warp_devices::cores::cms::{CmsOps, CmsReg};
use warp_devices::shells::{Shell, XilinxU55nXdmaStd};
use warp_devices::xdma::{BasedDmaOps, DmaBuffer};

const PAYLOAD_LEN: usize = 1 * 1024 * 1024 * 1024;
const CHUNK_LEN: usize = 64;

fn random_payload() -> DmaBuffer {
    let mut buf: DmaBuffer = DmaBuffer::new(PAYLOAD_LEN);
    let mut chunk: [u8; CHUNK_LEN] = [0; CHUNK_LEN];
    for _ in 0..PAYLOAD_LEN / CHUNK_LEN {
        // Fill a chunk of bytes with random data.
        let simd_chunk: Simd<[u8; CHUNK_LEN]> = rand::random();
        simd_chunk.write_to_slice_unaligned(&mut chunk);
        // Copy the chunk into the payload.
        buf.get_mut().extend_from_slice(&chunk)
    }
    buf
}

fn write(c: &mut Criterion) {
    let mut shell = XilinxU55nXdmaStd::new().expect("cannot construct shell");
    let buf = random_payload();
    let bench_name = format!("write {} bytes", buf.get().len());
    let target_time = Duration::from_secs(12);
    let mut group = c.benchmark_group(&format!(
        "{} with target time {:?}",
        bench_name, target_time
    ));
    group.measurement_time(target_time);
    group.sample_size(50);
    group.bench_function(&bench_name, |b| b.iter(|| write_payload(&mut shell, &buf)));
    group.finish();
}

fn read(c: &mut Criterion) {
    let shell = XilinxU55nXdmaStd::new().expect("cannot construct shell");
    let mut buf = random_payload();
    let bench_name = format!("read {} bytes", buf.get().len());
    let target_time = Duration::from_secs(12);
    let mut group = c.benchmark_group(&format!(
        "{} with target time {:?}",
        bench_name, target_time
    ));
    group.measurement_time(target_time);
    group.sample_size(50);
    group.bench_function(&bench_name, |b| b.iter(|| read_payload(&shell, &mut buf)));
    group.finish();
}

#[inline]
fn write_payload(shell: &XilinxU55nXdmaStd, buf: &DmaBuffer) {
    shell.hbm.based_dma_write(buf, 0).expect("write failed");
}

#[inline]
fn read_payload(shell: &XilinxU55nXdmaStd, buf: &mut DmaBuffer) {
    shell.hbm.based_dma_read(buf, 0).expect("read failed");
}

fn get_fpga_temp_inst(c: &mut Criterion) {
    let shell = XilinxU55nXdmaStd::new().expect("cannot construct shell");
    shell.init().expect("cannot initialise CMS");
    shell
        .cms
        .expect_ready_host_status(1000)
        .expect("CMS is not ready");
    c.bench_function("get instant FPGA temperature", |b| {
        b.iter(|| shell.cms.get_cms_reg(CmsReg::FpgaTempInst))
    });
}

criterion_group!(benches, write, read, get_fpga_temp_inst);
criterion_main!(benches);
