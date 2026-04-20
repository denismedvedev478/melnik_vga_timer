set SIM_OPTIONS "-sv_seed random -voptargs=+acc -debugDB"
vlib work
vmap work work

vlog -work work -l logs/compile_rtl.log ../../src/timer_char_line.sv
vlog -work work -l logs/compile_tb.log tb_rom.sv

vsim -sv_seed random -voptargs=+acc -debugDB -l logs/simulation.log -do "run -all;" work.tb_rom