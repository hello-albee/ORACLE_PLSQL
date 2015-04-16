--第七章

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
    empno_remaining EXCEPTION; --自定义异常
    PRAGMA EXCEPTION_INIT(empno_remaining, -1);/* -1 是违反唯一约束条件的错误代码 */
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
      DBMS_OUTPUT.PUT_LINE('温馨提示:数据库中没有编码为' || dept_no || '的部门');
    WHEN TOO_MANY_ROWS THEN
      DBMS_OUTPUT.PUT_LINE('程序运行错误,请使用游标进行操作!');
    WHEN OTHERS THEN
      DBMS_OUTPUT.PUT_LINE(SQLCODE || '----' || SQLERRM);
  END query_dept;

END DEMO_PKG;

--程序包的调用
DECLARE
  Var NUMBER;
BEGIN
  Var := DEMO_PKG.add_dept(50, 'Develpoer', 'ChengDu');
  IF var = -1 THEN
    DBMS_OUTPUT.PUT_LINE(SQLCODE || '----' || SQLERRM);
  ELSIF var = 0 THEN
    DBMS_OUTPUT.PUT_LINE('温馨提示:该部门记录已经存在！ ');
  ELSE
    DBMS_OUTPUT.PUT_LINE('温馨提示:添加记录成功！ ');
  
    DEMO_PKG.query_dept(50);
    DBMS_OUTPUT.PUT_LINE(DEMO_PKG.DeptRec.deptno || '---' ||
                         DEMO_PKG.DeptRec.dname || '---' ||
                         DEMO_PKG.DeptRec.loc);
  
    var := DEMO_PKG.delete_dept(50);
    IF var = -1 THEN
      DBMS_OUTPUT.PUT_LINE(SQLCODE || '----' || SQLERRM);
    ELSIF var = 0 THEN
      DBMS_OUTPUT.PUT_LINE('温馨提示:该部门记录不存在！ ');
    ELSE
      DBMS_OUTPUT.PUT_LINE('温馨提示:删除记录成功！ ');
    END IF;
  END IF;
END;

--例2
--创建包头
CREATE OR REPLACE PACKAGE EMP_PKG IS
  TYPE emp_table_type IS TABLE OF emp%ROWTYPE INDEX BY BINARY_INTEGER;
  PROCEDURE read_emp_table(p_emp_table OUT emp_table_type);
END;
--创建包体
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
--执行
DECLARE
  E_table EMP_PKG.emp_table_type;
BEGIN
  EMP_PKG.read_emp_table(e_table);
  FOR I IN e_table.FIRST .. e_table.LAST LOOP
    /*i居然是从0开始的*/
    DBMS_OUTPUT.PUT_LINE(i|| ' - ' ||e_table(i).empno || ' - ' || e_table(i).ename);
  END LOOP;
END;


--
--创建序列从100开始,依次增加1
CREATE SEQUENCE empseq
START WITH 100
INCREMENT BY 1
ORDER NOCYCLE;
--创建序列从100开始,依次增加10
CREATE SEQUENCE deptseq
START WITH 100
INCREMENT BY 10
ORDER NOCYCLE;

--包头
CREATE OR REPLACE PACKAGE MANAGE_EMP_PKG AS
  --增加一名员工
  FUNCTION hire_emp(ename  VARCHAR2,
                    job    VARCHAR2,
                    mgr    NUMBER,
                    sal    NUMBER,
                    comm   NUMBER,
                    deptno NUMBER) RETURN NUMBER;
  --新增一个部门
  FUNCTION add_dept(dname VARCHAR2, loc VARCHAR2) RETURN NUMBER;
  --删除指定员工
  PROCEDURE remove_emp(empno NUMBER);
  --删除指定部门
  PROCEDURE remove_dept(deptno NUMBER);
  --增加指定员工的工资
  PROCEDURE increase_sal(empno NUMBER, sal_incr NUMBER);
  --增加指定员工的奖金
  PROCEDURE increase_comm(empno NUMBER, comm_incr NUMBER);
END;

--包体
CREATE OR REPLACE PACKAGE BODY MANAGE_EMP_PKG AS
  total_emps  NUMBER; --员工数
  total_depts NUMBER; --部门数
  no_sal  EXCEPTION;
  no_comm EXCEPTION;
  --增加一名员工
  FUNCTION hire_emp(ename  VARCHAR2,
                    job    VARCHAR2,
                    mgr    NUMBER,
                    sal    NUMBER,
                    comm   NUMBER,
                    deptno NUMBER) RETURN NUMBER --返回新增加的员工编号
   IS
    new_empno NUMBER(4);
  BEGIN
    SELECT empseq.NEXTVAL INTO new_empno FROM dual;
    SELECT COUNT(*) INTO total_emps FROM emp; --当前记录总数
    INSERT INTO emp
    VALUES (new_empno, ename, job, mgr, to_date(to_char(sysdate,'yyyy-mm-dd'),'yyyy/mm/dd'), sal, comm, deptno);
    total_emps := total_emps + 1;
    RETURN(new_empno);
  EXCEPTION
    WHEN OTHERS THEN
      DBMS_OUTPUT.PUT_LINE('温馨提示:发生系统错误!');
  END ;
  
  --新增一个部门
  FUNCTION add_dept(dname VARCHAR2, loc VARCHAR2) RETURN NUMBER IS
    new_deptno NUMBER(4); --部门编号
  BEGIN
    SELECT deptseq.NEXTVAL INTO new_deptno FROM dual;
    SELECT COUNT(*) INTO total_depts FROM dept; --当前部门总数
    INSERT INTO dept VALUES (new_deptno, dname, loc);
    total_depts := total_depts+1;
    RETURN(new_deptno);
  EXCEPTION
    WHEN OTHERS THEN
      DBMS_OUTPUT.PUT_LINE('温馨提示:发生系统错误!');
  END add_dept;
  
  --删除指定员工
  PROCEDURE remove_emp(empno NUMBER) IS
    no_result EXCEPTION; --自定义异常
  BEGIN
    DELETE FROM emp WHERE emp.empno = empno;
    IF SQL%NOTFOUND THEN
      RAISE no_result;
    END IF;
    total_emps := total_emps - 1; --总的员工数减1
  EXCEPTION
    WHEN no_result THEN
      DBMS_OUTPUT.PUT_LINE('温馨提示:你需要的数据不存在!');
    WHEN OTHERS THEN
      DBMS_OUTPUT.PUT_LINE('温馨提示:发生系统错误!');
  END ;
  
  --删除指定部门
  PROCEDURE remove_dept(deptno NUMBER) IS
    no_result                  EXCEPTION; --自定义异常
    exception_deptno_remaining EXCEPTION; --自定义异常
    /*-2292 是违反一致性约束的错误代码*/
    PRAGMA EXCEPTION_INIT(exception_deptno_remaining, -2292);
  BEGIN
    DELETE FROM dept WHERE dept.deptno = deptno;
    IF SQL%NOTFOUND THEN
      RAISE no_result;
    END IF;
    total_depts := total_depts - 1; --总的部门数减1
  EXCEPTION
    WHEN no_result THEN
      DBMS_OUTPUT.PUT_LINE('温馨提示:你需要的数据不存在!');
    WHEN exception_deptno_remaining THEN
      DBMS_OUTPUT.PUT_LINE('温馨提示:违反数据完整性约束!');
    WHEN OTHERS THEN
      DBMS_OUTPUT.PUT_LINE('温馨提示:发生系统错误!');
  END ;
  
  --给指定员工增加指定数量的工资
  PROCEDURE increase_sal(empno NUMBER, sal_incr NUMBER) IS
    curr_sal NUMBER(7, 2); --当前工资
  BEGIN
    --得到当前工资
    SELECT sal INTO curr_sal FROM emp WHERE emp.empno = empno;
    IF curr_sal IS NULL THEN
      RAISE no_sal;
    ELSE
      UPDATE emp
         SET sal = sal + sal_incr --当前工资加新增的工资
       WHERE emp.empno = empno;
    END IF;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      DBMS_OUTPUT.PUT_LINE('温馨提示:你需要的数据不存在!');
    WHEN no_sal THEN
      DBMS_OUTPUT.PUT_LINE('温馨提示:此员工的工资不存在!');
    WHEN OTHERS THEN
      DBMS_OUTPUT.PUT_LINE('温馨提示:发生系统错误!');
  END ;
  
  --给指定员工增加指定数量的奖金
  PROCEDURE increase_comm(empno NUMBER, comm_incr NUMBER) IS
    curr_comm NUMBER(7, 2);
  BEGIN
    --得到指定员工的当前资金
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
      DBMS_OUTPUT.PUT_LINE('温馨提示:你需要的数据不存在!');
    WHEN no_comm THEN
      DBMS_OUTPUT.PUT_LINE('温馨提示:此员工的奖金不存在!');
    WHEN OTHERS THEN
      DBMS_OUTPUT.PUT_LINE('温馨提示:发生系统错误!');
  END;
END;

--调用
--Command中执行--
/*声明了一个绑定变量empno，绑定变量声明的时候不能赋值*/
variable empno number 
/*绑定变量直接引用必须加前缀 ":"*/
execute :empno:= manage_emp_pkg.hire_emp('Lynch',PM,9999,8888,6666,10)
-----------------

------------------
--包与游标结合使用
--包头
CREATE OR REPLACE PACKAGE CURROR_VARIBAL_PKG AS
  TYPE DeptCurType IS REF CURSOR RETURN dept%ROWTYPE; --强类型定义
  TYPE CurType IS REF CURSOR; -- 弱类型定义
  PROCEDURE OpenDeptVar(Cv        IN OUT DeptCurType,
                        Choice    INTEGER DEFAULT 0,
                        Dept_no   NUMBER DEFAULT 50,
                        Dept_name VARCHAR DEFAULT '%');
END;

--包体
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

--定义一个过程
CREATE OR REPLACE PROCEDURE UP_OpenCurType(Cv                  IN OUT CURROR_VARIBAL_PKG.CurType,
                                           FirstCapInTableName CHAR) AS
BEGIN
  --CURROR_VARIBAL_PKG.CurType采用弱类型定义
  --所以可以使用它定义的游标变量打开不同类型的查询语句
  IF FirstCapInTableName = 'D' THEN
    OPEN cv FOR
      SELECT * FROM dept;
  ELSE
    OPEN cv FOR
      SELECT * FROM emp;
  END IF;
END;

--定义一个应用
DECLARE
  DeptRec Dept%ROWTYPE;
  EmpRec  Emp%ROWTYPE;
  Cv1     CURROR_VARIBAL_PKG.deptcurtype;
  Cv2     CURROR_VARIBAL_PKG.curtype;
BEGIN
  DBMS_OUTPUT.PUT_LINE('游标变量强类型定义应用');
  CURROR_VARIBAL_PKG.OpenDeptVar(cv1, 1, 30);
  FETCH cv1 INTO DeptRec;
  WHILE cv1%FOUND LOOP
    DBMS_OUTPUT.PUT_LINE(DeptRec.deptno || ':' || DeptRec.dname);
    FETCH cv1 INTO DeptRec;
  END LOOP;
  /*务必要关闭游标*/
  CLOSE cv1;
  
  DBMS_OUTPUT.PUT_LINE('游标变量弱类型定义应用');
  CURROR_VARIBAL_PKG.OpenDeptvar(cv2, 2, dept_name => 'A%');
  FETCH cv2 INTO DeptRec;
  WHILE cv2%FOUND LOOP
    DBMS_OUTPUT.PUT_LINE(DeptRec.deptno || ':' || DeptRec.dname);
    FETCH cv2 INTO DeptRec;
  END LOOP;
  
  DBMS_OUTPUT.PUT_LINE('游标变量弱类型定义应用—dept表');
  UP_OpenCurType(cv2, 'D');
  FETCH cv2 INTO DeptRec;
  WHILE cv2%FOUND LOOP
    DBMS_OUTPUT.PUT_LINE(deptrec.deptno || ':' || deptrec.dname);
    FETCH cv2 INTO deptrec;
  END LOOP;
  
  DBMS_OUTPUT.PUT_LINE('游标变量弱类型定义应用—emp表');
  UP_OpenCurType(cv2, 'E');
  FETCH cv2 INTO EmpRec;
  WHILE cv2%FOUND LOOP
    DBMS_OUTPUT.PUT_LINE(emprec.empno || ':' || emprec.ename);
    FETCH cv2 INTO emprec;
  END LOOP;
  CLOSE cv2;
END;

--重载
--包头
CREATE OR REPLACE PACKAGE DEMO_PKG1 IS
  DeptRec   dept%ROWTYPE;
  V_sqlcode NUMBER;
  V_sqlerr  VARCHAR2(2048);
  --两个子程序名字相同,但参数类型不同
  FUNCTION query_dept(dept_no IN NUMBER) RETURN INTEGER;
  FUNCTION query_dept(dept_no IN VARCHAR2) RETURN INTEGER;
END ;

--包体
CREATE OR REPLACE PACKAGE BODY DEMO_PKG1 IS
  FUNCTION check_dept(dept_no NUMBER) RETURN INTEGER IS
    deptCnt INTEGER; --指定部门号的部门数量
  BEGIN
    SELECT COUNT(*) INTO deptCnt FROM dept WHERE deptno = dept_no;
    IF deptCnt > 0 THEN
      RETURN 1;
    ELSE
      RETURN 0;
    END IF;
  END ;
  --名称相同的函数，入参不同
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
  --函数名称相同，入参不同
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

--调用
--Command执行
variable  cnt1 number;
exec :cnt1:= DEMO_PKG1.query_dept(30)

var       cnt2 number 
call DEMO_PKG1.query_dept('30') into :cnt2
/

print cnt1
print cnt2


