# directory locations
VHDL_RTL_DIR 	= $(PROJ_NAME).srcs/rtl/vhdl
VLOG_RTL_DIR 	= $(PROJ_NAME).srcs/rtl/vlog
SV_RTL_DIR 		= $(PROJ_NAME).srcs/rtl/sv
VHDL_TB_DIR 	= $(PROJ_NAME).srcs/tb/vhdl
VLOG_TB_DIR 	= $(PROJ_NAME).srcs/tb/vlog
SV_TB_DIR 		= $(PROJ_NAME).srcs/tb/sv
WORK_LIB 		= $(PROJ_NAME).libs

# create work library
library:
	vlib $(WORK_LIB)

# create modelsim.ini
modelsim: Makefile
	rm -rf modelsim.ini
	echo [Library] >> modelsim.ini
	echo others = "$$"MODEL_TECH/../modelsim.ini >> modelsim.ini
	echo work = $(WORK_LIB) >> modelsim.ini

# compile verilog
vlog_rtl:
	$(eval SRC_FILES :=$(wildcard $(VLOG_RTL_DIR)/*.v))
	$(eval NO_OF_FILES := $(words $(SRC_FILES)))
	@if [ ${NO_OF_FILES} -gt 0 ] ; then \
        for file in $(SRC_FILES); do \
			vlog -work $(WORK_LIB)/ $${file}; \
		done \
    fi

vlog_tb:
	$(eval SRC_FILES :=$(wildcard $(VLOG_TB_DIR)/*.v))
	$(eval NO_OF_FILES := $(words $(SRC_FILES)))
	@if [ ${NO_OF_FILES} -gt 0 ] ; then \
        for file in $(SRC_FILES); do \
			vlog -work $(WORK_LIB)/ $${file}; \
		done \
    fi

# compile vhdl
vhdl_rtl: 
	$(eval SRC_FILES :=$(wildcard $(VHDL_RTL_DIR)/*.vhd))
	$(eval NO_OF_FILES := $(words $(SRC_FILES)))
	@if [ ${NO_OF_FILES} -gt 0 ] ; then \
        for file in $(SRC_FILES); do \
			vcom -2008 -work $(WORK_LIB)/ $${file}; \
		done \
    fi

vhdl_tb:
	$(eval SRC_FILES :=$(wildcard $(VHDL_TB_DIR)/*.vhd))
	$(eval NO_OF_FILES := $(words $(SRC_FILES)))
	@if [ ${NO_OF_FILES} -gt 0 ] ; then \
        for file in $(SRC_FILES); do \
			vcom -2008 -work $(WORK_LIB)/ $${file}; \
		done \
    fi

# compile sv
sv_rtl:
	$(eval SRC_FILES :=$(wildcard $(SV_RTL_DIR)/*.sv))
	$(eval NO_OF_FILES := $(words $(SRC_FILES)))
	@if [ ${NO_OF_FILES} -gt 0 ] ; then \
        for file in $(SRC_FILES); do \
			vlog -work $(WORK_LIB)/ $${file}; \
		done \
    fi

sv_tb:
	$(eval SRC_FILES :=$(wildcard $(VLOG_TB_DIR)/*.sv))
	$(eval NO_OF_FILES := $(words $(SRC_FILES)))
	@if [ ${NO_OF_FILES} -gt 0 ] ; then \
        for file in $(SRC_FILES); do \
			vcom -work $(WORK_LIB)/ $${file}; \
		done \
    fi

all: library modelsim \
		vlog_rtl vlog_tb \
		vhdl_rtl vhdl_tb \
		sv_rtl sv_tb 

init: library modelsim

clean:
	$(eval LIBS :=$(wildcard *.libs/))
	$(eval NO_OF_LIBS := $(words $(LIBS)))
	@if [ ${NO_OF_LIBS} -gt 0 ] ; then \
        echo Deleting libraries ; \
        vdel -all ; \
    fi
	@echo Deleting modelsim.ini
	@rm -f modelsim.ini