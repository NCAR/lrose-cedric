      FUNCTION ISUFLD(NAM2,ISCL,IPR)
C
C        DELETES A FIELD FROM THE EDIT FILE, ISCL IS RETURNED
C           IF IP= 0, A SEARCH FOR THE FIELD IS PERFORMED
C                > 0, NAM2 IS RETURNED.
C           IF ISUFLD > 0, FIELD WAS SUCCESSFULLY DELETED
C                     = 0, NO-OP.
C
      INCLUDE 'CEDRIC.INC'
      COMMON /VOLUME/ INPID(NID),ID(NID),NAMF(4,NFMAX),SCLFLD(NFMAX),
     X                IRCP(NFMAX),MAPVID(NFMAX,2),CSP(3,3),NCX(3),
     X                NCXORD(3),NFL,NPLANE,BAD
      CHARACTER*2 NAMF, NAM2(4)
      CHARACTER*1 IBL
      DATA IBL/' '/
         JP=LOCFLD(NAM2,NAMF,4,NFMAX,4)
         IF(JP.EQ.0) THEN
            WRITE(IPR,101) (NAM2(I), I=1,4)
  101       FORMAT(1X,4A2,' FIELD DOES NOT EXIST    ',
     X                    '... NO DELETION PERFORMED.')
            ISUFLD=0
            RETURN
         END IF
C
C        DELETE FIELD NAME FROM TABLE AND REINITIALIZE DISPLAY FEATURES
C
      WRITE(IPR,102) NAM2
  102 FORMAT(1X,4A2,' FIELD HAS BEEN DELETED FROM THE EDIT FILE.')
      DO 10 I=1,4
      NAMF(I,JP)=IBL
   10 CONTINUE
      ISCL=SCLFLD(JP)
      SCLFLD(JP)=0.0
      CALL DSINIT(JP)
      CALL UPDHED(0)
      ISUFLD=JP
      RETURN
      END
