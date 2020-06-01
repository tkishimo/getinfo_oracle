/*ロック保持sql取得
locked_mode
0 - NONE: ロックが要求されたが、まだ取得されていない
1 - NULL
2 - ROWS_S (SS): 行共有ロック
3 - ROW_X (SX): 行排他表ロック
4 - SHARE (S): 共有表ロック
5 - S/ROW-X (SSX): 共有行排他表ロック
6 - Exclusive (X): 排他表ロック
*/
select d.owner,
d.object_name,
l.inst_id,
l.object_id,
l.session_id,
l.locked_mode,
l.os_user_name,
s.sql_id,
s.program,
a.sql_text,
a.executions,
a.elapsed_time,
a.cpu_time
from
gv$locked_object l inner join dba_objects d
on l.object_id=d.object_id
inner join gv$session s
on s.inst_id=l.inst_id and
l.session_id=s.sid
inner join gv$sqlarea a
on a.inst_id=s.inst_id and
a.sql_id=s.sql_id and
s.user#=a.parsing_schema_id
