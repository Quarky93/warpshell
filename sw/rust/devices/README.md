# XDMA device library


## Build

- Install Rust

- `cargo build` to just build


## Setup

Currently it is required to change character device permissions from the ones set (incorrectly) by
the XDMA kernel driver. The host-to-card devices should be write-only. The card-to-host devices
should be read-only.

To run benchmarks without `sudo`, all XDMA character devices should be assigned to a group which
also contains the user who is running the benchmarks.

There is a handy [script](../..scripts/set-xdma-perms.sh) for that.


## Test

- `cargo test` to build and run unit tests

- `RUST_LOG=debug cargo test -- --nocapture` to show debug logs in all tests


## Benchmark

- `cargo install cargo-criterion` to install the Cargo Criterion subcommand

- `cargo criterion --output-format verbose` to build and run benchmarks


## Examples

- `cargo run --example cms_regs` to read CMS register values
