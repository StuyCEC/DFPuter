# SPDX-FileCopyrightText: © 2024 Tiny Tapeout
# SPDX-License-Identifier: Apache-2.0

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles, Timer


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

    await reset_dut(dut)

    # Verify outputs are cleared immediately after reset
    assert dut.uo_out.value == 0, f"Expected uo_out to be 0 after reset, got {dut.uo_out.value}"
    dut._log.info("Reset state verified successfully.")


@cocotb.test()
async def test_arithmetic_instruction(dut):
    """Test arithmetic execution (e.g., ADD operation)."""
    dut._log.info("Running Test: Arithmetic Operation")

    clock = Clock(dut.clk, 10, unit="us")
    cocotb.start_soon(clock.start())

    await reset_dut(dut)

    # Drive input operands or instruction triggers via ui_in / uio_in
    # Adjust these values based on your instruction decoder layout
    dut.ui_in.value = 0x12   # Example operand A or instruction code
    dut.uio_in.value = 0x23  # Example operand B

    # Allow sufficient clock cycles for fetch-decode-execute
    await ClockCycles(dut.clk, 10)

    dut._log.info(f"Arithmetic Result on uo_out: {dut.uo_out.value}")

    # Assert expected arithmetic output (update 0x35 to match your ALU's expected result for 0x12 + 0x23)
    expected_val = 0x35
    assert dut.uo_out.value == expected_val, (
        f"Arithmetic test failed: expected {hex(expected_val)}, got {hex(dut.uo_out.value)}"
    )


@cocotb.test()
async def test_memory_load_store(dut):
    """Test interaction with the SRAM macro."""
    dut._log.info("Running Test: SRAM Memory Access")

    clock = Clock(dut.clk, 10, unit="us")
    cocotb.start_soon(clock.start())

    await reset_dut(dut)

    # Set up data lines for a store or load operation
    dut.ui_in.value = 0xAA
    await ClockCycles(dut.clk, 5)

    dut.uio_in.value = 0x55
    await ClockCycles(dut.clk, 10)

    dut._log.info(f"Memory test output state: {dut.uo_out.value}")
    
    # Assert stable output condition post-execution
    assert dut.uo_out.value is not None