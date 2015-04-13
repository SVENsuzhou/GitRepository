#!/bin/bash
#author: zhu huifeng
trap "exec 1000>&- && exec 1000<&- && exit 1" SIGINT

#关联命名管道和文件描述符
fifofile="/tmp/$$.fifo"
/bin/mknod $fifofile p
exec 1000<>$fifofile
rm $fifofile

#定义进程数
thread=10
for ((i=0;i<$thread;i++)); do
    echo >& 1000
done

#将区名字填入MYZONE数组中
DIR="/db/backup/"
declare -a MYZONE
declare -i M=0
for ZONE in `/bin/find $DIR -name \*-$(/bin/date +%Y%m%d)_\*.sql | grep -o record.*- | awk -F '-' '{print $1}' | sort -u`; do
    MYZONE[$M]=$ZONE
    let M=$M+1
done 

#开始多进程打包
for ((i=0;i<$M;i++)); do
    read -u 1000
    {
	cd $DIR
        /bin/find . -name ${MYZONE[$i]}-`/bin/date --date='1 days ago' +%Y%m%d`_\*.sql -exec basename {} \; | sort | xargs tar zcf ${MYZONE[$i]}-`/bin/date --date='1 days ago' +%Y%m%d`.tar.gz --remove-files
	echo >& 1000
    } &
done
wait

#获取备份文件的日期
declare -a MyDate
declare -i n=0
for I in `ls $DIR | grep [0-9]*\.tar\.gz | cut -d '.' -f 1 | cut -d '-' -f 2`; do 
    MyDate[$n]=$I
    let n=$n+1
done

#debug()
#{
#for I in `seq 0 $[$n-1]`; do
#    echo ${MyDate[$I]}
#done
#}

#当磁盘空间小于某个值时，将最早的5个日期的备份文件删除
declare -i real_num
declare -i disk_num
real_num=`du -s $DIR | cut -f 1`
disk_num=60000000
if [ $real_num -gt $disk_num ]; then
   for I in `seq 0 4`; do
      /bin/rm -f $DIR*-${MyDate[$I]}.tar.gz
   done
fi

#取消文件描述符的关联
exec 1000>&-
exec 1000<&-

exit 0