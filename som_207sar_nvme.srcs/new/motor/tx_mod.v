module tx_mod(
    input       clk             ,
    input       rst_n           ,
    
    output  reg tx              ,
    output      ready           ,
    output      busy            ,
    input [2:0] idle_cg         ,
    input       mod_en_ndge     ,
    input       turn_en_ndge    ,
    input       close_en_ndge   ,
    output reg  rs485_en        ,
    input [7:0] dout            ,
    input       dvld            ,
    output      end_twait
);
    parameter band = 434;   //band:115200   50mhz/band
    reg [10:0]  data        ;
    reg [7:0]   data_reg    ;
    reg         open_twait  ;
    reg         init        ;
    wire        end_init    ;
    reg [8:0]   cnt_band    ;
    wire        add_band    ;
    wire        end_band    ;
    reg [3:0]   cnt_bit     ;
    wire        add_bit     ;
    wire        end_bit     ;
    reg [3:0]   odd         ;
    reg         init_1      ;
    reg         init_2      ;
    wire        init_ndge   ;
    wire        add_odd     ;
//t1.5
    reg [11:0]  cnt_1       ;
    wire        add_cnt_1   ;
    wire        end_cnt_1   ;
    reg         cnt_1_op    ;
    
      always @(posedge clk or negedge rst_n)begin
        if(!rst_n)
            cnt_1_op <= 0;
        else if(end_bit)
            cnt_1_op <= 1;
        else if(end_cnt_1)
            cnt_1_op <= 0;
    end
    always @(posedge clk or negedge rst_n)begin
        if(!rst_n)
            cnt_1 <= 0;
        else if(add_cnt_1)begin
            if(end_cnt_1)
                cnt_1 <= 0;
            else
                cnt_1 <= cnt_1 + 1;
        end
        else
            cnt_1 <= cnt_1;
    end
    assign add_cnt_1 = cnt_1_op;
    assign end_cnt_1 = add_cnt_1 & cnt_1 == 'd3471;
//t2
    reg [14:0]  twait       ;
    wire        add_twait   ;
    reg         twait_cnt   ;

    always @(posedge clk or negedge rst_n)begin
        if(!rst_n)
            open_twait <= 0;
        else if(idle_cg || end_bit || mod_en_ndge || turn_en_ndge || close_en_ndge) 
            open_twait <= 1;
        else if(end_twait || dvld)
            open_twait <= 0;
        else
            open_twait <= open_twait;
    end
    
    always @(posedge clk or negedge rst_n)begin
        if(!rst_n)
            twait <= 0;
        else if(dvld)
            twait <= 0;
        else if(add_twait)begin
            if(end_twait)
                twait <= 0;
            else 
                twait <= twait + 1;
        end
        else if(end_init)begin
            twait <= 0;
        end
        else
            twait <= twait;
    end
    assign add_twait = open_twait;
    assign end_twait = twait == 17000 - 1'd1;
    
    always @(posedge clk or negedge rst_n)begin
        if(!rst_n)
            twait_cnt <= 0;
        else if(end_twait)
            twait_cnt <= twait_cnt + 1;
        else if(end_init)
            twait_cnt <= 0;
    end
///////////////////////////

   always @(posedge clk or negedge rst_n)begin
       if(!rst_n)
           rs485_en <= 0;
       else if(idle_cg || mod_en_ndge || turn_en_ndge || close_en_ndge)
           rs485_en <= 1;
       else if(init_ndge)
           rs485_en <= 0;
       else
           rs485_en <= rs485_en ;
   end

    always @(posedge clk or negedge rst_n)begin
        if(!rst_n)
            init <= 0 ;
        else if(dvld)
            init <= 1 ;
        else if(end_init)
            init <= 0;
        else
            init <= init;
    end
    assign end_init = end_twait && twait_cnt;

    always @(posedge clk or negedge rst_n)begin
        if(!rst_n)begin
            init_1 <= 0;
            init_2 <= 0;
        end
        else
            init_1 <= init;
            init_2 <= init_1;
    end
    assign init_ndge = ~init_1 & init_2;

    always @(posedge clk or negedge rst_n)begin
        if(!rst_n)
            cnt_band <= 0;
        else if(open_twait || add_cnt_1)
            cnt_band <= 0;
        else if(add_band)begin
            if(end_band)
                cnt_band <= 0;
            else
                cnt_band <= cnt_band + 1;
        end
        else
            cnt_band <= cnt_band;
    end
    assign add_band = init;
    assign end_band = add_band & cnt_band == band - 'd1;

    always @(posedge clk or negedge rst_n)begin
        if(!rst_n)
            cnt_bit <= 0;
        else if(add_bit)begin
            if(end_bit)
                cnt_bit <= 0;
            else 
                cnt_bit <= cnt_bit + 1;
        end
        else
            cnt_bit <= cnt_bit;
    end
    assign add_bit = end_band;
    assign end_bit = add_bit & cnt_bit == 'd10;

    assign ready = end_cnt_1;
    
    always @(posedge clk or negedge rst_n)begin
        if(!rst_n)
            odd <= 0;
        else if(add_odd)begin
            if(data_reg[cnt_bit])
                odd <= odd + 1;
        end
        else if(end_bit)
            odd <= 0;
        else
            odd <= odd;
    end
    assign add_odd = (cnt_band == (band/2)) && (cnt_bit <= 'd7);
    always @(posedge clk or negedge rst_n)begin
        if(!rst_n)
            data_reg <= 0;
        else if(dvld)
            data_reg <= dout;
        else
            data_reg <= data_reg;
    end

    always @(posedge clk or negedge rst_n)begin
        if(!rst_n)
            data <= 0;
        else if(odd % 2 == 1)
            data <= {1'b1,1'b0,data_reg,1'b0};
        else
            data <= {1'b1,1'b1,data_reg,1'b0};
    end
    always @(*)begin
        if(init)
            tx = open_twait ? 1 : data[cnt_bit];
        else
            tx = 1;
    end
    assign busy = init ? 1 : 0;


endmodule
