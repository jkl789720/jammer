module rx_mod(
    input   clk     ,
    input   rst_n   ,

    output  bingo   ,
    input   rx      ,
    output  [7:0]din,

    input  close_baud,

    output end_rwait

);
    parameter band = 434;   //band:115200   50mhz/band
    reg     [10:0]  data        ;
    reg             open_rwait  ;
    wire            ndge        ;
    reg             bgn_1       ;
    reg             bgn_2       ;
    reg             init        ;
    wire            end_init    ;
    wire            byte_end    ;
    reg     [8:0]   cnt_band    ;
    wire            add_band    ;
    wire            end_band    ;
    wire            detect      ;
    reg     [3:0]   cnt_bit     ;
    wire            add_bit     ;
    wire            end_bit     ;

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n)begin
            bgn_1 <= 1 ; 
            bgn_2 <= 1 ;
        end
        else begin
            bgn_1 <= rx    ;
            bgn_2 <= bgn_1 ;
        end
    end
    assign ndge = ~bgn_1 & bgn_2 ;

    always @(posedge clk or negedge rst_n)begin
        if(!rst_n)
            init <= 0 ;
        else if(ndge)  
            init <= 1 ;
        else if(end_init)
            init <= 0 ;
        else
            init <= init;
    end
    assign end_init = byte_end || close_baud;
    assign byte_end = (cnt_bit == 'd10) && (cnt_band == 'd220);
    always @(posedge clk or negedge rst_n)begin
        if(!rst_n)
            cnt_band <= 0;
        else if(end_bit || end_init)
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
        else if(end_init)
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

    assign bingo = end_bit || byte_end;

    always @(posedge clk or negedge rst_n)begin
        if(!rst_n)
            data <= 0;
        else if(detect)
            data[cnt_bit] <= rx;
        else 
            data <= data;
    end
    assign din = data[8:1];
    assign detect = cnt_band == band/2;

    reg [14:0]rwait;
    wire add_rwait;

    always @(posedge clk or negedge rst_n)begin
        if(!rst_n)
            open_rwait <= 0;
        else if(bingo) 
            open_rwait <= 1;
        else if(ndge || end_rwait)
            open_rwait <= 0;
        else
            open_rwait <= open_rwait;
    end
    
    always @(posedge clk or negedge rst_n)begin
        if(!rst_n)
            rwait <= 0;
        else if(add_rwait)begin
            if(end_rwait)
                rwait <= 0;
            else 
                rwait <= rwait + 1;
        end
        else if(ndge || ~open_rwait)
            rwait <= 0;
        else
            rwait <= rwait;
    end
    assign add_rwait = open_rwait;
    assign end_rwait = (rwait == 16709 - 1'd1);

endmodule