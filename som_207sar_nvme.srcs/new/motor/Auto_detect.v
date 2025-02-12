module Auto_detect(
    //system signal
    input   clk     ,
    input   rst_n   ,
    //u_rx signal
    input   end_rwait,
    //u_Crl signal
    input   [3:0]   current_sta ,
    input   [5:0]   brust_sta   ,//{idle2init,idle2auto,idle2exec,init2idle,exec2idle,auto2idle}
    output  [47:0]  auto_data   ,
    output          detect_en   ,
    //To PL
    output  op_en
);  

    assign  auto_data = 48'h01_03_03_3d_00_02   ;
    
    //20ms 50hz Automatic Detection clock
    reg     [19:0]  cnt ;
    wire    add_cnt     ;
    wire    end_cnt     ;
    reg     timing      ;
    wire    zero        ;
    wire    close       ;
    wire    open        ;
    always @(posedge clk or negedge rst_n)begin
        if(!rst_n)
            cnt <= 0;
        else if(zero)
                cnt <= 0;           
        else if(add_cnt)begin
            if(end_cnt)
                cnt <= 0;
            else
                cnt <= cnt + 1;
        end
        else
            cnt <= cnt;
    end
    assign add_cnt = (current_sta == 4'b0001);
    assign end_cnt = add_cnt && (cnt == 1_000_000 - 1);
    assign zero = brust_sta[5] || brust_sta[4] || brust_sta[3];
    assign detect_en = end_cnt ;

    always @(posedge clk or negedge rst_n)begin
        if(!rst_n)
            timing <= 1;
        else if(close)
            timing <= 0;
        else if(open)
            timing <= 1;
        else
            timing <= timing;
    end
    assign open  = (end_rwait && (current_sta != 4'b0010)) || brust_sta[2];
    assign close = (cnt == 1_000_000 - 2) || brust_sta[5:3] ;
    assign op_en = timing ;
    
endmodule