# XDMA device library

This is a user-space library for interfacing with Xilinx FPGAs using the Xilinx XDMA driver. The
library is a part of the [warpshell](https://github.com/quarky93/warpshell) project to improve Vivado
flow support on the Varium C1100 compute accelerator card. Support for other cards from the Alveo
and Versal series may be added in the future.

See the [warpshell README](../../README.md) for more information.


## Build

- Install Rust

- `cargo build` to just build


## Setup

Currently it is required to change character device permissions from the ones set (incorrectly) by
the XDMA kernel driver. The host-to-card devices should be write-only. The card-to-host devices
should be read-only.

To run benchmarks without `sudo`, all XDMA character devices should be assigned to a group which
also contains the user who is running the benchmarks.

There is a handy [script](../../scripts/set-xdma-perms.sh) for that.


## Test

- `cargo test` to build and run unit tests

- `RUST_LOG=debug cargo test -- --nocapture` to show debug logs in all tests


## Benchmark

- `cargo install cargo-criterion` to install the Cargo Criterion subcommand

- `cargo criterion --output-format verbose` to build and run benchmarks


## Examples

- `cargo run --example cms_regs` to read CMS register values
