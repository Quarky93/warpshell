# Warpshell

Warpshell is an open source project designed to simplify PCIe-based FPGA accelerator development. It provides a powerful "Shell" that includes a wide range of common features, such as the PCIe subsystem (DMA), AXI Firewalls, and infrastructure to reconfigure the user-partition at runtime.

One of the unique features of Warpshell is the decoupling of the Shell and the user-partition. The Shell is compiled separately (ahead of time) from the user logic and is linked at the implementation stage. This approach allows for easy swapping of different accelerators without requiring a system reboot. Additionally, the Warpshell project provides default shells for each FPGA platform/board. Any user applications that are compiled with these default shells will be compatible with each other, making community sharing of binaries easy.

Warpshell provides a customizable Rust driver that enables easy interaction with the Shell and offers a stub for the user to develop custom driver logic to interact with the user-logic.

Warpshell's aim is to simplify and speed up the development of FPGA-based accelerators. By providing a robust and flexible infrastructure that abstracts away the low-level details of PCIe communication, AXI interfaces, and other common tasks, developers can focus on designing and implementing their own custom logic with ease.

## Instructions
*UNDER CONSTRUCTION*
