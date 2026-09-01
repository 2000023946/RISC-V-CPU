#!/bin/bash

iverilog -g2012 -o sim memory.sv memory_tb.sv && vvp sim