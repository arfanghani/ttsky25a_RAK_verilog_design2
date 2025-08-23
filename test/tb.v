`default_nettype none
`timescale 1ns / 1ps

module tb ();

    // Dump signals for GTKWave
    initial begin
        $dumpfile("tb.vcd");
        $dumpvars(0, tb);
        $dumpvars(1, user_project);
    end

    // Signals
    reg clk;
    reg rst_n;
    reg ena;
    reg [7:0] ui_in_reg;
    reg [7:0] uio_in_reg;

    wire [7:0] ui_in;
    wire [7:0] uio_in;
    wire [7:0] uo_out;
    wire [7:0] uio_out;
    wire [7:0] uio_oe;

    assign ui_in  = ui_in_reg;
    assign uio_in = uio_in_reg;

    // Clock 50 MHz
    initial begin
        clk = 0;
        forever #10 clk = ~clk;
    end

    // DUT instantiation
    tt_um_minirisc user_project (
        .clk(clk),
        .rst_n(rst_n),
        .ena(ena),
        .ui_in(ui_in),
        .uio_in(uio_in),
        .uo_out(uo_out),
        .uio_out(uio_out),
        .uio_oe(uio_oe)
    );

    // Test stimulus
    initial begin
        rst_n = 0;
        ena = 1;
        ui_in_reg = 8'd0;
        uio_in_reg = 8'd0;
        #20;
        rst_n = 1;

        // Instruction sequence
        ui_in_reg = 8'h01; uio_in_reg = 8'h01; #20;
        ui_in_reg = 8'h02; uio_in_reg = 8'h02; #20;
        ui_in_reg = 8'h03; uio_in_reg = 8'h03; #20;
        ui_in_reg = 8'h04; uio_in_reg = 8'h04; #20;

        #100; // extra cycles
        $display("Simulation finished. Final uo_out=%02x", uo_out);
    end

    // Optional console monitor
    initial begin
        $monitor("Time=%0t | ui_in=%02x | uo_out=%02x | uio_out=%02x | uio_oe=%02x",
                 $time, ui_in, uo_out, uio_out, uio_oe);
    end

endmodule
