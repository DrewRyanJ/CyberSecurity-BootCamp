#!/bin/bash

cat "$1"_Dealer_schedule | awk -F" " '{print $1, $2, $5, $6}'| grep "$2" | grep "$3" 

