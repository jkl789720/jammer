module Control(
    //system signal
    input           clk           ,
    input           rst_n         ,
    //u_init singal  
    input           set_speed     ,
    input           init_speed    ,
    input           spd_mod       ,
    input           turn_mod      ,
    input           close_mod     ,
    input           init_end      ,
    input   [47:0]  init_data     ,
    output          speed_over    ,
    output          mod_over      ,
    output          turn_over     ,
    output          close_over    ,
    //u_rx signal  
    input           end_rwait     ,
    //u_tx signal  
    output  [7:0]   dout_tx       ,
    output          dout_tx_vld   ,
    input           end_twait     ,
    input           busy          ,
    input           ready         ,
    output          mod_en_ndge   ,
    output          turn_en_ndge  ,
    output          close_en_ndge ,
    //u_fb signal
    input           fb_over       ,
    output  [5:0]   brust_sta     ,
    output  [3:0]   current_sta   ,
    //u_autodetect signal  
    input   [47:0]  auto_data     ,
    input           detect        , 
    //u_execute signal  
    input   [87:0]  exec_data     ,
    input           exec          ,
    //u_CRC signal  
    output  [7:0]   crc_data      ,
    output          crc_vld       ,
    input           crc_bingo     ,
    input   [15:0]  crc_reg       ,
    output  reg     crc_over      ,
    output   [2:0]   idle_cg      ,
    //PL
    output          addr_set_over ,
    output          speed_set_over
);
    //fifo signal
    wire    [7:0]   din_fifo    ;
    wire            wr_en       ;
    wire            rd_en       ;
    wire    [7:0]   dout_fifo   ;
    wire            full        ;
    wire            empty       ;
    wire    [4:0]   data_count  ;
    wire            wr_rst_busy ;
    wire            rd_rst_busy ;
    //FSM signal
    localparam  IDLE = 4'b0001  ,
                INIT = 4'b0010  ,
                EXEC = 4'b0100  ,
                AUTO = 4'b1000  ;

    reg     [3:0]   state_c     ;
    reg     [3:0]   state_n     ;
    wire            idle2init   ;
    wire            idle2auto   ;
    wire            idle2exec   ;
    wire            init2idle   ;
    wire            exec2idle   ; 
    wire            auto2idle   ;
    //cnt_byte    
    reg     [3:0]   cnt_byte    ;  
    wire            add_byte    ;
    wire            end_byte    ;
    //init signal
    wire    [7:0]   init_devie  ;
    wire    [7:0]   init_instr  ;
    wire    [7:0]   init_addr_h ;
    wire    [7:0]   init_addr_l ;
    wire    [7:0]   init_h      ;
    wire    [7:0]   init_l      ;
    wire            speed_en    ;
    wire            mod_en      ;
    wire            turn_en     ;
    wire            close_en    ;
    wire    [7:0]   init2fifo   ;
    reg             mod_en_1    ;
    reg             mod_en_2    ;
    reg             turn_en_1   ;
    reg             turn_en_2   ;
    reg             close_en_1  ;
    reg             close_en_2  ;
    //exec signal
    wire    [7:0]   exec_devie      ;
    wire    [7:0]   exec_instr      ;
    wire    [7:0]   exec_addr_h     ;
    wire    [7:0]   exec_addr_l     ;
    wire    [7:0]   exec_cnt_h      ;
    wire    [7:0]   exec_cnt_l      ;
    wire    [7:0]   exec_quantity   ;  
    wire    [7:0]   exec_data1_h    ;
    wire    [7:0]   exec_data1_l    ;
    wire    [7:0]   exec_data2_h    ;
    wire    [7:0]   exec_data2_l    ;
    wire            exec_en         ;
    wire    [7:0]   exec2fifo       ;
    //auto_detect signal
    wire    [7:0]   auto_devie  ;
    wire    [7:0]   auto_instr  ;
    wire    [7:0]   auto_addr_h ;
    wire    [7:0]   auto_addr_l ;
    wire    [7:0]   auto_h      ;
    wire    [7:0]   auto_l      ;
    wire            auto_en     ;
    wire    [7:0]   auto2fifo   ;
    /////////////////////////////////////////////////////////////////////////////////
    //CRC signal
    reg     [15:0]  crc_data_v  ;
    always @(posedge clk or negedge rst_n)begin
        if(!rst_n)
            crc_data_v <= 0;
        else if(crc_bingo)
            crc_data_v <= crc_reg;
        else 
            crc_data_v <= crc_data_v;
    end
    /////////////////////////////////////////////////////////////////////////////////
    //FSM SHIFT
    always @(posedge clk or negedge rst_n)begin
        if(!rst_n)
            state_c <= IDLE ;
        else 
            state_c <= state_n  ;
    end
    always @(*)begin
        case(state_c)
            IDLE : begin
                if(idle2init)
                    state_n = INIT    ;
                else if(idle2exec)  
                    state_n = EXEC    ;
                else if(idle2auto)
                    state_n = AUTO    ;
                else
                    state_n = state_c ;
            end
            INIT : begin
                if(init2idle)
                    state_n = IDLE    ;
                else 
                    state_n = state_c ;
            end
            EXEC : begin
                if(exec2idle)
                    state_n = IDLE    ;
                else
                    state_n = state_c ;
            end
            AUTO : begin
                if(auto2idle)
                    state_n = IDLE    ;
                else
                    state_n = state_c ;
            end
            default:state_n = IDLE    ; 
        endcase
    end       
    assign  idle2init = (state_c == IDLE) && set_speed  ;
    assign  idle2auto = (state_c == IDLE) && detect     ;
    assign  idle2exec = (state_c == IDLE) && exec       ;
    assign  init2idle = (state_c == INIT) && close_over ;
    assign  exec2idle = (state_c == EXEC) && end_rwait  ;
    assign  auto2idle = (state_c == AUTO) && end_rwait  ;

    assign brust_sta   = {idle2init,idle2auto,idle2exec,init2idle,exec2idle,auto2idle};
    assign idle_cg     = {idle2init,idle2auto,idle2exec};
    assign current_sta = state_c    ;
    /////////////////////////////////////////////////////////////////////////////////
    assign  addr_set_over  = exec2idle ;
    assign  speed_set_over = init2idle ;
    /////////////////////////////////////////////////////////////////////////////////
    //INIT ing
    assign  init2fifo = (cnt_byte == 4'd0) ? init_devie : (cnt_byte == 4'd1) ? init_instr : (cnt_byte == 4'd2) ? init_addr_h : (cnt_byte == 4'd3) ? init_addr_l : 
                        (cnt_byte == 4'd4) ? init_h  : (cnt_byte == 4'd5) ? init_l : 0;

    assign  init_devie  = init_data[47:40] ;
    assign  init_instr  = init_data[39:32] ;
    assign  init_addr_h = init_data[31:24] ;
    assign  init_addr_l = init_data[23:16] ;
    assign  init_h      = init_data[15:8]  ;
    assign  init_l      = init_data[7:0]   ;

    assign  speed_en    = init_speed && cnt_byte <= 4'd5 ;
    assign  mod_en      = spd_mod    && cnt_byte <= 4'd5 ;
    assign  turn_en     = turn_mod   && cnt_byte <= 4'd5 ;
    assign  close_en    = close_mod  && cnt_byte <= 4'd5 ;
    assign  speed_over  = init_speed && fb_over          ;
    assign  mod_over    = spd_mod    && fb_over          ;
    assign  turn_over   = turn_mod   && fb_over          ;
    assign  close_over  = close_mod  && fb_over          ;
    always @(posedge clk or negedge rst_n)begin
        if(!rst_n)begin
            mod_en_1 <= 0;
            mod_en_2 <= 0;
        end
        else begin
            mod_en_1 <= mod_en;
            mod_en_2 <= mod_en_1;
        end
    end
    assign mod_en_ndge = ~mod_en_1 && mod_en_2;

        always @(posedge clk or negedge rst_n)begin
        if(!rst_n)begin
            turn_en_1 <= 0;
            turn_en_2 <= 0;
        end
        else begin
            turn_en_1 <= turn_en;
            turn_en_2 <= turn_en_1;
        end
    end
    assign turn_en_ndge = ~turn_en_1 && turn_en_2;

        always @(posedge clk or negedge rst_n)begin
        if(!rst_n)begin
            close_en_1 <= 0;
            close_en_2 <= 0;
        end
        else begin
            close_en_1 <= close_en;
            close_en_2 <= close_en_1;
        end
    end
    assign close_en_ndge = ~close_en_1 && close_en_2;
    /////////////////////////////////////////////////////////////////////////////////
    //EXEC ing
    assign  exec2fifo = (cnt_byte == 4'd0) ? exec_devie: (cnt_byte == 4'd1) ? exec_instr : (cnt_byte == 4'd2) ? exec_addr_h : (cnt_byte == 4'd3) ? exec_addr_l : 
                        (cnt_byte == 4'd4) ? exec_cnt_h  : (cnt_byte == 4'd5) ? exec_cnt_l : (cnt_byte == 4'd6) ? exec_quantity : (cnt_byte == 4'd7) ? exec_data1_h : 
                        (cnt_byte == 4'd8) ? exec_data1_l : (cnt_byte == 4'd9) ? exec_data2_h : (cnt_byte == 4'd10) ? exec_data2_l : 0;

    assign   exec_devie    = exec_data[87:80] ;
    assign   exec_instr    = exec_data[79:72] ;
    assign   exec_addr_h   = exec_data[71:64] ;
    assign   exec_addr_l   = exec_data[63:56] ;
    assign   exec_cnt_h    = exec_data[55:48] ;
    assign   exec_cnt_l    = exec_data[47:40] ;
    assign   exec_quantity = exec_data[39:32] ;  
    assign   exec_data1_h  = exec_data[31:24] ;
    assign   exec_data1_l  = exec_data[23:16] ;
    assign   exec_data2_h  = exec_data[15:8]  ;
    assign   exec_data2_l  = exec_data[7:0]   ;

    assign   exec_en = (state_c == EXEC) && cnt_byte <= 4'd10 ;
    /////////////////////////////////////////////////////////////////////////////////
    //AUTO ing
    assign  auto2fifo = (cnt_byte == 4'd0) ? auto_devie: (cnt_byte == 4'd1) ? auto_instr : (cnt_byte == 4'd2) ? auto_addr_h : (cnt_byte == 4'd3) ? auto_addr_l : 
                        (cnt_byte == 4'd4) ? auto_h  : (cnt_byte == 4'd5) ? auto_l : 0;

    assign  auto_devie  = auto_data[47:40] ;
    assign  auto_instr  = auto_data[39:32] ;
    assign  auto_addr_h = auto_data[31:24] ;
    assign  auto_addr_l = auto_data[23:16] ;
    assign  auto_h      = auto_data[15:8]  ;
    assign  auto_l      = auto_data[7:0]   ;    

    assign auto_en = (state_c == AUTO) && cnt_byte <= 4'd5 ;  
    /////////////////////////////////////////////////////////////////////////////////
    //CRC 
    reg [1:0]cnt_crc;
    always @(posedge clk or negedge rst_n)begin
        if(!rst_n)
            crc_over <= 0;
        else if(crc_bingo && empty)
            crc_over <= 1;
        else if(ready && cnt_crc == 2'd2)
            crc_over <= 0;
        else
            crc_over <= crc_over;
    end
    always @(posedge clk or negedge rst_n)begin
        if(!rst_n)
            cnt_crc <= 0;
        else if(crc_over && ready)begin
            if(cnt_crc == 2'd2)
                cnt_crc <= 0;
            else
                cnt_crc <= cnt_crc + 1;
        end
        else
            cnt_crc <= cnt_crc;
    end
    assign crc_vld = (end_twait && (data_count == ((state_c == INIT) ? 4'd6 : (state_c == AUTO) ? 4'd6 : 4'd11))) || (~empty & ready);
    /////////////////////////////////////////////////////////////////////////////////
    //byte count
    always @(posedge clk or negedge rst_n)begin
        if(!rst_n)
            cnt_byte <= 0;
        else if(end_byte)
            cnt_byte <= 0;
        else if(add_byte)
            cnt_byte <= cnt_byte + 1;
        else
            cnt_byte <= cnt_byte;
    end
    assign add_byte = ((state_c == INIT) || (state_c == AUTO) || (state_c == EXEC)) && (cnt_byte <= 4'd10) ;
    assign end_byte = init2idle || speed_over || mod_over || turn_over || exec2idle || auto2idle;
    /////////////////////////////////////////////////////////////////////////////////
    MTctrl_fifo MTctrl_fifo0 (
        .clk          (clk         ),    
        .srst         (~rst_n      ),    
        .din          (din_fifo    ),    
        .wr_en        (wr_en       ),    
        .rd_en        (rd_en       ),    
        .dout         (dout_fifo   ),    
        .full         (full        ),    
        .empty        (empty       ),    
        .data_count   (data_count  ),    
        .wr_rst_busy  (wr_rst_busy ),  
        .rd_rst_busy  (rd_rst_busy ) 
  );
    assign     din_fifo = (state_c == INIT) ? init2fifo : (state_c == EXEC) ? exec2fifo : (state_c == AUTO) ? auto2fifo : 0;
    assign     wr_en    = speed_en || mod_en || turn_en || close_en || exec_en || auto_en;
    assign     rd_en    = (end_twait && (data_count == ((state_c == INIT) ? 4'd6 : (state_c == AUTO) ? 4'd6 : 4'd11))) || (~empty & ready) ;
    assign     dout_tx  = crc_over ? (cnt_crc ? crc_data_v[15:8] : crc_data_v[7:0]) : dout_fifo;
    assign     dout_tx_vld = (end_twait && (data_count == ((state_c == INIT) ? 4'd6 : (state_c == AUTO) ? 4'd6 : 4'd11))) || (~empty & ready) || (cnt_crc < 2'd2 & ready);
    assign     crc_data = dout_fifo;
endmodule