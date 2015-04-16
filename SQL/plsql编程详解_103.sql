--������
DECLARE
  err_msg VARCHAR2(100);
BEGIN
  /* �õ����� ORACLE ������Ϣ */
  FOR err_num IN -20 .. 0 LOOP
    err_msg := SQLERRM(err_num);
    dbms_output.put_line(err_num||' - '||err_msg);
  END LOOP;
END;

--�����쳣����׽ʱ���쳣֮�����䲻�ᱻִ��
CREATE TABLE errlog(
Errcode NUMBER,
Errtext CHAR(40));

CREATE OR REPLACE FUNCTION get_sal(p_deptno NUMBER) RETURN NUMBER AS
  v_sal NUMBER;
BEGIN
  IF p_deptno IS NULL THEN
    RAISE_APPLICATION_ERROR(-20991, �����Ŵ���Ϊ�ա�);
  ELSIF p_deptno < 0 THEN
    RAISE_APPLICATION_ERROR(-20992, ����Ч�Ĳ��Ŵ��롯);
  ELSE
    SELECT SUM(emp.sal) INTO v_sal FROM emp
     WHERE emp.deptno = p_deptno;
    RETURN v_sal;
  END IF;
END;



DECLARE
  V_sal     NUMBER(7, 2);
  V_sqlcode NUMBER;
  V_sqlerr  VARCHAR2(512);
  Null_deptno    EXCEPTION;
  Invalid_deptno EXCEPTION;
  PRAGMA EXCEPTION_INIT(null_deptno, -20991);
  PRAGMA EXCEPTION_INIT(invalid_deptno, -20992);
BEGIN
  V_sal := get_sal(10);
  DBMS_OUTPUT.PUT_LINE('10�Ų��Ź��ʣ� ' || TO_CHAR(V_sal));
  
  BEGIN
    V_sal := get_sal(-10);
  EXCEPTION
    WHEN invalid_deptno THEN
      V_sqlcode := SQLCODE;
      V_sqlerr  := SQLERRM;
      INSERT INTO errlog (errcode, errtext) VALUES (v_sqlcode, v_sqlerr);
      COMMIT;
  END ;
  
  V_sal := get_sal(20);
  DBMS_OUTPUT.PUT_LINE('���ź�Ϊ20�Ĺ���Ϊ�� ' || TO_CHAR(V_sal));
  
  BEGIN
    V_sal := get_sal(NULL);
  END ;
  
  V_sal := get_sal(30);
  DBMS_OUTPUT.PUT_LINE('���ź�Ϊ30�Ĺ���Ϊ�� ' || TO_CHAR(V_sal));
  
EXCEPTION
  WHEN null_deptno THEN
    V_sqlcode := SQLCODE;
    V_sqlerr  := SQLERRM;
    INSERT INTO errlog (errcode, errtext) VALUES (v_sqlcode, v_sqlerr);
    COMMIT;
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE(SQLCODE || '---' || SQLERRM);
END ;

