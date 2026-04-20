onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb_timer/timer_inst/clk
add wave -noupdate /tb_timer/timer_inst/rst
add wave -noupdate /tb_timer/timer_inst/key1_min
add wave -noupdate /tb_timer/timer_inst/key2_sec
add wave -noupdate /tb_timer/timer_inst/key3_mode
add wave -noupdate /tb_timer/timer_inst/min_o
add wave -noupdate /tb_timer/timer_inst/sec_o
add wave -noupdate /tb_timer/timer_inst/ms_o
add wave -noupdate /tb_timer/timer_inst/timeout
add wave -noupdate /tb_timer/timer_inst/state_o
add wave -noupdate /tb_timer/timer_inst/tick_1ms
add wave -noupdate /tb_timer/timer_inst/cnt
add wave -noupdate /tb_timer/timer_inst/state
add wave -noupdate /tb_timer/timer_inst/next_state
add wave -noupdate /tb_timer/timer_inst/set_min
add wave -noupdate /tb_timer/timer_inst/set_sec
add wave -noupdate /tb_timer/timer_inst/timer
add wave -noupdate /tb_timer/timer_inst/timer_min
add wave -noupdate /tb_timer/timer_inst/timer_sec
add wave -noupdate /tb_timer/timer_inst/timer_ms
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ns} 0}
quietly wave cursor active 0
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {0 ns} {1 us}
