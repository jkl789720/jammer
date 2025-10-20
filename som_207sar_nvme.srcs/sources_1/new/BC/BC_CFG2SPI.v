module BC_CFG2SPI
#(
parameter DATA_WIDTH = 80
)
(
input clk,  // 100MHz
input reset,

input 			                cfg_wr_en,
input [4*DATA_WIDTH-1:0] 		cfg_wr_dat,
output reg		                cfg_done,

output reg SPI_CS,
output reg SPI_SCLK,
output reg [3:0] SPI_MOSI,
input SPI_MISO
);

//---------------- decrease freqz logic ----------------
localparam DECREASE_BYPASS = 1'b0;
localparam DECREASE_FREQZ = 40; // must be >= 2
reg [DECREASE_FREQZ-1:0] clk_enable = 1;
always@(posedge clk)begin
	if(reset)clk_enable <= 1;
	else begin
		clk_enable <= {clk_enable[DECREASE_FREQZ-2:0], clk_enable[DECREASE_FREQZ-1]};
	end
end


//---------------- para to serial IF ----------------
reg sub_start;
reg [DATA_WIDTH-1:0] sub_wdata[0:3];
wire sub_done;

/*
sub_start ______|1|____________________________________
sub_done  __________________________________|1|________
sub_wdata ______|xxxxxxxxxxxxxxxxxxxxxxxxxxxxx|________
*/
genvar kk;
generate
for(kk=0;kk<4;kk=kk+1)begin:blk1
	always@(posedge clk)begin
		if(reset)sub_wdata[kk] <= 0;
		else begin
			if(cfg_wr_en)sub_wdata[kk] <= cfg_wr_dat[kk*DATA_WIDTH+DATA_WIDTH-1:kk*DATA_WIDTH];
		end
	end
end
endgenerate

always@(posedge clk)begin
	if(reset)begin
		sub_start <= 0;
		cfg_done <= 0;
	end
	else begin
		if(cfg_wr_en)begin
			sub_start <= 1;
			cfg_done <= 0;
		end
		else begin
			if(clk_enable[0] | DECREASE_BYPASS)begin
				sub_start <= 0;
				cfg_done <= sub_done;
			end
			else cfg_done <= 0;
		end
	end
end

//---------------- spi logic -------------------
localparam 
IDLE = 0,
WRITE0 = 1,
WRITE1 = 2,
WAIT0 = 3;

reg [3:0] cstate;
reg [7:0] shiftcount;
reg [DATA_WIDTH:0] shiftvalue [0:3];
reg [DATA_WIDTH:0] slavevalue;
reg slavevalid;
reg [7:0] tcnt;

assign sub_done = slavevalid;
always@(posedge clk)begin
	if(reset)begin
		SPI_CS <= 1;
		SPI_SCLK <= 0;
		SPI_MOSI <= 0;
		cstate <= IDLE;
		shiftcount <= 0;
		shiftvalue[0] <= 0;
		shiftvalue[1] <= 0;
		shiftvalue[2] <= 0;
		shiftvalue[3] <= 0;
		slavevalue <= 0;
		slavevalid <= 0;
		tcnt <= 0;
	end
	else begin
		if(clk_enable[0] | DECREASE_BYPASS)begin
			case(cstate)
			IDLE:begin
				SPI_CS <= ~sub_start;
				SPI_SCLK <= 0;
				SPI_MOSI <= 0;
				if(sub_start)begin
					cstate <= WRITE0;
					shiftcount <= DATA_WIDTH;
					shiftvalue[0] <= sub_wdata[0];
					shiftvalue[1] <= sub_wdata[1];
					shiftvalue[2] <= sub_wdata[2];
					shiftvalue[3] <= sub_wdata[3];
					tcnt <= 16;
				end
				else begin
					cstate <= IDLE;
					shiftcount <= 0;
					shiftvalue[0] <= 0;
					shiftvalue[1] <= 0;
					shiftvalue[2] <= 0;
					shiftvalue[3] <= 0;
					tcnt <= 0;
				end
				slavevalue <= 0;
				slavevalid <= 0;
			end
			WRITE0:begin
				if(shiftcount>0)begin
					SPI_CS <= 0;
					SPI_SCLK <= 0;
					SPI_MOSI[0] <= shiftvalue[0][0];
					SPI_MOSI[1] <= shiftvalue[1][0];
					SPI_MOSI[2] <= shiftvalue[2][0];
					SPI_MOSI[3] <= shiftvalue[3][0];
					shiftcount <= shiftcount - 1;
					shiftvalue[0] <= {1'b0, shiftvalue[0][DATA_WIDTH:1]};
					shiftvalue[1] <= {1'b0, shiftvalue[1][DATA_WIDTH:1]};
					shiftvalue[2] <= {1'b0, shiftvalue[2][DATA_WIDTH:1]};
					shiftvalue[3] <= {1'b0, shiftvalue[3][DATA_WIDTH:1]};
					cstate <= WRITE1;
				end
				else begin
					SPI_CS <= 0;
					SPI_SCLK <= 0;
					SPI_MOSI <= 0;
					cstate <= WAIT0;
				end
			end
			WRITE1:begin
				SPI_SCLK <= 1;
				cstate <= WRITE0;
				if(shiftcount<DATA_WIDTH)begin
					slavevalue[0] <= SPI_MISO;
					slavevalue[DATA_WIDTH:1] <= slavevalue[DATA_WIDTH-1:0];
				end
			end
			WAIT0:begin
				SPI_CS <= 1;
				SPI_SCLK <= 0;
				SPI_MOSI <= 0;
				if(tcnt>0)tcnt <= tcnt - 1;
				if(tcnt==0)begin
					slavevalid <= 1;
					cstate <= IDLE;
				end
				else begin
					slavevalid <= 0;
					cstate <= WAIT0;
				end
			end
			default:begin
				SPI_CS <= 1;
				SPI_SCLK <= 0;
				SPI_MOSI <= 0;
				cstate <= IDLE;
				shiftcount <= 0;
				shiftvalue[0] <= 0;
				shiftvalue[1] <= 0;
				shiftvalue[2] <= 0;
				shiftvalue[3] <= 0;
				slavevalue <= 0;
				slavevalid <= 0;
				tcnt <= 0;
			end
			endcase
		end
	end
end

endmodule
