module Execute(
    //system signal
    input               clk         ,
    input               rst_n       ,
    //PL sinal
    input       [31:0]  data_addr   ,
    input               set_addr    ,
    //u_Control signal
    output  reg [87:0]  exec_data   ,
    output  reg         exec_en     
);
    always @(posedge clk or negedge rst_n)begin
        if(!rst_n)begin
            exec_data <= {87'h01_10_03_32_00_02_04_00_00_00_00};
            exec_en <= 0;
        end
        else if(set_addr)begin
            exec_data <= {56'h01_10_03_32_00_02_04,data_addr[15:0],data_addr[31:16]};
            exec_en   <= set_addr;
        end
        else
            exec_en  <= 0;
    end
endmodule