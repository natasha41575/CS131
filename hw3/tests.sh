#!/bin/bash

max_int=127
transitions=1000000
models=(Null Synchronized Unsynchronized GetNSet BetterSafe)
threads=(8 16 32)

echo -e "Using" $transitions "transitions\n"

for model in ${models[*]}
do
    for thread in ${threads[*]}
    do
        echo $model "model with" $thread "threads:"
        java UnsafeMemory $model $thread $transitions 127 32 80 25 10 53 125 109 53 109 86 87 44 124 86 125 2 17 123 67 126 63 8 126 10 18 46 9 9 67 124 2 34 26 119 8 97 53 12 6 30 34 10 90 112 118 126 16 75 55 14 1 4 44 38 108 44 86 114 66 109 114 47 91 61 127 86 46 18 108 45 85 34 36 96 32 88 19 78 50 87 44 8 102 48 47 60 117 70 99 61 51 50 110 4 40 19 116 58 2 0  
        echo
    done
done