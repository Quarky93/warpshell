#![feature(portable_simd)]
use core::simd::Simd;
use criterion::{criterion_group, criterion_main, Criterion};
use std::time::Duration;
use warpshell::{
    cores::cms::{CmsOps, CmsReg},
    shells::{Shell, XilinxU55nXdmaStd},
    BasedDmaOps, DmaBuffer,
};

const PAYLOAD_LEN: usize = 1024 * 1024 * 1024;
const CHUNK_LEN: usize = 64;

fn random_payload() -> DmaBuffer {
    let mut buf: DmaBuffer = DmaBuffer::new(PAYLOAD_LEN);
    let mut chunk: [u8; CHUNK_LEN] = [0; CHUNK_LEN];
    for _ in 0..PAYLOAD_LEN / CHUNK_LEN {
        // Fill a chunk of bytes with random data.
        let simd_chunk: Simd<u8, CHUNK_LEN> = rand::random();
        simd_chunk.copy_to_slice(&mut chunk);
        // Copy the chunk into the payload.
        buf.get_mut().extend_from_slice(&chunk)
    }
    buf
}

fn write(c: &mut Criterion) {
    let shell = XilinxU55nXdmaStd::new().expect("cannot construct shell");
    let buf = random_payload();
    let bench_name = format!("write {} bytes", buf.get().len());
    let target_time = Duration::from_secs(12);
    let mut group = c.benchmark_group(&format!("{bench_name} with target time {target_time:?}",));
    group.measurement_time(target_time);
    group.sample_size(50);
    group.bench_function(&bench_name, |b| b.iter(|| write_payload(&shell, &buf)));
    group.finish();
}

fn read(c: &mut Criterion) {
    let shell = XilinxU55nXdmaStd::new().expect("cannot construct shell");
    let mut buf = random_payload();
    let bench_name = format!("read {} bytes", buf.get().len());
    let target_time = Duration::from_secs(12);
    let mut group = c.benchmark_group(&format!("{bench_name} with target time {target_time:?}",));
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
    shell.init().expect("cannot initialise shell");
    c.bench_function("get instant FPGA temperature", |b| {
        b.iter(|| shell.cms.get_cms_reg(CmsReg::FpgaTempInst))
    });
}

criterion_group!(benches, write, read, get_fpga_temp_inst);
criterion_main!(benches);
