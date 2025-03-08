`timescale 1ns / 1ps

module receiver(
	input wire rx,
	output reg rdy = 0,
	input wire clk_50m,
	output reg [7:0] data = 0);

parameter  ST_IDLE = 0;
parameter  ST_PACK = 1;
parameter  ST_ENDR = 2;
parameter  BIT_UAT = 10-1-1; // (-1)NumBit start from 0  // (-1)We don't sampling bitUart[10]
parameter  MAX_SAM = 10;
parameter  MID_SAM = 5;
parameter  BUAD_RATE = 115200;
parameter  CLK_SORC  = 50000000;
parameter  CLK_SAMP  = 43;  //  1/115200(baud rate)=8680ns , 1/50mhz(main clk)=20ns , 8680/20=434 , 434/10("Numsamples")=43


reg [2:0]state = ST_IDLE;
reg [3:0]NumBit = 0;
reg [3:0]NumSam = 0;
reg [9:0]ContClk = 0;
reg [3:0]AddSam = 0;
reg [9:0]Buffer = 0;



   always @(posedge clk_50m)begin
        
        case(state)
            ST_IDLE: begin
                if(!rx)begin
                    state <= ST_PACK;
                    ContClk <= 0;
                    NumBit <= 0;
		    NumSam <= 0;
		    AddSam <= 0;
		    Buffer <= 0;
		    rdy <= 0;
                end
            end
            ST_PACK: begin
		ContClk <= ContClk + 1;
		if(NumSam >= MAX_SAM)begin
			if(AddSam <= MID_SAM)
			    Buffer[NumBit] <= 0;
			else
			    Buffer[NumBit] <= 1;
			
			AddSam <= 0;
			NumSam <= 0;
			NumBit <= NumBit + 1;
			if(NumBit >= BIT_UAT)
			state <= ST_ENDR;
		end
		if(ContClk >= CLK_SAMP)begin
			ContClk <= 0;
			AddSam <= AddSam + rx;
			NumSam <= NumSam + 1;
		end
            end
            ST_ENDR: begin
		if(rx)begin
			state <= ST_IDLE;
			data <= Buffer[8:1];
			rdy <= 1;
		end
            end
            default: begin
                state <= ST_IDLE;
            end
         endcase
	   
    end
	
endmodule

