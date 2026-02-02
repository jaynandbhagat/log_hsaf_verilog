`timescale 1ns / 1ps

module lod_4(
input [3:0] data1,
output reg [1:0] pos,
output valid);

wire valid1, valid0;

// valid is 1 if any bit in data is 1
//valid is 1 if there is any leading 1, acts as an indicator
assign valid1 = data1[3] | data1[2];
assign valid0 = data1[1] | data1[0];
assign valid = valid0 | valid1;

//reg [1:0] pos;
//pos is position of leading 1
 always @ (*) 
  begin 
   if(valid1)
    pos = {1'b1, data1[3]};
   else if(valid0)
    pos = {1'b0, data1[1]};
   else 
    pos = 2'b0; //x means value is unknown/undefined
  end
 
endmodule