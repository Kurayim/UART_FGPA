`timescale 1ns / 1ps

module Test_UART(
    input wire CLK,
    input wire Rx,
    output wire Tx,
    output reg [3:0]LED = 0,
    output reg [7:0]SegMents = 1,
    output reg [5:0]SegSel = 1,
    output reg Buz = 1 );
	 
	  
//********************** TX STR *************************
 parameter LIMIT_LEN_PACK_T = 20;		// Length Packert Tx
 parameter STA_T_IDLE  = 0;				// State First Confige
 parameter STA_T_PDOB  = 1;				// State Put The Data On the Bus
 parameter STA_T_ENDT  = 2;				// State End Transmitter
 
 wire StatuseTX;
 
 reg LetSendPacket = 0;
 reg LetSendByte = 0;
 reg [7:0]DataTx = 8'b0;
 reg [4:0]StateTransmitter = STA_T_IDLE;
 reg [7:0]PacketTx[0:LIMIT_LEN_PACK_T];
 reg [16:0]NumPacketTx = 0;
 reg [5:0]CounterTx = 0;
	 
	 
//********************** TX END *************************		 
	 
	 
//********************** RX STR *************************	 
 parameter LIMIT_TIM_CP = 5000000;		// Conter Wait For last Packet
 parameter LIMIT_LEN_PACK_R = 10;		// Length Packert Rx
 parameter STA_R_IDLE  = 0;				// State First Confige
 parameter STA_R_DFIL  = 1;				// State Filling Data 
 parameter STA_R_CPAC  = 2;				// State End Of Receive And Close Packet
 
 wire[7:0]DataRx;
 wire ReadyMes;
 
 reg [23:0]ClosePacketTimer = 0;
 reg FlagStartTim = 0;
 reg [4:0]StateReceive = 0;
 reg [7:0]PacketRx[0:LIMIT_LEN_PACK_R];
 reg [16:0]NumPacketRx = 0;
 reg FlagReadyDate = 0;
 reg LastReadyMes = 0;
//********************** RX END *************************	
//********************** TIMER STR *************************	

reg [3:0]Sgm[0:5];
reg [27:0]ClkCout = 1;
reg FlagResetSgms = 1;
reg LetRunTimSgm = 1;

//********************** TIMER END *************************
//********************** SEGM STR *************************	

reg [5:0]NumSgm = 0;
reg [27:0]DelayTimShowSgm = 1;

//********************** SEGM END *************************		 
//********************** BUZZER STR *************************	

reg [27:0]CountRunBuz = 0;
reg FlagRunBuz = 0;

//********************** BUZZER END *************************		 
	 
	 
	 
	 
 receiver RX(
    .rx(Rx),
    .rdy(ReadyMes),
    .clk_50m(CLK),
    .data(DataRx));
	 
 transmitter TX(
   .din(DataTx),
	   .wr_en(LetSendByte),
	   .clk_50m(CLK),
	   .tx(Tx),
	   .tx_busy(StatuseTX));


	always@(posedge CLK)begin	
		
		if(FlagRunBuz)begin
			CountRunBuz <= CountRunBuz + 1;
			Buz <= 0;
			if(CountRunBuz >= 220000)begin //  buzzer run 200 ms
				CountRunBuz <= 0;
				FlagRunBuz <= 0;
				Buz <= 1;
			end
		end
		
	//********************** Seven Segment STR *************************	
		
		DelayTimShowSgm <= DelayTimShowSgm + 1;
		if(DelayTimShowSgm >= 50000)begin
			DelayTimShowSgm <= 0;
			NumSgm <= NumSgm + 1;
			if(NumSgm >= 5)
				NumSgm <= 0;
				
			SegSel[0] <= 1;
			SegSel[1] <= 1;
			SegSel[2] <= 1;
			SegSel[3] <= 1;
			SegSel[4] <= 1;
			SegSel[5] <= 1;
			SegSel[NumSgm] <= 0;
			case(Sgm[NumSgm])
				4'd0: SegMents = 8'b11000000;
				4'd1: SegMents = 8'b11111001;
				4'd2: SegMents = 8'b10100100;
				4'd3: SegMents = 8'b10110000;
				4'd4: SegMents = 8'b10011001;
				4'd5: SegMents = 8'b10010010;
				4'd6: SegMents = 8'b10000010;
				4'd7: SegMents = 8'b11111000;
				4'd8: SegMents = 8'b10000000;
				4'd9: SegMents = 8'b10010000;
			endcase
		end

	//********************** Timer STR *************************	
		
		ClkCout <= ClkCout + 1;
		if(FlagResetSgms)begin
			FlagResetSgms <= 0;
			LetRunTimSgm <= 1;
			ClkCout <= 0;
			Sgm[0] <= 0;
			Sgm[1] <= 0;
			Sgm[2] <= 0;
			Sgm[3] <= 0;
			Sgm[4] <= 0;
			Sgm[5] <= 0;
		end
		else if(ClkCout >= 50000000 && LetRunTimSgm)begin
			ClkCout <= 0;
			Sgm[0] <= Sgm[0] + 1;
			if(Sgm[0] >= 4'b1001)begin
				Sgm[0] <= 0;  
				Sgm[1] <= Sgm[1] + 1;
			end
			if(Sgm[1] >= 4'b1001)begin  
				Sgm[0] <= 0; 
				Sgm[1] <= 0;
				Sgm[2] <= Sgm[2] + 1;
			end
			if(Sgm[2] >= 4'b1001)begin  
				Sgm[0] <= 0; 
				Sgm[1] <= 0;
				Sgm[2] <= 0;
				Sgm[3] <= Sgm[3] + 1;
			end
			if(Sgm[3] >= 4'b1001)begin  
				Sgm[0] <= 0; 
				Sgm[1] <= 0;
				Sgm[2] <= 0;
				Sgm[3] <= 0;
				Sgm[4] <= Sgm[4] + 1;
			end
			if(Sgm[4] >= 4'b1001)begin 
				Sgm[0] <= 0; 
				Sgm[1] <= 0;
				Sgm[2] <= 0;
				Sgm[3] <= 0;
				Sgm[4] <= 0;
				Sgm[5] <= Sgm[5] + 1;
			end
			if(Sgm[5] >= 4'b1001)begin  
				Sgm[0] <= 0;
				Sgm[1] <= 0;
				Sgm[2] <= 0;
				Sgm[3] <= 0;
				Sgm[4] <= 0;
				Sgm[5] <= 0;
			end
	
		end
	
	//********************** RX STR *************************
		case(StateTransmitter)
			STA_T_IDLE:begin
				LetSendPacket <= 0;
				LetSendByte <= 0;
				NumPacketTx <= 0;
				CounterTx <= 0;
				DataTx <= 0;
				if(LetSendPacket)begin
					StateTransmitter <= STA_T_PDOB;
				end
				else begin
					PacketTx[0] <= 8'b0;
					PacketTx[1] <= 8'b0;
					PacketTx[2] <= 8'b0;
					PacketTx[3] <= 8'b0;
					PacketTx[4] <= 8'b0;
					PacketTx[5] <= 8'b0;
					PacketTx[6] <= 8'b0;
					PacketTx[7] <= 8'b0;
					PacketTx[8] <= 8'b0;
					PacketTx[9] <= 8'b0;
					PacketTx[10] <= 8'b0;
					PacketTx[11] <= 8'b0;
					PacketTx[12] <= 8'b0;
					PacketTx[13] <= 8'b0;
					PacketTx[14] <= 8'b0;
					PacketTx[15] <= 8'b0;
					PacketTx[16] <= 8'b0;
					PacketTx[17] <= 8'b0;
					PacketTx[18] <= 8'b0;
					PacketTx[19] <= 8'b0;
					PacketTx[20] <= 8'b0;
				end
			end
			STA_T_PDOB:begin
				LetSendByte <= 0;
				CounterTx <= CounterTx + 1;
				if(PacketTx[NumPacketTx] == 8'h00 || NumPacketTx >= LIMIT_LEN_PACK_T)begin
					StateTransmitter <= STA_T_ENDT;
				end
				else begin
					if(!StatuseTX  &&  CounterTx >= 5)begin
						CounterTx <= 0;
						LetSendByte <= 1;
						DataTx <= PacketTx[NumPacketTx];
						NumPacketTx <= NumPacketTx + 1;
					end
				end
			end
			STA_T_ENDT:begin
			      StateTransmitter <= STA_R_IDLE;
			end
	                default: begin
			      StateTransmitter <= STA_R_IDLE;
			end
		endcase	
	
	//********************** RX STR *************************		
			
		LastReadyMes <= ReadyMes;
		case(StateReceive)
			STA_R_IDLE:begin
				PacketRx[0] <= 8'b0;
				PacketRx[1] <= 8'b0;
				PacketRx[2] <= 8'b0;
				PacketRx[3] <= 8'b0;
				PacketRx[4] <= 8'b0;
				PacketRx[5] <= 8'b0;
				PacketRx[6] <= 8'b0;
				PacketRx[7] <= 8'b0;
				PacketRx[8] <= 8'b0;
				PacketRx[9] <= 8'b0;
				PacketRx[10] <= 8'b0;
				NumPacketRx <= 0;
				FlagStartTim <= 0;
				ClosePacketTimer <= 0;
				StateReceive <= STA_R_DFIL;			
			end
			STA_R_DFIL:begin
				if(FlagStartTim)
					ClosePacketTimer <= ClosePacketTimer + 1;
				if(!LastReadyMes && ReadyMes)begin
					 FlagStartTim <= 1;
					ClosePacketTimer <= 0;
					PacketRx[NumPacketRx] <= DataRx;
					NumPacketRx <= NumPacketRx + 1;
				end
				if(ClosePacketTimer >= LIMIT_TIM_CP)begin
					ClosePacketTimer <= 0;
					StateReceive <= STA_R_CPAC;
				end
				if(NumPacketRx >= LIMIT_LEN_PACK_R)
					StateReceive <= STA_R_CPAC;
			end
			STA_R_CPAC:begin
				FlagReadyDate <= 1;
				StateReceive <= STA_R_IDLE;
				FlagStartTim <= 0;
			end
	      		default: begin
				StateReceive <= STA_R_IDLE;
			end
		endcase
	//********************** RX END *************************
	
		if(FlagReadyDate)begin
		/*
			LetSendPacket <= 1;
			PacketTx[0] <= "\n";
			PacketTx[1] <= PacketRx[0];
			PacketTx[2] <= PacketRx[1];
			PacketTx[3] <= PacketRx[2];
			PacketTx[4] <= PacketRx[3];
			PacketTx[5] <= PacketRx[4];
			PacketTx[6] <= PacketRx[5];
			PacketTx[7] <= PacketRx[6];
			PacketTx[8] <= "\n";
		
			if(PacketRx[0] == 8'h4c && PacketRx[1] == 8'h45 && PacketRx[2] == 8'h44 && PacketRx[3] == 8'h20 && PacketRx[4] == 8'h4f && PacketRx[5] == 8'h4e && PacketRx[6] == 8'h20 && PacketRx[7] == 8'h30)begin
				LED[0] <= 1;             // LED ON 0
				LetSendPacket <= 1;
				PacketTx[0] <= "\n";
				PacketTx[1] <= "H";
				PacketTx[2] <= "i";
				PacketTx[3] <= " ";
				PacketTx[4] <= "L";
				PacketTx[5] <= "E";
				PacketTx[6] <= "D";
				PacketTx[7] <= "0";
				PacketTx[8] <= " ";
				PacketTx[9] <= "O";
				PacketTx[10] <= "N";
				PacketTx[11] <= "\n";
								
			end
			else if(PacketRx[0] == 8'h4c && PacketRx[1] == 8'h45 && PacketRx[2] == 8'h44 && PacketRx[3] == 8'h20 && PacketRx[4] == 8'h4f && PacketRx[5] == 8'h46 && PacketRx[6] == 8'h46) begin
				LED[0] <= 0;				// LED OFF 0
				LetSendPacket <= 1;
				PacketTx[0] <= "\n";
				PacketTx[1] <= "H";
				PacketTx[2] <= "i";
				PacketTx[3] <= " ";
				PacketTx[4] <= "L";
				PacketTx[5] <= "E";
				PacketTx[6] <= "D"
				PacketTx[7] <= "0";
				PacketTx[8] <= " ";
				PacketTx[9] <= "O";
				PacketTx[10] <= "F";
				PacketTx[11] <= "F";
				PacketTx[12] <= "\n";
			end   
		*/
			
			if( PacketRx[0] == 8'h4c && PacketRx[1] == 8'h45 && PacketRx[2] == 8'h44  && PacketRx[4] == 8'h20  &&  PacketRx[5] == 8'h4F )begin // "LED O"
				
				PacketTx[0] <= "\n";
				PacketTx[1] <= "H";
				PacketTx[2] <= "i";
				PacketTx[3] <= " ";
				PacketTx[4] <= "L";
				PacketTx[5] <= "E";
				PacketTx[6] <= "D";
				PacketTx[8] <= " ";
				PacketTx[9] <= "i";
				PacketTx[10] <= "s";
				PacketTx[11] <= " ";
				if(PacketRx[6] == 8'h4E )begin // "N "
					PacketTx[12] <= "o";
					PacketTx[13] <= "n";
					PacketTx[14] <= "\n";
					if(PacketRx[3] == 8'h30)begin //"0"
						PacketTx[7] <= "0";
						LED[0] <= 1;		
						LetSendPacket <= 1;
						FlagRunBuz <= 1;
					end
					else if(PacketRx[3] == 8'h31)begin //"1"
						PacketTx[7] <= "1";
						LED[1] <= 1;				
						LetSendPacket <= 1;
						FlagRunBuz <= 1;
					end
					else if(PacketRx[3] == 8'h32)begin //"2"
						PacketTx[7] <= "2";
						LED[2] <= 1;				
						LetSendPacket <= 1;
						FlagRunBuz <= 1;
					end
					else if(PacketRx[3] == 8'h33)begin //"3"
						PacketTx[7] <= "3";
						LED[3] <= 1;				
						LetSendPacket <= 1;
						FlagRunBuz <= 1;
					end
				end  
				else if(PacketRx[6] == 8'h46 && PacketRx[7] == 8'h46 )begin  // "FF "
					PacketTx[12] <= "o";
					PacketTx[13] <= "f";
					PacketTx[14] <= "f";
					PacketTx[15] <= "\n";
					if(PacketRx[3] == 8'h30)begin //"0"
						PacketTx[7] <= "0";
						LED[0] <= 0;				
						LetSendPacket <= 1;
						FlagRunBuz <= 1;
					end
					else if(PacketRx[3] == 8'h31)begin //"1"
						PacketTx[7] <= "1";
						LED[1] <= 0;				
						LetSendPacket <= 1;
						FlagRunBuz <= 1;
					end
					else if(PacketRx[3] == 8'h32)begin //"2"
						PacketTx[7] <= "2";
						LED[2] <= 0;				
						LetSendPacket <= 1;
						FlagRunBuz <= 1;
					end
					else if(PacketRx[3] == 8'h33)begin //"3"
						PacketTx[7] <= "3";
						LED[3] <= 0;				
						LetSendPacket <= 1;
						FlagRunBuz <= 1;
					end
				end
			end
			else if( PacketRx[0] == 8'h54 && PacketRx[1] == 8'h49 && PacketRx[2] == 8'h4D  && PacketRx[3] == 8'h20 )begin // "TIM "
				
				PacketTx[0] <= "\n";
				PacketTx[1] <= "H";
				PacketTx[2] <= "i";
				PacketTx[3] <= " ";
				PacketTx[4] <= "T";
				PacketTx[5] <= "i";
				PacketTx[6] <= "m";
				PacketTx[7] <= "e";
				PacketTx[8] <= "r";
				PacketTx[9] <= " ";
				
				if( PacketRx[4] == 8'h53 && PacketRx[5] == 8'h54 && PacketRx[6] == 8'h41  && PacketRx[7] == 8'h52  &&  PacketRx[8] == 8'h54 )begin // "START"
					LetRunTimSgm <= 1;
					LetSendPacket <= 1;
					FlagRunBuz <= 1;
					PacketTx[10] <= "S";
					PacketTx[11] <= "t";
					PacketTx[12] <= "a";
					PacketTx[13] <= "r";
					PacketTx[14] <= "t";
					PacketTx[15] <= "\n";
				end
				else if( PacketRx[4] == 8'h53 && PacketRx[5] == 8'h54 && PacketRx[6] == 8'h4F  && PacketRx[7] == 8'h50 )begin // "STOP"
					LetRunTimSgm <= 0;
					LetSendPacket <= 1;
					FlagRunBuz <= 1;
					PacketTx[10] <= "S";
					PacketTx[11] <= "t";
					PacketTx[12] <= "o";
					PacketTx[13] <= "p";
					PacketTx[14] <= "\n";
				end
				else if( PacketRx[4] == 8'h52 && PacketRx[5] == 8'h45 && PacketRx[6] == 8'h53  && PacketRx[7] == 8'h45  &&  PacketRx[8] == 8'h54 )begin // "RESET"
					FlagResetSgms <= 1;
					LetRunTimSgm <= 1;
					LetSendPacket <= 1;
					FlagRunBuz <= 1;
					PacketTx[10] <= "R";
					PacketTx[11] <= "e";
					PacketTx[12] <= "s";
					PacketTx[13] <= "e";
					PacketTx[14] <= "t";
					PacketTx[15] <= "\n";
				end
			end
		     FlagReadyDate <= 0;
		end
	end
	
endmodule






