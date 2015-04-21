#!/bin/bash
#author:zhu huifeng

#��������
User="ljc"
Passwd="xxxxx"
Host="192.168.0.110"
DataBase="db_public"

#�жϲ����Ƿ���ȷ
if [ -z $1 ] || [ -z $2 ]; then
	echo "Usage: $0 OldCharid NewCharid"
	exit 1;
fi

#�鿴�������Ƿ����
value=`\mysql -u $User -p$Passwd -h $Host -e "use $DataBase; select charid from CHARBASE where charid = $2;"`
if [ -n "$value" ]; then
    echo "CHARID $2 �Ѿ����ڣ����ֶ�����"
    exit 2;
fi

#���ݾ�����
if [ ! -e /tmp/$1.sql.bak ]; then
    \mysql -u $User -p$Passwd -h $Host -e "use $DataBase; select * from CHARBASE where charid = $1 into outfile \"/tmp/$1.sql.bak\";"
fi

#��������
\mysql -u $User -p$Passwd -h $Host -e "use $DataBase; load data infile \"/tmp/$2.sql\" into table CHARBASE;"

#�����洢����
\mysql -u $User -p$Passwd -h $Host << EOF
use $DataBase
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
\mysql -u $User -p$Passwd -h $Host -e "use $DataBase; call BackRecord($1, $2);"


