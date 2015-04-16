--第四章

DECLARE
  CURSOR c_cursor IS
    SELECT ename || ' - ' || job, Sal FROM emp WHERE rownum < 11;
  v_ename varchar2(255);
  v_sal   emp.Sal%TYPE;
BEGIN
  OPEN c_cursor;
  FETCH c_cursor INTO v_ename, v_sal;
  WHILE c_cursor%FOUND LOOP
    DBMS_OUTPUT.PUT_LINE(v_ename || ' +++ ' || to_char(v_sal));
    FETCH c_cursor INTO v_ename, v_sal;
  END LOOP;
  CLOSE c_cursor;
END;

--游标参数的传递方法
DECLARE
  DeptRec   dept%ROWTYPE;
  Dept_name dept.dname%TYPE;
  Dept_loc  dept.loc%TYPE;
  CURSOR c1 IS
    SELECT dname, loc FROM dept WHERE deptno <= 30;
  CURSOR c2(dept_no NUMBER DEFAULT 10) IS
    SELECT dname, loc FROM dept WHERE deptno <= dept_no;
  CURSOR c3(dept_no NUMBER DEFAULT 20) IS
    SELECT * FROM dept WHERE dept.deptno <= dept_no;
BEGIN
  OPEN c1;
  LOOP
    FETCH c1 INTO dept_name, dept_loc;
    EXIT WHEN c1%NOTFOUND;
    DBMS_OUTPUT.PUT_LINE(dept_name || ' --- ' || dept_loc);
  END LOOP;
  CLOSE c1;
  
  OPEN c2;
  LOOP
    FETCH c2 INTO dept_name, dept_loc;
    EXIT WHEN c2%NOTFOUND;
    DBMS_OUTPUT.PUT_LINE(dept_name || ' -+- ' || dept_loc);
  END LOOP;
  CLOSE c2;
  
  OPEN c3(dept_no => 20);
  LOOP
    FETCH c3 INTO deptrec;
    EXIT WHEN c3%NOTFOUND;
    DBMS_OUTPUT.PUT_LINE(deptrec.deptno || ' --- ' || deptrec.dname || ' --- ' || deptrec.loc);
  END LOOP;
  CLOSE c3;

END;

--有入参且有返回的游标
--一个疑问，返回值有什么作用？最后不还是用了FETCH？
DECLARE
  TYPE emp_record_type IS RECORD(
    f_name emp.ename%TYPE,
    h_date emp.hiredate%TYPE);
  v_emp_record emp_record_type;
  CURSOR c3(dept_id NUMBER, j_id VARCHAR2) --声明游标,有参数有返回值
  RETURN emp_record_type IS
    SELECT ename, hiredate FROM emp WHERE deptno = dept_id AND empno = j_id;
BEGIN
  OPEN c3(j_id => 7788, dept_id => 20); --打开游标,采用名称传递参数值（还有一种顺序传值）
  LOOP
    FETCH c3 INTO v_emp_record; --提取游标
    IF c3%FOUND THEN
      DBMS_OUTPUT.PUT_LINE(v_emp_record.f_name || '的雇佣日期是' || v_emp_record.h_date);
    ELSE
      DBMS_OUTPUT.PUT_LINE('已经处理完结果集了');
      EXIT;
    END IF;
  END LOOP;
  CLOSE c3; --关闭游标

END;


--使用for循环打开游标
DECLARE
  CURSOR c_sal IS SELECT empno, ename || ' - ' || job ename, sal FROM emp;
BEGIN
  --隐含打开游标
  FOR v_sal IN c_sal LOOP
    --隐含执行一个FETCH语句
    DBMS_OUTPUT.PUT_LINE(to_char(v_sal.empno) || '---' || v_sal.ename || '---' || to_char(v_sal.sal));
    --隐含监测c_sal%NOTFOUND
  END LOOP;
  --隐含关闭游标
END;

--子查询实现游标
BEGIN
  FOR c1_rec IN (SELECT dname, loc,deptno FROM dept) LOOP
    DBMS_OUTPUT.PUT_LINE(c1_rec.dname || ' + ' || c1_rec.loc||' - ' || c1_rec.deptno);
  END LOOP;
END;

--
PROMPT

PROMPT 'What table would you like to see?'
ACCEPT tab PROMPT '(D)epartment, or (E)mployees:'

DECLARE
  Type refcur_t IS REF CURSOR;
  Refcur refcur_t;
  TYPE sample_rec_type IS RECORD(
    Id          number,
    Description VARCHAR2(30));
  sample    sample_rec_type;
  selection varchar2(1) := UPPER(SUBSTR('&tab', 1, 1));
BEGIN
  IF selection = 'D' THEN
    OPEN refcur FOR
      SELECT dept.deptno, dept.dname FROM dept;
    DBMS_OUTPUT.PUT_LINE('Department data');
  ELSIF selection = 'E' THEN
    OPEN refcur FOR
      SELECT emp.empno, emp.ename || ' is a ' || emp.job FROM emp;
    DBMS_OUTPUT.PUT_LINE('Employee data');
  ELSE
    DBMS_OUTPUT.PUT_LINE('Please enter ''D'' or ''E''');
    RETURN;
  END IF;
  DBMS_OUTPUT.PUT_LINE('----------------------');
  FETCH refcur INTO sample;
  WHILE refcur %FOUND LOOP
    DBMS_OUTPUT.PUT_LINE(sample.id || ': ' || sample.description);
    FETCH refcur INTO sample;
  END LOOP;
  CLOSE refcur;
END;
/


