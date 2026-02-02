`timescale 1ns / 1ps

module lod_8#(parameter WIDTH = 1)
(
input [WIDTH:0] pos0,pos1,
input valid0, valid1,
output reg [WIDTH+1:0] pos,
output valid);

assign valid = valid0 | valid1;

// reg [WIDTH+1:0] pos;

// We check for valid 0 first (higher position nibble). Now pos0+4 will be new leading 1 position for 8 bits 
// How do variable length parameters get synthesized in hardware
 always @ (*) 
  begin 
   if(valid0)
    pos = {1'b1, pos0};
   else if(valid1)
    pos = {1'b0, pos1};
   else 
    pos = 4'b0;
  end
 
endmodule