import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles, RisingEdge

@cocotb.test()
async def test_minirisc_repeated(dut):
    """Repeated FSM CPU test — HALT removed."""
    dut._log.info("Starting repeated FSM CPU test")

    # Start 50 MHz clock
    cocotb.start_soon(Clock(dut.clk, 20, units="ns").start())

    # Reset DUT
    dut.rst_n.value = 0
    dut.ena.value = 1
    dut.ui_in.value = 0
    dut.uio_in.value = 0
    await ClockCycles(dut.clk, 5)
    dut.rst_n.value = 1
    await ClockCycles(dut.clk, 1)

    # Instruction program (LOAD -> ADD -> SUB -> STORE)
    program = [0x01, 0x02, 0x03, 0x04]

    for repeat in range(5):
        dut._log.info(f"Starting program repeat {repeat+1}")

        for cycle, instr in enumerate(program):
            dut.ui_in.value = instr

            # Wait 2 clock cycles for FSM to update
            await RisingEdge(dut.clk)
            await RisingEdge(dut.clk)

            acc_val   = int(dut.uo_out.value)
            state_val = int(dut.uio_out.value) & 0xF
            uio_val   = int(dut.uio_out.value)

            dut._log.info(
                f"Cycle {cycle} | Instr=0x{instr:02X} | "
                f"uo_out=0x{acc_val:02X} | "
                f"state={state_val} | uio_out=0x{uio_val:02X}"
            )

        # Wait until FSM returns to IDLE
        while (int(dut.uio_out.value) & 0xF) != 0:
            await ClockCycles(dut.clk, 1)

        dut.ui_in.value = 0x00
        await ClockCycles(dut.clk, 3)

    dut._log.info("Simulation finished. Repeated FSM sequences completed.")

