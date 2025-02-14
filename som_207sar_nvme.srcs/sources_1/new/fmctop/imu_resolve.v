module imu_resolve
#(
parameter MSG_ID = 8'h6B,    // big endian
parameter MSG_LEN = 111,
parameter DAT_OFF = 3,
parameter DAT_LEN = 107,
parameter MSG_STAT = 7+3    // 7-10 byte, 21-22 is valid
)(
input clk,
input reset,

input       rx_valid,
input [7:0] rx_data,

output reg [DAT_LEN*8-1:0]  out_dat,
output reg                  out_en,
output reg                  out_stat
);
localparam HEAD_SYM = 16'h55AA;   // big endian

reg [31:0] rxdat;
reg [7:0] rxval;
wire hit_head;
assign hit_head = (rxdat[23:0]=={HEAD_SYM, MSG_ID});
reg pstart;
reg [15:0] pcnt;
reg [7:0] checksum;
always@(posedge clk)begin
    if(reset)begin
        rxval <= 0;
        rxdat <= 24'h00;
        pstart <= 0;
        pcnt <= 0;
        checksum <= 0;
        
        out_stat <= 0;
        out_en <= 0;
        out_dat <= {DAT_LEN{8'h0}};
    end
    else begin
        if(rx_valid)rxdat <= {rxdat[23:0], rx_data};    
        rxval <= {rxval[6:0], rx_valid};
        
        if(rxval[0])begin
            if(hit_head)pstart <= 1;
            else if(pcnt==MSG_LEN)pstart <= 0;
            
            if(hit_head)begin
                pcnt <= 3;
                checksum <= rxdat[7:0];
            end
            else if(pstart)begin
                pcnt <= pcnt + 1;
                checksum <= checksum + rxdat[7:0];
            end
            else pcnt <= 0;
            
            if(hit_head)out_stat <= 0;
            if((pcnt==MSG_STAT)&&(rxdat[31:0]>0)&&(rxdat[31:0]<23))out_stat <= 1;
            
            if((pcnt==(MSG_LEN-1))&&(checksum==rxdat[7:0]))out_en <= 1;
            else out_en <= 0;
            
            if((pcnt>=DAT_OFF)&&(pcnt<(DAT_OFF+DAT_LEN)))out_dat <= {rxdat[7:0], out_dat[DAT_LEN*8-1:8]};
        end
        else out_en <= 0;
    end
end


endmodule
