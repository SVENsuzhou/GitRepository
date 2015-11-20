#!/bin/bash
#auther: zhu huifeng

#MYSQL用户名和密码
User="wolsdgame"
Passwd="F97aDWQZ"
Host="10.146.68.150"

#日志需要保留月数
declare -i save=3

#当前的年和月
declare -i curYear=`date +%Y:%m | awk -F ':' '{print $1}'`
declare -i curMonth=`date +%Y:%m | awk -F ':' '{print $2}'`

#计算需要删除的月份
delMonth=$[$curMonth-$save]
declare -i delYear=$curYear

if [[ $delMonth -le 0 ]]; then
	delYear=$[$delYear-1]
	delMonth=$[$delMonth+12]
fi

#计算当前年指定月的天数
declare -i sumDay=`cal $delMonth $delYear | sed '/^$/d' | awk '{print $NF}' | tail -1`

#小于10的月份进行补0操作
if [[ $delMonth -lt 10 ]]; then
	delMonth=0$delMonth
fi

#删除表
for I in `seq -w 1 $sumDay`; do
	mysql -u $User -p$Passwd -h $Host -e "drop table zonedb.logger_$delYear$delMonth$I;"
done
