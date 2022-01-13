# XDMA device library


## Build

- Install Rust

- `cargo build` to just build


## Setup

Currently it is required to change character device permissions from the ones set (incorrectly) by
the XDMA kernel driver. The host-to-card devices should be write-only. The card-to-host devices
should be read-only.

```sh
sudo chmod 220 /dev/xdma0_h2c_0
sudo chmod 440 /dev/xdma0_c2h_0
```

etc.

To run benchmarks without `sudo`, all XDMA character devices should be assigned to a group which
also contains the user who is running the benchmarks.


## Test

- `cargo test` to build and run unit tests


## Benchmark

- `cargo install cargo-criterion` to install the Cargo Criterion subcommand

- `cargo criterion --output-format verbose` to build and run benchmarks


## Examples

- `cargo run --example cms_regs` to read CMS register values
