      SUBROUTINE SHOEDW(IDEV)
C
C     DISPLAYS CURRENT WINDOW INFORMATION
C
      COMMON /EDINFO/ IEDW(2,3),PEDW(2,3)
      COMMON /AXUNTS/ IUNAXS,LABAXS(3,3),SCLAXS(3,3),AXNAM(3)
      CHARACTER*4 AXNAM
      WRITE(IDEV,101)
  101 FORMAT(' EDITING WINDOW LOOKS LIKE THIS:'/18X,'INDICES',19X,
     X       'DISTANCES'/' AXIS  POSN.    MIN     MAX',
     X       10X,'MIN       MAX    UNITS')
      DO 3 I=1,3
         PL1=PEDW(1,I)*SCLAXS(I,IUNAXS)
         PL2=PEDW(2,I)*SCLAXS(I,IUNAXS)
         WRITE(IDEV,102) AXNAM(I),I,IEDW(1,I),IEDW(2,I),
     X                   PL1,PL2,LABAXS(I,IUNAXS)
  102    FORMAT(3X,A1,4X,I2,6X,I3,5X,I3,7X,F7.2,3X,F7.2,4X,A4)
    3 CONTINUE
      RETURN
      END
