#!/bin/bash
#author: zhu huifeng
trap "exec 6>&- && exec 6<&- && exit 1" SIGINT
fifofile="/tmp/$$.fifo"
/bin/mknod $fifofile p                          #新建一个fifo类型的文件
exec 6<>$fifofile                               #将文件描述符fd6和管道文件进行绑定
rm $fifofile

thread=5                                        #此处定义线程数
for ((i=0;i<$thread;i++));do
	echo >&6                                      #事实上就是在fd6中放置了$thread个回车符
done

for ((i=0;i<255;i++));do
	read -u6   #一个read -u6命令执行一次，就从fd6中减去一个回车符，然后向下执行，fd6中没有回车符的时候，就停在这了，从而实现了线程数量控制
	{     #此处子进程开始执行，被放到后台
		ping -c 1 -w 1 192.168.0.$i &> /dev/null
		if [ $? -eq 0 ]; then
			echo -e "192.168.0.$i is exist..."
		fi
		echo >&6        #当进程结束以后，再向fd6中加上一个回车符，即补上了read -u6减去的那个
	} &
done 
wait                #等待所有的后台子进程结束

exec 6>&-
exec 6<&-           #关闭文件描述符fd6

exit 0
