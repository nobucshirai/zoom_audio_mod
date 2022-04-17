#!/usr/bin/env python3
import sys
lines = sys.stdin.read()
flg = 0
d = {}
extract_start = 0
extract_end = 0

for line in lines.strip().split():
    #print(line)
    if line.find("silence_") >= 0:
        flg = 1
        tag = line
    elif flg == 1:
        if tag in d:
            d[tag] += [float(line)]
        else:
            d[tag] = [float(line)]
        flg = 0

if ('silence_start:' in d) and ('silence_end:' in d):
    for start, end in zip(reversed(d['silence_start:']), reversed(d['silence_end:'])):
        if start == 0:
            print(start, end)
        else:
            print(start+1, end)
