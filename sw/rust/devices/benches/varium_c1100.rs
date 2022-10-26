use criterion::{criterion_group, criterion_main, Criterion};
use packed_simd::Simd;
use std::sync::{Arc, Mutex};
use std::thread;
use std::time::Duration;
use warp_devices::cms::{CardMgmtOps, CardMgmtSys, CmsReg};
use warp_devices::varium_c1100::{VariumC1100, HBM_BASE_ADDR};
use warp_devices::xdma::{DmaBuffer, XdmaOps};

const MEGA: usize = 1024 * 1024;
const PAYLOAD_LEN: usize = 1 * 1024 * MEGA;
const HBM_BANK_SIZE: usize = 256 * MEGA;
const HBM_BANK_COUNT: usize = 32;
const CHUNK_LEN: usize = 64;

// const NUM_POH_CORES: usize = 4;
// const VARIUM_URAM_HASHES_BASE: u64 = 0x2_0000_0000;
// const VARIUM_URAM_MAX_HASHES_PER_CORE: usize = 32_768;
// const VARIUM_URAM_PAYLOAD_LEN: usize = VARIUM_URAM_MAX_HASHES_PER_CORE * 32;

fn random_payload(len: usize) -> DmaBuffer {
    let mut buf: DmaBuffer = DmaBuffer::new(len);
    let mut chunk: [u8; CHUNK_LEN] = [0; CHUNK_LEN];
    for _ in 0..len / CHUNK_LEN {
        // Fill a chunk of bytes with random data.
        let simd_chunk: Simd<[u8; CHUNK_LEN]> = rand::random();
        simd_chunk.write_to_slice_unaligned(&mut chunk);
        // Copy the chunk into the payload.
        buf.get_mut().extend_from_slice(&chunk)
    }
    buf
}

fn write_hbm(c: &mut Criterion) {
    let mut varium = VariumC1100::new().expect("cannot construct device");
    let buf = random_payload(PAYLOAD_LEN);
    let bench_name = format!("write HBM {} Mbytes in one thread", PAYLOAD_LEN / MEGA);
    let target_time = Duration::from_secs(12);
    let mut group = c.benchmark_group(&format!(
        "{} with target time {:?}",
        bench_name, target_time
    ));
    group.measurement_time(target_time);
    group.sample_size(50);
    group.bench_function(&bench_name, |b| {
        b.iter(|| write_hbm_payload(&mut varium, &buf))
    });
    group.finish();
}

fn read_hbm(c: &mut Criterion) {
    let varium = VariumC1100::new().expect("cannot construct device");
    let mut buf = random_payload(PAYLOAD_LEN);
    let bench_name = format!("read HBM {} Mbytes in one thread", PAYLOAD_LEN / MEGA);
    let target_time = Duration::from_secs(12);
    let mut group = c.benchmark_group(&format!(
        "{} with target time {:?}",
        bench_name, target_time
    ));
    group.measurement_time(target_time);
    group.sample_size(50);
    group.bench_function(&bench_name, |b| {
        b.iter(|| read_hbm_payload(&varium, &mut buf))
    });
    group.finish();
}

fn write_hbm_banks(c: &mut Criterion) {
    let varium = VariumC1100::new().expect("cannot construct device");
    let bufs: Vec<_> = (0..HBM_BANK_COUNT)
        .map(|_| random_payload(HBM_BANK_SIZE))
        .collect();
    let bench_name = format!("write HBM banks each {} Mbytes", HBM_BANK_SIZE / MEGA);
    let target_time = Duration::from_secs(60);
    let mut group = c.benchmark_group(&format!(
        "{} with target time {:?}",
        bench_name, target_time
    ));
    let varium = Arc::new(Mutex::new(varium));
    let bufs: Vec<_> = bufs
        .into_iter()
        .map(|buf| Arc::new(Mutex::new(buf)))
        .collect();
    group.measurement_time(target_time);
    group.sample_size(40);
    group.bench_function(&bench_name, |b| {
        b.iter(|| {
            let handlers_iter = (0..HBM_BANK_COUNT).map(|i| {
                let varium = varium.clone();
                let buf = bufs[i].clone();
                // let bufs = bufs.clone();
                thread::Builder::new()
                    .name(format!("HBM bank {} write", i))
                    .spawn(move || {
                        varium
                            .lock()
                            .unwrap()
                            .dma_write(
                                &buf.lock().unwrap(),
                                HBM_BASE_ADDR + (HBM_BANK_SIZE * i) as u64,
                            )
                            .expect("write failed")
                    })
                    .unwrap()
            });
            // Wait until all threads terminate.
            handlers_iter.for_each(|handle| {
                handle.join().unwrap();
            });
        })
    });
    group.finish();
}

fn read_hbm_banks(c: &mut Criterion) {
    let varium = VariumC1100::new().expect("cannot construct device");
    let bufs: Vec<_> = (0..HBM_BANK_COUNT)
        .map(|_| random_payload(HBM_BANK_SIZE))
        .collect();
    let bench_name = format!("read HBM banks each {} Mbytes", HBM_BANK_SIZE / MEGA);
    let target_time = Duration::from_secs(60);
    let mut group = c.benchmark_group(&format!(
        "{} with target time {:?}",
        bench_name, target_time
    ));
    let varium = Arc::new(Mutex::new(varium));
    let bufs: Vec<_> = bufs
        .into_iter()
        .map(|buf| Arc::new(Mutex::new(buf)))
        .collect();
    group.measurement_time(target_time);
    group.sample_size(40);
    group.bench_function(&bench_name, |b| {
        b.iter(|| {
            let handlers_iter = (0..HBM_BANK_COUNT).map(|i| {
                let varium = varium.clone();
                let buf = bufs[i].clone();
                // let bufs = bufs.clone();
                thread::Builder::new()
                    .name(format!("HBM bank {} read", i))
                    .spawn(move || {
                        varium
                            .lock()
                            .unwrap()
                            .dma_read(
                                &mut buf.lock().unwrap(),
                                HBM_BASE_ADDR + (HBM_BANK_SIZE * i) as u64,
                            )
                            .expect("write failed")
                    })
                    .unwrap()
            });
            // Wait until all threads terminate.
            handlers_iter.for_each(|handle| {
                handle.join().unwrap();
            });
        })
    });
    group.finish();
}

// fn write_uram(c: &mut Criterion) {
//     let mut varium = VariumC1100::new().expect("cannot construct device");
//     let buf = random_payload(VARIUM_URAM_PAYLOAD_LEN);
//     let bench_name = format!("write URAM {} bytes", buf.get().len());
//     let target_time = Duration::from_secs(7);
//     let mut group = c.benchmark_group(&format!(
//         "{} with target time {:?}",
//         bench_name, target_time
//     ));
//     group.measurement_time(target_time);
//     group.sample_size(50);
//     group.bench_function(&bench_name, |b| {
//         b.iter(|| write_uram_payload(&mut varium, &buf))
//     });
//     group.finish();
// }

// fn read_uram(c: &mut Criterion) {
//     let varium = VariumC1100::new().expect("cannot construct device");
//     let mut buf = random_payload(VARIUM_URAM_PAYLOAD_LEN);
//     let bench_name = format!("read URAM {} bytes", buf.get().len());
//     let target_time = Duration::from_secs(7);
//     let mut group = c.benchmark_group(&format!(
//         "{} with target time {:?}",
//         bench_name, target_time
//     ));
//     group.measurement_time(target_time);
//     group.sample_size(50);
//     group.bench_function(&bench_name, |b| {
//         b.iter(|| read_uram_payload(&varium, &mut buf))
//     });
//     group.finish();
// }

#[inline]
fn write_hbm_payload(varium: &VariumC1100, buf: &DmaBuffer) {
    varium.dma_write(buf, HBM_BASE_ADDR).expect("write failed");
}

#[inline]
fn read_hbm_payload(varium: &VariumC1100, buf: &mut DmaBuffer) {
    varium.dma_read(buf, HBM_BASE_ADDR).expect("read failed");
}

// #[inline]
// fn write_uram_payload(varium: &VariumC1100, buf: &DmaBuffer) {
//     varium
//         .dma_write(buf, VARIUM_URAM_HASHES_BASE)
//         .expect("write failed");
// }

// #[inline]
// fn read_uram_payload(varium: &VariumC1100, buf: &mut DmaBuffer) {
//     varium
//         .dma_read(buf, VARIUM_URAM_HASHES_BASE)
//         .expect("read failed");
// }

fn get_fpga_temp_inst(c: &mut Criterion) {
    let varium = VariumC1100::new().expect("cannot construct device");
    varium.init_cms().expect("cannot initialise CMS");
    varium
        .expect_ready_host_status(1000)
        .expect("CMS is not ready");
    c.bench_function("get instant FPGA temperature", |b| {
        b.iter(|| varium.get_cms_reg(CmsReg::FpgaTempInst))
    });
}

criterion_group!(
    benches,
    // write_uram,
    // read_uram,
    write_hbm_banks,
    read_hbm_banks,
    write_hbm,
    read_hbm,
    get_fpga_temp_inst
);
criterion_main!(benches);
