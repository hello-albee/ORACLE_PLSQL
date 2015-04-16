--������
--ע�⣬��β����о���
CREATE OR REPLACE FUNCTION get_sal(Dept_no NUMBER, Emp_count OUT NUMBER)
  RETURN NUMBER IS
  V_sum NUMBER;
BEGIN
  SELECT SUM(sal), count(*)
    INTO V_sum, emp_count
    FROM emp
   WHERE deptno = dept_no;
  RETURN v_sum;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    DBMS_OUTPUT.PUT_LINE('����Ҫ�����ݲ�����!');
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE(SQLCODE || '---' || SQLERRM);
END;

--λ�ñ�ʾ���ú���
DECLARE
  V_num NUMBER;
  V_sum NUMBER;
BEGIN
  V_sum := get_sal(10, v_num);
  DBMS_OUTPUT.PUT_LINE('���ź�Ϊ:10�Ĺ����ܺͣ� ' || v_sum || '�� ����Ϊ�� ' || v_num);
END;
--���ƶ�Ӧ���ú���
DECLARE
  V_num NUMBER;
  V_sum NUMBER;
BEGIN
  V_sum := get_sal(emp_count => v_num, dept_no => 10);
  DBMS_OUTPUT.PUT_LINE('���ź�Ϊ:10�Ĺ����ܺͣ� ' || v_sum || '�� ����Ϊ�� ' || v_num);
END;


--�洢����
CREATE TABLE logtable (userid VARCHAR2(10), logdate date);
CREATE OR REPLACE PROCEDURE logexecution IS
BEGIN
  INSERT INTO logtable (userid, logdate) VALUES (USER, SYSDATE);
END;

--���ô洢����
--EXECUTE���Ҫ��command��ִ��
EXECUTE logexecution;

select * from logtable;
--����
CREATE OR REPLACE PROCEDURE QueryEmp(v_empno IN emp.empno%TYPE,
                                     v_ename OUT emp.ename%TYPE,
                                     v_sal   OUT emp.sal%TYPE) AS
BEGIN
  SELECT ename, sal INTO v_ename, v_sal FROM emp WHERE empno = v_empno;
  DBMS_OUTPUT.PUT_LINE('��ܰ��ʾ:����Ϊ' || v_empno || '��Ա���Ѿ��鵽!');
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    DBMS_OUTPUT.PUT_LINE('��ܰ��ʾ:����Ҫ�����ݲ�����!');
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE(SQLCODE || '---' || SQLERRM);
END;
--����
DECLARE
  v1 emp.ename%TYPE;
  v2 emp.sal%TYPE;
BEGIN
  QueryEmp(7788, v1, v2);
  DBMS_OUTPUT.PUT_LINE('����:' || v1);
  DBMS_OUTPUT.PUT_LINE('����:' || v2);
  QueryEmp(103, v1, v2);
  DBMS_OUTPUT.PUT_LINE('����:' || v1);
  DBMS_OUTPUT.PUT_LINE('����:' || v2);
  QueryEmp(104, v1, v2);
  DBMS_OUTPUT.PUT_LINE('����:' || v1);
  DBMS_OUTPUT.PUT_LINE('����:' || v2);
END;


create table test(m varchar2(30));

--��������
create or replace procedure auto_proce as
  pragma autonomous_transaction;
begin
  insert into test values ('autonomous!');
  commit;
end;

--����������
create or replace procedure nonauto_proce as
begin
  insert into test values ('nonautonomous!');
  commit;
end;

--����Command��ִ��---------------
begin
  insert into test values ('test');
  nonauto_proce;
  rollback;
end;
/
----------------------------------
--����nonauto_proce���̲����������������ύ���������е�insertһ���ύ�����rollbackû�лع�����nonauto_proceӰ�������ĸ�����(������Ӱ�츸����)��

truncate table test; 

--����Command��ִ��---------------
begin
  insert into test values ('test1');
  auto_proce;
  rollback;
end;
/
----------------------------------
select * from test; 
 

--���������븸���񣨵����ߣ��Ĺ�ϵ��û���µĻỰ����������������auto_p1���丸���������飩��ͬһ�Ự�С�
--����һ�����̣���commitǰ����10�룬�Ա�鿴ϵͳ�е�һЩ��Ϣ��
create or replace procedure auto_p1 as
  pragma AUTONOMOUS_TRANSACTION;
begin
  insert into test values ('test2');
  dbms_lock.sleep(10);
  commit;
end;


--���������Ӧ�ó�������־��¼��
create table test1(
id number(8),   
msg varchar2(10),   
constraint test1_pk primary key(id)  
);  

create table test1_log (
dat timestamp,  
err clob  
);  

create or replace procedure log_err(errinfo varchar2) as
  pragma autonomous_transaction;
begin
  insert into test1_log values (systimestamp, errinfo);
  commit;
end;


create or replace procedure insert_test(numid number, msg varchar2) as
begin
  insert into test1 values (numid, msg);
end;
--�������Command��ִ��-------------------------
begin
  insert_test(1, 'test1');
  insert_test(2, 'test2');
exception
  when others then
    log_err(dbms_utility.format_error_backtrace);
    raise;
end;
/
------------------------------------------------

--�������Command��ִ��-------------------------
begin
  insert_test(1, 'ffffffff');
exception
  when others then
    log_err(dbms_utility.format_error_backtrace);
    raise;
end;
/
------------------------------------------------

select * from test1_log;
select * from test1;

/*��2*/
--�������������������Ա�
--------------------------
DROP TABLE logtable;
CREATE TABLE logtable(
Username varchar2(20),
Dassate_time date,
Mege varchar2(60)
);
CREATE TABLE temp_table( N number );

--��������
CREATE OR REPLACE PROCEDURE log_message(p_message varchar2) AS
  PRAGMA AUTONOMOUS_TRANSACTION /*����Ϊ��������*/ ;
BEGIN
  INSERT INTO logtable VALUES (user, sysdate, p_message);
  COMMIT;
END;

--������������
--Command��ִ��------------------------------------
BEGIN
  Log_message('About to insert into temp_table');
  INSERT INTO temp_table VALUES (1);
  Log_message('Rollback to insert into temp_table');
  ROLLBACK;
END;
/
---------------------------------------------------
--����������
DROP TABLE logtable2;
CREATE TABLE logtable2(
Username varchar2(20),
Dassate_time date,
Mege varchar2(60)
);
CREATE TABLE temp_table2( N number );

CREATE OR REPLACE PROCEDURE log_message2(p_message varchar2) AS
BEGIN
  INSERT INTO logtable2 VALUES (user, sysdate, p_message);
  COMMIT;
END;

--���÷���������
--Command��ִ��-------------------------------------
BEGIN
  Log_message2('About to insert into temp_table');
  INSERT INTO temp_table2 VALUES (1);
  Log_message2('Rollback to insert into temp_table');
  ROLLBACK;
END;
/
----------------------------------------------------
SELECT * FROM logtable;
SELECT * FROM temp_table;

SELECT * FROM logtable2;
SELECT * FROM temp_table2;



select * from emp;
