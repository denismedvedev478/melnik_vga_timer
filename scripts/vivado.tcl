set CURDIR [file normalize [file dirname [info script]]]
set PRJDIR "$CURDIR/.."
set RTLDIR "$PRJDIR/src"
set XDCDIR "$PRJDIR/xdc"
set TMPDIR "$PRJDIR/tmp"
set PRJNAME "melnik_vga_timer"

file mkdir $TMPDIR
cd $TMPDIR

create_project $PRJNAME -force -part xc7a35ticsg324-1L
add_files -fileset sources_1 -norecurse ${RTLDIR}

add_files -fileset constrs_1 -norecurse ${XDCDIR}

update_compile_order -fileset sources_1