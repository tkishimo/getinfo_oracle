-------------------------------------------  
-- SQL  
-------------------------------------------  
-- データベース  
set line 5000  
set pagesize 30000  
set colsep "|"  
set trimspool on  
set echo on  
alter session set nls_date_format = 'YYYY/MM/DD HH24:MI:SS';  
spool dbinfo.log  
  
col FS_FAILOVER_OBSERVER_HOST for a30  
  
SELECT  
 * 
FROM  
 v$database; 
  
select * from v$option;  
col COMP_NAME for a60  
select comp_name,version from dba_registry;  
select parameter,value from nls_database_parameters;  
  
-- インスタンス  
SELECT  
 * 
FROM  
 v$instance; 
  
-- DB構成情報  
(  
SELECT  
 'maxlogfiles', 
 to_char(records_total) 
FROM  
 v$controlfile_record_section 
WHERE  
 type = 'REDO LOG' 
)  
UNION  
(  
SELECT  
 'maxlogmembers', 
 to_char(dimlm) 
FROM  
 sys.x$kccdi 
)  
UNION  
(  
SELECT  
 'maxdatafiles', 
 to_char(records_total) 
FROM  
 v$controlfile_record_section 
WHERE  
 type = 'DATAFILE' 
)  
UNION  
(  
SELECT  
 'maxinstances', 
 to_char(records_total) 
FROM  
 v$controlfile_record_section 
WHERE  
 type = 'DATABASE' 
)  
UNION  
(  
SELECT  
 'maxloghistory', 
 to_char(records_total) 
FROM  
 v$controlfile_record_section 
WHERE  
 type = 'LOG HISTORY' 
)  
UNION  
(  
SELECT  
 'CHARACTER SET', 
 value 
FROM  
 v$nls_parameters 
WHERE  
 parameter = 'NLS_CHARACTERSET' 
)  
UNION  
(  
SELECT  
 'NATIONAL CHARACTER SET', 
 value 
FROM  
 v$nls_parameters 
WHERE  
 parameter = 'NLS_NCHAR_CHARACTERSET' 
);  
  
-- 初期化パラメータ  
SELECT  
 '"'||name||'","'|| 
 value||'","'|| 
 isdefault||'","'|| 
 isses_modifiable||'","'|| 
 issys_modifiable||'","'|| 
 ismodified||'"' 
FROM  
 v$parameter; 
  
-- 隠しパラメータ  
SELECT  
 i.ksppinm parameter, 
 v.ksppstvl value 
FROM  
 x$ksppi i, 
 x$ksppcv v 
WHERE  
 i.indx = v.indx; 
  
-- 表領域  
SELECT  
 * 
FROM  
 dba_tablespaces; 
  
-- データファイル  
col FILE_NAME for a100  
SELECT  
 adf.*, 
 (bytes - free_bytes) / 1024 used_kbytes, 
 free_bytes / 1024 free_kbytes, 
 to_char(((bytes - free_bytes) / (bytes)) * 100, '990.99') || '%' capacity 
FROM  
 dba_data_files adf 
 LEFT OUTER JOIN ( SELECT dfs.file_id,sum(dfs.bytes) free_bytes FROM dba_free_space dfs GROUP BY file_id) fs 
 ON adf.file_id = fs.FILE_ID 
ORDER BY  
 adf.tablespace_name, 
 adf.file_name; 
  
-- TEMPファイル  
SELECT  
 dtf.* 
FROM  
 dba_temp_files dtf; 
  
-- REDOログファイル  
col MEMBER for a100  
SELECT  
 vl.thread#, 
 vlf.group#, 
 vlf.member, 
 vl.bytes/1024/1024 "SIZE(MB)" 
FROM  
 v$logfile vlf LEFT OUTER JOIN v$log vl ON vlf.group# = vl.group#; 
  
-- ロール  
SELECT  
 rsp.* 
FROM  
 role_sys_privs rsp 
WHERE  
 rsp.role NOT IN ('EXP_FULL_DATABASE', 
 'AQ_ADMINISTRATOR_ROLE', 
 'DBA', 
 'OEM_ADVISOR', 
 'RECOVERY_CATALOG_OWNER', 
 'SCHEDULER_ADMIN', 
 'RESOURCE', 
 'IMP_FULL_DATABASE', 
 'DATAPUMP_EXP_FULL_DATABASE', 
 'CONNECT', 
 'DATAPUMP_IMP_FULL_DATABASE', 
 'OEM_MONITOR', 
 'MGMT_USER', 
 'LOGSTDBY_ADMINISTRATOR'); 
  
-- ユーザ  
col EXTERNAL_NAME for a30  
SELECT  
 * 
FROM  
 dba_users du 
ORDER BY  
 du.username; 
  
-- プロファイル  
SELECT  
 dp.* 
FROM  
 dba_profiles dp; 
  
-- DBLINK  
SELECT  
 ddl.* 
FROM  
 dba_db_links ddl; 
  

--Scheduler Window
select * from DBA_AUTOTASK_WINDOW_CLIENTS;

col COMMENTS for a50  
col REPEAT_INTERVAL for a100  
select window_name,start_date,end_date,duration,comments,REPEAT_INTERVAL
 from DBA_SCHEDULER_WINDOWS;


--統計情報履歴保持期間
select dbms_stats.get_stats_history_retention from dual;

  
spool off  

set trimspool on;
set pages 1000;
set lin 1000;

alter session set nls_date_format='YYYY-MM-DD HH24:MI:SS';

spool getinfo.log
select sysdate from dual;

select username,user_id,account_status,default_tablespace,temporary_tablespace,created,profile,initial_rsrc_consumer_group
  from dba_users order by username;

select * from dba_tablespaces order by 1;


col NAME for a80
col tablespace_name for a20

select v.name,d.tablespace_name,v.file#,v.creation_time,v.bytes/1024/1024 size_MB,
       d.status,d.autoextensible,
       d.increment_by*(select value from v$parameter where name = 'db_block_size')/1024/1024 increment_by_mb,
       d.maxbytes/1024/1024 MAXSIZE_MB
  from v$datafile v,dba_data_files d where v.file#=d.file_id
union
select v.name,d.tablespace_name,v.file#,v.creation_time,v.bytes/1024/1024 size_MB,
       d.status,d.autoextensible,
       d.increment_by*(select value from v$parameter where name = 'db_block_size')/1024/1024 increment_by_mb,
       d.maxbytes/1024/1024 MAXSIZE_MB
  from v$tempfile v,dba_temp_files d where v.file#=d.file_id
order by 2;



select name from v$controlfile;

col MEMBER for a80
select * from v$logfile;

select * from v$log;


col PROFILE for a20
col RESOURCE_NAME for a30
col LIMIT for a20
select * from dba_profiles
 where PROFILE = 'DEFAULT' and RESOURCE_TYPE = 'PASSWORD'
 order by 2
;


col NAME for a50
col value for a120
select inst_id,num,name,'"' || value || '"' as value,isdefault from gv$parameter
order by 1,2,3;

select inst_id,name,'"' || value || '"' as value from gv$spparameter
order by 1,2;

set lin 120
col name for a20
col path for a50

select
NAME,
TOTAL_MB,
USABLE_FILE_MB,
TYPE
from
v$asm_diskgroup
;

select
NAME,
OS_MB,
TOTAL_MB,
PATH
from
v$asm_disk
order by path
;

select 
 tablespace_name
,username
,max_bytes
from
dba_ts_quotas
;

col COMP_NAME for a60
col VERSION for a20
col STATUS for a10
select COMP_NAME,VERSION,STATUS from dba_registry;

spool off
