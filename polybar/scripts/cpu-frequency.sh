#!/bin/sh

lscpu | grep "CPU MHz" | awk '{sub("\\..*", "", $3); print $3 " MHz"}'
