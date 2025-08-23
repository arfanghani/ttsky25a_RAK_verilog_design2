import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, ClockCycles

@cocotb.test()
async def test_minirisc_repeated(dut):
    """FSM CPU repeated test"""
    dut._log.info("Starting FSM repeated test")

    clock = Clock(dut.clk, 20, units="ns")
    cocotb.start_soon(clock.start())

    # Reset
    dut.rst_n.value = 0
    dut.ena.value = 1
    dut.ui_in.value = 0
    dut.uio_in.value = 0
    await ClockCycles(dut.clk, 2)
    dut.rst_n.value = 1
    await ClockCycles(dut.clk, 1)

    program = [0x01, 0x02, 0x03, 0x04, 0x00]

    for repeat in range(3):
        dut._log.info(f"Program repeat {repeat+1}")
        for cycle, instr in enumerate(program):
            dut.ui_in.value = instr
            await RisingEdge(dut.clk)
            await RisingEdge(dut.clk)  # give FSM 2 cycles to update

            acc_val = int(dut.uo_out.value)
            state_val = int(dut.uio_out.value) & 0xF
            dut._log.info(f"Cycle {cycle} | Instr={instr:02X} | uo_out={acc_val:02X} | state={state_val:01X}")
