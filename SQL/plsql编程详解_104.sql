--第六章
--注意，入参不能有精度
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
    DBMS_OUTPUT.PUT_LINE('你需要的数据不存在!');
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE(SQLCODE || '---' || SQLERRM);
END;

--位置表示调用函数
DECLARE
  V_num NUMBER;
  V_sum NUMBER;
BEGIN
  V_sum := get_sal(10, v_num);
  DBMS_OUTPUT.PUT_LINE('部门号为:10的工资总和： ' || v_sum || '， 人数为： ' || v_num);
END;
--名称对应调用函数
DECLARE
  V_num NUMBER;
  V_sum NUMBER;
BEGIN
  V_sum := get_sal(emp_count => v_num, dept_no => 10);
  DBMS_OUTPUT.PUT_LINE('部门号为:10的工资总和： ' || v_sum || '， 人数为： ' || v_num);
END;


--存储过程
CREATE TABLE logtable (userid VARCHAR2(10), logdate date);
CREATE OR REPLACE PROCEDURE logexecution IS
BEGIN
  INSERT INTO logtable (userid, logdate) VALUES (USER, SYSDATE);
END;

--调用存储过程
--EXECUTE语句要在command中执行
EXECUTE logexecution;

select * from logtable;
--定义
CREATE OR REPLACE PROCEDURE QueryEmp(v_empno IN emp.empno%TYPE,
                                     v_ename OUT emp.ename%TYPE,
                                     v_sal   OUT emp.sal%TYPE) AS
BEGIN
  SELECT ename, sal INTO v_ename, v_sal FROM emp WHERE empno = v_empno;
  DBMS_OUTPUT.PUT_LINE('温馨提示:编码为' || v_empno || '的员工已经查到!');
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    DBMS_OUTPUT.PUT_LINE('温馨提示:你需要的数据不存在!');
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE(SQLCODE || '---' || SQLERRM);
END;
--调用
DECLARE
  v1 emp.ename%TYPE;
  v2 emp.sal%TYPE;
BEGIN
  QueryEmp(7788, v1, v2);
  DBMS_OUTPUT.PUT_LINE('姓名:' || v1);
  DBMS_OUTPUT.PUT_LINE('工资:' || v2);
  QueryEmp(103, v1, v2);
  DBMS_OUTPUT.PUT_LINE('姓名:' || v1);
  DBMS_OUTPUT.PUT_LINE('工资:' || v2);
  QueryEmp(104, v1, v2);
  DBMS_OUTPUT.PUT_LINE('姓名:' || v1);
  DBMS_OUTPUT.PUT_LINE('工资:' || v2);
END;


create table test(m varchar2(30));

--自治事务
create or replace procedure auto_proce as
  pragma autonomous_transaction;
begin
  insert into test values ('autonomous!');
  commit;
end;

--非自治事务
create or replace procedure nonauto_proce as
begin
  insert into test values ('nonautonomous!');
  commit;
end;

--以下Command中执行---------------
begin
  insert into test values ('test');
  nonauto_proce;
  rollback;
end;
/
----------------------------------
--由于nonauto_proce过程不是自治事务，它的提交将父事务中的insert一并提交，造成rollback没有回滚，即nonauto_proce影响了它的父事务(子事务影响父事务)。

truncate table test; 

--以下Command中执行---------------
begin
  insert into test values ('test1');
  auto_proce;
  rollback;
end;
/
----------------------------------
select * from test; 
 

--自治事务与父事务（调用者）的关系：没有新的会话产生，即自治事务auto_p1与其父事务（匿名块）在同一会话中。
--创建一个过程，在commit前休眠10秒，以便查看系统中的一些信息。
create or replace procedure auto_p1 as
  pragma AUTONOMOUS_TRANSACTION;
begin
  insert into test values ('test2');
  dbms_lock.sleep(10);
  commit;
end;


--自治事务的应用场景（日志记录）
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
--以下语句Command中执行-------------------------
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

--以下语句Command中执行-------------------------
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

/*例2*/
--自治事务与非自治事务对比
--------------------------
DROP TABLE logtable;
CREATE TABLE logtable(
Username varchar2(20),
Dassate_time date,
Mege varchar2(60)
);
CREATE TABLE temp_table( N number );

--自治事务
CREATE OR REPLACE PROCEDURE log_message(p_message varchar2) AS
  PRAGMA AUTONOMOUS_TRANSACTION /*声明为自治事务*/ ;
BEGIN
  INSERT INTO logtable VALUES (user, sysdate, p_message);
  COMMIT;
END;

--调用自治事务
--Command中执行------------------------------------
BEGIN
  Log_message('About to insert into temp_table');
  INSERT INTO temp_table VALUES (1);
  Log_message('Rollback to insert into temp_table');
  ROLLBACK;
END;
/
---------------------------------------------------
--非自治事务
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

--调用非自治事务
--Command中执行-------------------------------------
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
