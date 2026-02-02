`timescale 1ns / 1ps
///////////////////////////////////////////////////////////
// Author: Pavan Kumar
// Create Date: 17-07-2024
// Module name: log_multiplier.v
///////////////////////////////////////////////////////////

module log_multiplier
#(parameter WIDTH = 16)
(
  input signed [WIDTH:0] log_in1,
  input signed [WIDTH:0] log_in2,
  input log_in1_valid, log_in2_valid, in1_sign, in2_sign,
  input clk,
  input rst,
  output signed [WIDTH-1:0] prod_out
);


    wire signed [WIDTH+1:0] log_prod;
    wire        [WIDTH-2:0] prod_out_unsgd;
    wire signed [WIDTH - 1:0] prod_out_unsgd_vld; 
  

    // Addition of the log terms
    assign log_prod = log_in1 + log_in2;

    // Antilog of product
    alog18_Q3_12 ALOG_PROD (.data(log_prod), .adata(prod_out_unsgd));

    // Valid and sign decoding
    assign log_prod_valid = log_in1_valid & log_in2_valid;
    assign prod_out_unsgd_vld = log_prod_valid ? {1'b0, prod_out_unsgd} : 16'b0;
    assign prod_out = {(in1_sign ^ in2_sign)} ? -prod_out_unsgd_vld: prod_out_unsgd_vld;

endmodule
