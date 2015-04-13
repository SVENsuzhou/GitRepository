#/bin/bash
#author: zhu huifeng
clean()
{
/bin/find /log/ -type f -mtime +2 -name global*\.log\.* -exec rm -f {} \;
/bin/find /log/ -type f -mtime +2 -name gate*\.log\.* -exec rm -f {} \;
/bin/find /log/ -type f -mtime +2 -name logger*\.log\.* -exec rm -f {} \;
/bin/find /log/ -type f -mtime +3 -name login*\.log\.* -exec rm -f {} \;
/bin/find /log/ -type f -mtime +3 -name license*\.log\.* -exec rm -f {} \;
/bin/find /log/ -type f -mtime +5 -name record*\.log\.* -exec rm -f {} \;
}

clean

declare -a MyDate
declare -i n
n=0
for I in `ls -l /log/ | awk '{print $9}' | grep bill\.log\.[0-9] | cut -d '.' -f 3 | cut -d '-' -f 1 | uniq -d`; do 
    MyDate[$n]=$I
    let n=$n+1
done

#测试生成数组是否成功
debug()
{
for I in `seq 0 $[$n-1]`; do
    echo ${MyDate[$I]}
done
}

declare -i real_num
declare -i disk_num
real_num=`du -s /log/ | cut -f 1`
disk_num=30000000
if [ $real_num -gt $disk_num ]; then
   for I in `seq 0 4`; do
      /bin/find /log/ -name bill*\.log\.${MyDate[$I]}-* -exec rm -f {} \;
      /bin/find /log/ -name logic*\.log\.${MyDate[$I]}-* -exec rm -f {} \;
   done
fi