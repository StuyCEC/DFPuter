<!---

This file is used to generate your project datasheet. Please fill in the information below and delete any unused
sections.

You can also include images in this folder and reference them in the markdown. Each image must be less than
512 kb in size, and the name of the image must contain ONLY letters, numbers, underscores, and dashes.

-->

## How it works

DFPuter is an 8-bit CPU coupled with a 256x8 GF180MCU SRAM macro (`gf180mcu_ocd_ip_sram__sram256x8m8wm1`). The control unit (`dfcu`) decodes instructions fetched from SRAM and executes arithmetic, logic, and memory operations on the 8-bit datapath.

## How to test

1. Set `ena = 1` and hold `rst_n = 0` for several clock cycles on `clk` to reset the CPU registers and program counter.
2. Release reset (`rst_n = 1`) and drive `ui_in` with the desired input data while pulsing `clk`.
3. Observe the CPU state and output data on `uo_out`.

## External hardware

None required.