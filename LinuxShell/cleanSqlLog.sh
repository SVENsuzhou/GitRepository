#!/bin/bash
#auther: zhu huifeng

#MYSQL�û���������
User="wolsdgame"
Passwd="F97aDWQZ"
Host="10.146.68.150"

#��־��Ҫ��������
declare -i save=3

#��ǰ�������
declare -i curYear=`date +%Y:%m | awk -F ':' '{print $1}'`
declare -i curMonth=`date +%Y:%m | awk -F ':' '{print $2}'`

#������Ҫɾ�����·�
delMonth=$[$curMonth-$save]
declare -i delYear=$curYear

if [[ $delMonth -le 0 ]]; then
	delYear=$[$delYear-1]
	delMonth=$[$delMonth+12]
fi

#���㵱ǰ��ָ���µ�����
declare -i sumDay=`cal $delMonth $delYear | sed '/^$/d' | awk '{print $NF}' | tail -1`

#С��10���·ݽ��в�0����
if [[ $delMonth -lt 10 ]]; then
	delMonth=0$delMonth
fi

#ɾ����
for I in `seq -w 1 $sumDay`; do
	mysql -u $User -p$Passwd -h $Host -e "drop table zonedb.logger_$delYear$delMonth$I;"
done
