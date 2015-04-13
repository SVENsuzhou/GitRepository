DROP PROCEDURE if exists MyDrop;
delimiter $$
create PROCEDURE MyDrop()
begin
	declare num,maxer,playid,record int default 1;
	/*存放球员ID的临时表*/
	CREATE TABLE `TMPTABLE`(
	`ID` int(10) unsigned NOT NULL auto_increment,
	`PLAYERID` int(10) unsigned NOT NULL,
	PRIMARY KEY (`ID`)
	)ENGINE=MyISAM default CHARSET=latin1;
	/*存放数据的临时表*/
	CREATE TABLE `RECRUITSORT_TMP` (
	`ID` int(10) unsigned NOT NULL auto_increment,
  `PLAYERID` int(10) NOT NULL DEFAULT '0',
  `CHARID` int(10) NOT NULL DEFAULT '0',
  `NAME` varchar(33) NOT NULL DEFAULT '',
  `TIME` int(10) NOT NULL DEFAULT '0',
  KEY `ID` (`ID`)
  ) ENGINE=MyISAM DEFAULT CHARSET=latin1;
	insert into TMPTABLE(PLAYERID) select PLAYERID from RECRUITSORT group by PLAYERID;
	/*获取招募榜球员的个数*/
	select count(*) into maxer from TMPTABLE;
	while num <= maxer do
	select PLAYERID into playid from TMPTABLE where ID = num;
	/*获取每个球员的条目数*/
	select count(*) into record from RECRUITSORT where PLAYERID = playid;
	/*条目数大于30，开始数据复制，并删除*/
	if (record > 30) then
	insert into RECRUITSORT_TMP(PLAYERID,CHARID,NAME,TIME) select PLAYERID,CHARID,NAME,TIME from RECRUITSORT where PLAYERID = playid order by TIME;
	delete from RECRUITSORT where PLAYERID = playid;
	delete from RECRUITSORT_TMP where ID > 30;
	insert into RECRUITSORT(PLAYERID,CHARID,NAME,TIME) select PLAYERID,CHARID,NAME,TIME from RECRUITSORT_TMP;
	truncate table RECRUITSORT_TMP;
	end if;
	set num = num + 1;
	end while;
	DROP TABLE `TMPTABLE`;
	DROP TABLE `RECRUITSORT_TMP`;
end
$$
delimiter ;

call MyDrop;