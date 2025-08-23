module tt_um_minirisc (
  input  wire        clk,
  input  wire        rst_n,
  input  wire        ena,
  input  wire [7:0]  ui_in,
  input  wire [7:0]  uio_in,
  output reg  [7:0]  uo_out,
  output wire [7:0]  uio_out,
  output wire [7:0]  uio_oe,
  
  // New ports for internal monitoring
  output wire [7:0]  acc_out,
  output wire [3:0]  state_out
);

  // Internal registers
  reg [7:0] acc;
  reg [3:0] state;

  // Dummy wire to mark uio_in as used
  wire [7:0] unused_uio_in = uio_in;

  // Simple example FSM states
  localparam IDLE  = 4'd0;
  localparam LOAD  = 4'd1;
  localparam ADD   = 4'd2;
  localparam STORE = 4'd3;
  localparam DONE  = 4'd4;

  // For this example, uio_out and uio_oe are driven to 0
  assign uio_out = 8'd0;
  assign uio_oe  = 8'd0;

  // Expose internal signals
  assign acc_out   = acc;
  assign state_out = state;

  // Simple FSM example logic
  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      acc <= 8'd0;
      state <= IDLE;
      uo_out <= 8'd0;
    end else if (ena) begin
      case(state)
        IDLE: begin
          acc <= 8'd0;
          uo_out <= 8'd0;
          if (ui_in != 8'd0)
            state <= LOAD;
        end

        LOAD: begin
          acc <= ui_in;
          uo_out <= acc;
          state <= ADD;
        end

        ADD: begin
          acc <= acc + 8'h08; // example addition
          uo_out <= acc;
          state <= STORE;
        end

        STORE: begin
          uo_out <= acc;
          state <= DONE;
        end

        DONE: begin
          uo_out <= acc;
          state <= IDLE; // auto-reset for next cycle
        end

        default: state <= IDLE;
      endcase
    end
  end

endmodule
