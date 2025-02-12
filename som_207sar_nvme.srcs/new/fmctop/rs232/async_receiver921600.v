    `timescale 1ns/1ps

module async_receiver921600(clk, RxD, RxD_data_ready, RxD_data);
input clk, RxD;
output RxD_data_ready;  // onc clock pulse when RxD_data is valid
output [7:0] RxD_data;

//parameter ClkFreq = 50000000;	// 50MHz
//parameter Baud = 921600;
parameter BaudStep = 19327;
// Step = Baud * 2^AccWidth / ClkFreq = 19327;

// Baud generator (we use 8 times oversampling)
//parameter Baud8 = Baud*8; // Sampling rate
parameter AccWidth = 20;
wire [AccWidth:0] Baud8Step = BaudStep*8;
reg [AccWidth:0] Baud8Acc = 'd0;
always @(posedge clk) Baud8Acc <= Baud8Acc[AccWidth-1:0] + Baud8Step;
wire Baud8Tick = Baud8Acc[AccWidth];

////////////////////////////
reg [1:0] RxD_sync_inv = 'd0;
always @(posedge clk) if(Baud8Tick) RxD_sync_inv <= {RxD_sync_inv[0], ~RxD};
// we invert RxD, so that the idle becomes "0", to prevent a phantom character to be received at startup

reg [1:0] RxD_cnt_inv = 'd0;
reg RxD_bit_inv = 'd0;

always @(posedge clk)
if(Baud8Tick)
begin
	if( RxD_sync_inv[1] && RxD_cnt_inv!=2'b11) RxD_cnt_inv <= RxD_cnt_inv + 2'h1;
	else 
	if(~RxD_sync_inv[1] && RxD_cnt_inv!=2'b00) RxD_cnt_inv <= RxD_cnt_inv - 2'h1;

	if(RxD_cnt_inv==2'b00) RxD_bit_inv <= 1'b0;
	else
	if(RxD_cnt_inv==2'b11) RxD_bit_inv <= 1'b1;
end
localparam STATE_END = 4'b1010;
reg [3:0] state = 'd0;
reg [3:0] bit_spacing = 'd0;

// "next_bit" controls when the data sampling occurs
// depending on how noisy the RxD is, different values might work better
// with a clean connection, values from 8 to 11 work
wire next_bit = (bit_spacing==4'd10);

always @(posedge clk)
if(state==0)
	bit_spacing <= 4'b0000;
else
if(Baud8Tick)
	bit_spacing <= {bit_spacing[2:0] + 4'b0001} | {bit_spacing[3], 3'b000};

always @(posedge clk)
if(Baud8Tick)
case(state)
	0: if(RxD_bit_inv) state <= 1;  // start bit found?
	1: if(next_bit) state <= 2;  // bit 0
	2: if(next_bit) state <= 3;  // bit 1
	3: if(next_bit) state <= 4;  // bit 2
	4: if(next_bit) state <= 5;  // bit 3
	5: if(next_bit) state <= 6;  // bit 4
	6: if(next_bit) state <= 7;  // bit 5
	7: if(next_bit) state <= 8;  // bit 6
	//8: if(next_bit) state <= 9;  // bit 7
	8: if(next_bit) state <= 10;  // bit 7
	//9: if(next_bit) state <= 10;  // bit 8
	10: if(next_bit) state <= 0;  // stop bit
	default: state <= 0;
endcase

reg [7:0] RxD_data = 'd0;
always @(posedge clk)
if(Baud8Tick && next_bit && (state != STATE_END) && (state != 0)) RxD_data <= {~RxD_bit_inv, RxD_data[7:1]};

reg RxD_data_ready = 'd0, RxD_data_error = 'd0;
always @(posedge clk)
begin
	RxD_data_ready <= (Baud8Tick && next_bit && state==STATE_END && ~RxD_bit_inv);  // ready only if the stop bit is received
	RxD_data_error <= (Baud8Tick && next_bit && state==STATE_END &&  RxD_bit_inv);  // error if the stop bit is not received
end

endmodule