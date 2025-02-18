module bc_mode(
input       sys_clk    ,
input       sys_rst    ,
   

input       trt_o      ,
input       trr_o      ,

input       sel_param  ,


output reg  trt_o_p_0  ,
output reg  trr_o_p_0  ,
output reg  trt_o_p_1  ,
output reg  trr_o_p_1  ,
output reg  trt_o_p_2  ,
output reg  trr_o_p_2  ,
output reg  trt_o_p_3  ,
output reg  trr_o_p_3 

);

reg [1:0] sel_dff;
always @(posedge sys_clk) begin
    if(sys_rst)
        sel_dff <= 0;
    else
        sel_dff <= {sel_dff[0],sel_param};
end

always @(posedge sys_clk) begin
    if(sys_rst)begin
        trt_o_p_0 = 0 ;
        trr_o_p_0 = 0 ;

        trt_o_p_1 = 0 ;
        trr_o_p_1 = 0 ;

        trt_o_p_2 = 0 ;
        trr_o_p_2 = 0 ;

        trt_o_p_3 = 0 ;
        trr_o_p_3 = 0 ;
    end
    else begin
        begin
            trt_o_p_0 = sel_dff[1] == 1 ? trt_o : 0 ;//干扰机V极化
            trr_o_p_0 = sel_dff[1] == 1 ? trr_o : 0 ;//干扰机V极化
            trt_o_p_1 = sel_dff[1] == 1 ? trt_o : 0 ;//干扰机V极化
            trr_o_p_1 = sel_dff[1] == 1 ? trr_o : 0 ;//干扰机V极化

            trt_o_p_2 = sel_dff[1] == 1 ? 0 : trt_o ;//干扰机H极化
            trr_o_p_2 = sel_dff[1] == 1 ? 0 : trr_o ;//干扰机H极化
            trt_o_p_3 = sel_dff[1] == 1 ? 0 : trt_o ;//干扰机H极化
            trr_o_p_3 = sel_dff[1] == 1 ? 0 : trr_o ;//干扰机H极化
        end
    end

end

endmodule