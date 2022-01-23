# Warpshell
*WARNING*... This project is currently incompatible with the official XRT drivers.
You must unload the XRT drivers before programming the device, otherwise, your system
may hang.
```sh
# blacklist kernel modules
sudo sh -c "echo 'blacklist xclmgmt\nblacklist xocl' > /etc/modprobe.d/blacklist-xrt.conf"
# remove currently loaded modules
sudo modprobe -r xclmgmt xocl
```

To revert to XRT, remove the blacklist:
```sh
sudo rm /etc/modprobe.d/blacklist-xrt.conf
```
Then power cycle the computer. (power off, wait 5 seconds, power on)

## Board Support
| board        | blinky | xdma_gen4_x1_minimal | xdma_gen4_x4_minimal |
|--------------|--------|----------------------|----------------------|
| Varium C1100 | &#9989;| &#9989;              |                      |

## Blinky Build Instructions (Linux)

We must first set up the environment.
```sh
source /tools/Xilinx/Vivado/2021.2/settings64.sh
```

Set up the repository.
```sh
git clone https://github.com/Quarky93/warpshell.git
cd warpshell
mkdir build
cd build
```

Build blinky.
```sh
vivado -mode batch -source ../hw/scripts/varium_c1100_blinky.tcl
```

A bitstream file is generated:
```
blinky.bit
```
Program the device using Vivado hardware manager.

## Shell Build Instructions
Same as blinky, find the relevant script in:
```sh
warpshell/hw/scripts
```

We must also build and install the [XDMA drivers](https://github.com/Xilinx/dma_ip_drivers):
Follow the instructions [here](https://github.com/Xilinx/dma_ip_drivers/tree/master/XDMA/linux-kernel).

*Currently all shell versions are in active development and is not generally usable.*

## Customize the Shell
Generate a Vivado project:
```sh
cd build
vivado -mode batch -source ../hw/scripts/varium_c1100_xdma_gen4_x1_custom.tcl
```
A project will be generated in the build directory, open this with Vivado.


## Documentation

There is an online [book](https://quarky93.github.io/warpshell) with the sources in
[book/](./book/). To compile the book from source, install `mdbook` (having installed
[Rust](https://www.rust-lang.org/tools/install))

- `cargo install mdbook`

and run `mdbook serve` in [book/](./book/). Then go to `http://[::1]:3000` in the browser.
