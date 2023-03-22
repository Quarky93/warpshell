use criterion::{criterion_group, criterion_main, Criterion};
use packed_simd::Simd;
use std::time::Duration;
use warpshell::{
    xdma::{CtrlChannel, GetCtrlChannel, CTRL_CHANNEL},
    BaseParam, BasedCtrlOps,
};
use warpshell_derive::GetCtrlChannel;

const PAYLOAD_LEN: usize = 8 * 1024;
const CHUNK_LEN: usize = 64;

#[derive(GetCtrlChannel)]
struct Bram<'a> {
    ctrl_channel: &'a CtrlChannel,
}

impl<'a> BaseParam for Bram<'a> {
    const BASE_ADDR: u64 = 0x0080_0000;
}

fn random_payload() -> Vec<u8> {
    let mut buf: Vec<u8> = Vec::with_capacity(PAYLOAD_LEN);
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

fn setup<'a>() -> (Bram<'a>, Vec<u8>) {
    let ctrl_channel = CTRL_CHANNEL
        .get_or_init()
        .expect("cannot get control channel");
    let bram = Bram { ctrl_channel };
    let buf = random_payload();
    (bram, buf)
}

fn write(c: &mut Criterion) {
    let (bram, buf) = setup();
    let bench_name = format!("write {} bytes", buf.len());
    let target_time = Duration::from_secs(4);
    let mut group = c.benchmark_group(&format!("{bench_name} with target time {target_time:?}",));
    group.measurement_time(target_time);
    group.sample_size(50);
    group.bench_function(&bench_name, |b| b.iter(|| write_payload(&bram, &buf)));
    group.finish();
}

fn read(c: &mut Criterion) {
    let (bram, mut buf) = setup();
    let bench_name = format!("read {} bytes", buf.len());
    let target_time = Duration::from_secs(4);
    let mut group = c.benchmark_group(&format!("{bench_name} with target time {target_time:?}",));
    group.measurement_time(target_time);
    group.sample_size(50);
    group.bench_function(&bench_name, |b| b.iter(|| read_payload(&bram, &mut buf)));
    group.finish();
}

#[inline]
fn write_payload(bram: &Bram, buf: &[u8]) {
    bram.based_ctrl_write(buf, 0).expect("write failed");
}

#[inline]
fn read_payload(bram: &Bram, buf: &mut [u8]) {
    bram.based_ctrl_read(buf, 0).expect("read failed");
}

criterion_group!(benches, write, read);
criterion_main!(benches);
