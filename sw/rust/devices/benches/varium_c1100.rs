use criterion::{criterion_group, criterion_main, Criterion};
use rand::Rng;
use warp_devices::varium_c1100::*;
use warp_devices::xdma::XdmaOps;

const BENCH_PAYLOAD_LEN: usize = 1; // * 1024 * 1024 * 1024;
const HBM_BASE_ADDR: u64 = 0;

#[repr(align(4096))]
struct AlignedBytes(pub Vec<u8>);

fn write(c: &mut Criterion) {
    let mut varium = VariumC1100::new();
    let mut buf: AlignedBytes = AlignedBytes(Vec::with_capacity(BENCH_PAYLOAD_LEN));

    for _ in 0..BENCH_PAYLOAD_LEN {
        buf.0.push(rand::random())
    }

    println!("buf len {}", buf.0.as_slice().len());

    c.bench_function("write", |b| {
        b.iter(|| {
            varium
                .device
                .dma_write(buf.0.as_slice(), HBM_BASE_ADDR)
                .expect("write failed")
        })
    });
}

fn read(c: &mut Criterion) {
    let mut varium = VariumC1100::new();
    let mut buf: AlignedBytes = AlignedBytes(Vec::with_capacity(BENCH_PAYLOAD_LEN));

    c.bench_function("read", |b| {
        b.iter(|| {
            varium
                .device
                .dma_read(buf.0.as_mut_slice(), HBM_BASE_ADDR)
                .expect("read failed")
        })
    });
}

criterion_group!(benches, write, read);
criterion_main!(benches);
