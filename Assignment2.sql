PL/SQL2
======

-----QUESTION1------
----CREATE TRIGGER------------
CREATE OR REPLACE TRIGGER BB_ORDERCANCEL_TRG 
AFTER
INSERT
ON bb_basketstatus
FOR EACH ROW
WHEN (NEW.idstage = 4)
BEGIN
   UPDATE bb_basket SET orderplaced = 0 WHERE idBasket = :NEW.idbasket;
   FOR v_stockrec IN (SELECT idproduct,quantity FROM bb_basketitem WHERE IDBASKET=:NEW.idbasket)
   LOOP
    UPDATE bb_product SET stock = stock + v_stockrec.quantity WHERE idproduct = v_stockrec.idproduct;
    UPDATE bb_basketitem SET quantity = 0 WHERE idproduct = v_stockrec.idproduct;
   END LOOP;
END;
--------EXECUTE-----------------
INSERT
INTO bb_basketstatus
  (
    idstatus,
    idbasket,
    idstage,
    dtstage
  )
  VALUES
  (
    bb_status_seq.nextval,
    6,
    4,
    sysdate
  );
  
SELECT idproduct,stock FROM bb_product WHERE idproduct=2 OR idproduct=10;
SELECT orderplaced FROM bb_basket WHERE IDBASKET=6;
SELECT idproduct,quantity FROM BB_BASKETITEM WHERE IDBASKET = 6;
Alter trigger BB_ORDERCANCEL_TRG disable;


-----QUESTION2------
----CREATE TRIGGER------------
CREATE OR REPLACE PACKAGE DISC_PKG  IS
PV_DISC_NUM  NUMBER:=0;
PV_DISC_TXT VARCHAR2(2):='N';
PROCEDURE reset_dis;
END DISC_PKG;

CREATE OR REPLACE PACKAGE BODY DISC_PKG IS
PROCEDURE reset_dis IS
BEGIN
if PV_DISC_NUM = 5 then PV_DISC_TXT := 'Y';
DBMS_OUTPUT.PUT_LINE('THIS CUSTOMER HAS 10% DISCOUNT!');
PV_DISC_NUM := 0;
PV_DISC_TXT := 'N';
end if;
end reset_dis;
END DISC_PKG;

CREATE OR REPLACE TRIGGER BB_DISCOUNT_TRG 
BEFORE update ON BB_BASKET
FOR EACH ROW
WHEN (new.ORDERPLACED = 1)
DECLARE 
  PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN
select count(IDBASKET) into DISC_PKG.PV_DISC_NUM from bb_basket where idshopper = :new.idshopper;
DISC_PKG.RESET_DIS();
END;
--------EXECUTE-----------------
set serveroutput on
begin
  UPDATE BB_BASKET SET orderplaced = 1 WHERE idbasket = 16;
end;

INSERT INTO BB_BASKET(IDBASKET,IDSHOPPER,ORDERPLACED) VALUES(BB_IDBASKET_SEQ.NEXTVAL,21,0);

-----QUESTION3------
----CREATE TRIGGER------------
CREATE OR REPLACE TRIGGER BB_PRODUCT_TRG
AFTER UPDATE OF IDPRODUCT ON BB_PRODUCT
FOR EACH ROW
BEGIN
UPDATE BB_BASKETITEM  SET IDPRODUCT = :NEW.IDPRODUCT
WHERE IDPRODUCT = :OLD.IDPRODUCT;

UPDATE BB_PRODUCTOPTION SET IDPRODUCT = :NEW.IDPRODUCT
WHERE IDPRODUCT = :OLD.IDPRODUCT;

END;

--------EXECUTE-----------------

Update BB_PRODUCT set idproduct =22 where idproduct=7;

select b.idproduct, p.idproduct from BB_BASKETITEM b, bb_productoption p WHERE P.idproduct =22;

rollback;

Alter trigger BB_PRODUCT_TRG disable;

-----QUESTION4------
----CREATE TRIGGER------------
CREATE TABLE BB_PRODCHG_AUDIT (
user_id VARCHAR2(30),
time_stamp date,
PRODUCTNAME VARCHAR2(25),
IDPRODUCT NUMBER(6),
old_PRICE NUMBER(6,2),
new_PRICE NUMBER(6,2),
old_SALESTART date,
new_SALESTART date,
old_SALEEND date,
new_SALEEND date,
old_SALEPRICE NUMBER(6,2),
new_SALEPRICE NUMBER(6,2));
/
CREATE OR REPLACE TRIGGER BB_AUDIT_TRG
AFTER DELETE OR INSERT OR UPDATE ON BB_PRODUCT 
FOR EACH ROW
BEGIN
INSERT INTO  BB_PRODCHG_AUDIT (user_id, time_stamp, PRODUCTNAME, IDPRODUCT,
old_PRICE, new_PRICE, old_SALESTART,
new_SALESTART, old_SALEEND, new_SALEEND, old_SALEPRICE, new_SALEPRICE)
VALUES (USER, SYSDATE, :OLD.PRODUCTNAME,:OLD.IDPRODUCT,
:OLD.PRICE, :NEW.PRICE, :OLD.SALESTART,
:NEW.SALESTART, :OLD.SALEEND, :NEW.SALEEND,:OLD.SALEPRICE, :NEW.SALEPRICE);
END;
--------EXECUTE-----------------

Update bb_product set salestart = '05-MAY-03', saleend = '12-MAY-03', saleprice = 9 where idproduct = 10;

SELECT * FROM BB_PRODCHG_AUDIT; 

rollback;

Alter trigger BB_AUDIT_TRG disable;


