#!/bin/bash
IFS=$'\n'
function out () {
	name=$(stat $1 | grep File | awk '{for (i=2; i<10; i++) print $i}')
	size=$(stat $1 | grep Size | awk '{print $2}')
	modif=$(stat -c %y $1 | awk '{print $1}')
	if file -ib "$1" | grep 'video'
	then
		duration=$(ffmpeg -i $1 2>&1 | grep Duration | awk '{print $2}' )
	elif file -ib "$1" | grep 'audio'
	then
		duration=$(ffmpeg -i $1 2>&1 | grep Duration | awk '{print $2}' )
	else
		duration=""
	fi
	echo "$name, $size, $modif, $duration"
}

function func () {
for all in $(ls $1)
do
	if [[ -f $all ]]
	then
		out $all
	fi
	if [[ -d $all ]]
	then
		cd $all
		func $1/$all
		cd ../
	fi
done
}

echo "name, size, modification, duration" >> LIST.csv
func "$(pwd)" >> LIST.csv
