#!/bin/bash

iverilog -g2012 -o sim register_file.sv register_file_tb.sv && vvp sim