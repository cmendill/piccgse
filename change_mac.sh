#!/bin/bash

sudo ifconfig enp0s25 down
sudo ifconfig enp0s25 hw ether 3c:97:0e:8f:bc:5c
sudo ifconfig enp0s25 up
