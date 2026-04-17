onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb_debouncer/debouncer_key2_inst/clk
add wave -noupdate /tb_debouncer/debouncer_key2_inst/rst
add wave -noupdate /tb_debouncer/debouncer_key2_inst/btn_raw
add wave -noupdate /tb_debouncer/debouncer_key2_inst/btn_clean
add wave -noupdate /tb_debouncer/debouncer_key2_inst/btn_edge
add wave -noupdate /tb_debouncer/debouncer_key2_inst/cnt
add wave -noupdate /tb_debouncer/debouncer_key2_inst/btn_sync1
add wave -noupdate /tb_debouncer/debouncer_key2_inst/btn_sync2
add wave -noupdate /tb_debouncer/debouncer_key2_inst/btn_sync
add wave -noupdate /tb_debouncer/debouncer_key2_inst/btn_prev
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
