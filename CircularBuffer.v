`timescale 1ns / 1ps
//Description: Implementation of a circular buffer data structure
//dataOut1 is equal to input and dataOut2 is delayed version of input 
//Lower resetn => clear buffer, clear output data lines, reset both addresses to 0
//Raise resetn, keep enable low => Output data lines retain current values, buffer retains current values, addresses retain current values
//Raise resetn and enable => On next clock edge, output data lines will have data from buffer from addresses at address ports, 
//read/write pointers will update, buffer will read in current value on data in line

module CircularBuffer(clk, resetn, dataIn, dataOut1, dataOut2, delay, enable);
    parameter bufferSize = 44100;
    input clk;
    input resetn;
    input [15:0] dataIn;
    input [15: 0] delay;
    input enable;
    output reg [15:0] dataOut1 = 16'b0;
    output reg [15:0] dataOut2 = 16'b0;
        
    reg[15:0] readAddr = 16'b0;
    reg[15:0] writeAddr = 16'b0;
    
    //Buffer logic
    wire [15:0] bufferDataOut;
    BRAM2 #(.size(bufferSize)) buffer(.clk(clk), .addrR(readAddr), .addrW(writeAddr), .enable(enable), .dataOut(bufferDataOut), .dataIn(dataIn));
    
    //DataOut1 should always be equal to buffer[writeAddr] AFTER the clock tick
    always@(posedge clk)
    begin
        if (enable)
        begin
            dataOut1 <= dataIn;
            if (readAddr == writeAddr)
            begin
                dataOut2 <= dataIn; 
            end
            else
            begin
                dataOut2 <=  bufferDataOut;  
            end
        end     
    end
        
    
    //Logic to control read/write pointers
    always@(posedge clk)
    begin
        if (~resetn)
        begin
            readAddr <= 16'b0;
            writeAddr <= 16'b0;
        end
        else if (~enable)
        begin
            readAddr <= readAddr;
            writeAddr <= writeAddr;
        end
        else
        begin
            if (writeAddr != bufferSize-1)
            begin
                writeAddr <= (writeAddr + 1);
                
                if (writeAddr + 1 < delay)
                    readAddr <= writeAddr + 1 + bufferSize - delay;
                else
                    readAddr <= writeAddr + 1 - delay;
            end
                
            else
            begin
                writeAddr <= 0;
                
                if (0 < delay)
                    readAddr <= bufferSize - delay;
                else
                    readAddr <= 0;
            end                        
        end
    end
    
endmodule

module BRAM2(clk, addrR, addrW, enable, dataOut, dataIn);
    parameter size = 44100;
    
    input clk, enable;
    input [15:0] addrR, addrW;
    input [15:0] dataIn;
    output reg [15:0] dataOut = 16'b0;
    
    (* RAM_STYLE = "block" *)  reg [15:0] memory [size-1:0];
    
    integer i;
    initial
    begin
        for (i = 0; i < size; i = i+1)
        begin
            memory[i] = 16'b0000000000000000;
        end
    end
    
    always @(posedge clk) 
    begin
       if(enable)
           memory[addrW] <= dataIn;
       dataOut <= memory[addrR];
    end
    
endmodule
