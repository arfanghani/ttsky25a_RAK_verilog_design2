import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles

@cocotb.test()
async def test_minirisc_repeated(dut):
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
    program = [0x01, 0x02, 0x03, 0x04, 0x00]  # LOAD -> ADD -> SUB -> STORE -> HALT

    # Repeat the program multiple times
    for repeat in range(5):  # repeat 5 times
        dut._log.info(f"Starting program repeat {repeat+1}")
        for cycle, instr in enumerate(program):
            dut.ui_in.value = instr
            await ClockCycles(dut.clk, 1)

            # Safe conversion: replace X/Z with 0
            uo_val   = int(dut.uo_out.value.integer if dut.uo_out.value.is_resolvable else 0)
            uio_val  = int(dut.uio_out.value.integer if dut.uio_out.value.is_resolvable else 0)

            # State encoded in lower 4 bits of uio_out
            state_val = uio_val & 0xF

            dut._log.info(
                f"Cycle {cycle} | Instr=0x{instr:02X} | "
                f"uo_out=0x{uo_val:02X} | "
                f"state={state_val} | uio_out=0x{uio_val:02X}"
            )

        # Wait until FSM returns to IDLE before next program repeat
        while ((int(dut.uio_out.value) & 0xF) != 0):
            await ClockCycles(dut.clk, 1)

        # Insert a few idle cycles to clearly see return to IDLE
        dut.ui_in.value = 0x00
        await ClockCycles(dut.clk, 3)

    dut._log.info("Simulation finished. Repeated FSM sequences completed.")
