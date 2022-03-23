use criterion::{criterion_group, criterion_main, Criterion};
use packed_simd_2::Simd;
use std::time::Duration;
use warp_devices::cms::{CardMgmtOps, CardMgmtSys, CmsReg};
use warp_devices::varium_c1100::{VariumC1100, HBM_BASE_ADDR};
use warp_devices::xdma::{DmaBuffer, XdmaOps};

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
        buf.extend_from_slice(&chunk)
    }
    buf
}

fn write(c: &mut Criterion) {
    let mut varium = VariumC1100::new().expect("cannot construct device");
    let buf = random_payload();
    let bench_name = format!("write {} bytes", buf.0.len());
    let target_time = Duration::from_secs(12);
    let mut group = c.benchmark_group(&format!(
        "{} with target time {:?}",
        bench_name, target_time
    ));
    group.measurement_time(target_time);
    group.sample_size(50);
    group.bench_function(&bench_name, |b| b.iter(|| write_payload(&mut varium, &buf)));
    group.finish();
}

fn read(c: &mut Criterion) {
    let varium = VariumC1100::new().expect("cannot construct device");
    let mut buf = random_payload();
    let bench_name = format!("read {} bytes", buf.0.len());
    let target_time = Duration::from_secs(12);
    let mut group = c.benchmark_group(&format!(
        "{} with target time {:?}",
        bench_name, target_time
    ));
    group.measurement_time(target_time);
    group.sample_size(50);
    group.bench_function(&bench_name, |b| b.iter(|| read_payload(&varium, &mut buf)));
    group.finish();
}

#[inline]
fn write_payload(varium: &mut VariumC1100, buf: &DmaBuffer) {
    varium.dma_write(buf, HBM_BASE_ADDR).expect("write failed");
}

#[inline]
fn read_payload(varium: &VariumC1100, buf: &mut DmaBuffer) {
    varium.dma_read(buf, HBM_BASE_ADDR).expect("read failed");
}

fn get_fpga_temp_inst(c: &mut Criterion) {
    let mut varium = VariumC1100::new().expect("cannot construct device");
    varium.init_cms().expect("cannot initialise CMS");
    varium
        .expect_ready_host_status(1000)
        .expect("CMS is not ready");
    c.bench_function("get instant FPGA temperature", |b| {
        b.iter(|| varium.get_cms_reg(CmsReg::FpgaTempInst))
    });
}

criterion_group!(benches, write, read, get_fpga_temp_inst);
criterion_main!(benches);
