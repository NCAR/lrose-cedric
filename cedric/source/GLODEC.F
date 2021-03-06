      SUBROUTINE GLODEC(A,NI,NJ,IBEG,IEND,JBEG,JEND,SDFAC,BAD)
C
C        DECIMATES USING A GLOBAL MEAN TO REMOVE STATISTICAL OUTLYERS
C
      DIMENSION A(NI,NJ)
      DATA CNTMIN/3.0/
      SUM=0.0
      SUMSQ=0.0
      CNT=0.0
      DO 30 J=JBEG,JEND
      DO 30 I=IBEG,IEND
         V=A(I,J)
         IF(V.EQ.BAD) GO TO 30
         SUM=SUM+V
         SUMSQ=SUMSQ+V*V
         CNT=CNT+1.0
   30 CONTINUE
      IF(CNT.LT.CNTMIN) RETURN
      ABAR=SUM/CNT
      ABAR2=SUMSQ/CNT
      ASIG=SQRT(ABAR2-ABAR*ABAR)
      IF(ASIG.LT.0.01) ASIG=0.01
      AMX=SDFAC*ASIG
      DO 60 J=JBEG,JEND
      DO 60 I=IBEG,IEND
         V=A(I,J)
         IF(V.EQ.BAD) GO TO 60
         IF(ABS(V-ABAR).GT.AMX) A(I,J)=BAD
   60 CONTINUE
      RETURN
      END
