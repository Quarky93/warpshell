# Warpshell library and CLI

This is a user-space library and CLI for interfacing with Xilinx FPGAs using the [Xilinx XDMA
transport driver](https://github.com/Xilinx/dma_ip_drivers). It is a part of the
[warpshell](https://github.com/quarky93/warpshell) project to improve Vivado flow support on Alveo
U55N (aka Varium C1100 compute accelerator card). Support for other cards from Alveo and Versal
series or third-party cards with compatible chipsets, and support for QDMA transport driver may be
added in the future.

See the [warpshell README](../../README.md) for more information.


## Build

- [Install Rust](https://www.rust-lang.org/learn/get-started)

- `cargo build` to just build


## Setup

At the time of writing, XDMA drivers need this
[patch](https://github.com/Xilinx/dma_ip_drivers/pull/179) to work with Linux kernels 5.16 and
newer. If you are on a Linux distro not supported by Xilinx and the kernel version is >= 5.16,
compile the XDMA kernel driver from the [PR
branch](https://github.com/vkomenda/dma_ip_drivers/tree/dma-compat-fix-linux-5.19).

It is also required to change character device permissions from the ones set (incorrectly) by the
XDMA kernel driver. The host-to-card devices should be write-only. The card-to-host devices should
be read-only. To run benchmarks without `sudo`, all XDMA character devices should be assigned to a
group which also contains the user who runs the benchmarks.

There is a handy [script](../scripts/set-xdma-perms.sh) for that.


## Test

- `cargo test` to build and run unit tests

- `RUST_LOG=debug cargo test -- --nocapture` to show debug logs in all tests


## Benchmarks

- `cargo install cargo-criterion` to install the Cargo Criterion subcommand

- `cargo criterion --output-format verbose --bench u55n` to run the HBM and CMS benchmarks that work
  with a device running Warpshell.

- `cargo criterion --output-format verbose --bench bram` to run the BRAM benchmarks that work
  with a device running Warpshell and the default user image which implements AXI BRAM.


## Examples

- `cargo run --example u55n_regs` to read CMS register values

- `cargo run --example card_info` to read the description from the card


## CLI

The CLI allows to program the user partition bitstream onto the FPGA running Warpshell and to read
CMS register values.

```
$ cargo run -- --help
Interface to Warpshell on an FPGA

Usage: warpshell-cli [OPTIONS] [COMMAND]

Commands:
  program  Program the bitstream onto the FPGA
  get      Read management register values
  help     Print this message or the help of the given subcommand(s)

Options:
  -c, --config <CONFIG>  Config file location
  -h, --help             Print help
  -V, --version          Print version
```
