      SUBROUTINE COMCHK(IPR,KRD)
C
C        CLEARS OUT ANY COMMENTS NESTLED WITHIN A STACK OPERATION
C
      CHARACTER*(*) KRD(10)
      CHARACTER*3 ICOM,ITEST
      DATA ICOM/'COM'/
    5 CONTINUE
      READ (KRD,101)ITEST
  101 FORMAT(A3)
      IF(ITEST.EQ.ICOM) THEN
         CALL COMMNT(IPR,KRD)
         CALL KARDIN(KRD)
         GO TO 5
      END IF
      RETURN
      END
