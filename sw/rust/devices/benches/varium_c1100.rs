use criterion::{criterion_group, criterion_main, Criterion};
use packed_simd_2::Simd;
use std::time::Duration;
use warp_devices::varium_c1100::*;
use warp_devices::xdma::XdmaOps;

const PAYLOAD_LEN: usize = 1 * 1024 * 1024 * 1024;
const CHUNK_LEN: usize = 64;
const HBM_BASE_ADDR: u64 = 0;

fn fill_random(buf: &mut AlignedBytes) {
    let mut chunk: [u8; CHUNK_LEN] = [0; CHUNK_LEN];
    for _ in 0..PAYLOAD_LEN / CHUNK_LEN {
        // Fill a chunk of bytes with random data.
        let simd_chunk: Simd<[u8; CHUNK_LEN]> = rand::random();
        simd_chunk.write_to_slice_unaligned(&mut chunk);
        // Append the chunk to the payload.
        buf.0.extend_from_slice(&chunk)
    }
}

#[repr(align(4096))]
struct AlignedBytes(pub Vec<u8>);

fn write(c: &mut Criterion) {
    let mut varium = VariumC1100::new().expect("cannot construct device");
    let mut buf: AlignedBytes = AlignedBytes(Vec::with_capacity(PAYLOAD_LEN));
    fill_random(&mut buf);

    c.bench_function(&format!("write {} bytes", buf.0.len()), |b| {
        b.iter(|| {
            varium
                .device
                .dma_write(buf.0.as_slice(), HBM_BASE_ADDR)
                .expect("write failed")
        })
    });
}

fn read(c: &mut Criterion) {
    let varium = VariumC1100::new().expect("cannot construct device");
    let mut buf: AlignedBytes = AlignedBytes(Vec::with_capacity(PAYLOAD_LEN));
    fill_random(&mut buf);

    c.bench_function(&format!("read {} bytes", buf.0.len()), |b| {
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
