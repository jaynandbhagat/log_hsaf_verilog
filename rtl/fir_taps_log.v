`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Author: Pavan Kumar
// Create Date: 22-08-2022
// Module name: fir_taps.v
//////////////////////////////////////////////////////////////////////////////////

module fir_taps_log
#(parameter WIDTH = 16, QP = 12, ORD = 64)
  (   input clk,
    input reset,
    input [ORD*(WIDTH+3)-1:0] filter_in_packed,
    input [ORD*WIDTH-1:0] weight_in_packed,
    output [ORD*WIDTH-1:0] tap_out_packed
);
    wire signed [WIDTH-1:0] weight[ORD-1:0], tap_out[ORD-1:0], weight_abs[ORD-1:0];
    wire signed [WIDTH+2:0] filter_in[ORD-1:0];
    wire signed [WIDTH:0] weight_log[ORD-1:0], weight_log_d[ORD-1:0];
    wire weight_sign[ORD-1:0], weight_valid[ORD-1:0], weight_sign_d[ORD-1:0], weight_valid_d[ORD-1:0];
  
   genvar j;

    generate
      for(j = 0; j < ORD; j = j + 1)
        begin: tap_delay
          DelayNUnit #(1, 1) WEIGHT_VALID(.clk(clk), .reset(reset), .reg_in(weight_valid[j]), .reg_out(weight_valid_d[j]));
          DelayNUnit #(1, 1) WEIGHT_SIGN(.clk(clk), .reset(reset), .reg_in(weight_sign[j]), .reg_out(weight_sign_d[j]));
          DelayNUnit #(WIDTH+1, 1) WEIGHT_LOG(.clk(clk), .reset(reset), .reg_in(weight_log[j]), .reg_out(weight_log_d[j]));
          
        end
    endgenerate
   
  
    
  
    // it takes product of each of the inputs with the correspsonding weights

    genvar i;

    generate
        for(i = 0; i < ORD; i = i + 1)
        begin:taps
          log_multiplier #(.WIDTH(16)) log_multiplier_filter (.log_in1(filter_in[i][WIDTH:0]), 
                                                              .log_in2(weight_log_d[i]), 
                                                              .log_in1_valid(filter_in[i][WIDTH+2]),
                                                              .log_in2_valid(weight_valid_d[i]), 
                                                              .in1_sign(filter_in[i][WIDTH+1]),
                                                              .in2_sign(weight_sign_d[i]),
                                                              .prod_out(tap_out[i]), 
                                                              .clk(clk), 
                                                              .rst(reset));
        end
    endgenerate

   
    
    genvar ind;
    generate
        for ( ind = 0; ind < ORD; ind=ind+1 )
        begin:filter_pack
            // unpacking the inputs
            // these are basically simple wire connections
          assign filter_in[ind] = filter_in_packed[(WIDTH+3)*ind+:(WIDTH+3)];
        end
    endgenerate

  
  
    generate
        for ( ind = 0; ind < ORD; ind=ind+1 )
        begin:weight_pack
            // unpacking the weightscking the weigh
            assign weight[ind] = weight_in_packed[WIDTH*ind+:WIDTH];
          
            // find the absolute value and sign bit of weight
            assign weight_sign[ind] = weight[ind][WIDTH-1];
            assign weight_abs[ind] = weight_sign[ind]?-weight[ind]:weight[ind];
            
            // taking log of the weight
            log1_16 LOG_weight (.data(weight_abs[ind]),
                                .log(weight_log[ind]),
                                .valid(weight_valid[ind]));
        end
    endgenerate

   
    generate
        for ( ind = 0; ind < ORD; ind=ind+1 )
        begin:tap_pack
            // packing the outputs of each of the multipliers into a vector
            assign tap_out_packed[WIDTH*ind+:WIDTH] = tap_out[ind];
        end
    endgenerate

endmodule 
