`timescale 1ns / 1ps

module alog18_Q3_12(
    input signed [17:0] data, //data is in Q6.12 format
    output reg [14:0] adata
    );



wire [12:0] fraction;

//Take fractional bits, add 1 and then shift so that leading one is in appropriate position
assign fraction = {1'b1 ,data[11:0]};

always @ (*)
  begin
  case (data[17:12])
    // 6'b000011  : adata = {       fraction[12:0], 2'b0};   //(3,12) FORMAT
    6'b000010  : adata = {       fraction[12:0], 2'b0};
    6'b000001  : adata = {1'b0,  fraction[12:0], 1'b0}; 
    6'b000000  : adata = {2'b0,  fraction[12:0]      };
	//For nos. with negative log starting from -1, all integer bits are 0 and then no. is in appropriate fractional position
    6'b111111  : adata = {3'b0,  fraction[12:1]      };
    6'b111110  : adata = {4'b0,  fraction[12:2]      };
    6'b111101  : adata = {5'b0,  fraction[12:3]      };
    6'b111100  : adata = {6'b0,  fraction[12:4]      };
    6'b111011  : adata = {7'b0,  fraction[12:5]      };
    6'b111010  : adata = {8'b0,  fraction[12:6]      };
    6'b111001  : adata = {9'b0,  fraction[12:7]      };
    6'b111000  : adata = {10'b0, fraction[12:8]      };
    6'b110111  : adata = {11'b0, fraction[12:9]      };
    6'b110110  : adata = {12'b0, fraction[12:10]     };
    6'b110101  : adata = {13'b0, fraction[12:11]     };
    6'b110100  : adata = {14'b0, fraction[12:12]     };
    // 6'b110100  : adata = {15'b0,fraction[12:]};
    // 6'b110011  : adata = {16'b0,fraction[12:10]};
    // 6'b110010  : adata = {17'b0,fraction[12:11]};
    // 6'b110001  : adata = {18'b0,fraction[12:12]};
    default : adata = 15'b0;
  endcase
 end

endmodule
