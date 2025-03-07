module transmitter(input wire [7:0] din,
		   input wire wr_en,
		   input wire clk_50m,
		   output reg tx,
		   output reg tx_busy);



parameter STATE_IDLE	= 2'b00;
parameter STATE_START	= 2'b01;
parameter STATE_DATA	= 2'b10;
parameter STATE_STOP	= 2'b11;
parameter  COUNT_CLK    = 434;  //(1/115200) / (1/50000000) 


reg [9:0] CounterCLK = 0;
reg [7:0] data = 8'h00;
reg [2:0] bitpos = 3'h0;
reg [1:0] state = STATE_IDLE;
reg StartTX = 0;


always @(posedge clk_50m) begin
    if(state == STATE_IDLE  && wr_en == 1'b1)
        StartTX <= 1;
	 if(state == STATE_START)
        StartTX <= 0;
end



always @(posedge clk_50m) begin
	case (state)
        STATE_IDLE: begin
            tx <= 1'b1;
            tx_busy <= 0;
            if (StartTX) begin
                state <= STATE_START;
                data <= din;
                bitpos <= 3'h0;
                tx_busy <= 1;
                CounterCLK <= 0;
            end 
        end
        STATE_START: begin			
            CounterCLK <= CounterCLK + 1'b1;
            if(CounterCLK > COUNT_CLK)begin
                tx <= 1'b0;
                state <= STATE_DATA;
                CounterCLK <= 0;
            end
        end
        STATE_DATA: begin
            CounterCLK <= CounterCLK + 1'b1;
            if(CounterCLK > COUNT_CLK)begin
                tx <= data[bitpos];
                if (bitpos == 3'h7)begin
                    state <= STATE_STOP;
                end
                else
                    bitpos <= bitpos + 3'h1;
                //tx <= data[bitpos];
                
                CounterCLK <= 0;
            end
        end
        STATE_STOP: begin
            CounterCLK <= CounterCLK + 1'b1;
            if(CounterCLK > COUNT_CLK)begin
                tx <= 1'b1;
                state <= STATE_IDLE;
                tx_busy <= 0;
                CounterCLK <= 0;
            end
        end
        default: begin
            tx <= 1'b1;
            state <= STATE_IDLE;
            tx_busy <= 0;
        end
	endcase
end

//assign tx_busy = (state != STATE_IDLE);

endmodule
