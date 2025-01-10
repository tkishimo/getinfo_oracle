--get session count last month
spool session_cnt.log
alter session set nls_date_format = 'yy/mm/dd hh24:mi';
alter session set current_schema = PERFSTAT;
set pages 50000 lin 200 colsep ,
select snap_id,s.snap_time,r.resource_name,r.current_utilization,r.max_utilization,r.initial_allocation,r.limit_value
from stats$snapshot s join stats$resource_limit r using(snap_id)
where r.resource_name='sessions' and trunc(s.snap_time,'MM')=trunc(sysdate-20,'MM')
order by 2;
spool off

--get cursor count last month
spool cursor_cnt.log
alter session set nls_date_format = 'yy/mm/dd hh24:mi';
set pages 50000 lin 200 colsep ,
select s.snap_id,s.snap_time,y.* from stats$snapshot s join stats$sysstat y on s.snap_id=y.snap_id
where y.name ='opened cursors current' and trunc(s.snap_time,'MM')=trunc(sysdate-20,'MM')
order by 1;
spool off

--log switch count/hour last month
spool log_cnt.log
alter session set nls_date_format='yy/mm/dd hh24:mi';
set pages 50000,lin 200 colsep ,
select snap_time,max_seq,lag(max_seq) over(order by snap_time) from (
select trunc(s.snap_time,'hh24') snap_time,min(sequence#) min_seq,max(sequence#) max_seq from stats$snapshot s join stats$thread t on s.snap_id=t.snap_id group by trunc(snap_time,'hh24') order by snap_time);
spool off

--cumalative logon count last month
spool logon_cnt.log
alter session set nls_date_format='yy/mm/dd hh24:mi';
set pages 50000 lin 200 colsep , echo off
select snap_time,max_value,lag(max_value) over(order by snap_time) from (
select trunc(s.snap_time,'hh24') snap_time,min(y.value) min_value,max(y.value) max_value from stats$snapshot s join stats$sysstat y on s.snap_id=y.snap_id
where y.name ='logons cumulative'
group by trunc(snap_time,'hh24') order by snap_time);
spool off

--wait time/hour last month
spool system_event.log
alter session set nls_date_format='yy/mm/dd hh24:mi';
set pages 50000 lin 200 colsep , feed off numwidth 15
select snap_time,wait_class#,wait_class,max_value,lag(max_value) over(partition by wait_class#,wait_class order by snap_time) lag_value from
(Select snap_time,e.wait_class#,e.wait_class,sum(max_value) max_value from v$event_name e join
(select trunc(s.snap_time,'hh24') snap_time,
y.event,
y.event_id,
min(y.time_waited_micro_fg) min_value,
max(y.time_waited_micro_fg) max_value
from stats$snapshot s join stats$system_event y
on s.snap_id=y.snap_id
where trunc(s.snap_time,'MM')=trunc(sysdate-20,'MM')
group by trunc(snap_time,'hh24'),event, event_id order by snap_time) d
on e.event_id=d.event_id
Group by d.snap_time,e.wait_class#,e.wait_class
Order by d.snap_time)
order by snap_time;
spool off
