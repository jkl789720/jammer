task cct_init;
begin
	//force UUT.datachannel_wrap_EP0.control_unit_EP0.cfg_AD_base = 0;
	//force UUT.datachannel_wrap_EP0.control_unit_EP0.cfg_AD_rnum = 0;
	//force UUT.datachannel_wrap_EP0.control_unit_EP0.cfg_AD_anum = 0;
	//force UUT.datachannel_wrap_EP0.control_unit_EP0.cfg_AD_delay = 0;
	//force UUT.datachannel_wrap_EP0.control_unit_EP0.cfg_AD_div = 0;
	//force UUT.datachannel_wrap_EP0.control_unit_EP0.cfg_AD_repeat = 0;
	//force UUT.datachannel_wrap_EP0.cfg_AD_mode[5] = 0;
	//force UUT.datachannel_wrap_EP0.control_unit_EP0.cfg_AD_multiclr = 0;
	//force UUT.datachannel_wrap_EP0.control_unit_EP0.cfg_AD_start = 0;
	//force UUT.datachannel_wrap_EP0.control_unit_EP0.cfg_DA_base = 0;
	//force UUT.datachannel_wrap_EP0.control_unit_EP0.cfg_DA_rnum = 0;
	//force UUT.datachannel_wrap_EP0.control_unit_EP0.cfg_DA_anum = 0;
	//force UUT.datachannel_wrap_EP0.control_unit_EP0.cfg_DA_delay = 0;
	//force UUT.datachannel_wrap_EP0.control_unit_EP0.cfg_DA_div = 0;
	//force UUT.datachannel_wrap_EP0.control_unit_EP0.cfg_DA_repeat = 0;
	//force UUT.datachannel_wrap_EP0.control_unit_EP0.cfg_DA_continu = 0;
	//force UUT.datachannel_wrap_EP0.control_unit_EP0.cfg_DA_multiclr = 0;
	//force UUT.datachannel_wrap_EP0.control_unit_EP0.cfg_DA_start = 0;
	//force UUT.datachannel_wrap_EP0.control_unit_EP0.cfg_mode_auxen = 0;
	//force UUT.datachannel_wrap_EP0.control_unit_EP0.cfg_mode_selda = 0;
	//force UUT.datachannel_wrap_EP0.control_unit_EP0.cfg_mode_selad = 0;	
	
	force UUT.datachannel_wrap_EP0.cfg_mAD_base = 0;
	force UUT.datachannel_wrap_EP0.cfg_mAD_rnum = 0;
	force UUT.datachannel_wrap_EP0.cfg_mAD_anum = 0;
	force UUT.datachannel_wrap_EP0.cfg_mAD_delay = 0;
	force UUT.datachannel_wrap_EP0.cfg_mAD_mode[3:0] = 0;
	force UUT.datachannel_wrap_EP0.cfg_mAD_mode[4] = 0;
	force UUT.datachannel_wrap_EP0.cfg_mAD_mode[5] = 0;
	force UUT.datachannel_wrap_EP0.cfg_mAD_mode[6] = 0;
	force UUT.datachannel_wrap_EP0.cfg_mAD_mode[8] = 0;
	force UUT.datachannel_wrap_EP0.cfg_mDA_base = 0;
	force UUT.datachannel_wrap_EP0.cfg_mDA_rnum = 0;
	force UUT.datachannel_wrap_EP0.cfg_mDA_anum = 0;
	force UUT.datachannel_wrap_EP0.cfg_mDA_delay = 0;
	force UUT.datachannel_wrap_EP0.cfg_mDA_mode[3:0] = 0;
	force UUT.datachannel_wrap_EP0.cfg_mDA_mode[4] = 0;
	force UUT.datachannel_wrap_EP0.cfg_mDA_mode[5] = 0;
	force UUT.datachannel_wrap_EP0.cfg_mDA_mode[6] = 0;
	force UUT.datachannel_wrap_EP0.cfg_mDA_mode[8] = 0;

	//force UUT.datachannel_wrap_EP0.cfg_D2H_ptr_sym = 32'hFFFFFFFF;	
	force UUT.datachannel_wrap_EP0.cfg_D2H_ptr_sym = 32'h00000200;	
end
endtask

localparam param_rnum = 16384;
localparam param_anum = 32768;

task cct_start;
input [31:0] adaddr, daaddr;
input adsel, dasel;
input adrep, darep;
input adcon, dacon;
input adclr, daclr;
input [3:0] addiv, dadiv;
begin
	force UUT.datachannel_wrap_EP0.host_channel_EP0.cfg_D2H_addr_dma = 0;
	force UUT.datachannel_wrap_EP0.host_channel_EP0.cfg_D2H_addr_sym = 32'h800000;
	force UUT.datachannel_wrap_EP0.host_channel_EP0.cfg_D2H_size_dma = 32'h800000;
	force UUT.datachannel_wrap_EP0.host_channel_EP0.cfg_D2H_size_sym = 32'h800000;
	force UUT.datachannel_wrap_EP0.host_channel_EP0.cfg_D2H_burst_len = 32;
	if(adcon)begin
		force UUT.datachannel_wrap_EP0.host_channel_EP0.cfg_D2H_frame_len = 40960*2/addiv;
		force UUT.datachannel_wrap_EP0.host_channel_EP0.cfg_D2H_trans_len = 40960*2/addiv;	
	end
	else begin
		force UUT.datachannel_wrap_EP0.host_channel_EP0.cfg_D2H_frame_len = param_rnum*2/addiv;
		force UUT.datachannel_wrap_EP0.host_channel_EP0.cfg_D2H_trans_len = param_rnum*2/addiv;
	end

	force UUT.datachannel_wrap_EP0.host_channel_EP0.cfg_H2D_addr_dma = 0;
	force UUT.datachannel_wrap_EP0.host_channel_EP0.cfg_H2D_size_dma = 32'h800000;
	force UUT.datachannel_wrap_EP0.host_channel_EP0.cfg_H2D_burst_len = 32;
	if(dacon)begin
		force UUT.datachannel_wrap_EP0.host_channel_EP0.cfg_H2D_frame_len = 40960*2/dadiv;
		force UUT.datachannel_wrap_EP0.host_channel_EP0.cfg_H2D_trans_len = 40960*2/dadiv;
	end
	else begin
		force UUT.datachannel_wrap_EP0.host_channel_EP0.cfg_H2D_frame_len = param_anum*2/dadiv;
		force UUT.datachannel_wrap_EP0.host_channel_EP0.cfg_H2D_trans_len = param_anum*2/dadiv;
	end
	
	force UUT.datachannel_wrap_EP0.host_channel_EP0.ram_dout = {224'h0, 32'hDAC0_FF00};
	#10;
	force UUT.datachannel_wrap_EP0.host_channel_EP0.cfg_D2H_axi_ctrl = 1;
	force UUT.datachannel_wrap_EP0.host_channel_EP0.cfg_H2D_axi_ctrl = 1;
	#10;
	/*
	force UUT.datachannel_wrap_EP0.control_unit_EP0.cfg_AD_base = adaddr;
	if(adcon)begin
		force UUT.datachannel_wrap_EP0.control_unit_EP0.cfg_AD_rnum = 20480*2;
	end
	else begin
		force UUT.datachannel_wrap_EP0.control_unit_EP0.cfg_AD_rnum = param_rnum;
	end
	force UUT.datachannel_wrap_EP0.control_unit_EP0.cfg_AD_anum = 8;
	force UUT.datachannel_wrap_EP0.control_unit_EP0.cfg_AD_delay = 32;
	force UUT.datachannel_wrap_EP0.control_unit_EP0.cfg_AD_div = addiv;
	force UUT.datachannel_wrap_EP0.control_unit_EP0.cfg_AD_repeat = adrep;
	force UUT.datachannel_wrap_EP0.cfg_AD_mode[5] = adcon;
	force UUT.datachannel_wrap_EP0.control_unit_EP0.cfg_AD_multiclr = adclr;
	force UUT.datachannel_wrap_EP0.control_unit_EP0.cfg_mode_selad = adsel;	
	#10;
	force UUT.datachannel_wrap_EP0.control_unit_EP0.cfg_AD_start = 1;
	force UUT.datachannel_wrap_EP0.control_unit_EP0.cfg_DA_base = daaddr;
	if(dacon)begin
		force UUT.datachannel_wrap_EP0.control_unit_EP0.cfg_DA_rnum = 20480*2;
	end
	else begin
		force UUT.datachannel_wrap_EP0.control_unit_EP0.cfg_DA_rnum = param_anum;
	end
	force UUT.datachannel_wrap_EP0.control_unit_EP0.cfg_DA_anum = 12;
	force UUT.datachannel_wrap_EP0.control_unit_EP0.cfg_DA_delay = 64;
	force UUT.datachannel_wrap_EP0.control_unit_EP0.cfg_DA_div = dadiv;
	force UUT.datachannel_wrap_EP0.control_unit_EP0.cfg_DA_repeat = darep;
	force UUT.datachannel_wrap_EP0.control_unit_EP0.cfg_DA_continu = dacon;
	force UUT.datachannel_wrap_EP0.control_unit_EP0.cfg_DA_multiclr = daclr;
	force UUT.datachannel_wrap_EP0.control_unit_EP0.cfg_mode_selda = dasel;
	
	force UUT.datachannel_wrap_EP0.control_unit_EP0.cfg_mode_auxen = 0;
	#10;
	force UUT.datachannel_wrap_EP0.control_unit_EP0.cfg_DA_start = 1;
	#1000;
	*/
end
endtask

task cct_stop;
begin
	force UUT.datachannel_wrap_EP0.control_unit_EP0.cfg_AD_start = 0;
	force UUT.datachannel_wrap_EP0.control_unit_EP0.cfg_DA_start = 0;
	force UUT.datachannel_wrap_EP0.cfg_mAD_mode[8] = 0;
	force UUT.datachannel_wrap_EP0.cfg_mDA_mode[8] = 0;
	#10;
	force UUT.datachannel_wrap_EP0.host_channel_EP0.cfg_D2H_axi_ctrl = 0;
	force UUT.datachannel_wrap_EP0.host_channel_EP0.cfg_H2D_axi_ctrl = 0;
	#10;
end
endtask

task prf_start;
input [31:0] ptime, dtime;
begin
	force UUT.datachannel_wrap_EP0.control_unit_EP0.cfg_prftime = ptime;
	force UUT.datachannel_wrap_EP0.control_unit_EP0.cfg_pretime = dtime;
	force UUT.datachannel_wrap_EP0.control_unit_EP0.cfg_prfmode = 32'h12;
end
endtask
task prf_stop;
begin
	force UUT.datachannel_wrap_EP0.control_unit_EP0.cfg_prftime = 0;
	force UUT.datachannel_wrap_EP0.control_unit_EP0.cfg_pretime = 0;
	force UUT.datachannel_wrap_EP0.control_unit_EP0.cfg_prfmode = 0;
end
endtask

task cct_start_mem;
input [31:0] adaddr, daaddr;
input adsel, dasel;
input adrep, darep;
input adcon, dacon;
input adclr, daclr;
input [3:0] addiv, dadiv;
begin
	#10;
	force UUT.datachannel_wrap_EP0.cfg_mAD_base = adaddr;
	if(adcon)begin
		force UUT.datachannel_wrap_EP0.cfg_mAD_rnum = 20480*2;
	end
	else begin
		force UUT.datachannel_wrap_EP0.cfg_mAD_rnum = param_rnum;
	end
	force UUT.datachannel_wrap_EP0.cfg_mAD_anum = 8;
	force UUT.datachannel_wrap_EP0.cfg_mAD_delay = 32;
	force UUT.datachannel_wrap_EP0.cfg_mAD_mode[3:0] = addiv;
	force UUT.datachannel_wrap_EP0.cfg_mAD_mode[4] = adrep;
	force UUT.datachannel_wrap_EP0.cfg_mAD_mode[5] = adcon;
	force UUT.datachannel_wrap_EP0.cfg_mAD_mode[6] = adclr;
	#10;
	force UUT.datachannel_wrap_EP0.cfg_mAD_mode[8] = 1;
	force UUT.datachannel_wrap_EP0.control_unit_EP0.cfg_DA_base = daaddr;
	if(dacon)begin
		force UUT.datachannel_wrap_EP0.cfg_mDA_rnum = 20480*2;
	end
	else begin
		force UUT.datachannel_wrap_EP0.cfg_mDA_rnum = param_anum;
	end
	force UUT.datachannel_wrap_EP0.cfg_mDA_anum = 12;
	force UUT.datachannel_wrap_EP0.cfg_mDA_delay = 500;
	force UUT.datachannel_wrap_EP0.cfg_mDA_mode[3:0] = dadiv;
	force UUT.datachannel_wrap_EP0.cfg_mDA_mode[4] = darep;
	force UUT.datachannel_wrap_EP0.cfg_mDA_mode[5] = dacon;
	force UUT.datachannel_wrap_EP0.cfg_mDA_mode[6] = daclr;
	#10;
	force UUT.datachannel_wrap_EP0.cfg_mDA_mode[8] = 1;
	#1000;
end
endtask

task cct_start_host;
input [31:0] adaddr, daaddr;
input adsel, dasel;
input adrep, darep;
input adcon, dacon;
input adclr, daclr;
input [3:0] addiv, dadiv;
begin
	#10;
	force UUT.datachannel_wrap_EP0.control_unit_EP0.cfg_AD_base = adaddr;
	if(adcon)begin
		force UUT.datachannel_wrap_EP0.control_unit_EP0.cfg_AD_rnum = 20480*2;
	end
	else begin
		force UUT.datachannel_wrap_EP0.control_unit_EP0.cfg_AD_rnum = param_rnum;
	end
	force UUT.datachannel_wrap_EP0.control_unit_EP0.cfg_AD_anum = 8;
	force UUT.datachannel_wrap_EP0.control_unit_EP0.cfg_AD_delay = 32;
	force UUT.datachannel_wrap_EP0.control_unit_EP0.cfg_AD_div = addiv;
	force UUT.datachannel_wrap_EP0.control_unit_EP0.cfg_AD_repeat = adrep;
	force UUT.datachannel_wrap_EP0.cfg_mAD_mode[5] = adcon;
	force UUT.datachannel_wrap_EP0.control_unit_EP0.cfg_AD_multiclr = adclr;
	#10;
	force UUT.datachannel_wrap_EP0.control_unit_EP0.cfg_AD_start = 1;
	force UUT.datachannel_wrap_EP0.control_unit_EP0.cfg_DA_base = daaddr;
	if(dacon)begin
		force UUT.datachannel_wrap_EP0.control_unit_EP0.cfg_DA_rnum = 20480*2;
	end
	else begin
		force UUT.datachannel_wrap_EP0.control_unit_EP0.cfg_DA_rnum = param_anum;
	end
	force UUT.datachannel_wrap_EP0.control_unit_EP0.cfg_DA_anum = 12;
	force UUT.datachannel_wrap_EP0.control_unit_EP0.cfg_DA_delay = 64;
	force UUT.datachannel_wrap_EP0.control_unit_EP0.cfg_DA_div = dadiv;
	force UUT.datachannel_wrap_EP0.control_unit_EP0.cfg_DA_repeat = darep;
	force UUT.datachannel_wrap_EP0.control_unit_EP0.cfg_DA_continu = dacon;
	force UUT.datachannel_wrap_EP0.control_unit_EP0.cfg_DA_multiclr = daclr;
	#10;
	force UUT.datachannel_wrap_EP0.control_unit_EP0.cfg_DA_start = 1;
	#1000;
end
endtask


/*
task cct_start_pcie;
input [31:0] adaddr, daaddr;
input adsel, dasel;
input adrep, darep;
input adcon, dacon;
input adclr, daclr;
input [3:0] addiv, dadiv;
begin
	force UUT.datachannel_wrap_EP0.host_channel_EP0.cfg_D2H_addr_dma = 0;
	force UUT.datachannel_wrap_EP0.host_channel_EP0.cfg_D2H_addr_sym = 32'h800000;
	force UUT.datachannel_wrap_EP0.host_channel_EP0.cfg_D2H_size_dma = 32'h800000;
	force UUT.datachannel_wrap_EP0.host_channel_EP0.cfg_D2H_size_sym = 32'h800000;
	force UUT.datachannel_wrap_EP0.host_channel_EP0.cfg_D2H_burst_len = 32;
	if(adcon)begin
		force UUT.datachannel_wrap_EP0.host_channel_EP0.cfg_D2H_frame_len = 40960*2/addiv;
		force UUT.datachannel_wrap_EP0.host_channel_EP0.cfg_D2H_trans_len = 40960*2/addiv;	
	end
	else begin
		force UUT.datachannel_wrap_EP0.host_channel_EP0.cfg_D2H_frame_len = 4096*32/addiv;
		force UUT.datachannel_wrap_EP0.host_channel_EP0.cfg_D2H_trans_len = 4096*32/addiv;
	end

	force UUT.datachannel_wrap_EP0.host_channel_EP0.cfg_H2D_addr_dma = 0;
	force UUT.datachannel_wrap_EP0.host_channel_EP0.cfg_H2D_size_dma = 32'h800000;
	force UUT.datachannel_wrap_EP0.host_channel_EP0.cfg_H2D_burst_len = 32;
	if(dacon)begin
		force UUT.datachannel_wrap_EP0.host_channel_EP0.cfg_H2D_frame_len = 40960*2/dadiv;
		force UUT.datachannel_wrap_EP0.host_channel_EP0.cfg_H2D_trans_len = 40960*2/dadiv;
	end
	else begin
		force UUT.datachannel_wrap_EP0.host_channel_EP0.cfg_H2D_frame_len = 8192*16/dadiv;
		force UUT.datachannel_wrap_EP0.host_channel_EP0.cfg_H2D_trans_len = 8192*16/dadiv;
	end
	
	force UUT.datachannel_wrap_EP0.host_channel_EP0.ram_dout = {224'h0, 32'hDAC0_FF00};
	#10;
	force UUT.datachannel_wrap_EP0.host_channel_EP0.cfg_D2H_axi_ctrl = 1;
	force UUT.datachannel_wrap_EP0.host_channel_EP0.cfg_H2D_axi_ctrl = 1;
	#10;
	force UUT.datachannel_wrap_EP0.control_unit_EP0.cfg_AD_base = adaddr;
	if(adcon)begin
		force UUT.datachannel_wrap_EP0.control_unit_EP0.cfg_AD_rnum = 20480*2;
	end
	else begin
		force UUT.datachannel_wrap_EP0.control_unit_EP0.cfg_AD_rnum = 4096*4;
	end
	force UUT.datachannel_wrap_EP0.control_unit_EP0.cfg_AD_anum = 8;
	force UUT.datachannel_wrap_EP0.control_unit_EP0.cfg_AD_delay = 32;
	force UUT.datachannel_wrap_EP0.control_unit_EP0.cfg_AD_div = addiv;
	force UUT.datachannel_wrap_EP0.control_unit_EP0.cfg_AD_repeat = adrep;
	force UUT.datachannel_wrap_EP0.cfg_AD_mode[5] = adcon;
	force UUT.datachannel_wrap_EP0.control_unit_EP0.cfg_AD_multiclr = adclr;
	force UUT.datachannel_wrap_EP0.control_unit_EP0.cfg_mode_selad = adsel;	
	#10;
	force UUT.datachannel_wrap_EP0.control_unit_EP0.cfg_AD_start = 1;
	force UUT.datachannel_wrap_EP0.control_unit_EP0.cfg_DA_base = daaddr;
	if(dacon)begin
		force UUT.datachannel_wrap_EP0.control_unit_EP0.cfg_DA_rnum = 20480*2;
	end
	else begin
		force UUT.datachannel_wrap_EP0.control_unit_EP0.cfg_DA_rnum = 8192*3;
	end
	force UUT.datachannel_wrap_EP0.control_unit_EP0.cfg_DA_anum = 12;
	force UUT.datachannel_wrap_EP0.control_unit_EP0.cfg_DA_delay = 64;
	force UUT.datachannel_wrap_EP0.control_unit_EP0.cfg_DA_div = dadiv;
	force UUT.datachannel_wrap_EP0.control_unit_EP0.cfg_DA_repeat = darep;
	force UUT.datachannel_wrap_EP0.control_unit_EP0.cfg_DA_continu = dacon;
	force UUT.datachannel_wrap_EP0.control_unit_EP0.cfg_DA_multiclr = daclr;
	force UUT.datachannel_wrap_EP0.control_unit_EP0.cfg_mode_selda = dasel;
	
	force UUT.datachannel_wrap_EP0.control_unit_EP0.cfg_mode_auxen = 0;
	#10;
	force UUT.datachannel_wrap_EP0.control_unit_EP0.cfg_DA_start = 1;
	#1000;
end
endtask
*/