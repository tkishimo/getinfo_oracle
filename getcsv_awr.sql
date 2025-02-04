--get session count
spool session_cnt.log
alter session set nls_date_format = 'yy/mm/dd hh24:mi';
set pages 50000 lin 300 colsep ,
select snap_id,s.end_interval_time,
r.resource_name,r.current_utilization,r.max_utilization,r.initial_allocation,r.limit_value 
from dba_hist_resource_limit r join dba_hist_snapshot s using(snap_id) where resource_name='sessions' --and trunc(s.end_interval_time,'MM')=trunc(sysdate-20,'MM')
order by 2;
spool off

--get cursor count
spool cursor_cnt.log
alter session set nls_date_format = 'yy/mm/dd hh24:mi';
set pages 50000 lin 300 colsep ,
select s.snap_id,s.end_interval_time,t.* from DBA_HIST_SYSSTAT t join dba_hist_snapshot s on s.snap_id=t.snap_id
where stat_name='opened cursors current' --and trunc(s.end_interval_time,'MM')=trunc(sysdate-20,'MM')
order by 2;
spool off

--log switch count/hour
spool log_cnt.log
alter session set nls_date_format='yy/mm/dd hh24:mi';
set pages 50000,lin 300 colsep ,
select end_interval_time,max_seq,lag(max_seq) over(order by end_interval_time) from 
(select trunc(s.end_interval_time,'hh24') end_interval_time,min(sequence#) min_seq,max(sequence#) max_seq 
from dba_hist_thread t join dba_hist_snapshot s on s.snap_id=t.snap_id group by trunc(end_interval_time,'hh24') order by end_interval_time);
spool off

--cumalative logon count
spool logon_cnt.log
alter session set nls_date_format='yy/mm/dd hh24:mi';
set pages 50000 lin 300 colsep , echo off
select end_interval_time,max_value,lag(max_value) over(order by end_interval_time) from (
select trunc(s.end_interval_time,'hh24') end_interval_time,min(y.value) min_value,max(y.value) max_value from dba_hist_snapshot s join DBA_HIST_SYSSTAT y on s.snap_id=y.snap_id
where y.stat_name ='logons cumulative'
group by trunc(end_interval_time,'hh24') order by end_interval_time);
spool off

--wait time/hour
spool system_event.log
alter session set nls_date_format='yy/mm/dd hh24:mi';
set pages 50000 lin 300 colsep , feed off numwidth 15
select END_INTERVAL_TIME,wait_class,sum_value,lag(sum_value) over(partition by WAIT_CLASS_ID,wait_class order by END_INTERVAL_TIME) lag_value 
from
(select trunc(s.END_INTERVAL_TIME,'hh24') END_INTERVAL_TIME,e.WAIT_CLASS_ID,e.WAIT_CLASS,
sum(e.time_waited_micro_fg) sum_value from DBA_HIST_SYSTEM_EVENT e join dba_hist_snapshot s on e.SNAP_ID=s.SNAP_ID 
--where trunc(s.END_INTERVAL_TIME,'MM')=trunc(sysdate-0,'MM')
group by trunc(s.END_INTERVAL_TIME,'hh24'),e.WAIT_CLASS_ID,e.WAIT_CLASS order by 1) order by 1,2;
spool off
