#!/bin/bash

iverilog -g2012 -o sim decoder.sv decoder_tb.sv && vvp sim