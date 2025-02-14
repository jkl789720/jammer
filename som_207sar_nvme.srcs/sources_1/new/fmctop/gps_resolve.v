module gps_resolve
#(
parameter MSG_ID = 16'h2A00,    // big endian
parameter MSG_LEN = 104,
parameter DAT_OFF = 36,
parameter DAT_LEN = 24,
parameter MSG_STAT = 28+3       // 28:31
)(
input clk,
input reset,

input       rx_valid,
input [7:0] rx_data,

output reg [DAT_LEN*8-1:0]  out_dat,
output reg                  out_en,
output reg                  out_stat
);
localparam HEAD_SYM = 32'hAA44121C;   // big endian
localparam HEAD_LEN = 28;
localparam CRC_LEN = 4;
localparam OFF_HEAD_SYM = 0;   // 4byte
localparam OFF_HEAD_ID = 4;    // 2byte
localparam OFF_MSG_LEN = 8;    // 2byte


reg [63:0] rxdat;
reg [7:0] rxval;
wire hit_head;
assign hit_head = (rxdat[47:0]=={HEAD_SYM, MSG_ID});
reg pstart;
reg [15:0] pcnt;
always@(posedge clk)begin
    if(reset)begin
        rxval <= 0;
        rxdat[0] <= 8'h00;
        pstart <= 0;
        pcnt <= 0;
        
        out_stat <= 0;
        out_en <= 0;
        out_dat <= {DAT_LEN{8'h0}};
    end
    else begin
        if(rx_valid)rxdat <= {rxdat[55:0], rx_data};    
        rxval <= {rxval[6:0], rx_valid};
        
        if(rxval[0])begin
            if(hit_head)pstart <= 1;
            else if(pcnt==MSG_LEN)pstart <= 0;
            
            if(hit_head)pcnt <= 6;
            else if(pstart)pcnt <= pcnt + 1;
            else pcnt <= 0;
            
            if(hit_head)out_stat <= 0;
            if((pcnt==MSG_STAT)&&(rxdat[31:0]==32'h0))out_stat <= 1;
            
            if(pcnt==(DAT_OFF+DAT_LEN))out_en <= 1;
            else out_en <= 0;
            
            if((pcnt>=DAT_OFF)&&(pcnt<(DAT_OFF+DAT_LEN)))out_dat <= {rxdat[7:0], out_dat[DAT_LEN*8-1:8]};
        end
        else out_en <= 0;
    end
end


endmodule
