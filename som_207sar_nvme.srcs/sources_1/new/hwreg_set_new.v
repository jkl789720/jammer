`define PARAM_WRITE 16'h0000
`define PARAM_READ  16'h0060

`define ID_ADDR 16'h0080
`define ID_NUM_TEST 98

module hwreg_set_new(
// input      			resetn_vio	,
input      [31:0]   app_status0  ,
input      [31:0]   app_status1  ,
input      [31:0]   app_status2  ,
input      [31:0]   app_status3  ,
input      [31:0]   app_status4  ,
input      [31:0]   app_status5  ,
input      [31:0]   app_status6  ,
input      [31:0]   app_status7  ,
input      [31:0]   app_status8  ,
input      [31:0]   app_status9  ,
input      [31:0]   app_status10 ,
input      [31:0]   app_status11 ,

output reg [31:0]   app_param0   ,
output reg [31:0]   app_param1   ,
output reg [31:0]   app_param2   ,
output reg [31:0]   app_param3   ,
output reg [31:0]   app_param4   ,
output reg [31:0]   app_param5   ,
output reg [31:0]   app_param6   ,
output reg [31:0]   app_param7   ,
output reg [31:0]   app_param8   ,
output reg [31:0]   app_param9   ,
output reg [31:0]   app_param10  ,
output reg [31:0]   app_param11  ,
output reg [31:0]   app_param12  ,
output reg [31:0]   app_param13  ,
output reg [31:0]   app_param14  ,
output reg [31:0]   app_param15  ,
output reg [31:0]   app_param16  ,
output reg [31:0]   app_param17  ,
output reg [31:0]   app_param18  ,
output reg [31:0]   app_param19  ,
output reg [31:0]   app_param20  ,
output reg [31:0]   app_param21  ,
output reg [31:0]   app_param22  ,



input 				cfg_clk     ,
input 				cfg_rd_en   ,
input 				cfg_wr_en   ,
input      [11:0] 	cfg_wr_addr ,
input      [11:0]   cfg_rd_addr ,
input      [31:0] 	cfg_wr_dat  ,
output reg [31:0] 	cfg_rd_dat  ,
input 				cfg_rst     
);

// ila_ram_reg u_ila_ram_reg (
// 	.clk	(cfg_clk		), // input wire clk
// 	.probe0	(cfg_rd_en		), // input wire [0:0]  probe0  
// 	.probe1	(cfg_rd_addr	), // input wire [11:0]  probe1 
// 	.probe2	(cfg_rd_dat		), // input wire [31:0]  probe2 
// 	.probe3	(app_status0	) // input wire [31:0]  probe3
// );

(* max_fanout=50 *)reg [11:0] cfg_rd_addr_r1;
always@(posedge cfg_clk)begin
		cfg_rd_addr_r1 <= cfg_rd_addr;
end
(* max_fanout=100 *)reg resetn_r1;
always@(posedge cfg_clk)resetn_r1 <= cfg_rst;

reg  [11:0] 		cfg_wr_addr_r;
reg  [31:0] 		cfg_wr_dat_r;
reg 				cfg_wr_en_r;
always@(posedge cfg_clk)cfg_wr_addr_r <= cfg_wr_addr;
always@(posedge cfg_clk)cfg_wr_dat_r <= cfg_wr_dat;
always@(posedge cfg_clk)cfg_wr_en_r <= cfg_wr_en;


reg [31:0] app_status0_r ;
reg [31:0] app_status1_r ;
reg [31:0] app_status2_r ;
reg [31:0] app_status3_r ;
reg [31:0] app_status4_r ;
reg [31:0] app_status5_r ;
reg [31:0] app_status6_r ;
reg [31:0] app_status7_r ;
reg [31:0] app_status8_r ;
reg [31:0] app_status9_r ;
reg [31:0] app_status10_r;
reg [31:0] app_status11_r;

always@(posedge cfg_clk)begin
	case(cfg_rd_addr_r1)
		`PARAM_READ+16'h00:cfg_rd_dat <= app_status0_r ;
		`PARAM_READ+16'h04:cfg_rd_dat <= app_status1_r ;
		`PARAM_READ+16'h08:cfg_rd_dat <= app_status2_r ;
		`PARAM_READ+16'h0C:cfg_rd_dat <= app_status3_r ;
		`PARAM_READ+16'h10:cfg_rd_dat <= app_status4_r ;
		`PARAM_READ+16'h14:cfg_rd_dat <= app_status5_r ;
		`PARAM_READ+16'h18:cfg_rd_dat <= app_status6_r ;
		`PARAM_READ+16'h1C:cfg_rd_dat <= app_status7_r ;
		`PARAM_READ+16'h20:cfg_rd_dat <= app_status8_r ;
		`PARAM_READ+16'h24:cfg_rd_dat <= app_status9_r ;
		`PARAM_READ+16'h28:cfg_rd_dat <= app_status10_r;
		`PARAM_READ+16'h2C:cfg_rd_dat <= app_status11_r;
		
		`PARAM_WRITE+16'h00:cfg_rd_dat <= app_param0;
		`PARAM_WRITE+16'h04:cfg_rd_dat <= app_param1;
		`PARAM_WRITE+16'h08:cfg_rd_dat <= app_param2;
		`PARAM_WRITE+16'h0C:cfg_rd_dat <= app_param3;
		`PARAM_WRITE+16'h10:cfg_rd_dat <= app_param4;
		`PARAM_WRITE+16'h14:cfg_rd_dat <= app_param5;
		`PARAM_WRITE+16'h18:cfg_rd_dat <= app_param6;
		`PARAM_WRITE+16'h1C:cfg_rd_dat <= app_param7;
		`PARAM_WRITE+16'h20:cfg_rd_dat <= app_param8;
		`PARAM_WRITE+16'h24:cfg_rd_dat <= app_param9;
		`PARAM_WRITE+16'h28:cfg_rd_dat <= app_param10;
		`PARAM_WRITE+16'h2C:cfg_rd_dat <= app_param11;
		`PARAM_WRITE+16'h30:cfg_rd_dat <= app_param12;
		`PARAM_WRITE+16'h34:cfg_rd_dat <= app_param13;
		`PARAM_WRITE+16'h38:cfg_rd_dat <= app_param14;
		`PARAM_WRITE+16'h3C:cfg_rd_dat <= app_param15;
		`PARAM_WRITE+16'h40:cfg_rd_dat <= app_param16;
		`PARAM_WRITE+16'h44:cfg_rd_dat <= app_param17;
		`PARAM_WRITE+16'h48:cfg_rd_dat <= app_param18;
		`PARAM_WRITE+16'h4C:cfg_rd_dat <= app_param19;
		`PARAM_WRITE+16'h50:cfg_rd_dat <= app_param20;
		`PARAM_WRITE+16'h54:cfg_rd_dat <= app_param21;
		`PARAM_WRITE+16'h58:cfg_rd_dat <= app_param22;

		`ID_ADDR+16'h00		   :cfg_rd_dat <= 88;
		`ID_ADDR+16'h04		   :cfg_rd_dat <= 99;


		default:cfg_rd_dat <= 32'h0A0A_0A0A;
    endcase
end

always@(posedge cfg_clk)begin
    if(resetn_r1)begin
		app_param0  <= 0;
		app_param1  <= 0;
		app_param2  <= 0;
		app_param3  <= 0;
		app_param4  <= 0;
		app_param5  <= 0;
		app_param6  <= 0;
		app_param7  <= 0;
		app_param8  <= 0;
		app_param9  <= 0;
		app_param10 <= 0;
		app_param11 <= 0;
		app_param12 <= 0;
		app_param13 <= 0;
		app_param14 <= 0;
		app_param15 <= 0;
		app_param16 <= 0;
		app_param17 <= 0;
		app_param18 <= 0;
		app_param19 <= 0;
		app_param20 <= 0;
		app_param21 <= 0;
		app_param22 <= 0;
    end
    else begin
        if (cfg_wr_en_r)begin
            case(cfg_wr_addr_r)
				`PARAM_WRITE+16'h00:app_param0  <= cfg_wr_dat_r;
				`PARAM_WRITE+16'h04:app_param1  <= cfg_wr_dat_r;
				`PARAM_WRITE+16'h08:app_param2  <= cfg_wr_dat_r;
				`PARAM_WRITE+16'h0C:app_param3  <= cfg_wr_dat_r;
				`PARAM_WRITE+16'h10:app_param4  <= cfg_wr_dat_r;
				`PARAM_WRITE+16'h14:app_param5  <= cfg_wr_dat_r;
				`PARAM_WRITE+16'h18:app_param6  <= cfg_wr_dat_r;
				`PARAM_WRITE+16'h1C:app_param7  <= cfg_wr_dat_r;
				`PARAM_WRITE+16'h20:app_param8  <= cfg_wr_dat_r;
				`PARAM_WRITE+16'h24:app_param9  <= cfg_wr_dat_r;
				`PARAM_WRITE+16'h28:app_param10 <= cfg_wr_dat_r;
				`PARAM_WRITE+16'h2C:app_param11 <= cfg_wr_dat_r;
				`PARAM_WRITE+16'h30:app_param12 <= cfg_wr_dat_r;
				`PARAM_WRITE+16'h34:app_param13 <= cfg_wr_dat_r;
				`PARAM_WRITE+16'h38:app_param14 <= cfg_wr_dat_r;
				`PARAM_WRITE+16'h3C:app_param15 <= cfg_wr_dat_r;
				`PARAM_WRITE+16'h40:app_param16 <= cfg_wr_dat_r;
				`PARAM_WRITE+16'h44:app_param17 <= cfg_wr_dat_r;
				`PARAM_WRITE+16'h48:app_param18 <= cfg_wr_dat_r;
				`PARAM_WRITE+16'h4C:app_param19 <= cfg_wr_dat_r;
				`PARAM_WRITE+16'h50:app_param20 <= cfg_wr_dat_r;
				`PARAM_WRITE+16'h54:app_param21 <= cfg_wr_dat_r;
				`PARAM_WRITE+16'h58:app_param22 <= cfg_wr_dat_r;

		        default:begin
                end
            endcase
        end
    end
end


always@(posedge cfg_clk)begin
    if(resetn_r1)begin
		app_status0_r  <= 0;
        app_status1_r  <= 0;
        app_status2_r  <= 0;
        app_status3_r  <= 0;
        app_status4_r  <= 0;
        app_status5_r  <= 0;
        app_status6_r  <= 0;
        app_status7_r  <= 0;
        app_status8_r  <= 0;
        app_status9_r  <= 0;
        app_status10_r <= 0;
        app_status11_r <= 0;
    end
    else begin
        app_status0_r  <= app_status0 ;
        app_status1_r  <= app_status1 ;
        app_status2_r  <= app_status2 ;
        app_status3_r  <= app_status3 ;
        app_status4_r  <= app_status4 ;
        app_status5_r  <= app_status5 ;
        app_status6_r  <= app_status6 ;
        app_status7_r  <= app_status7 ;
        app_status8_r  <= app_status8 ;
        app_status9_r  <= app_status9 ;
        app_status10_r <= app_status10;
        app_status11_r <= app_status11;
    end
end



endmodule
