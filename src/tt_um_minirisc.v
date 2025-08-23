`default_nettype none
`timescale 1ns / 1ps

module tt_um_minirisc (
    input  wire [7:0] ui_in,    
    output wire [7:0] uo_out,  
    input  wire [7:0] uio_in,  
    output wire [7:0] uio_out, 
    output wire [7:0] uio_oe,  
    input  wire       ena,     
    input  wire       clk,     
    input  wire       rst_n    
);

    localparam STATE_IDLE  = 4'h0;
    localparam STATE_LOAD  = 4'h1;
    localparam STATE_ADD   = 4'h2;
    localparam STATE_SUB   = 4'h3;
    localparam STATE_STORE = 4'h4;

    reg [3:0] state;
    reg [7:0] acc;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= STATE_IDLE;
            acc   <= 8'h00;
        end else if (!ena) begin
            state <= STATE_IDLE;
            acc   <= 8'h00;
        end else begin
            case (state)
                STATE_IDLE: begin
                    case (ui_in)
                        8'h01: state <= STATE_LOAD;
                        8'h02: state <= STATE_ADD;
                        8'h03: state <= STATE_SUB;
                        8'h04: state <= STATE_STORE;
                        default: state <= STATE_IDLE; // NOP for 0x00
                    endcase
                end

                STATE_LOAD: begin
                    acc   <= ui_in;
                    state <= STATE_IDLE;
                end

                STATE_ADD: begin
                    acc   <= acc + 8'h01;
                    state <= STATE_IDLE;
                end

                STATE_SUB: begin
                    acc   <= acc - 8'h01;
                    state <= STATE_IDLE;
                end

                STATE_STORE: begin
                    acc   <= acc;
                    state <= STATE_IDLE;
                end

                default: state <= STATE_IDLE;
            endcase
        end
    end

    assign uo_out  = acc;
    assign uio_out = {4'h0, state};
    assign uio_oe  = 8'hFF;

endmodule
