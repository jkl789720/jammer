module imu_wrap
(
input clk,
input reset, 

input       uart_rx,

output [107*8-1:0]  imu_dat,
output             imu_stat,
output             imu_en
);

// rx side
(* KEEP="TRUE" *)wire rx_valid;
(* KEEP="TRUE" *)wire [7:0] rx_data;
async_receiver921600	RS232_async_receiver
(		
	.clk              (clk), 
	.RxD              (uart_rx), 
	.RxD_data_ready   (rx_valid), 
	.RxD_data         (rx_data)
);


imu_resolve imu_resolve_EP0(
.clk(clk),    //input 
.reset(reset),    //input 
.rx_valid(rx_valid),    //input 
.rx_data(rx_data),    //input [7:0]
.out_dat(imu_dat),    //output [DAT_LEN*8-1:0]
.out_en(imu_en),    //output 
.out_stat(imu_stat)    //output 
);

`ifndef BYPASS_ALLSCOPE
ila_imu ila_imu_ep0(
.clk(clk),
.probe0(uart_rx),
.probe1(rx_valid),
.probe2(rx_data),
.probe3(imu_en),
.probe4(imu_stat),
.probe5(imu_dat)
);
`endif
endmodule
