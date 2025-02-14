module feedback(
    //system signal
    input           clk             ,
    input           rst_n           ,
    //u_rx signal
    input   [7:0]   feedback_byte   ,
    input           bingo           ,
    input           end_rwait       ,
    output          end_cnt         ,
    //u_Control signal
    output          feedback_over   ,
    input   [3:0]   current_sta     ,
    input   [5:0]   brust_sta       ,
    //to PL
    output  [71:0]  feedback_all    ,
    output  [31:0]  status          ,
    output          feedback_en     ,
    output          addr_set_over   ,
    output          speed_set_over  
    
);
    reg     [71:0]  fb_data          ;
    reg     [3:0]   current_sta_sync ;
    wire            change           ;
    wire    [31:0]  status_reg       ;
    reg     [3:0]   cnt_byte         ;
    reg     [3:0]   cnt              ;
    wire            add_cnt          ;
    always @(posedge clk or negedge rst_n)begin
        if(!rst_n)
            current_sta_sync <= 4'b1000 ;
        else
            current_sta_sync <= current_sta ;
    end
    assign  change        = current_sta_sync & current_sta ;
    assign  feedback_over = end_rwait                      ;
    assign  feedback_en   = end_rwait                      ;
    assign  feedback_all  = end_rwait ? fb_data : 0        ;
    assign  status        = end_rwait ? status_reg : 0 ;
    assign  status_reg    = current_sta[3] ? {fb_data[31:16],fb_data[47:32]} : 0;


    always @(*)begin
        if(current_sta == 4'b0010)
            cnt_byte = 4'd8;
        else if(current_sta == 4'b0100)
            cnt_byte = 4'd8;
        else if(current_sta == 4'b1000)
            cnt_byte = 4'd9;
    end
    always @(posedge clk or negedge rst_n)begin
        if(!rst_n)
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
    assign add_cnt = bingo;
    assign end_cnt = add_cnt & cnt == cnt_byte - 1;

    always @(posedge clk or negedge rst_n)begin
        if(!rst_n)
             fb_data <= 0;
        else if(bingo)
            case(cnt)
                0 : fb_data[71:64] <= feedback_byte ;
                1 : fb_data[63:56] <= feedback_byte ;
                2 : fb_data[55:48] <= feedback_byte ;
                3 : fb_data[47:40] <= feedback_byte ;
                4 : fb_data[39:32] <= feedback_byte ;
                5 : fb_data[31:24] <= feedback_byte ;
                6 : fb_data[23:16] <= feedback_byte ;
                7 : fb_data[15:8]  <= feedback_byte ;
                8 : fb_data[7:0]   <= feedback_byte ;
                default : fb_data <= 0;
        endcase
        else if(change)
            fb_data <= 0 ;
        else
            fb_data <= fb_data;
    end

endmodule