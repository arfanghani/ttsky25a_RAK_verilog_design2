import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles

@cocotb.test()
async def test_minirisc_repeated(dut):
    """Test repeated execution of the FSM CPU."""

    dut._log.info("Starting repeated FSM CPU test")

    # Start 50 MHz clock (20 ns period)
    clock = Clock(dut.clk, 20, units="ns")
    cocotb.start_soon(clock.start())

    # Reset DUT
    dut.rst_n.value = 0
    dut.ena.value = 1
    dut.ui_in.value = 0
    dut.uio_in.value = 0
    await ClockCycles(dut.clk, 5)
    dut.rst_n.value = 1
    await ClockCycles(dut.clk, 1)

    # Instruction program for FSM
    program = [0x01, 0x02, 0x03, 0x04, 0x00]  # example program sequence

    # Repeat the program multiple times
    for repeat in range(5):
        dut._log.info(f"Starting program repeat {repeat+1}")
        for cycle, instr in enumerate(program):
            dut.ui_in.value = instr
            await ClockCycles(dut.clk, 1)

            uo_val  = int(dut.uo_out.value)
            uio_val = int(dut.uio_out.value)

            dut._log.info(
                f"Cycle {cycle} | Instr=0x{instr:02X} | "
                f"uo_out=0x{uo_val:02X} | uio_out=0x{uio_val:02X}"
            )

        # Wait until FSM returns to idle (uo_out == 0) before next program repeat
        while int(dut.uo_out.value) != 0:
            await ClockCycles(dut.clk, 1)

        # Insert a few idle cycles to clearly see return to idle
        dut.ui_in.value = 0x00
        await ClockCycles(dut.clk, 3)

    dut._log.info("Simulation finished. Repeated FSM sequences completed.")
