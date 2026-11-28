# SPDX-FileCopyrightText: © 2024 Tiny Tapeout
# SPDX-License-Identifier: Apache-2.0

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles


async def reset_dut(dut):
    """Helper routine to apply and release reset."""
    dut.ena.value = 1
    dut.ui_in.value = 0
    dut.uio_in.value = 0
    dut.rst_n.value = 0
    await ClockCycles(dut.clk, 5)
    dut.rst_n.value = 1
    await ClockCycles(dut.clk, 2)


@cocotb.test()
async def test_reset_state(dut):
    """Test that the CPU initializes correctly upon reset release."""
    dut._log.info("Running Test: Reset State Verification")

    clock = Clock(dut.clk, 10, unit="us")
    cocotb.start_soon(clock.start())

    ## Apply reset sequence
    await reset_dut(dut)

    ## Verify output is zero after reset
    assert int(dut.uo_out.value) == 0, f"Expected uo_out to be 0 after reset, got {dut.uo_out.value}"
    dut._log.info("Reset state verified successfully.")


@cocotb.test()
async def test_immediate_load_and_add(dut):
    """Test loading an immediate value into a register and performing an addition."""
    dut._log.info("Running Test: LDI and ADD Operation")

    clock = Clock(dut.clk, 10, unit="us")
    cocotb.start_soon(clock.start())

    ## Reset the device under test
    await reset_dut(dut)

    ## Load value of 10 into register 0
    ## LDI R0, 0x0A
    dut.ui_in.value = 0x40
    dut.uio_in.value = 0x0A
    await ClockCycles(dut.clk, 2)

    ## Load value of 5 into register 1
    ## LDI R1, 0x05
    dut.ui_in.value = 0x41      
    dut.uio_in.value = 0x05 
    await ClockCycles(dut.clk, 2)

    ## Add registers 0, 1, and store result in register 2
    ## ADD R2, R0, R1
    dut.ui_in.value = 0x52
    dut.uio_in.value = 0x01
    await ClockCycles(dut.clk, 2)

    ## Insert a NOP to allow register file write to fully latch
    dut.ui_in.value = 0x00
    dut.uio_in.value = 0x00
    await ClockCycles(dut.clk, 2)

    ## Use EXT_GWRITE to send R2 to uo_out (gpio_out)
    ## EXT 4'hF R2, subop GWRITE, port 2
    dut.ui_in.value = 0xF2
    dut.uio_in.value = 0x42
    await ClockCycles(dut.clk, 2)

    ## Hold inputs stable for the final readback evaluation cycle
    dut.ui_in.value = 0x00
    dut.uio_in.value = 0x00
    await ClockCycles(dut.clk, 1)

    dut._log.info(f"Arithmetic Result on uo_out: {int(dut.uo_out.value)}")
    
    ## Expecting 10 + 5 = 15 (0x0F)
    assert int(dut.uo_out.value) == 15, f"Expected 15, got {int(dut.uo_out.value)}"
    dut._log.info("Arithmetic instruction verified successfully.")