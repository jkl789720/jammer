module para_cmulti(
input clk,
input [255:0] ina,
input [255:0] inb,
output reg [255:0] outc
);
reg [255:0] inar;
reg [255:0] inbr;
wire [255:0] outcr;
always@(posedge clk)inar <= ina;
always@(posedge clk)inbr <= inb;
always@(posedge clk)outc <= outcr;
genvar kk;
generate
for(kk=0;kk<8;kk=kk+1)begin
cmpy_top16x16 ep0 (
  .aclk(clk),                              // input wire aclk
  .s_axis_a_tvalid(1'b1),        // input wire s_axis_a_tvalid
  .s_axis_a_tdata(inar[32*kk+31:32*kk]),          // input wire [31 : 0] s_axis_a_tdata
  .s_axis_b_tvalid(1'b1),        // input wire s_axis_b_tvalid
  .s_axis_b_tdata(inbr[32*kk+31:32*kk]),          // input wire [31 : 0] s_axis_b_tdata
  .m_axis_dout_tvalid(),  // output wire m_axis_dout_tvalid
  .m_axis_dout_tdata(outcr[32*kk+31:32*kk])    // output wire [31 : 0] m_axis_dout_tdata
);
end
endgenerate
endmodule
