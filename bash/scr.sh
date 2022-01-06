#!/bin/bash
URL=https://raw.githubusercontent.com/GreatMedivack/files/master/list.out
FILE=$(basename "$URL")
wget -q "$URL"
DATA=$(date +"%d-%m-%Y")
NAME="$(whoami)"
RESTART=$(less $FILE | awk -F" " '{ print $4}' | awk '! /RESTARTS/' | grep -cve '^0')
SERVER=${1:-SERVER_NAME}

awk '/Running/' $FILE |  awk -F" " '{ print $1}' >> "$SERVER"_"$DATA"_running.out
awk '/Error/ || /CrashLoopBackOff/' $FILE | awk -F" " '{ print $1}' >> "$SERVER"_"$DATA"_failed.out
sed -i --regexp-extended 's@-[a-z0-9]{10}-[a-z0-9]{5}$@@; s@-[a-z0-9]{9}-[a-z0-9]{5}$@@'  "$SERVER"_"$DATA"_running.out
sed -i --regexp-extended 's@-[a-z0-9]{10}-[a-z0-9]{5}$@@; s@-[a-z0-9]{9}-[a-z0-9]{5}$@@'  "$SERVER"_"$DATA"_failed.out

N1=$(sed -n '$=' "$SERVER"_"$DATA"_running.out)
N2=$(sed -n '$=' "$SERVER"_"$DATA"_failed.out)

touch "$SERVER"_"$DATA"_report.out && chmod 644 "$SERVER"_"$DATA"_report.out
echo "Количество работающих сервисов:" $N1 >> "$SERVER"_"$DATA"_report.out
echo "Количество сервисов с ошибками:" $N2 >> "$SERVER"_"$DATA"_report.out
echo "Количество перезапустившихся сервисов:" $RESTART >> "$SERVER"_"$DATA"_report.out
echo "Имя системного пользователя:" $NAME >>  "$SERVER"_"$DATA"_report.out
echo "Дата:" $DATA >> "$SERVER"_"$DATA"_report.out

mkdir -p archives
if [ -e archives/"$SERVER"_"$DATA".tar.gz ]
then
  echo "Archive exist"
else
  tar --exclude='./archives'  -cvf archives/"$SERVER"_"$DATA".tar.gz . > /dev/null
fi

RESULT=$(tar -tvf archives/"$SERVER"_"$DATA".tar.gz >/dev/null;echo $?)

ls | grep -v archives | xargs rm -rfv > /dev/null

if [ $RESULT -eq 0 ]
then
  echo "Archive is good!"
else
  echo "Archive failed!"
fi
