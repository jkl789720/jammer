
// change cfg_wr_addr/cfg_wr_addr to 12bit for fitting 4KB range
`define BASE_DEEP_FIFO 16'h0000

module register_set_deepfifo(
output reg [31:0] cfg_deepfifo_ctrl,
input      [31:0] cfg_deepfifo_status,
input      [31:0] cfg_deepfifo_max_depth,
input      [31:0] cfg_deepfifo_nonbypass_data_L,
input      [31:0] cfg_deepfifo_nonbypass_data_H,
input      [31:0] cfg_deepfifo_total_data_L,
input      [31:0] cfg_deepfifo_total_data_H,
input      [31:0] cfg_deepfifo_status7,
input      [31:0] cfg_deepfifo_status8,

input 				cfg_clk,
input 				cfg_rst,
input  [11:0] 		cfg_wr_addr,
input  [31:0] 		cfg_wr_dat,
input 				cfg_wr_en,
input [11:0] 		cfg_rd_addr,
output reg [31:0] 	cfg_rd_dat,
input 				cfg_rd_en
);

(* max_fanout=50 *)reg [11:0] cfg_rd_addr_r1;
always@(posedge cfg_clk)cfg_rd_addr_r1 <= cfg_rd_addr;
(* max_fanout=100 *)reg cfg_rst_r1;
always@(posedge cfg_clk)cfg_rst_r1 <= cfg_rst;
reg [31:0] cfg_deepfifo_status_r1;
reg [31:0] cfg_deepfifo_max_depth_r1;
reg [31:0] cfg_deepfifo_nonbypass_data_L_r1;
reg [31:0] cfg_deepfifo_nonbypass_data_H_r1;
reg [31:0] cfg_deepfifo_total_data_L_r1;
reg [31:0] cfg_deepfifo_total_data_H_r1;
reg [31:0] cfg_deepfifo_status7_r1;
reg [31:0] cfg_deepfifo_status8_r1;

always@(posedge cfg_clk)begin
	case(cfg_rd_addr_r1)
		`BASE_DEEP_FIFO+16'h00:cfg_rd_dat <= cfg_deepfifo_ctrl;
		`BASE_DEEP_FIFO+16'h04:cfg_rd_dat <= cfg_deepfifo_status_r1;
		`BASE_DEEP_FIFO+16'h08:cfg_rd_dat <= cfg_deepfifo_max_depth_r1;
		`BASE_DEEP_FIFO+16'h0C:cfg_rd_dat <= cfg_deepfifo_nonbypass_data_L_r1;
		`BASE_DEEP_FIFO+16'h10:cfg_rd_dat <= cfg_deepfifo_nonbypass_data_H_r1;
		`BASE_DEEP_FIFO+16'h14:cfg_rd_dat <= cfg_deepfifo_total_data_L_r1;
		`BASE_DEEP_FIFO+16'h18:cfg_rd_dat <= cfg_deepfifo_total_data_H_r1;
		`BASE_DEEP_FIFO+16'h1C:cfg_rd_dat <= cfg_deepfifo_status7_r1;
		`BASE_DEEP_FIFO+16'h20:cfg_rd_dat <= cfg_deepfifo_status8_r1;
		default:cfg_rd_dat <= 32'h0A0A_0A0A;
    endcase
end

always@(posedge cfg_clk)begin
    if(cfg_rst_r1)begin
		cfg_deepfifo_ctrl <= 0;
		//cfg_deepfifo_status <= 0;
		//cfg_deepfifo_max_depth <= 0;
		//cfg_deepfifo_nonbypass_data_L <= 0;
		//cfg_deepfifo_nonbypass_data_H <= 0;
		//cfg_deepfifo_total_data_L <= 0;
		//cfg_deepfifo_total_data_H <= 0;
		//cfg_deepfifo_status7 <= 0;
		//cfg_deepfifo_status8 <= 0;
    end
    else begin
        if (cfg_wr_en)begin
            case(cfg_wr_addr)
				`BASE_DEEP_FIFO+16'h00:cfg_deepfifo_ctrl <= cfg_wr_dat;
				//`BASE_DEEP_FIFO+16'h04:cfg_deepfifo_status <= cfg_wr_dat;
				//`BASE_DEEP_FIFO+16'h08:cfg_deepfifo_max_depth <= cfg_wr_dat;
				//`BASE_DEEP_FIFO+16'h0C:cfg_deepfifo_nonbypass_data_L <= cfg_wr_dat;
				//`BASE_DEEP_FIFO+16'h10:cfg_deepfifo_nonbypass_data_H <= cfg_wr_dat;
				//`BASE_DEEP_FIFO+16'h14:cfg_deepfifo_total_data_L <= cfg_wr_dat;
				//`BASE_DEEP_FIFO+16'h18:cfg_deepfifo_total_data_H <= cfg_wr_dat;
				//`BASE_DEEP_FIFO+16'h1C:cfg_deepfifo_status7 <= cfg_wr_dat;
				//`BASE_DEEP_FIFO+16'h20:cfg_deepfifo_status8 <= cfg_wr_dat;
		        default:begin
                end
            endcase
        end
    end
end


always@(posedge cfg_clk)begin
    if(cfg_rst_r1)begin
		 cfg_deepfifo_status_r1 <= 0;
		 cfg_deepfifo_max_depth_r1 <= 0;
		 cfg_deepfifo_nonbypass_data_L_r1 <= 0;
		 cfg_deepfifo_nonbypass_data_H_r1 <= 0;
		 cfg_deepfifo_total_data_L_r1 <= 0;
		 cfg_deepfifo_total_data_H_r1 <= 0;
		 cfg_deepfifo_status7_r1 <= 0;
		 cfg_deepfifo_status8_r1 <= 0;

    end
    else begin
		 cfg_deepfifo_status_r1 <= cfg_deepfifo_status;
		 cfg_deepfifo_max_depth_r1 <= cfg_deepfifo_max_depth;
		 cfg_deepfifo_nonbypass_data_L_r1 <= cfg_deepfifo_nonbypass_data_L;
		 cfg_deepfifo_nonbypass_data_H_r1 <= cfg_deepfifo_nonbypass_data_H;
		 cfg_deepfifo_total_data_L_r1 <= cfg_deepfifo_total_data_L;
		 cfg_deepfifo_total_data_H_r1 <= cfg_deepfifo_total_data_H;
		 cfg_deepfifo_status7_r1 <= cfg_deepfifo_status7;
		 cfg_deepfifo_status8_r1 <= cfg_deepfifo_status8;

    end
end
endmodule
