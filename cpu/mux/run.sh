#!/bin/bash

iverilog -g2012 -o sim mux.sv mux_tb.sv
vvp sim