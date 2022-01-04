#!/bin/bash

for num in 1 2 3 4 5 6 7 8
do
./minilsp < ref/testcase/test_data/0${num}_1.lsp
printf "\n"
./minilsp < ref/testcase/test_data/0${num}_2.lsp
printf "\n"
done
