#!/bin/bash
#echo "[" > location.json #
COUNTER=0 #
grep sendFingerprint out.txt | grep INFO | cut -d "{" -f2- | while read -r line; do
  let COUNTER=COUNTER+1;
  if [[ $COUNTER -gt "1" ]]; then
    echo ","
  fi
  echo "{$line";
done > location.json #
#echo "]" >> location.json #
