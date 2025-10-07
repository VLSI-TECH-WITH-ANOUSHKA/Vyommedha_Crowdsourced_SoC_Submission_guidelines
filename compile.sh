#!/bin/bash

clear

iverilog -o output.out src/cordic_core.v src/tb.v
vvp output.out
gtkwave dump.vcd