c
c----------------------------------------------------------------------X
c
      SUBROUTINE IFNOBAD(DAT,IOUT,IIN1,IIN2,C1,C2,BDVAL,MNGATE,MXGATE,
     X                   NANG,MXR,MXA,MXF)
C
C  FUNCTION - IFNOBAD: F(OUT)=F(IIN1); ONLY IF F(IIN2) .NE. BDVAL
C
C     IOUT   - OUTPUT FIELD NUMBER
C     IIN1   -  INPUT   "      "
C     IIN2   -    "     "      "  (TESTING ON THIS FIELD)
C     DATIN1 - TEMPORARY VARIABLE TO ALLOW IOUT=IIN1
C     DATIN2 - TEMPORARY VARIABLE TO ALLOW IOUT=IIN2
C
      DIMENSION DAT(MXR,MXA,MXF)

c      DO 100 J=1,NANG
c         DO 90 I=MNGATE,MXGATE
      DO 100 J=1,MXA
         DO 90 I=1,MXR
            DATIN1=DAT(I,J,IIN1)
            DATIN2=DAT(I,J,IIN2)
            DAT(I,J,IOUT)=BDVAL
            IF(DATIN2.NE.BDVAL)DAT(I,J,IOUT)=DATIN1
   90    CONTINUE
  100 CONTINUE
      RETURN
      END
