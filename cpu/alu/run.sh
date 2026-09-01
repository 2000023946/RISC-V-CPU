#!/bin/bash

iverilog -g2012 -o sim alu.sv alu_tb.sv
vvp sim