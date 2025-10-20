module ModbusRTUtop (
    input           rs485_rx        ,
    output          rs485_tx        , 
    output          rs485_en        ,

    input           clk             ,//50mhz
    input           rst             ,

    input           set_addr        ,
    input           set_speed       ,
    input   [31:0]  set_data_1      , //addr
    input   [1:0]   set_data_2      , //speed

    output  [71:0]  feedback_all    ,
    output          feedback_en     ,
    output  [31:0]  status          ,
    output          addr_set_over   ,
    output          speed_set_over  
    );

    //u_cmd_reg signal list
    wire        set_addr_vld      ;
    wire        set_speed_vld     ;
    wire [31:0] set_data1_vld     ;
    wire [1:0]  set_data2_vld     ;
    //u_init signal list
    wire        speed_over        ;
    wire [47:0] init_data         ;
    wire        mod_over          ;
    wire        init_speed        ;
    wire        turn_over         ;
    wire        close_over        ;
    wire        spd_mod           ;
    wire        turn_mod          ;
    wire        close_mod         ;
    wire        init_end          ;
    //u_fb signal list
    wire        fb_over           ;
    wire        end_cnt           ;
    //u_auto signal list
    wire [47:0] auto_data         ;
    wire        detect_en         ;
    wire        op_en             ;
    //u_exec signal list
    wire [87:0] exec_data         ;
    wire        exec_en           ;
    //u_control signal list
    wire  [5:0]  brust_sta        ;
    wire  [3:0]  current_sta      ;
    wire         mod_en_ndge      ;
    //u_rx signal list 
    wire        bingo             ;
    wire [7:0]  din_rx            ;
    wire        turn_en_ndge      ;
    wire        close_en_ndge     ;
    wire        end_rwait         ;
    //u_tx signal list
    wire        ready             ;
    wire        busy              ;
    wire [7:0]  dout_tx           ;
    wire        dvld              ;
    wire [2:0]  idle_cg           ;
    wire        end_twait         ;
    //u_crc signal list
    wire [7:0]  crc_data          ;
    wire        crc_vld           ;
    wire        crc_bingo         ;
    wire [15:0] crc_reg           ;
    wire        crc_over          ;


    Cmd_reg u_cmd_reg(
        .clk            (clk           ) ,
        .rst_n          (~rst          ) ,
        .set_addr       (set_addr      ) ,
        .set_speed      (set_speed     ) ,
        .set_data_1     (set_data_1    ) ,
        .set_data_2     (set_data_2    ) ,
        .op_en          (op_en         ) ,
        .brust_sta      (brust_sta     ) ,
 
        .set_addr_vld   (set_addr_vld  ) ,
        .set_speed_vld  (set_speed_vld ) ,
        .set_data1_vld  (set_data1_vld ) ,
        .set_data2_vld  (set_data2_vld ) 
);
    init u_init(
        .clk        (clk            ) ,
        .rst_n      (~rst           ) ,

        .set_speed  (set_speed_vld  ) ,
        .data_speed (set_data2_vld  ) ,

        .speed_over (speed_over     ) ,
        .mod_over   (mod_over       ) ,
        .turn_over  (turn_over      ) ,
        .close_over (close_over     ) ,

        .init_data  (init_data      ) ,
        .init_speed (init_speed     ) ,
        .spd_mod    (spd_mod        ) , 
        .turn_mod   (turn_mod       ) ,
        .close_mod  (close_mod      ) ,
        .init_end   (init_end       )
    );
    Execute u_exec(
    //system signal
        .clk        (clk            ) ,
        .rst_n      (~rst           ) , 
    //PL sinal
        .data_addr  (set_data1_vld  ) ,
        .set_addr   (set_addr_vld   ) , 
    //u_Control signal
        .exec_data  (exec_data      ) ,
        .exec_en    (exec_en        )
    );
    Auto_detect u_auto(
    //system signal
        .clk         (clk           ) ,
        .rst_n       (~rst          ) , 
    //u_rx signal
        .end_rwait   (end_rwait     ) ,
    //u_Crl signal
        .brust_sta   (brust_sta     ) ,
        .current_sta (current_sta   ) ,
        .auto_data   (auto_data     ) ,
        .detect_en   (detect_en     ) ,
    //To PL
        .op_en       (op_en         )
    );  
    Control u_ctl(
        //system signal
        .clk            (clk           ) ,
        .rst_n          (~rst          ) ,
        //u_init singal
        .set_speed      (set_speed_vld ) ,
        .init_speed     (init_speed    ) ,
        .spd_mod        (spd_mod       ) ,
        .turn_mod       (turn_mod      ) ,
        .close_mod      (close_mod     ) ,
        .init_end       (init_end      ) ,
        .init_data      (init_data     ) ,
        .speed_over     (speed_over    ) ,
        .mod_over       (mod_over      ) ,
        .turn_over      (turn_over     ) ,
        .close_over     (close_over    ) ,
        //u_rx signal
        .end_rwait      (end_rwait     ) ,
        //u_tx signal
        .dout_tx        (dout_tx       ) ,
        .dout_tx_vld    (dvld          ) ,
        .end_twait      (end_twait     ) ,
        .busy           (busy          ) ,
        .ready          (ready         ) ,
        .idle_cg        (idle_cg       ) ,
        .mod_en_ndge    (mod_en_ndge   ) ,
        .turn_en_ndge   (turn_en_ndge  ) ,
        .close_en_ndge  (close_en_ndge ) ,
        //u_fb signal
        .fb_over        (fb_over       ) ,
        .brust_sta      (brust_sta     ) ,
        .current_sta    (current_sta   ) ,
        //u_autodetect signal
        .auto_data      (auto_data     ) ,
        .detect         (detect_en     ) ,
        //u_execute signal
        .exec_data      (exec_data     ) ,
        .exec           (exec_en       ) ,
        //u_CRC signal
        .crc_data       (crc_data      ) ,
        .crc_vld        (crc_vld       ) ,
        .crc_bingo      (crc_bingo     ) ,
        .crc_reg        (crc_reg       ) ,
        .crc_over       (crc_over      ) ,
        //to PL
        .addr_set_over  (addr_set_over  ) ,
        .speed_set_over (speed_set_over ) 
    );

    rx_mod u_rx(
        .clk        (clk        ) ,
        .rst_n      (~rst       ) ,

        .bingo      (bingo      ) ,
        .rx         (rs485_rx   ) ,
        .din        (din_rx     ) ,

        .end_rwait  (end_rwait  ) ,
        .close_baud (end_cnt    ) 

    );

    tx_mod u_tx(    
        .clk           (clk           ) ,
        .rst_n         (~rst          ) ,
      
        .tx            (rs485_tx      ) ,
        .ready         (ready         ) ,
        .busy          (busy          ) , 
        .idle_cg       (idle_cg       ) ,
        .mod_en_ndge   (mod_en_ndge   ) ,
        .turn_en_ndge  (turn_en_ndge  ) ,
        .close_en_ndge (close_en_ndge ) ,

        .dout       (dout_tx    ) ,
        .dvld       (dvld       ) ,

        .rs485_en   (rs485_en   ) ,

        .end_twait  (end_twait  )
    );

    feedback u_fb(
    //system signal
        .clk            (clk            ) ,
        .rst_n          (~rst           ) ,
    //u_rx signal
        .feedback_byte  (din_rx         ) ,
        .bingo          (bingo          ) ,
        .end_rwait      (end_rwait      ) ,
        .end_cnt        (end_cnt        ) ,
    //u_Control signal
        .feedback_over  (fb_over        ) ,
        .current_sta    (current_sta    ) ,
        .brust_sta      (brust_sta      ) ,
    //to PL
        .feedback_all   (feedback_all   ) ,
        .status         (status         ) ,
        .feedback_en    (feedback_en    ) 
    );

    CRC u_crc(
        .clk                (clk        ) ,
        .rst_n              (~rst       ) ,
        .data_l             (crc_data   ) ,
        .vld                (crc_vld    ) ,
        .crc_vld            (crc_bingo  ) ,
        .crc_reg            (crc_reg    ) ,
        .crc_vld_over_reg   (crc_over   )
    );

endmodule