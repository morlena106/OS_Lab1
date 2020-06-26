#!/bin/bash

#указываем разделитель полей 
IFS=$'\n'

#функция сбора и вывода информации о данном файле ($1): имя, размер, дата последнего изменения и длительность для аудио и видео файлов (выполняется проверка на медиафайл)
function out () {
	name=$1
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

#Функция проходится по списку файлов в директории, делает проверку на файл/директорию
#Для файлов вызывает функцию out(), для директорий вызывает саму себя 
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

#добавляем шапку
echo "name, size, modification, duration" >> LIST.csv

#вызываем функцию для директории, в которой находимся, создаем csv файл 
func "$(pwd)" >> LIST.csv

#делаем вывод красивеньким 
#sed 's/,/:,/g' LIST.csv | column -t -s: | sed 's/ ,/|/g'
