module gps_wrap
#(
parameter MSG_LEN = 24+12+8
)(
input clk,
input reset, 

input       uart_rx,

output [MSG_LEN*8-1:0]  msg_dat,
output [2:0]            msg_stat,
output                  msg_en
);

// rx side
(* KEEP="TRUE" *)wire rx_valid;
(* KEEP="TRUE" *)wire [7:0] rx_data;
async_receiver115200	RS232_async_receiver
(		
	.clk              (clk), 
	.RxD              (uart_rx), 
	.RxD_data_ready   (rx_valid), 
	.RxD_data         (rx_data)
);


gps_module 
#(
.MSG_LEN(MSG_LEN)
)
gps_module_EP0(
.clk(clk),    //input 
.reset(reset),    //input 
.rx_valid(rx_valid),    //input 
.rx_data(rx_data),    //input [7:0]
.msg_dat(msg_dat),    //output [MSG_LEN*8-1:0]
.msg_stat(msg_stat),    //output [2:0]
.msg_en(msg_en)    //output 
);

`ifndef BYPASS_ALLSCOPE
ila_gps ila_gps_ep0(
.clk(clk),
.probe0(uart_rx),
.probe1(rx_valid),
.probe2(rx_data),
.probe3(msg_en),
.probe4(msg_stat),
.probe5(msg_dat)
);
`endif
endmodule
