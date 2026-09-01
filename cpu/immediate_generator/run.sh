#!/bin/bash

iverilog -g2012 -o sim immediate_generator.sv immediate_generator_tb.sv && vvp sim