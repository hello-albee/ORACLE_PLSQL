--�ڰ���
CREATE TABLE emp_his AS SELECT * FROM EMP WHERE 1=2;

CREATE OR REPLACE TRIGGER tr_del_emp
  BEFORE DELETE --ָ������ʱ��Ϊɾ������ǰ����
ON scott.emp
  FOR EACH ROW --˵�����������м�������
BEGIN
  --���޸�ǰ���ݲ��뵽��־��¼�� del_emp ,�Թ��ලʹ�á�
  INSERT INTO emp_his
    (deptno, empno, ename, job, mgr, sal, comm, hiredate)
  VALUES
    (:old.deptno,
     :old.empno,
     :old.ename,
     :old.job,
     :old.mgr,
     :old.sal,
     :old.comm,
     :old.hiredate);
END;

DELETE emp WHERE empno = 7788; 

select * from emp_his;

DROP TABLE emp_his;

DROP TRIGGER tr_del_emp;

--
CREATE OR REPLACE TRIGGER tr_dept_time
  BEFORE INSERT OR DELETE OR UPDATE ON dept
BEGIN
  IF (trim(TO_CHAR(sysdate, 'DAY')) IN ('SATURDAY', 'SUNDAY', 'FRIDAY')) OR
     (TO_CHAR(sysdate, 'HH24:MI') NOT BETWEEN '08:30' AND '18:00') THEN
    RAISE_APPLICATION_ERROR(-20001, '�����ϰ�ʱ�䣬 �����޸�dept��');
  END IF;
END;

--
CREATE OR REPLACE TRIGGER TR_EMP_SAL_COMM
  BEFORE UPDATE OF SAL, COMM OR DELETE ON EMP
  FOR EACH ROW
  WHEN (OLD.DEPTNO = 20)
BEGIN
  CASE
    WHEN UPDATING('SAL') THEN
      IF :NEW.SAL < :OLD.SAL THEN
        RAISE_APPLICATION_ERROR(-20001, '����20����Ա�Ĺ��ʲ��ܽ�');
      END IF;
    WHEN UPDATING('COMM') THEN
      IF :NEW.COMM < :OLD.COMM THEN
        RAISE_APPLICATION_ERROR(-20002, '����20����Ա�Ľ����ܽ�');
      END IF;
    WHEN DELETING THEN
      RAISE_APPLICATION_ERROR(-20003, '����ɾ������20����Ա��¼');
  END CASE;
END;

/*ʵ����
UPDATE emp SET sal = 1000 WHERE empno = 7788;
DELETE FROM emp WHERE empno in (7788);*/

--
CREATE TABLE emp_his AS SELECT * FROM EMP WHERE 1=2;

CREATE OR REPLACE PROCEDURE add_job_history(p_emp_id        emp_his.empno%type,
                                            p_start_date    emp_his.hiredate%type,
                                            p_job           emp_his.job%type,
                                            p_department_id emp_his.deptno%type) IS
BEGIN
  INSERT INTO emp_his
    (empno, hiredate, job, deptno)
  VALUES
    (p_emp_id, p_start_date, p_job, p_department_id);
END;

--�������������ô洢����
CREATE OR REPLACE TRIGGER update_job_history
  AFTER UPDATE OF job, deptno ON emp
  FOR EACH ROW
BEGIN
  add_job_history(:old.empno, :old.hiredate, :old.job, :old.deptno);
END;

/*update emp e set e.job = 'DBd' where e.empno = 7844;
select * from emp_his;
*/

--INSTEAD OF ������
CREATE OR REPLACE VIEW emp_view AS
SELECT deptno, count(*) total_employeer, sum(sal) total_salary
FROM emp GROUP BY deptno;

select * from emp_view;
/*DELETE FROM emp_view WHERE deptno=10;*/

CREATE OR REPLACE TRIGGER emp_view_delete
  INSTEAD OF DELETE ON emp_view /*����*/
  FOR EACH ROW
BEGIN
  DELETE FROM emp WHERE deptno = :old.deptno;
END;

/*DELETE FROM emp_view WHERE deptno = 10;
select * from emp;
DROP TRIGGER emp_view_delete;
DROP VIEW emp_view;
*/

--
CREATE TABLE ddl_event
(crt_date timestamp PRIMARY KEY,
event_name VARCHAR2(20),
user_name VARCHAR2(10),
obj_type VARCHAR2(20),
obj_name VARCHAR2(20));

--������������
CREATE OR REPLACE TRIGGER tr_ddl
  AFTER DDL ON SCHEMA
BEGIN
  INSERT INTO ddl_event
  VALUES
    (systimestamp,
     ora_sysevent,
     ora_login_user,
     ora_dict_obj_type,
     ora_dict_obj_name);
END;

/*drop table TEST;
select * from ddl_event;*/

--
CREATE TABLE log_event
(user_name VARCHAR2(20),
address VARCHAR2(20),
logon_date timestamp,
logoff_date timestamp);

--������¼������
CREATE OR REPLACE TRIGGER tr_logon
  AFTER LOGON ON DATABASE
BEGIN
  INSERT INTO log_event
    (user_name, address, logon_date)
  VALUES
    (ora_login_user, ora_client_ip_address, systimestamp);
END;
--�����˳�������
CREATE OR REPLACE TRIGGER tr_logoff
  BEFORE LOGOFF ON DATABASE
BEGIN
  INSERT INTO log_event
    (user_name, address, logoff_date)
  VALUES
    (ora_login_user, ora_client_ip_address, systimestamp);
END;

/*select * from log_event;*/

--
ALTER TABLE emp DISABLE ALL TRIGGERS;

--
SELECT TRIGGER_NAME,
       TRIGGER_TYPE,
       TRIGGERING_EVENT,
       TABLE_OWNER,
       BASE_OBJECT_TYPE,
       REFERENCING_NAMES,
       STATUS,
       ACTION_TYPE
  FROM user_triggers;

--
CREATE TABLE dept_summary(
Deptno NUMBER(2),
Sal_sum NUMBER(9, 2),
Emp_count NUMBER);
INSERT INTO dept_summary
  (deptno, sal_sum, emp_count)
  SELECT deptno, SUM(sal), COUNT(*) FROM emp GROUP BY deptno;

select * from dept_summary;

--����һ��PL/SQL����disp_dept_summary
--�ڴ������е��øù�����ʾdept_summary���е����ݡ�
CREATE OR REPLACE PROCEDURE disp_dept_summary IS
  Rec dept_summary%ROWTYPE;
  CURSOR c1 IS
    SELECT * FROM dept_summary;
BEGIN
  OPEN c1;
  FETCH c1
    INTO REC;
  DBMS_OUTPUT.PUT_LINE('deptno sal_sum emp_count');
  DBMS_OUTPUT.PUT_LINE('-------------------------------------');
  WHILE c1%FOUND LOOP
    DBMS_OUTPUT.PUT_LINE(RPAD(rec.deptno, 6) || To_char(rec.sal_sum, '$999,999.99') || LPAD(rec.emp_count, 13));
    FETCH c1 INTO rec;
  END LOOP;
  CLOSE c1;
END;

--����
DECLARE
BEGIN
  DBMS_OUTPUT.PUT_LINE('����ǰ');
  Disp_dept_summary();
  DBMS_UTILITY.EXEC_DDL_STATEMENT('CREATE OR REPLACE TRIGGER trig1
  AFTER INSERT OR DELETE OR UPDATE OF sal ON emp
BEGIN
  DBMS_OUTPUT.PUT_LINE('' ����ִ��trig1 �������� '');
  DELETE FROM dept_summary;
  INSERT INTO dept_summary
    (deptno, sal_sum, emp_count)
    SELECT deptno, SUM(sal), COUNT(*) FROM emp GROUP BY deptno;
END;');
  INSERT INTO dept
    (deptno, dname, loc)
  VALUES
    (90, 'demo_dept', 'ChengDu');
  INSERT INTO emp
    (ename, deptno, empno, sal)
  VALUES
    (USER, 90, 9999, 3000);
  DBMS_OUTPUT.PUT_LINE('�����');
  Disp_dept_summary();

  UPDATE emp SET sal = 1000 WHERE empno = 9999;
  DBMS_OUTPUT.PUT_LINE('�޸ĺ�');
  Disp_dept_summary();

  DELETE FROM emp WHERE empno = 9999;
  DELETE FROM dept WHERE deptno = 90;
  DBMS_OUTPUT.PUT_LINE('ɾ����');
  Disp_dept_summary();

  DBMS_UTILITY.EXEC_DDL_STATEMENT('DROP TRIGGER trig1');
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE(SQLCODE || '---' || SQLERRM);
END;

--
CREATE TABLE eventlog(
Eventname VARCHAR2(20) NOT NULL,
Eventdate date default sysdate,
Inst_num NUMBER NULL,
Db_name VARCHAR2(50) NULL,
Srv_error NUMBER NULL,
Username VARCHAR2(30) NULL,
Obj_type VARCHAR2(20) NULL,
Obj_name VARCHAR2(30) NULL,
Obj_owner VARCHAR2(30) NULL
);
-- ����DDL������trig4_ddl
CREATE OR REPLACE TRIGGER trig4_ddl
  AFTER CREATE OR ALTER OR DROP ON DATABASE
DECLARE
  Event VARCHAR2(20);
  Typ   VARCHAR2(20);
  Name  VARCHAR2(30);
  Owner VARCHAR2(30);
BEGIN
  -- ��ȡDDL�¼�����
  Event := SYSEVENT;
  Typ   := DICTIONARY_OBJ_TYPE;
  Name  := DICTIONARY_OBJ_NAME;
  Owner := DICTIONARY_OBJ_OWNER;
  --���¼����Բ��뵽�¼���־����
  INSERT INTO eventlog
    (eventname, obj_type, obj_name, obj_owner)
  VALUES
    (event, typ, name, owner);
END;

/*select * from EVENTLOG t;*/

-- ����LOGON�� STARTUP��SERVERERROR �¼�������
CREATE OR REPLACE TRIGGER trig4_after
  AFTER LOGON OR STARTUP OR SERVERERROR ON DATABASE
DECLARE
  Event    VARCHAR2(20);
  Instance NUMBER;
  Err_num  NUMBER;
  Dbname   VARCHAR2(50);
  User     VARCHAR2(30);
BEGIN
  Event := SYSEVENT;
  IF event = 'LOGON' THEN
    User := LOGIN_USER;
    INSERT INTO eventlog (eventname, username) VALUES (event, user);
  ELSIF event = 'SERVERERROR' THEN
    Err_num := SERVER_ERROR(1);
    INSERT INTO eventlog (eventname, srv_error) VALUES (event, err_num);
  ELSE
    Instance := INSTANCE_NUM;
    Dbname   := DATABASE_NAME;
    INSERT INTO eventlog
      (eventname, inst_num, db_name)
    VALUES
      (event, instance, dbname);
  END IF;
END;
/*select * from EVENTLOG t;*/

-- ����LOGOFF��SHUTDOWN �¼�������
CREATE OR REPLACE TRIGGER trig4_before
  BEFORE LOGOFF OR SHUTDOWN ON DATABASE
DECLARE
  Event    VARCHAR2(20);
  Instance NUMBER;
  Dbname   VARCHAR2(50);
  User     VARCHAR2(30);
BEGIN
  Event := SYSEVENT;
  IF event = 'LOGOFF' THEN
    User := LOGIN_USER;
    INSERT INTO eventlog (eventname, username) VALUES (event, user);
  ELSE
    Instance := INSTANCE_NUM;
    Dbname   := DATABASE_NAME;
    INSERT INTO eventlog
      (eventname, inst_num, db_name)
    VALUES
      (event, instance, dbname);
  END IF;
END;
/*select * from EVENTLOG t;*/

DROP TRIGGER trig4_ddl;
DROP TRIGGER trig4_before;
DROP TRIGGER trig4_after;
DROP TABLE eventlog;


--
CREATE TABLE audit_table(
Audit_id NUMBER,
User_name VARCHAR2(20),
Now_time DATE,
Terminal_name VARCHAR2(10),
Table_name VARCHAR2(10),
Action_name VARCHAR2(10),
Emp_id NUMBER(4));

CREATE TABLE audit_table_val(
Audit_id NUMBER,
Column_name VARCHAR2(10),
Old_val NUMBER(7,2),
New_val NUMBER(7,2));

CREATE SEQUENCE audit_seq
START WITH 1000
INCREMENT BY 1
NOMAXVALUE
NOCYCLE NOCACHE;

CREATE OR REPLACE TRIGGER audit_emp
  AFTER INSERT OR UPDATE OR DELETE ON emp
  FOR EACH ROW
DECLARE
  Time_now DATE;
  Terminal CHAR(10);
BEGIN
  Time_now := sysdate;
  Terminal := USERENV('TERMINAL'); /*��ǰ��¼�û��ļ������*/
  IF INSERTING THEN
    INSERT INTO audit_table
    VALUES
      (audit_seq.NEXTVAL,
       user,
       time_now,
       terminal,
       'EMP',
       'INSERT',
       :new.empno);
  ELSIF DELETING THEN
    INSERT INTO audit_table
    VALUES
      (audit_seq.NEXTVAL,
       user,
       time_now,
       terminal,
       'EMP',
       'DELETE',
       :old.empno);
  ELSE
    INSERT INTO audit_table
    VALUES
      (audit_seq.NEXTVAL,
       user,
       time_now,
       terminal,
       'EMP',
       'UPDATE',
       :old.empno);
  
    IF UPDATING('SAL') THEN
      INSERT INTO audit_table_val
      VALUES
        (audit_seq.CURRVAL, 'SAL', :old.sal, :new.sal);
    
    ELSIF UPDATING('DEPTNO') then
      INSERT INTO audit_table_val
      VALUES
        (audit_seq.CURRVAL, 'DEPTNO', :old.deptno, :new.deptno);
    END IF;
  END IF;
END;

INSERT INTO emp(ename, deptno, empno, sal) VALUES ('Lynch', 40, 9999, 7777);
update emp p set p.sal = 9999 where p.empno = 9999;
delete from emp p where p.empno = 9999;

select * from audit_table;
select * from audit_table_val;

