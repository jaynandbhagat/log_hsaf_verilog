`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Author: Pavan Kumar
// Create Date: 11-08-2022
// Module name: w_update.v
//////////////////////////////////////////////////////////////////////////////////

module w_update
#(parameter WIDTH = 16, QP = 12)
(
    input clk,
    input reset,
    input [WIDTH-1:0] mu_error,
    input [WIDTH+2:0] log_x_n,
    output reg [WIDTH-1:0] weight
);

     //wire signed [2*WIDTH-1:0] x_n_error_full, x_n_error_rnd; 
    wire signed [WIDTH-1:0] x_n_error, new_weight, x_n_error_d;
    wire [WIDTH-1:0] mu_error_abs;
    wire mu_error_sign, mu_error_valid;
    wire [WIDTH:0] log_mu_error;
    wire [WIDTH+2:0]log_mu_error_d;
    
    //DelayNUnit #(WIDTH, 1) IN_PIP(clk, reset, mu_error, mu_error_d);        
    // Retiming delay before mult and add
  
    // Retiming delay occurs after the multiplication of mu_error and x_n
    DelayNUnit #(WIDTH, 1) IN_PIP(clk, reset, x_n_error, x_n_error_d);  
  
    // Retiming delay before add
    //assign x_n_error_full = $signed(x_n) * $signed(mu_error_d);
  
    // x_n_error_full is the product of mu_error and x_n
    // it is then rounded off and truncated to give x_n_error
    // this x_n error is passed through a Delay Unit
  
   assign mu_error_sign = mu_error[WIDTH-1];
   assign mu_error_abs = mu_error_sign?-mu_error:mu_error;
  
   log1_16 LOG_mu_error (.data(mu_error_abs),
                         .log(log_mu_error),
                         .valid(mu_error_valid));
  
   DelayNUnit #(WIDTH+3, 1) ERR_PIP_W(clk, reset, {mu_error_sign, mu_error_valid,log_mu_error}, log_mu_error_d); 
  
   log_multiplier #(.WIDTH(16)) log_multiplier_weight(.log_in1(log_x_n[WIDTH:0]), 
                                                      .log_in2(log_mu_error_d[WIDTH:0]), 
                                                      .log_in1_valid(log_x_n[WIDTH+2]),
                                                      .log_in2_valid(log_mu_error_d[WIDTH+1]), 
                                                      .in1_sign(log_x_n[WIDTH+1]),
                                                      .in2_sign(log_mu_error_d[WIDTH+2]),
                                                      .prod_out(x_n_error), 
                                                      .clk(clk), 
                                                      .rst(reset));
       
    //assign x_n_error_full = $signed(x_n) * $signed(mu_error);
    //assign x_n_error_rnd = x_n_error_full + (1<<(QP-1));
    //assign x_n_error = x_n_error_rnd[QP+:WIDTH];
   
    // weight update equation
    assign new_weight = weight + x_n_error_d;
    
    // this is the register for storing the weights
    always @ ( posedge clk )
    if ( reset )
        weight <= 0;
    else
        weight <= new_weight;

endmodule 
