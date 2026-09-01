#!/bin/bash

iverilog -g2012 -o sim program_counter.sv program_counter_tb.sv && vvp sim