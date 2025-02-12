module Cmd_reg(
    input   clk,
    input   rst_n,

    input           set_addr        ,
    input           set_speed       ,
    input   [31:0]  set_data_1      ,
    input   [1:0]   set_data_2      ,
    input           op_en           ,
    input   [5:0]   brust_sta       ,

    output          set_addr_vld    ,
    output          set_speed_vld   ,
    output  [31:0]  set_data1_vld   ,
    output  [1:0]   set_data2_vld    
);
    reg         set_addr_reg   ;
    reg         set_speed_reg  ;
    reg [31:0]  set_data1_reg  ;
    reg  [1:0]  set_data2_reg  ;
    reg         edge_cnt       ;
    reg         open1          ;
    reg         open2          ;
    wire        open_pdge      ;
    wire        open_ndge      ;

    always @(posedge clk or negedge rst_n)begin
        if(!rst_n)begin
            open1 <= 1;
            open2 <= 1;
        end
        else begin
            open1 <= op_en;
            open2 <= open1;
        end
    end
    assign open_pdge = ~open2 & open1;
    assign open_ndge = ~open1 & open2;

    assign  set_addr_vld  = (open_ndge & ~edge_cnt) ? set_addr_reg  : (open_pdge & ~edge_cnt) ? set_addr_reg  : op_en ?  set_addr    : 0 ;
    assign  set_speed_vld = (open_ndge & ~edge_cnt) ? set_speed_reg : (open_pdge & ~edge_cnt) ? set_speed_reg : op_en ?  set_speed   : 0 ;
    assign  set_data1_vld = (open_ndge & ~edge_cnt) ? set_data1_reg : (open_pdge & ~edge_cnt) ? set_data1_reg : op_en ?  set_data_1  : 0 ;
    assign  set_data2_vld = (open_ndge & ~edge_cnt) ? set_data2_reg : (open_pdge & ~edge_cnt) ? set_data2_reg : op_en ?  set_data_2  : 0 ;
   
   always @(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        set_addr_reg  <= 0;
        set_speed_reg <= 0;
        set_data1_reg <= 0;
        set_data2_reg <= 0;
    end
    else if(set_addr)begin
        if(set_addr ^ op_en)begin
            set_addr_reg  <= set_addr   ;
            set_data1_reg <= set_data_1 ;
        end
    end
    else if(set_speed)begin
        if(set_speed ^ op_en)begin
            set_speed_reg  <= set_speed ;
            set_data2_reg <= set_data_2 ;
        end
    end
    else if(brust_sta[5] || brust_sta[3])begin
        set_addr_reg  <= 0;
        set_speed_reg <= 0;
    end
end
    
    always @(posedge clk or negedge rst_n)begin
        if(!rst_n)
            edge_cnt <= 0;
        else if(open_ndge || open_pdge)
            edge_cnt <= 1;
        else if(brust_sta[2:0])
            edge_cnt <= 0;
    end
endmodule