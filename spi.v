`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/01/2023 12:25:10 PM
// Design Name: 
// Module Name: spi
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module spi #(
    CLK_FREQ =125000000,
    SPI_FREQ= 10000000
)(
    input clk,
    input reset,
    input [7:0] spi_output_reg,
    
    output reg sclk,
    output reg mosi,
	input miso,

    input data_valid,
    output reg spi_done
    );
    
    localparam CLK_DIV = (CLK_FREQ/SPI_FREQ/2)-1;
    
    reg [7:0] shift_reg;
    
    reg [$clog2(CLK_DIV):0] counter;
    reg [2:0] bits;
    
    localparam IDLE = 0;
    localparam TRANSMIT = 1;
    localparam DONE = 2;
    
    reg [1:0] STATE = IDLE;
    
    initial begin
        sclk <= 1;
        counter <= 0;
        bits <= 0;
        spi_done <= 0;
        shift_reg <= 0;
        mosi <= 0;
    end
    always@(posedge clk)
    begin
        if(counter != CLK_DIV)
            counter <= counter + 1;
         else
            counter <= 0;
    end
    
    always@(posedge clk)
    begin
        if(counter == CLK_DIV)
            sclk <= !sclk;
    end
    
    always@(negedge sclk)
    begin
        if(reset)
        begin
            STATE <= IDLE;
        end
        else 
        begin
        case(STATE)
            IDLE:
            begin
                if(data_valid)
                begin
                    shift_reg <= spi_output_reg;
                    STATE <= TRANSMIT;
                    bits <= 0;
                end
            end
            TRANSMIT:
            begin
                if(bits != 7)
                    bits <= bits + 1;
                else
                begin
                    STATE <= DONE;
                end
                mosi <= shift_reg[7];
                shift_reg = {shift_reg[6:0],1'b0};
                
            end
            
            DONE:
            begin
                spi_done <= 1;
                if(!data_valid)
                begin
                    spi_done <= 0;
                    STATE <= IDLE;
                end
            end
        endcase
        end
    end
endmodule

