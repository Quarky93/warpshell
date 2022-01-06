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
| board        | blinky | xdma_gen3_x1_minimal | xdma_gen3_x4_minimal |
|--------------|--------|----------------------|----------------------|
| Varium C1100 | &#9989;|                      |                      |

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
