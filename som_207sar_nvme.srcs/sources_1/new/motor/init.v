module init(
    //system signal
    input           clk         ,
    input           rst_n       ,    
    //PC signal
    input           set_speed   ,
    input  [1:0]    data_speed  ,
    //RS485 rx
    input           speed_over  ,
    input           mod_over    ,
    input           turn_over   ,
    input           close_over  ,
    //To RS485 tx
    output [47:0]   init_data   ,
    output          init_speed  ,
    output          spd_mod     , 
    output          turn_mod    ,
    output          close_mod   ,
    output          init_end 
);
    parameter RPM_900      = 48'h01_06_03_34_03_84  ;
    parameter RPM_600      = 48'h01_06_03_34_02_58  ;
    parameter RPM_300      = 48'h01_06_03_34_01_2c  ;
    parameter Speed_Moudle = 48'h01_06_03_39_00_01  ;
    parameter Turn         = 48'h01_06_03_3b_02_00  ;
    parameter Turn_close   = 48'h01_06_03_3b_00_00  ;

    reg [47:0]  init_data_reg   ;
    reg         init_speed_reg  ;
    reg         spd_mod_reg     ;
    reg         turn_reg        ;
    reg         close_reg       ;
    reg         init_end_reg    ;


    always @(posedge clk or negedge rst_n)begin
        if(!rst_n)
            init_data_reg <= RPM_600 ;
        else if(set_speed)begin
            if(data_speed == 2'd0)
                init_data_reg <= RPM_300 ;
            else if(data_speed == 2'd1)
                init_data_reg <= RPM_600 ;
            else if(data_speed == 2'd2)
                init_data_reg <= RPM_900 ;
            else
                init_data_reg <= RPM_600 ;
        end
        else if(speed_over)
            init_data_reg <= Speed_Moudle ;
        else if(mod_over)
            init_data_reg <= Turn ;
        else if(turn_over)
            init_data_reg <= Turn_close ;
    end

    always @(posedge clk or negedge rst_n)begin
        if(!rst_n)
            init_speed_reg <= 0;
        else if(set_speed)
            init_speed_reg <= 1;
        else if(speed_over)
            init_speed_reg <= 0;
    end

    always @(posedge clk or negedge rst_n)begin
        if(!rst_n)
            spd_mod_reg <= 0;
        else if(speed_over)
            spd_mod_reg <= 1;
        else if(mod_over)
            spd_mod_reg <= 0;
    end

    always @(posedge clk or negedge rst_n)begin
        if(!rst_n)
            turn_reg <= 0;
        else if(mod_over)
            turn_reg <= 1;
        else if(turn_over)
            turn_reg <= 0;
    end

    always @(posedge clk or negedge rst_n)begin
        if(!rst_n)
            close_reg <= 0;
        else if(turn_over)
            close_reg <= 1;
        else if(close_over)
            close_reg <= 0;
    end

    always @(posedge clk or negedge rst_n)begin
        if(!rst_n)
            init_end_reg <= 0;
        else if(close_over)
            init_end_reg <= 1;
        else if(set_speed)
            init_end_reg <= 0;
    end

    assign init_data  = init_data_reg   ;
    assign init_speed = init_speed_reg  ;
    assign spd_mod    = spd_mod_reg     ;
    assign turn_mod   = turn_reg        ;
    assign close_mod  = close_reg       ;
    assign init_end   = init_end_reg    ;

endmodule