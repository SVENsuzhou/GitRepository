#!/bin/bash
#
my_fun1()
{
    for HOST in `cat list-sdgamer | grep $1 | awk '{print $1}'`; do
        echo "====================================$1====================================="
        scp -P 50000 /media/Slamdunk/Resources_Test/$1/Server/cfg/IniFile/* sdgamer@$HOST:~/release/cfg/IniFile/
    done
}

#分发函数

my_fun2()
{
    for HOST in `cat list-sdgamer2 | grep $1 | awk '{print $1}'`; do
        echo "====================================$1====================================="
        scp -P 50000 /media/Slamdunk/Resources_Test/$1/Server/cfg/IniFile/* sdgamer2@$HOST:~/release/cfg/IniFile/
    done
}

declare -a menus
declare -i index=1
#检测配置文件的平台是否存在
for I in `cat list-sdgamer* | awk '{print $2}' | uniq -c | awk '{print $2}'`; do
    ls /media/Slamdunk/Resources_Test/ | grep $I > /dev/null
    if [ $? -ne 0 ]; then
        echo "Wrong Config File!!!"
        echo "$I platform not exist!!!"
        exit 1
    else
        menus[index]=$I              #填充数组
	      index=$[$index+1]
    fi
done

#显示菜单
echo -en "\e[33;1m"                   #开启黄色字体
for ((i=1;i<=$index;i++)); do
    if [ $(($i%6)) -eq 0 ]; then      #每行显示6个
        printf "%d)%-15s\t" $i ${menus[i]}                  #设置字符串的长度为15，加上Tab键可以完成列的对齐
        echo 
    else
        printf "%d)%-15s\t" $i ${menus[i]}
    fi
done
echo -e "\e[0m"                       #关闭颜色显示

read -p "please input platform name: " PLAT

#所有平台都分发
if [ $PLAT = 'all' ];then
    for FILE in 'list-sdgamer' 'list-sdgamer2'; do
        for F_PLAT in `cat $FILE | awk '{print $2}' | uniq -c | awk '{print $2}'`; do
            if [ $FILE = 'list-sdgamer' ]; then
                my_fun1 $F_PLAT
            else 
                my_fun2 $F_PLAT
            fi
        done
    done
    exit 0
fi


#按输入的平台进行分发
cat list-sdgamer | grep $PLAT > /dev/null
if [ $? -eq 0 ]; then
    my_fun1 $PLAT 
else
    cat list-sdgamer2 | grep $PLAT > /dev/null
    if [ $? -eq 0 ]; then
        my_fun2 $PLAT
    else 
        echo "Please Input Corrent Platform Name. Thank You."
        exit 1
    fi
fi