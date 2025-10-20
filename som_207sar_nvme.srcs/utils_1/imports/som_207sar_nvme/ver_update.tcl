
set file_addr "../../som_207sar_nvme.srcs/sources_1/new/version_date.vh"

set time_now [clock seconds]
set time0 [clock format $time_now -format "%Y%m%d"]
set time1 [clock format $time_now -format "%H%M%S"]

set f [open $file_addr r]

gets $f lines
close $f
set f [open $file_addr w]

puts $f $lines

set str "parameter 	[31:0]  	FPGA_VERSION_DATA = 32'h$time0;"
puts $f $str

set str "parameter 	[31:0] 		FPGA_VERSION_TIME = 32'h$time1;"
puts $f $str

close $f