#!/usr/bin/env sh

ls -l $1 |awk '{print "[" $9 ",\x27" $9 " " $10 "\x27]"}' >> $2 
