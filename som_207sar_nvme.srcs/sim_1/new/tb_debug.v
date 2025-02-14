`timescale 1ns / 1ps
module tb_debug#(
    parameter LOCAL_DWIDTH 	= 256,
    parameter WIDTH         = 32  ,
    parameter LANE_NUM      = 8   ,
    parameter CHIRP_NUM     = 256
)();

reg sys_clk_p,resetn;
wire sys_clk_n;
initial begin
    sys_clk_p     <= 0;
    resetn      <= 0;
    #200
    resetn      <= 1;
end

always #1.666666666666 sys_clk_p=~sys_clk_p;
assign sys_clk_n = ~sys_clk_p;

debug#(
    . LOCAL_DWIDTH (LOCAL_DWIDTH) ,
    . WIDTH        (WIDTH       ) ,
    . LANE_NUM     (LANE_NUM    ) ,
    . CHIRP_NUM    (CHIRP_NUM   ) 
)
u_debug(
    . sys_clk_p   (sys_clk_p  ),
    . sys_clk_n   (sys_clk_n  ),
    . resetn      (resetn     ),
    . dac_valid   (dac_valid  )
);

endmodule
