`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Author: Pavan Kumar
// Create Date: 22-08-2022
// Module name: fir_taps.v
//////////////////////////////////////////////////////////////////////////////////

module fir_u_q
#(parameter WIDTH = 16, QP = 12, ORD = 64)
(
    input [ORD*WIDTH-1:0] filter_in_packed,
    input [ORD*WIDTH-1:0] weight_in_packed,
    input clk,
    input reset,
    output [ORD*WIDTH-1:0] tap_out_packed_antilog
);

    wire signed [2*WIDTH-1:0] tap_out_full[ORD-1:0], tap_out_rnd[ORD-1:0];
    wire signed [WIDTH-1:0] filter_in[ORD-1:0], weight[ORD-1:0], tap_out[ORD-1:0];
    wire filt_sign [ORD-1:0];
    wire q_sign    [ORD-1:0];
    wire  [WIDTH-1:0] filt_abs [ORD-1:0];
    wire  [WIDTH-1:0] q_abs    [ORD-1:0];
    wire  [WIDTH:0] filter_in_log [ORD-1:0];
    wire  [WIDTH:0] q_in_log      [ORD-1:0];
    wire filt_valid [ORD-1:0];
    wire q_valid    [ORD-1:0];




    genvar i;

    generate
        for(i = 0; i < ORD; i = i + 1)
        begin:taps
            assign filt_sign[i] = filter_in[i][WIDTH-1];
             assign q_sign[i] = weight[i][WIDTH-1];
            assign filt_abs[i] = filt_sign[i] ? -filter_in[i] : filter_in[i] ;
             assign q_abs[i] = q_sign[i] ? -weight[i] : weight[i] ;
            log1_16 log_filter_in (.data(filt_abs[i]),.log(filter_in_log[i]),.valid(filt_valid[i]));
            log1_16 log_weight_in (.data(q_abs[i]),.log(q_in_log[i]),.valid(q_valid[i]));
     log_multiplier log_mult_u_q (.log_in1(filter_in_log[i]),.log_in2(q_in_log[i]),.log_in1_valid(filt_valid[i]),.log_in2_valid(q_valid[i]),.in1_sign(filt_sign[i]),.in2_sign(q_sign[i]),.prod_out(tap_out[i]),.clk(clk),.rst(reset)) ;

           // assign tap_out_full[i] = $signed(filter_in[i]) * $signed(weight[i]);
          //  assign tap_out_rnd[i] = tap_out_full[i] + (1'b1 << (QP-1));
           // assign tap_out[i] = tap_out_rnd[i][QP+:WIDTH];
            // tap_multiply #(WIDTH, QP) TAP(filter_in[i], weight[i], tap_out[i]);
        end
    endgenerate


    genvar ind;
    generate
        for ( ind = 0; ind < ORD; ind=ind+1 )
        begin:filter_pack
            assign filter_in[ind] = filter_in_packed[WIDTH*ind+:WIDTH];
        end
    endgenerate

    generate
        for ( ind = 0; ind < ORD; ind=ind+1 )
        begin:weight_pack
            assign weight[ind] = weight_in_packed[WIDTH*ind+:WIDTH];
        end
    endgenerate

    generate
        for ( ind = 0; ind < ORD; ind=ind+1 )
        begin:tap_pack
            assign tap_out_packed_antilog[WIDTH*ind+:WIDTH] = tap_out[ind];
        end
    endgenerate

endmodule
