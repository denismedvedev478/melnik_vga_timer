set SIM_OPTIONS "-sv_seed random -voptargs=+acc -debugDB"
vlib work
vmap work work

vlog -work work -l logs/compile_rtl.log ../../src/debouncer.sv
vlog -work work -l logs/compile_tb.log tb_debouncer.sv

vsim -sv_seed random -voptargs=+acc -debugDB -l logs/simulation.log -do "do wave.do; run -all;" work.tb_debouncer