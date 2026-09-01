#!/bin/bash

iverilog -g2012 -o sim password_detector.sv password_detector_tb.sv && vvp sim