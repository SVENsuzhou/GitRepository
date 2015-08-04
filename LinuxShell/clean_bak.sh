#!/bin/bash
#author: zhu huifeng
trap "exec 1000>&- && exec 1000<&- && exit 1" SIGINT

#�����ܵ����ļ�������
fifofile="/tmp/$$.fifo"
/bin/mknod $fifofile p
exec 1000<>$fifofile
rm $fifofile

thread=10
for ((i=0;i<$thread;i++)); do
    echo >& 1000
done

#��������MYZONE������
DIR="/db/backup/"
DAYBAK="/db/daybackup/"
[ -d $DAYBAK ] || mkdir $DAYBAK       #���ÿ�ձ����ļ����Ƿ����

declare -a MYZONE
declare -i M=0
for ZONE in `/bin/find $DIR -name \*-$(/bin/date +%Y%m%d)_\*.sql | grep -o record.*- | awk -F '-' '{print $1}' | sort -u`; do
    MYZONE[$M]=$ZONE
    let M=$M+1
done

#��ʼ����̴��
for ((i=0;i<$M;i++)); do
    read -u 1000
    {
        cd $DIR
        /bin/find . -name ${MYZONE[$i]}-`/bin/date --date='1 days ago' +%Y%m%d`_\*.sql -exec basename {} \; | sort | xargs tar zcf ${DAYBAK}${MYZONE[$i]}-`/bin/date --date='1 days ago' +%Y%m%d`.tar.gz --remove-files
        echo >& 1000
    } &
done
wait

#��ȡ�����ļ�������
declare -a MyDate
declare -i n=0
for I in `ls $DAYBAK | grep [0-9]*\.tar\.gz | cut -d '.' -f 1 | cut -d '-' -f 2 | sort -u`; do
    MyDate[$n]=$I
    let n=$n+1
done

#debug()
#{
#for I in `seq 0 $[$n-1]`; do
#    echo ${MyDate[$I]}
#done
#}

#������ֵ��ɾ��һ���ֱ����ļ�
declare -i real_num
declare -i disk_num
real_num=`du -s /db/ | cut -f 1`
disk_num=60000000
if [ $real_num -gt $disk_num ]; then
   for I in `seq 0 2`; do
      /bin/rm -rf $DAYBAK*-${MyDate[$I]}.tar.gz
   done
fi


exec 1000>&-
exec 1000<&-

exit 0