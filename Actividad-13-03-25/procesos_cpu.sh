#!/bin/bash

echo "Procesos usando mas de 1% de CPU:"
ps -eo pid,cmd,%cpu --sort=-%cpu | awk 'NR==1 || $3+0 > 1'
