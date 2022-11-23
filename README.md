# Warpshell
## Flash using xbflash2 utility

First find the card BDF (Bus:Device.Function).
With the card plugged in, run:

```shell
sudo lspci -d 10ee:
```

If the card has a XRT compatible image loaded then you will see something like this:

```shell
01:00.0 Processing accelerators: Xilinx Corporation Device 5058
01:00.1 Processing accelerators: Xilinx Corporation Device 5059
```

Note the first function of each device in `Bus:Device.Function` (in this case `01:00.0`) notation.
There should be two functions for each device while using the Xilinx default image.

Flash the U55C/U55N device to a warpshell image:

```shell
sudo ./xbflash2 program --spi --image ./<warpshell_image>.mcs --bar-offset 0x1F06000 -d 01:00.0
```

You should see something like this:

```shell
Preparing to program flash on device: 01:00.0
Are you sure you wish to proceed? [Y/n]: y
Successfully opened /dev/xfpga/flash.m256.0
flashing via QSPI driver
Bitstream guard installed on flash @0x1002000
Extracting bitstream from MCS data:
..................
Extracted 18464340 bytes from bitstream @0x1002000
Writing bitstream to flash 0:
..................
Bitstream guard removed from flash
****************************************************
Cold reboot machine to load the new image on device.
****************************************************
```

Now power cycle the system and you're in the warpshell ecosystem!

After the reboot, check `lspci -d 10ee:` again and you should see:

```shell
01:00.0 Processing accelerators: Xilinx Corporation Device 9038
```

Success!
