#!/bin/bash
#author: zhu huifeng
trap "exec 6>&- && exec 6<&- && exit 1" SIGINT
fifofile="/tmp/$$.fifo"
/bin/mknod $fifofile p                          #�½�һ��fifo���͵��ļ�
exec 6<>$fifofile                               #���ļ�������fd6�͹ܵ��ļ����а�
rm $fifofile

thread=5                                        #�˴������߳���
for ((i=0;i<$thread;i++));do
	echo >&6                                      #��ʵ�Ͼ�����fd6�з�����$thread���س���
done

for ((i=0;i<255;i++));do
	read -u6   #һ��read -u6����ִ��һ�Σ��ʹ�fd6�м�ȥһ���س�����Ȼ������ִ�У�fd6��û�лس�����ʱ�򣬾�ͣ�����ˣ��Ӷ�ʵ�����߳���������
	{     #�˴��ӽ��̿�ʼִ�У����ŵ���̨
		ping -c 1 -w 1 192.168.0.$i &> /dev/null
		if [ $? -eq 0 ]; then
			echo -e "192.168.0.$i is exist..."
		fi
		echo >&6        #�����̽����Ժ�����fd6�м���һ���س�������������read -u6��ȥ���Ǹ�
	} &
done 
wait                #�ȴ����еĺ�̨�ӽ��̽���

exec 6>&-
exec 6<&-           #�ر��ļ�������fd6

exit 0
