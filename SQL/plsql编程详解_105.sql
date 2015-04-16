--������

CREATE OR REPLACE PACKAGE DEMO_PKG IS
  DEPTREC DEPT%ROWTYPE;
  --Add dept...
  FUNCTION add_dept(dept_no NUMBER, dept_name VARCHAR2, location VARCHAR2)
    RETURN NUMBER;
  --delete dept...
  FUNCTION delete_dept(dept_no NUMBER) RETURN NUMBER;
  --query dept...
  PROCEDURE query_dept(dept_no IN NUMBER);
END DEMO_PKG;


CREATE OR REPLACE PACKAGE BODY DEMO_PKG IS
  FUNCTION add_dept(dept_no NUMBER, dept_name VARCHAR2, location VARCHAR2) RETURN NUMBER IS
    empno_remaining EXCEPTION; --�Զ����쳣
    PRAGMA EXCEPTION_INIT(empno_remaining, -1);/* -1 ��Υ��ΨһԼ�������Ĵ������ */
  BEGIN
    INSERT INTO dept VALUES (dept_no, dept_name, location);
    IF SQL%FOUND THEN
      RETURN 1;
    END IF;
  EXCEPTION
    WHEN empno_remaining THEN
      RETURN 0;
    WHEN OTHERS THEN
      RETURN - 1;
  END add_dept;
  
  FUNCTION delete_dept(dept_no NUMBER) RETURN NUMBER IS
  BEGIN
    DELETE FROM dept WHERE deptno = dept_no;
    IF SQL%FOUND THEN
      RETURN 1;
    ELSE
      RETURN 0;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN - 1;
  END delete_dept;
  
  PROCEDURE query_dept(dept_no IN NUMBER) IS
  BEGIN
    SELECT * INTO DeptRec FROM dept WHERE deptno = dept_no;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      DBMS_OUTPUT.PUT_LINE('��ܰ��ʾ:���ݿ���û�б���Ϊ' || dept_no || '�Ĳ���');
    WHEN TOO_MANY_ROWS THEN
      DBMS_OUTPUT.PUT_LINE('�������д���,��ʹ���α���в���!');
    WHEN OTHERS THEN
      DBMS_OUTPUT.PUT_LINE(SQLCODE || '----' || SQLERRM);
  END query_dept;

END DEMO_PKG;

--������ĵ���
DECLARE
  Var NUMBER;
BEGIN
  Var := DEMO_PKG.add_dept(50, 'Develpoer', 'ChengDu');
  IF var = -1 THEN
    DBMS_OUTPUT.PUT_LINE(SQLCODE || '----' || SQLERRM);
  ELSIF var = 0 THEN
    DBMS_OUTPUT.PUT_LINE('��ܰ��ʾ:�ò��ż�¼�Ѿ����ڣ� ');
  ELSE
    DBMS_OUTPUT.PUT_LINE('��ܰ��ʾ:��Ӽ�¼�ɹ��� ');
  
    DEMO_PKG.query_dept(50);
    DBMS_OUTPUT.PUT_LINE(DEMO_PKG.DeptRec.deptno || '---' ||
                         DEMO_PKG.DeptRec.dname || '---' ||
                         DEMO_PKG.DeptRec.loc);
  
    var := DEMO_PKG.delete_dept(50);
    IF var = -1 THEN
      DBMS_OUTPUT.PUT_LINE(SQLCODE || '----' || SQLERRM);
    ELSIF var = 0 THEN
      DBMS_OUTPUT.PUT_LINE('��ܰ��ʾ:�ò��ż�¼�����ڣ� ');
    ELSE
      DBMS_OUTPUT.PUT_LINE('��ܰ��ʾ:ɾ����¼�ɹ��� ');
    END IF;
  END IF;
END;

--��2
--������ͷ
CREATE OR REPLACE PACKAGE EMP_PKG IS
  TYPE emp_table_type IS TABLE OF emp%ROWTYPE INDEX BY BINARY_INTEGER;
  PROCEDURE read_emp_table(p_emp_table OUT emp_table_type);
END;
--��������
CREATE OR REPLACE PACKAGE BODY EMP_PKG IS
  PROCEDURE read_emp_table(p_emp_table OUT emp_table_type) IS
    I BINARY_INTEGER := 0;
  BEGIN
    FOR emp_record IN (SELECT * FROM emp) LOOP
      P_emp_table(i) := emp_record;
      I := I + 1;
    END LOOP;
  END;
END;
--ִ��
DECLARE
  E_table EMP_PKG.emp_table_type;
BEGIN
  EMP_PKG.read_emp_table(e_table);
  FOR I IN e_table.FIRST .. e_table.LAST LOOP
    /*i��Ȼ�Ǵ�0��ʼ��*/
    DBMS_OUTPUT.PUT_LINE(i|| ' - ' ||e_table(i).empno || ' - ' || e_table(i).ename);
  END LOOP;
END;


--
--�������д�100��ʼ,��������1
CREATE SEQUENCE empseq
START WITH 100
INCREMENT BY 1
ORDER NOCYCLE;
--�������д�100��ʼ,��������10
CREATE SEQUENCE deptseq
START WITH 100
INCREMENT BY 10
ORDER NOCYCLE;

--��ͷ
CREATE OR REPLACE PACKAGE MANAGE_EMP_PKG AS
  --����һ��Ա��
  FUNCTION hire_emp(ename  VARCHAR2,
                    job    VARCHAR2,
                    mgr    NUMBER,
                    sal    NUMBER,
                    comm   NUMBER,
                    deptno NUMBER) RETURN NUMBER;
  --����һ������
  FUNCTION add_dept(dname VARCHAR2, loc VARCHAR2) RETURN NUMBER;
  --ɾ��ָ��Ա��
  PROCEDURE remove_emp(empno NUMBER);
  --ɾ��ָ������
  PROCEDURE remove_dept(deptno NUMBER);
  --����ָ��Ա���Ĺ���
  PROCEDURE increase_sal(empno NUMBER, sal_incr NUMBER);
  --����ָ��Ա���Ľ���
  PROCEDURE increase_comm(empno NUMBER, comm_incr NUMBER);
END;

--����
CREATE OR REPLACE PACKAGE BODY MANAGE_EMP_PKG AS
  total_emps  NUMBER; --Ա����
  total_depts NUMBER; --������
  no_sal  EXCEPTION;
  no_comm EXCEPTION;
  --����һ��Ա��
  FUNCTION hire_emp(ename  VARCHAR2,
                    job    VARCHAR2,
                    mgr    NUMBER,
                    sal    NUMBER,
                    comm   NUMBER,
                    deptno NUMBER) RETURN NUMBER --���������ӵ�Ա�����
   IS
    new_empno NUMBER(4);
  BEGIN
    SELECT empseq.NEXTVAL INTO new_empno FROM dual;
    SELECT COUNT(*) INTO total_emps FROM emp; --��ǰ��¼����
    INSERT INTO emp
    VALUES (new_empno, ename, job, mgr, to_date(to_char(sysdate,'yyyy-mm-dd'),'yyyy/mm/dd'), sal, comm, deptno);
    total_emps := total_emps + 1;
    RETURN(new_empno);
  EXCEPTION
    WHEN OTHERS THEN
      DBMS_OUTPUT.PUT_LINE('��ܰ��ʾ:����ϵͳ����!');
  END ;
  
  --����һ������
  FUNCTION add_dept(dname VARCHAR2, loc VARCHAR2) RETURN NUMBER IS
    new_deptno NUMBER(4); --���ű��
  BEGIN
    SELECT deptseq.NEXTVAL INTO new_deptno FROM dual;
    SELECT COUNT(*) INTO total_depts FROM dept; --��ǰ��������
    INSERT INTO dept VALUES (new_deptno, dname, loc);
    total_depts := total_depts+1;
    RETURN(new_deptno);
  EXCEPTION
    WHEN OTHERS THEN
      DBMS_OUTPUT.PUT_LINE('��ܰ��ʾ:����ϵͳ����!');
  END add_dept;
  
  --ɾ��ָ��Ա��
  PROCEDURE remove_emp(empno NUMBER) IS
    no_result EXCEPTION; --�Զ����쳣
  BEGIN
    DELETE FROM emp WHERE emp.empno = empno;
    IF SQL%NOTFOUND THEN
      RAISE no_result;
    END IF;
    total_emps := total_emps - 1; --�ܵ�Ա������1
  EXCEPTION
    WHEN no_result THEN
      DBMS_OUTPUT.PUT_LINE('��ܰ��ʾ:����Ҫ�����ݲ�����!');
    WHEN OTHERS THEN
      DBMS_OUTPUT.PUT_LINE('��ܰ��ʾ:����ϵͳ����!');
  END ;
  
  --ɾ��ָ������
  PROCEDURE remove_dept(deptno NUMBER) IS
    no_result                  EXCEPTION; --�Զ����쳣
    exception_deptno_remaining EXCEPTION; --�Զ����쳣
    /*-2292 ��Υ��һ����Լ���Ĵ������*/
    PRAGMA EXCEPTION_INIT(exception_deptno_remaining, -2292);
  BEGIN
    DELETE FROM dept WHERE dept.deptno = deptno;
    IF SQL%NOTFOUND THEN
      RAISE no_result;
    END IF;
    total_depts := total_depts - 1; --�ܵĲ�������1
  EXCEPTION
    WHEN no_result THEN
      DBMS_OUTPUT.PUT_LINE('��ܰ��ʾ:����Ҫ�����ݲ�����!');
    WHEN exception_deptno_remaining THEN
      DBMS_OUTPUT.PUT_LINE('��ܰ��ʾ:Υ������������Լ��!');
    WHEN OTHERS THEN
      DBMS_OUTPUT.PUT_LINE('��ܰ��ʾ:����ϵͳ����!');
  END ;
  
  --��ָ��Ա������ָ�������Ĺ���
  PROCEDURE increase_sal(empno NUMBER, sal_incr NUMBER) IS
    curr_sal NUMBER(7, 2); --��ǰ����
  BEGIN
    --�õ���ǰ����
    SELECT sal INTO curr_sal FROM emp WHERE emp.empno = empno;
    IF curr_sal IS NULL THEN
      RAISE no_sal;
    ELSE
      UPDATE emp
         SET sal = sal + sal_incr --��ǰ���ʼ������Ĺ���
       WHERE emp.empno = empno;
    END IF;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      DBMS_OUTPUT.PUT_LINE('��ܰ��ʾ:����Ҫ�����ݲ�����!');
    WHEN no_sal THEN
      DBMS_OUTPUT.PUT_LINE('��ܰ��ʾ:��Ա���Ĺ��ʲ�����!');
    WHEN OTHERS THEN
      DBMS_OUTPUT.PUT_LINE('��ܰ��ʾ:����ϵͳ����!');
  END ;
  
  --��ָ��Ա������ָ�������Ľ���
  PROCEDURE increase_comm(empno NUMBER, comm_incr NUMBER) IS
    curr_comm NUMBER(7, 2);
  BEGIN
    --�õ�ָ��Ա���ĵ�ǰ�ʽ�
    SELECT comm INTO curr_comm FROM emp
     WHERE emp.empno = empno;
    IF curr_comm IS NULL THEN
      RAISE no_comm;
    ELSE
      UPDATE emp
         SET comm = comm + increase_comm.comm_incr
       WHERE emp.empno = increase_comm.empno;
    END IF;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      DBMS_OUTPUT.PUT_LINE('��ܰ��ʾ:����Ҫ�����ݲ�����!');
    WHEN no_comm THEN
      DBMS_OUTPUT.PUT_LINE('��ܰ��ʾ:��Ա���Ľ��𲻴���!');
    WHEN OTHERS THEN
      DBMS_OUTPUT.PUT_LINE('��ܰ��ʾ:����ϵͳ����!');
  END;
END;

--����
--Command��ִ��--
/*������һ���󶨱���empno���󶨱���������ʱ���ܸ�ֵ*/
variable empno number 
/*�󶨱���ֱ�����ñ����ǰ׺ ":"*/
execute :empno:= manage_emp_pkg.hire_emp('Lynch',PM,9999,8888,6666,10)
-----------------

------------------
--�����α���ʹ��
--��ͷ
CREATE OR REPLACE PACKAGE CURROR_VARIBAL_PKG AS
  TYPE DeptCurType IS REF CURSOR RETURN dept%ROWTYPE; --ǿ���Ͷ���
  TYPE CurType IS REF CURSOR; -- �����Ͷ���
  PROCEDURE OpenDeptVar(Cv        IN OUT DeptCurType,
                        Choice    INTEGER DEFAULT 0,
                        Dept_no   NUMBER DEFAULT 50,
                        Dept_name VARCHAR DEFAULT '%');
END;

--����
CREATE OR REPLACE PACKAGE BODY CURROR_VARIBAL_PKG AS
  PROCEDURE OpenDeptvar(Cv        IN OUT DeptCurType,
                        Choice    INTEGER DEFAULT 0,
                        Dept_no   NUMBER DEFAULT 50,
                        Dept_name VARCHAR DEFAULT '%') IS
  BEGIN
    IF choice = 1 THEN
      OPEN cv FOR
        SELECT * FROM dept WHERE deptno <= dept_no;
    ELSIF choice = 2 THEN
      OPEN cv FOR
        SELECT * FROM dept WHERE dname LIKE dept_name;
    ELSE
      OPEN cv FOR
        SELECT * FROM dept;
    END IF;
  END ;
END ;

--����һ������
CREATE OR REPLACE PROCEDURE UP_OpenCurType(Cv                  IN OUT CURROR_VARIBAL_PKG.CurType,
                                           FirstCapInTableName CHAR) AS
BEGIN
  --CURROR_VARIBAL_PKG.CurType���������Ͷ���
  --���Կ���ʹ����������α�����򿪲�ͬ���͵Ĳ�ѯ���
  IF FirstCapInTableName = 'D' THEN
    OPEN cv FOR
      SELECT * FROM dept;
  ELSE
    OPEN cv FOR
      SELECT * FROM emp;
  END IF;
END;

--����һ��Ӧ��
DECLARE
  DeptRec Dept%ROWTYPE;
  EmpRec  Emp%ROWTYPE;
  Cv1     CURROR_VARIBAL_PKG.deptcurtype;
  Cv2     CURROR_VARIBAL_PKG.curtype;
BEGIN
  DBMS_OUTPUT.PUT_LINE('�α����ǿ���Ͷ���Ӧ��');
  CURROR_VARIBAL_PKG.OpenDeptVar(cv1, 1, 30);
  FETCH cv1 INTO DeptRec;
  WHILE cv1%FOUND LOOP
    DBMS_OUTPUT.PUT_LINE(DeptRec.deptno || ':' || DeptRec.dname);
    FETCH cv1 INTO DeptRec;
  END LOOP;
  /*���Ҫ�ر��α�*/
  CLOSE cv1;
  
  DBMS_OUTPUT.PUT_LINE('�α���������Ͷ���Ӧ��');
  CURROR_VARIBAL_PKG.OpenDeptvar(cv2, 2, dept_name => 'A%');
  FETCH cv2 INTO DeptRec;
  WHILE cv2%FOUND LOOP
    DBMS_OUTPUT.PUT_LINE(DeptRec.deptno || ':' || DeptRec.dname);
    FETCH cv2 INTO DeptRec;
  END LOOP;
  
  DBMS_OUTPUT.PUT_LINE('�α���������Ͷ���Ӧ�á�dept��');
  UP_OpenCurType(cv2, 'D');
  FETCH cv2 INTO DeptRec;
  WHILE cv2%FOUND LOOP
    DBMS_OUTPUT.PUT_LINE(deptrec.deptno || ':' || deptrec.dname);
    FETCH cv2 INTO deptrec;
  END LOOP;
  
  DBMS_OUTPUT.PUT_LINE('�α���������Ͷ���Ӧ�á�emp��');
  UP_OpenCurType(cv2, 'E');
  FETCH cv2 INTO EmpRec;
  WHILE cv2%FOUND LOOP
    DBMS_OUTPUT.PUT_LINE(emprec.empno || ':' || emprec.ename);
    FETCH cv2 INTO emprec;
  END LOOP;
  CLOSE cv2;
END;

--����
--��ͷ
CREATE OR REPLACE PACKAGE DEMO_PKG1 IS
  DeptRec   dept%ROWTYPE;
  V_sqlcode NUMBER;
  V_sqlerr  VARCHAR2(2048);
  --�����ӳ���������ͬ,���������Ͳ�ͬ
  FUNCTION query_dept(dept_no IN NUMBER) RETURN INTEGER;
  FUNCTION query_dept(dept_no IN VARCHAR2) RETURN INTEGER;
END ;

--����
CREATE OR REPLACE PACKAGE BODY DEMO_PKG1 IS
  FUNCTION check_dept(dept_no NUMBER) RETURN INTEGER IS
    deptCnt INTEGER; --ָ�����źŵĲ�������
  BEGIN
    SELECT COUNT(*) INTO deptCnt FROM dept WHERE deptno = dept_no;
    IF deptCnt > 0 THEN
      RETURN 1;
    ELSE
      RETURN 0;
    END IF;
  END ;
  --������ͬ�ĺ�������β�ͬ
  FUNCTION check_dept(dept_no VARCHAR2) RETURN INTEGER IS
    deptCnt INTEGER;
  BEGIN
    SELECT COUNT(*) INTO deptCnt FROM dept WHERE deptno = dept_no;
    IF deptCnt > 0 THEN
      RETURN 1;
    ELSE
      RETURN 0;
    END IF;
  END ;
  
  FUNCTION query_dept(dept_no IN NUMBER) RETURN INTEGER IS
  BEGIN
    IF check_dept(dept_no) = 1 THEN
      SELECT * INTO DeptRec FROM dept WHERE deptno = dept_no;
      RETURN 1;
    ELSE
      RETURN 0;
    END IF;
  END ;
  --����������ͬ����β�ͬ
  FUNCTION query_dept(dept_no IN VARCHAR2) RETURN INTEGER IS
  BEGIN
    IF check_dept(dept_no) = 1 THEN
      SELECT * INTO DeptRec FROM dept WHERE deptno = dept_no;
      RETURN 1;
    ELSE
      RETURN 0;
    END IF;
  END ;
END ;

--����
--Commandִ��
variable  cnt1 number;
exec :cnt1:= DEMO_PKG1.query_dept(30)

var       cnt2 number 
call DEMO_PKG1.query_dept('30') into :cnt2
/

print cnt1
print cnt2


