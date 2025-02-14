`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/04/29 11:22:07
// Design Name: 
// Module Name: axi_interface
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// n = Data bus width in bytes.
// i = TID width. Recommended maximum is 8-bits.
// d = TDEST width. Recommended maximum is 4-bits.
// u = TUSER width. Recommended number of bits is an integer multiple of the width of the interface in bytes
// 
//////////////////////////////////////////////////////////////////////////////////


// axi_interface
`ifndef AXI4_INTERFACE
`define AXI4_INTERFACE
interface axi4 #(parameter ndata = 0,naddr=0,nid=0,nregion=0,nuser=0)();
//write address channel,no awuser
	logic [naddr-1:0]axi_awaddr;
	logic [7:0]axi_awlen;
	logic [2:0]axi_awsize;
	logic [1:0]axi_awburst;
	logic [0:0]axi_awlock;
	logic [3:0]axi_awcache;
	logic [2:0]axi_awprot;
	logic [3:0]axi_awqos;
	logic [nregion-1:0]axi_awregion;
	logic axi_awready;
	logic axi_awvalid;
	logic [nid-1:0]axi_awid;
	logic [nuser-1:0]axi_awuser;
//write data channel,no wuser
	logic [ndata-1:0]axi_wdata;
	logic axi_wlast;
	logic axi_wready;
	logic [ndata/8-1:0]axi_wstrb;
	logic axi_wvalid;
//Write response channel,no buser
	logic [1:0]axi_bresp;
	logic axi_bready;
    logic axi_bvalid;
	logic [nid-1:0]axi_bid;	
//Read Address Channel, no aruser
	logic [naddr-1:0]axi_araddr;
	logic [7:0]axi_arlen;
	logic [2:0]axi_arsize;
	logic [1:0]axi_arburst;
	logic [0:0]axi_arlock;
	logic [3:0]axi_arcache;
	logic [2:0]axi_arprot;
	logic [3:0]axi_arqos;
	logic [nregion-1:0]axi_arregion;
	logic axi_arready;
	logic axi_arvalid;
	logic [nid-1:0]axi_arid;
	logic [nuser-1:0]axi_aruser;
//Read Data Channel	,no ruser
	logic [ndata-1:0]axi_rdata;
	logic [1:0]axi_rresp;
	logic axi_rlast;
	logic axi_rready;
	logic axi_rvalid;
	logic [nid-1:0]axi_rid;
  
	logic [ndata/8-1:0]axi_tkeep;
	logic [3:0]axi_tuser;
	logic [3:0]axi_tdest;
	
	
//信号分组
    modport AXI_SLAVE(input axi_awuser,axi_aruser,axi_awid,axi_arid,axi_awregion,axi_arregion,axi_araddr,axi_arburst,axi_arcache,axi_arlen,axi_arlock,axi_arprot,axi_arqos,axi_arsize,axi_arvalid,axi_awaddr,axi_awburst,axi_awcache,axi_awlen,axi_awlock,axi_awprot,axi_awqos,axi_awsize,axi_awvalid,axi_bready,axi_rready,axi_wdata,axi_wlast,axi_wstrb,axi_wvalid,output axi_bid,axi_rid,axi_arready,axi_awready,axi_bresp,axi_bvalid,axi_rdata,axi_rlast,axi_rresp,axi_rvalid,axi_wready);
	modport AXI_MASTER(output axi_awuser,axi_aruser,axi_awid,axi_arid,axi_awregion,axi_arregion,axi_araddr,axi_arburst,axi_arcache,axi_arlen,axi_arlock,axi_arprot,axi_arqos,axi_arsize,axi_arvalid,axi_awaddr,axi_awburst,axi_awcache,axi_awlen,axi_awlock,axi_awprot,axi_awqos,axi_awsize,axi_awvalid,axi_bready,axi_rready,axi_wdata,axi_wlast,axi_wstrb,axi_wvalid,input axi_bid,axi_rid,axi_arready,axi_awready,axi_bresp,axi_bvalid,axi_rdata,axi_rlast,axi_rresp,axi_rvalid,axi_wready);
	modport AXI_Lite_S(input axi_araddr,axi_arprot,axi_arvalid,axi_awaddr,axi_awprot,axi_awvalid,axi_bready,axi_rready,axi_wdata,axi_wstrb,axi_wvalid,output axi_arready,axi_awready,axi_bresp,axi_bvalid,axi_rdata,axi_rresp,axi_rvalid,axi_wready);
	modport AXI_Lite_M(output axi_araddr,axi_arprot,axi_arvalid,axi_awaddr,axi_awprot,axi_awvalid,axi_bready,axi_rready,axi_wdata,axi_wstrb,axi_wvalid,input axi_arready,axi_awready,axi_bresp,axi_bvalid,axi_rdata,axi_rresp,axi_rvalid,axi_wready);
	modport AXI_Stream_S(input axi_wdata,axi_wstrb,axi_wvalid,axi_wlast,axi_tdest,axi_tuser,axi_tkeep,output axi_wready);
	modport AXI_Stream_M(output axi_wdata,axi_wstrb,axi_wvalid,axi_wlast,axi_tdest,axi_tuser,axi_tkeep,input axi_wready);
	
  
  
  
endinterface:axi4
`endif