`default_nettype none
`timescale 1ns / 1ps

module tb ();

  // Dump signals for GTKWave
  initial begin
    $dumpfile("tb.vcd");
    $dumpvars(0, tb);
    $dumpvars(1, user_project); // dump DUT internals
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

  // Expose internal DUT regs
  wire [7:0] acc_out;
  wire [3:0] state_out;

  // Assign wires
  assign ui_in  = ui_in_reg;
  assign uio_in = uio_in_reg;

  // Initialize DUT outputs to prevent 'x'
  initial begin
    // Default all outputs to 0
    // This resolves the Cocotb issue with X values
    force uo_out    = 8'd0;
    force uio_out   = 8'd0;
    force uio_oe    = 8'd0;
    force acc_out   = 8'd0;
    force state_out = 4'd0;
  end

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
    .uio_oe(uio_oe),
    .acc_out(acc_out),
    .state_out(state_out)
  );

  // Test stimulus
  initial begin
    rst_n = 0;
    ena = 1;
    ui_in_reg = 8'd0;
    uio_in_reg = 8'd0;
    #20;
    rst_n = 1;

    // Program sequence as individual assignments
    ui_in_reg = 8'h01; uio_in_reg = 8'h01; #20;
    ui_in_reg = 8'h02; uio_in_reg = 8'h02; #20;
    ui_in_reg = 8'h03; uio_in_reg = 8'h03; #20;
    ui_in_reg = 8'h04; uio_in_reg = 8'h04; #20;
    ui_in_reg = 8'h05; uio_in_reg = 8'h05; #20;
    ui_in_reg = 8'h06; uio_in_reg = 8'h06; #20;
    ui_in_reg = 8'h07; uio_in_reg = 8'h07; #20;
    ui_in_reg = 8'h08; uio_in_reg = 8'h08; #20;
    ui_in_reg = 8'h09; uio_in_reg = 8'h09; #20;
    ui_in_reg = 8'h00; uio_in_reg = 8'h00; #20;

    #100; // extra cycles
    $display("Simulation finished. Final uo_out=%02x, ACC=%02x, STATE=%d", uo_out, acc_out, state_out);
  end

  // Optional console monitor
  initial begin
    $monitor("Time=%0t | ui_in=%02x | uo_out=%02x | acc_out=%02x | state_out=%0d | uio_out=%02x | uio_oe=%02x",
             $time, ui_in, uo_out, acc_out, state_out, uio_out, uio_oe);
  end

endmodule
