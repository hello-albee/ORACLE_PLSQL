--������

--ѭ��
DECLARE
  int NUMBER(2) := 0;
BEGIN
  LOOP
    int := int + 1;
    DBMS_OUTPUT.PUT_LINE('int �ĵ�ǰֵΪ:' || int);
    EXIT WHEN int = 10;
  END LOOP;
END;



DECLARE
  x NUMBER := 1;
BEGIN
  WHILE x <= 10 LOOP
    DBMS_OUTPUT.PUT_LINE('X�ĵ�ǰֵΪ:' || x);
    x := x + 1;
  END LOOP;
END;


BEGIN
  FOR int in 1 .. 10 LOOP
    DBMS_OUTPUT.PUT_LINE('int �ĵ�ǰֵΪ: ' || int);
  END LOOP;
END;

--Ƕ��ѭ��
/*��100��110֮�������*/
DECLARE
  v_m NUMBER := 101;
  v_i NUMBER;
  v_n NUMBER := 0;
BEGIN
  WHILE v_m < 110 LOOP
    v_i := 2;
    LOOP
      IF mod(v_m, v_i) = 0 THEN
        v_i := 0;
        EXIT;
      END IF;
      v_i := v_i + 1;
      EXIT WHEN v_i > v_m - 1;
    END LOOP;
    IF v_i > 0 THEN
      v_n := v_n + 1;
      DBMS_OUTPUT.PUT_LINE('��' || v_n || '��������' || v_m);
    END IF;
    v_m := v_m + 2;
  END LOOP;
END;


--GOTO
DECLARE
  V_counter NUMBER := 1;
BEGIN
  LOOP
    DBMS_OUTPUT.PUT_LINE('V_counter�ĵ�ǰֵΪ:' || V_counter);
    V_counter := v_counter + 1;
    IF v_counter > 10 THEN
      GOTO labelOffLOOP;
    END IF;
  END LOOP;
  <<labelOffLOOP>>
  DBMS_OUTPUT.PUT_LINE('V_counter�ĵ�ǰֵΪ:' || V_counter);
END;

--GOTOʵ��ѭ��
DECLARE
  v_i NUMBER := 0;
  v_s NUMBER := 0;
BEGIN
  <<label_1>>
  v_i := v_i + 1;
  IF v_i <= 1000 THEN
    v_s := v_s + v_i;
    GOTO label_1;
  END IF;
  DBMS_OUTPUT.PUT_LINE(v_s);
END;



