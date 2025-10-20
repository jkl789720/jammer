module CRC(
    input               clk              ,
    input               rst_n            ,
    input       [7:0]   data_l           ,
    input               vld              ,
    output reg          crc_vld          ,
    output reg [15:0]   crc_reg          ,
    input               crc_vld_over_reg
    );

    parameter   xor_a=16'd0;
    wire    [7:0]    data_n       ;
    wire    [15:0]   crc_n        ;
    reg     [7:0]    d            ;
    reg     [15:0]   newcrc       ;
    reg     [15:0]   nextCRC16_D8 ;
    wire    [15:0]   c            ;
    reg     [7:0]    count        ;
    reg crc_vld_1;
    reg crc_vld_2;
    wire crc_vld_ndge;

    always @(posedge clk or negedge rst_n) begin  
	  if(~rst_n) begin  
	  	 d<= 0; 
	  end 
      else if(vld) begin  
	  	 d<=data_n ;  
	  end
      else if(crc_vld_ndge & crc_vld_over_reg)
        d <= 0;
    end
    assign c=newcrc;
    always @(posedge clk or negedge rst_n) begin  
	  if(~rst_n) begin  
	  	 newcrc<= 16'hFFFF; 
	  end 
      else if(count==8'd5) begin  
	    newcrc[0] = d[7] ^ d[6] ^ d[5] ^ d[4] ^ d[3] ^ d[2] ^ d[1] ^ d[0] ^ c[8] ^ c[9] ^ c[10] ^ c[11] ^ c[12] ^ c[13] ^ c[14] ^ c[15];
        newcrc[1] = d[7] ^ d[6] ^ d[5] ^ d[4] ^ d[3] ^ d[2] ^ d[1] ^ c[9] ^ c[10] ^ c[11] ^ c[12] ^ c[13] ^ c[14] ^ c[15];
        newcrc[2] = d[1] ^ d[0] ^ c[8] ^ c[9];
        newcrc[3] = d[2] ^ d[1] ^ c[9] ^ c[10];
        newcrc[4] = d[3] ^ d[2] ^ c[10] ^ c[11];
        newcrc[5] = d[4] ^ d[3] ^ c[11] ^ c[12];
        newcrc[6] = d[5] ^ d[4] ^ c[12] ^ c[13];
        newcrc[7] = d[6] ^ d[5] ^ c[13] ^ c[14];
        newcrc[8] = d[7] ^ d[6] ^ c[0] ^ c[14] ^ c[15];
        newcrc[9] = d[7] ^ c[1] ^ c[15];
        newcrc[10] = c[2];
        newcrc[11] = c[3];
        newcrc[12] = c[4];
        newcrc[13] = c[5];
        newcrc[14] = c[6];
        newcrc[15] = d[7] ^ d[6] ^ d[5] ^ d[4] ^ d[3] ^ d[2] ^ d[1] ^ d[0] ^ c[7] ^ c[8] ^ c[9] ^ c[10] ^ c[11] ^ c[12] ^ c[13] ^ c[14] ^ c[15];
        nextCRC16_D8 = newcrc;  
	  end
      else if(crc_vld_ndge & crc_vld_over_reg)
        newcrc<= 16'hFFFF;
    end

    always @(posedge clk or negedge rst_n) begin  
	  if(~rst_n) begin  
	  	 count<= 0; 
	  end else if(vld) begin  
	  	 count<=1 ;
        end else if (count==8'd8) begin
        	 count<=0;	  
	  end else if (count!==0) begin 
	  	 count<=count+1;  
	  end
    end

    always @(posedge clk or negedge rst_n) begin  
	  if(~rst_n) 
	  	crc_reg<= 0; 
      else if(count==8'd8) 
	  	crc_reg <= crc_n^xor_a ; 
      else if(crc_vld_ndge & crc_vld_over_reg)
        crc_reg <= 0;
      else  
	  	 crc_reg <= crc_reg;  

    end
  
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n)
            crc_vld <= 0;
        else if(count==8'd8)
            crc_vld <= 1;
        else
            crc_vld<=0;
    end

    always @(posedge clk or negedge rst_n)begin
        if(!rst_n)begin
            crc_vld_1 <= 0;
            crc_vld_2 <= 0;
        end
        else begin
            crc_vld_1 <= crc_vld;
            crc_vld_2 <= crc_vld_1; 
        end
    end
    assign crc_vld_ndge = ~crc_vld_2 & crc_vld_1; 

    assign data_n[7]=data_l[0];
    assign data_n[6]=data_l[1];
    assign data_n[5]=data_l[2];
    assign data_n[4]=data_l[3];
    assign data_n[3]=data_l[4];
    assign data_n[2]=data_l[5];
    assign data_n[1]=data_l[6];
    assign data_n[0]=data_l[7]; 


    assign crc_n[15]=nextCRC16_D8[0];
    assign crc_n[14]=nextCRC16_D8[1];
    assign crc_n[13]=nextCRC16_D8[2];
    assign crc_n[12]=nextCRC16_D8[3];
    assign crc_n[11]=nextCRC16_D8[4];
    assign crc_n[10]=nextCRC16_D8[5];
    assign crc_n[9]=nextCRC16_D8[6];
    assign crc_n[8]=nextCRC16_D8[7];
    assign crc_n[7]=nextCRC16_D8[8];
    assign crc_n[6]=nextCRC16_D8[9];
    assign crc_n[5]=nextCRC16_D8[10];
    assign crc_n[4]=nextCRC16_D8[11];
    assign crc_n[3]=nextCRC16_D8[12];
    assign crc_n[2]=nextCRC16_D8[13];
    assign crc_n[1]=nextCRC16_D8[14];
    assign crc_n[0]=nextCRC16_D8[15]; 

    endmodule
