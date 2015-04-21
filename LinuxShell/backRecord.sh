#!/bin/bash
#author:zhu huifeng

if [ -z $1 ] || [ -z $2 ]; then
	echo "Usage: $0 OldCharid NewCharid"
	exit 1;
fi

#查看新数据是否存在
value=`\mysql -u ljc -pxxxxxx -h 192.168.0.110 -e "use db_public; select charid from CHARBASE where charid = $2;"`
if [ -n "$value" ]; then
    echo "CHARID $2 已经存在，请手动处理"
    exit 2;
fi

#加载数据
\mysql -u ljc -pxxxxxx -h 192.168.0.110 -e "use db_public; load data infile \"/tmp/$2.sql\" into table CHARBASE;"

#创建存储过程
\mysql -u ljc -pxxxxxx -h 192.168.0.110 << EOF
use db_public
drop PROCEDURE if exists BackRecord;
delimiter $$
create PROCEDURE BackRecord(OldCharid int, NewCharid int)
begin
    declare MyCharid,MyAccid,MyLogicid int default 1;
    /*存储旧记录的变量值*/
    select accid,logicid,charid into MyAccid,MyLogicid,MyCharid from CHARBASE where charid = OldCharid;
    /*删除旧记录*/
    delete from CHARBASE where charid = OldCharid;
    /*更新新记录*/
    update CHARBASE set charid = MyCharid, accid = MyAccid, logicid = MyLogicid where charid = NewCharid;
    /*查看更新后数据*/
    select name,charid,accid,logicid,point,allpoint,from_unixtime(offlinetime) from CHARBASE where charid = OldCharid;
end
$$
delimiter ;
EOF

#调用存储过程
\mysql -u ljc -pxxxxxx -h 192.168.0.110 -e "use db_public; call BackRecord($1, $2);"


