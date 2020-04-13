`timescale 1ns / 1ps
//Description: Takes an audio signal as input, and outputs the same signal with a chorus filter applied to it
module ChorusFilter(input clk, input resetn, input enable,  input[15:0] dataIn, output [15:0] dataOut);
       wire[15:0] dataOut1;
       wire[15:0] dataOut2;
       wire[15:0] delay;
       
       SineLUT LUT(.clk(clk), .resetn(resetn), .enable(enable), .data(delay));
       CircularBuffer circBuff(.clk(clk), .resetn(resetn), .dataIn(dataIn), .dataOut1(dataOut1), .dataOut2(dataOut2), .delay(delay), .enable(enable));
       
       wire [31:0] dataOut1_32;
       wire [31:0] dataOut2_32;
       
       assign dataOut1_32 = {16'h0000, dataOut1};
       assign dataOut2_32 = {16'h0000, dataOut2};
       
       wire [31:0] dataOut32 = dataOut1_32;
       assign dataOut = dataOut32[15:0]; 
endmodule
