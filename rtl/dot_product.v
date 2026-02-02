`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Author: Pavan Kumar
// Create Date: 05-09-2022
// Module name: dot_product.v
//////////////////////////////////////////////////////////////////////////////////

module dot_product
#(parameter WIDTH = 16, QP = 12, LEN = 8)
(
    input [LEN*WIDTH-1:0] vec1_packed,
    input [LEN*WIDTH-1:0] vec2_packed,
    input clk,
    input reset,
    output [WIDTH-1:0] dotp_out
);

    wire signed [LEN*WIDTH-1:0] mult_out_packed;

    fir_u_q #(WIDTH, QP, LEN) DOTP(vec1_packed, vec2_packed,clk,reset, mult_out_packed);
    adder_tree #(WIDTH, LEN) DOT_ADD(mult_out_packed, dotp_out);

endmodule
