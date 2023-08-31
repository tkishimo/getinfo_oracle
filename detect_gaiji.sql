--detect gaiji from gaiji table
--you will replace column and table name, you can detect gaiji from your table
set serveroutput on
declare
    pos_start number;
    pos_end   number;
begin
    for r1 in (
        select
        col1, xmlquery
          ( 'fn:string-to-codepoints( $p_input )'
            passing col1 as "p_input"
            returning content
          ).getstringval()
          as xquery_string_to_codepoints
        from gaiji
     ) loop
        for i in 1..regexp_count(r1.xquery_string_to_codepoints,'\s')+1 loop
            pos_start := regexp_instr(r1.xquery_string_to_codepoints,'\d+',1,i);
            pos_end   := regexp_instr(r1.xquery_string_to_codepoints,'(\s|$)',1,i) - pos_start;
            if 57344 <= substr(r1.xquery_string_to_codepoints,pos_start, pos_end ) and substr(r1.xquery_string_to_codepoints,pos_start, pos_end ) <= 63743 then
                dbms_output.put_line('gaiji detected = '||substr(r1.xquery_string_to_codepoints,pos_start, pos_end ));
                dbms_output.put_line(r1.col1);
                dbms_output.put_line(r1.xquery_string_to_codepoints);
            end if;
        end loop;
    end loop;
end;
/
