#!/bin/bash

SIM_OPTIONS="-sv_seed random -voptargs=+acc -debugDB"
if ! [ -d logs ]; then
    mkdir logs
fi
if ! [ -d dump ]; then
    mkdir dump
fi

if [ -n "$1" ] && [ "$1" = "gui" ]; then
	vsim.exe $SIM_OPTIONS -l logs/start.log -do "do re_tb_timer_bcd.tcl"
else 
	vsim.exe $SIM_OPTIONS -c -l logs/start.log -do "do re_tb_timer_bcd.tcl"
fi
