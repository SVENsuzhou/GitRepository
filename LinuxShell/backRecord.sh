#!/bin/bash
#author:zhu huifeng

if [ -z $1 ] || [ -z $2 ]; then
	echo "Usage: $0 OldCharid NewCharid"
	exit 1;
fi

#�鿴�������Ƿ����
value=`\mysql -u ljc -pxxxxxx -h 192.168.0.110 -e "use db_public; select charid from CHARBASE where charid = $2;"`
if [ -n "$value" ]; then
    echo "CHARID $2 �Ѿ����ڣ����ֶ�����"
    exit 2;
fi

#��������
\mysql -u ljc -pxxxxxx -h 192.168.0.110 -e "use db_public; load data infile \"/tmp/$2.sql\" into table CHARBASE;"

#�����洢����
\mysql -u ljc -pxxxxxx -h 192.168.0.110 << EOF
use db_public
drop PROCEDURE if exists BackRecord;
delimiter $$
create PROCEDURE BackRecord(OldCharid int, NewCharid int)
begin
    declare MyCharid,MyAccid,MyLogicid int default 1;
    /*�洢�ɼ�¼�ı���ֵ*/
    select accid,logicid,charid into MyAccid,MyLogicid,MyCharid from CHARBASE where charid = OldCharid;
    /*ɾ���ɼ�¼*/
    delete from CHARBASE where charid = OldCharid;
    /*�����¼�¼*/
    update CHARBASE set charid = MyCharid, accid = MyAccid, logicid = MyLogicid where charid = NewCharid;
    /*�鿴���º�����*/
    select name,charid,accid,logicid,point,allpoint,from_unixtime(offlinetime) from CHARBASE where charid = OldCharid;
end
$$
delimiter ;
EOF

#���ô洢����
\mysql -u ljc -pxxxxxx -h 192.168.0.110 -e "use db_public; call BackRecord($1, $2);"


