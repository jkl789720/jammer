module send_rf_cmd(
input clk,      // 50MHz
input reset, 

input set_en,
input [31:0] set_dat,

output uart_tx
);

// tx side
wire TxD_busy;
reg send_start;
reg [8:0] TxD_data;
async_transmitter async_transmitter232 (
	.clk(clk), 
	.TxD(uart_tx), 
	.TxD_start(send_start), 
	.TxD_data(TxD_data), 
	.TxD_busy(TxD_busy)
);

localparam INTERVAL = 5000; // 20ns*5000 = 100us
reg [15:0] tcnt;
reg [31:0] set_dat_r;
always@(posedge clk)begin
    if(reset)begin
        tcnt <= 16'hFFFF;
        set_dat_r <= 0;
    end
    else begin
        if(set_en)tcnt <= 0;
        else if(tcnt < 16'hFFFF)tcnt <= tcnt + 1;
        
        if(set_en)set_dat_r <= set_dat;
        
        if(tcnt==0)begin
            send_start <= 1;
            TxD_data <= 8'hEB;
        end
        else if(tcnt==(1*INTERVAL))begin
            send_start <= 1;
            TxD_data <= 8'h90;
        end
        else if(tcnt==(2*INTERVAL))begin
            send_start <= 1;
            TxD_data <= set_dat_r[7:0] & 8'h3F;
        end
        else if(tcnt==(3*INTERVAL))begin
            send_start <= 1;
            TxD_data <= set_dat_r[7:0] & 8'h3F;
        end
        else if(tcnt==(4*INTERVAL))begin
            send_start <= 1;
            TxD_data <= set_dat_r[15:8] & 8'h3F;
        end
        else if(tcnt==(5*INTERVAL))begin
            send_start <= 1;
            TxD_data <= set_dat_r[15:8] & 8'h3F;
        end
        else if(tcnt==(6*INTERVAL))begin
            send_start <= 1;
            TxD_data <= 8'hF0;
        end
        else if(tcnt==(7*INTERVAL))begin
            send_start <= 1;
            TxD_data <= 8'hAA;
        end    
        else send_start <= 0;
    end
end

endmodule
