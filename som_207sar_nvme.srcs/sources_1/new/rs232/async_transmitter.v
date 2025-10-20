`timescale 1ns/1ps

module async_transmitter(clk, TxD_start, TxD_data, TxD, TxD_busy);
input clk, TxD_start;
input [8:0] TxD_data;
output TxD, TxD_busy;


//parameter ClkFreq = 50000000;	// 50MHz
//parameter Baud = 115200;
parameter RegisterInputData = 1;	// in RegisterInputData mode, the input doesn't have to stay valid while the character is been transmitted
parameter BaudStep = 151;
// Step = Baud * 2^AccWidth / ClkFreq = 150.994 ¡Ö 151;

// Baud generator
parameter AccWidth = 16;
reg [AccWidth:0] Acc = 'd0;
wire [AccWidth:0] Step = BaudStep; 

wire BaudTick = Acc[AccWidth];
wire TxD_busy;
always @(posedge clk) if(TxD_busy) Acc <= Acc[AccWidth-1:0] + Step;

// Transmitter state_tx232 machine
reg [4:0] state_tx232 = 'd0;
wire TxD_ready = (state_tx232==0);
assign TxD_busy = ~TxD_ready;

reg [8:0] TxD_dataReg = 'd0;
always @(posedge clk) if(TxD_ready & TxD_start) TxD_dataReg <= TxD_data;
wire [8:0] TxD_dataD = RegisterInputData ? TxD_dataReg : TxD_data;

always @(posedge clk)
case(state_tx232)
	5'b00000: if(TxD_start) state_tx232 <= 5'b00001;
	5'b00001: if(BaudTick) state_tx232 <= 5'b00100;
	5'b00100: if(BaudTick) state_tx232 <= 5'b10000;  // start
	5'b10000: if(BaudTick) state_tx232 <= 5'b10001;  // bit 0
	5'b10001: if(BaudTick) state_tx232 <= 5'b10010;  // bit 1
	5'b10010: if(BaudTick) state_tx232 <= 5'b10011;  // bit 2
	5'b10011: if(BaudTick) state_tx232 <= 5'b10100;  // bit 3
	5'b10100: if(BaudTick) state_tx232 <= 5'b10101;  // bit 4
	5'b10101: if(BaudTick) state_tx232 <= 5'b10110;  // bit 5
	5'b10110: if(BaudTick) state_tx232 <= 5'b10111;  // bit 6
	//5'b10111: if(BaudTick) state_tx232 <= 5'b11000;  // bit 7
	5'b10111: if(BaudTick) state_tx232 <= 5'b00010;  // bit 7
	//5'b11000: if(BaudTick) state_tx232 <= 5'b00010;  // bit 8
	5'b00010: if(BaudTick) state_tx232 <= 5'b00000;  // stop1
	default: if(BaudTick) state_tx232 <= 5'b00000;
endcase

// Output mux
reg muxbit = 'd0;
always @( * )
case(state_tx232[3:0])
	4'd0: muxbit <= TxD_dataD[0];
	4'd1: muxbit <= TxD_dataD[1];
	4'd2: muxbit <= TxD_dataD[2];
	4'd3: muxbit <= TxD_dataD[3];
	4'd4: muxbit <= TxD_dataD[4];
	4'd5: muxbit <= TxD_dataD[5];
	4'd6: muxbit <= TxD_dataD[6];
	4'd7: muxbit <= TxD_dataD[7];
	4'd8: muxbit <= TxD_dataD[8];
endcase

// Put together the start, data and stop bits
reg TxD = 'd0;
always @(posedge clk) TxD <= (state_tx232<4) | ((state_tx232[4] | state_tx232[3]) & muxbit);  // register the output to make it glitch free

endmodule