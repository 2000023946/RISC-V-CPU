#!/bin/bash

iverilog -g2012 -o sim pc_mux.sv pc_mux_tb.sv && vvp sim