--�ڶ���

DECLARE
  Row_id ROWID;
  info   VARCHAR2(40);
BEGIN
  INSERT INTO dept
  VALUES
    (60, 'ʵʩ��', '�ɶ�')
  RETURNING rowid, dname || ':' || to_char    (deptno) || ':' || loc 
  INTO row_id, info;
  
  DBMS_OUTPUT.PUT_LINE('ROWID:' || row_id);
  DBMS_OUTPUT.PUT_LINE(info);
END;

DECLARE
  Row_id ROWID;
  info   VARCHAR2(40);
BEGIN
  update dept d set d.deptno=51
  where d.dname='ʵʩ��'
  RETURNING rowid, dname || ':' || to_char    (deptno) || ':' || loc 
  INTO row_id, info;
  
  DBMS_OUTPUT.PUT_LINE('ROWID:' || row_id);
  DBMS_OUTPUT.PUT_LINE(info);
END;

select * from dept;

--������������
DECLARE
  TYPE test_rec IS RECORD(
    Name VARCHAR2(30) NOT NULL := 'Lynch',
    Info VARCHAR2(255));
  rec_book test_rec;
BEGIN
  rec_book.Name := 'Lynch';
  rec_book.Info := '���ź���ѧϰPL/SQL���;';
  DBMS_OUTPUT.PUT_LINE(rec_book.Name || ' - ' || rec_book.Info);
END;

--
DECLARE
  TYPE RECORD_TYPE_EMPLOYEES IS RECORD(
    F_NAME EMP.ENAME%TYPE,
    H_DATE EMP.HIREDATE%TYPE,
    J_ID   EMP.EMPNO%TYPE);

  V_EMP_RECORD RECORD_TYPE_EMPLOYEES;
BEGIN
  SELECT ENAME, HIREDATE, EMPNO
    INTO V_EMP_RECORD
    FROM EMP
   WHERE EMPNO = &EMPNO;
  DBMS_OUTPUT.PUT_LINE('��Ա���ƣ� ' || V_EMP_RECORD.F_NAME || ' ��Ӷ���ڣ� ' ||
                       V_EMP_RECORD.H_DATE || ' ��λ�� ' || V_EMP_RECORD.J_ID);
END;


--�ڶ��� ��6
DECLARE
  TYPE reg_varray_type IS VARRAY(5) OF VARCHAR2(25);
  v_reg_varray reg_varray_type;
BEGIN
  --�ù��캯���﷨�����ֵ
  v_reg_varray := reg_varray_type('�й�', '����', 'Ӣ��', '�ձ�', '����');
  DBMS_OUTPUT.PUT_LINE('�������ƣ� ' || v_reg_varray(1) || '�� ' ||
                       v_reg_varray(2) || '�� ' || v_reg_varray(3) || '�� ' ||
                       v_reg_varray(4));
  DBMS_OUTPUT.PUT_LINE('��5����Ա��ֵ�� ' || v_reg_varray(5));
  --�ù��캯���﷨�����ֵ��Ϳ��������Գ�Ա��ֵ
  v_reg_varray(5) := '������';
  DBMS_OUTPUT.PUT_LINE('��5����Ա��ֵ�� ' || v_reg_varray(5));
END;

--�ڶ��� ��9
DECLARE
  v_empno emp.empno%TYPE := &no;
  rec     emp%ROWTYPE;
BEGIN
  SELECT * INTO rec FROM emp WHERE empno = v_empno;
  DBMS_OUTPUT.PUT_LINE('����:' || rec.ename || ' ����:' || rec.sal || ' ����ʱ��:' ||
                       rec.hiredate);
END;

--�ڶ��� ��15
DECLARE
  Emess char(80);
BEGIN
  DECLARE
    V1 NUMBER(4);
  BEGIN
    SELECT empno INTO v1 FROM emp WHERE LOWER(job) = 'president';
    DBMS_OUTPUT.PUT_LINE(V1);
  EXCEPTION
    When TOO_MANY_ROWS THEN
      DBMS_OUTPUT.PUT_LINE('More than one president');
  END;
  DECLARE
    V1 NUMBER(4);
  BEGIN
    SELECT empno INTO v1 FROM emp WHERE LOWER(job) = 'manager';
  EXCEPTION
    When TOO_MANY_ROWS THEN
      DBMS_OUTPUT.PUT_LINE('More than one manager');
  END;
EXCEPTION
  When others THEN
    Emess := substr(SQLERRM, 1, 80);
    DBMS_OUTPUT.PUT_LINE(emess);
END;


