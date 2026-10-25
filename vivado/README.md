# Vivado project notes

The repository contains the RTL and supporting screenshots, but the original `.xpr` project and complete target-device/constraint configuration were not provided as separate source files.

To recreate the project, create a Vivado RTL project, add the files in `../rtl/`, select the intended FPGA part, and add a testbench from `../tb/` for simulation. Use the project report to confirm the original target device and implementation settings before comparing synthesis results.
