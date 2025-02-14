`timescale 1ns / 1ps
module fft_config(
    input                   adc_clk                 ,
    input                   resetn                  ,
    input                   change_eq               ,
    input      [31:0]       proc_length             ,
    input                   s_axis_config_tready    ,
    output reg [23 : 0]     s_axis_config_tdata     ,
    output                  s_axis_config_tvalid    
    );

    //上电配置一下
    reg [31:0] cnt_init=100;

    //fft模式(2048还是8192个点)
    reg fft_num_mode;

    //请求处理信号
    wire change_eq_pos,change_response;
    reg change_pending;
    wire change_eq_total;
    reg [2:0] change_eq_total_r;
    wire change_eq_init;

    //上电配置逻辑生成
    always @(posedge adc_clk) begin
        if(cnt_init != 0)
            cnt_init <= cnt_init - 1;
        else 
            cnt_init <=  cnt_init;
    end

    //合并请求信号
    assign change_eq_init  =  (cnt_init !=0);
    assign change_eq_total = change_eq;

    //检测请求信号上升沿
    always@(posedge adc_clk)begin
        if(!resetn)begin
            change_eq_total_r <= 0;
        end
        else begin
            change_eq_total_r <= {change_eq_total_r[1:0],change_eq_total};
        end
    end
    assign change_eq_pos = (~change_eq_total_r[2]) && (change_eq_total_r[1]);

    //根据上升沿生成挂起信号
    always @(posedge adc_clk) begin
        if(!resetn)
            change_pending <= 0;
        else if(change_eq_pos)
            change_pending <= 1;
        else if(change_response)
            change_pending <= 0;
    end

    //响应请求
    assign change_response = change_pending && s_axis_config_tready;
    assign s_axis_config_tvalid = change_response;

    //根据处理信号长度确定fft模式
    always@(*)begin
        if(!resetn)
            fft_num_mode = 0;
        else if(proc_length == 1024)
            fft_num_mode = 0;
        else if(proc_length == 4096)
            fft_num_mode = 1;
        else
            fft_num_mode = 0;
    end

    //根据fft模式设置fft点数
    always@(*)begin
        if(!resetn)
            s_axis_config_tdata = {8'b0,8'b1,8'b01011};
        else begin
            case (fft_num_mode)
                0: s_axis_config_tdata = {8'b0,8'b1,8'b01011};
                1: s_axis_config_tdata = {8'b0,8'b1,8'b01101};
                default: s_axis_config_tdata = {8'b0,8'b1,8'b01011};
            endcase
        end
    end

    `ifdef DISTURB_DEBUG
        ila_fft_config u_ila_fft_config(
        .clk      (adc_clk                              ),
        .probe0   (s_axis_config_tready                 ),  //1
        .probe1   (s_axis_config_tvalid                 ),  //256
        .probe2   (s_axis_config_tdata                  )  //1
        );
    `endif

endmodule
