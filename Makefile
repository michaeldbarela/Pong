
# directory locations
VHDL_RTL_DIR = "Pong.srcs/rtl/vhdl"
VLOG_RTL_DIR = "Pong.srcs/rtl/vlog"
SV_RTL_DIR = "Pong.srcs/rtl/sv"
VHDL_TB_DIR = "Pong.srcs/tb/vhdl"
VLOG_TB_DIR = "Pong.srcs/tb/vlog"
SV_TB_DIR = "Pong.srcs/tb/sv"
WORK_LIB = "Pong.libs"

# compile verilog
# vlog -work $(WORK_LIB)/

# compile vhdl
vcom -2008 -work $(WORK_LIB) $(VHDL_RTL_DIR)/*

# compile sv