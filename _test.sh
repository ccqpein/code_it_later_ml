#!/usr/local/bin/zsh

for x in {1..10}
do
	time ./_build/default/core.exe -d ../codeitlater/ > /dev/null
done
