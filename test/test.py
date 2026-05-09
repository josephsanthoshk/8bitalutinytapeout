# SPDX-FileCopyrightText: © 2024 Tiny Tapeout
# SPDX-License-Identifier: Apache-2.0

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles


@cocotb.test()
async def test_project(dut):

    dut._log.info("Start")

    # 100 kHz clock
    clock = Clock(dut.clk, 10, unit="us")
    cocotb.start_soon(clock.start())

    # Reset
    dut._log.info("Reset")
    dut.ena.value = 1
    dut.ui_in.value = 0
    dut.uio_in.value = 0
    dut.rst_n.value = 0

    await ClockCycles(dut.clk, 10)

    dut.rst_n.value = 1
    await ClockCycles(dut.clk, 1)

    dut._log.info("Load A")

    # Load A = 20
    dut.ui_in.value = 20
    dut.uio_in.value = 1 << 0   # LOAD_A
    await ClockCycles(dut.clk, 1)
    dut.uio_in.value = 0

    dut._log.info("Load B")

    # Load B = 30
    dut.ui_in.value = 30
    dut.uio_in.value = 1 << 1   # LOAD_B
    await ClockCycles(dut.clk, 1)
    dut.uio_in.value = 0

    dut._log.info("Execute ADD")

    # opcode = 000 (ADD)
    # execute = bit 2
    dut.uio_in.value = (0 << 3) | (1 << 2)

    await ClockCycles(dut.clk, 1)

    dut.uio_in.value = 0

    await ClockCycles(dut.clk, 1)

    dut._log.info(f"ALU result = {int(dut.uo_out.value)}")

    assert int(dut.uo_out.value) == 50

    dut._log.info("PASS: ALU ADD works")
