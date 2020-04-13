`timescale 1ns / 1ps

//Description: Behaves as a sinusoidal function, storing "size" number of entries in BRAM
module SineLUT (input clk, input resetn, input enable, output [15:0] data);
    parameter size = 44100;
    reg [15:0] addrCounter = 16'b0;

    always@(posedge clk)
    begin
        if (~resetn)
        begin
            addrCounter <= 0;
        end
        else if (enable)
        begin
            if (addrCounter == size-1)
                addrCounter <= 0;
            else
                addrCounter <= addrCounter + 1;
        end
        else
            addrCounter <= 0;
    end
 
    BRAM #(.size(size)) LUT (.clk(clk), .addr(addrCounter), .write(1'b0), .dataOut(data));
endmodule

module BRAM(clk, addr, write, resetn, dataOut, dataIn);
    parameter size = 44100;
    
    input clk, write, resetn;
    input [15:0] addr;
    input [15:0] dataIn;
    output reg [15:0] dataOut = 16'b0;
    
    reg [15:0] memory [size-1:0];
    
    initial 
        $readmemh("/nfs/ug/homes-0/y/yusufal5/ip_repo/ChorusFilter_1.0/src/LUT.txt", memory);
    
    always @(posedge clk) 
    begin
       if( write == 1 )
           memory[addr] <= dataIn;
       dataOut <= memory[addr];       
    end
    
endmodule
