#!/bin/bash
SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
RTL_DIR="$SCRIPT_DIR/../src"

verilator +1800-2017ext+* -sv -Wall \
+define+VIDEO_1024_768 \
-f $RTL_DIR/rtl.files -Wno-EOFNEWLINE -Wno-PINMISSING \
-Wno-WIDTHEXPAND -Wno-WIDTHTRUNC \
--bbox-unsup --lint-only 
