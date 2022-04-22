
# directory locations
VHDL_RTL_DIR = "Pong.srcs/rtl/vhdl"
VLOG_RTL_DIR = "Pong.srcs/rtl/vlog"
SV_RTL_DIR = "Pong.srcs/rtl/sv"
VHDL_TB_DIR = "Pong.srcs/tb/vhdl"
VLOG_TB_DIR = "Pong.srcs/tb/vlog"
SV_TB_DIR = "Pong.srcs/tb/sv"
WORK_LIB = "Pong.libs"

# vhdl_rtl: 
# 	$(WORK_LIB)/_info modelsim.ini $(VHDL_RTL_DIR)/*.vhd $(WORK_LIB)/vhdl_rtl.cv

$(WORK_LIB)/_info:
	vlib $(WORK_LIB)
# create modelsim.ini
modelsim.ini: Makefile
	rm -rf modelsim.ini
	echo [Library] >> modelsim.ini
	echo others = $$$$MODEL_TECH/../modelsim.ini >> modelsim.ini
	echo work = $(WORK_LIB) >> modelsim.ini

# compile verilog
# vlog -work $(WORK_LIB)/

# compile vhdl
vhdl_rtl: 
	vcom -2008 -work $(WORK_LIB)/ $(VHDL_RTL_DIR)/*.vhd


# compile sv

clean:
	rm -f modelsim.ini