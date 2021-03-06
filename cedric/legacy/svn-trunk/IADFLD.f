      FUNCTION IADFLD(NAM2,ISCL,IPR)
C
C        ADDS A NEW FIELD TO THE HOUSEKEEPING
C           IF IP=0 THEN A SEARCH IS PERFORMED TO ENSURE THAT FIELD NAME
C                   DOES NOT ALREADY EXIST.
C           IF IADFLD > 0, IT CONTAINS THE POSITION IN THE TABLE STRUCTURE
C                          AND A FIELD IS ADDED
C                     = 0, EXISTING FIELD
C
      INCLUDE 'CEDRIC.INC'
      COMMON /VOLUME/ INPID(NID),ID(NID),NAMF(4,NFMAX),SCLFLD(NFMAX),
     X                IRCP(NFMAX),MAPVID(NFMAX,2),CSP(3,3),NCX(3),
     X                NCXORD(3),NFL,NPLANE,BAD
      CHARACTER*2 NAMF,IBL
      CHARACTER*2 NAM2(4)
      EQUIVALENCE (ID(453),MAXFLD)
      DATA IBL/'  '/
      IF(NAM2(1).EQ.IBL) THEN
         CALL CEDERX(520,1)
         IADFLD=-1
         RETURN
      END IF
      IF ((NFL+1).GT.NFMAX) THEN
         CALL CEDERX(505,1)
         IADFLD=-1
         RETURN
      END IF
      JP=LOCFLD(NAM2,NAMF,4,NFMAX,4)
         IF(JP.NE.0) THEN
            WRITE(IPR,101) NAM2
  101       FORMAT(5X,4A2,' IS AN EXISTING EDIT FIELD AND',
     X             ' WILL BE ALTERED.')
            GO TO 90
         END IF
      JP=LOCFLD(IBL,NAMF,4,NFMAX,1)
      IF(JP.EQ.0) CALL CEDERX(505,1)
      WRITE(IPR,102) NAM2,ISCL
  102 FORMAT(5X,4A2,' WILL BE CREATED AND SAVED AS A PERMANENT',
     X              ' EDIT FIELD SCALED BY ',I5)
      CALL COPCX(NAMF(1,JP),NAM2,4)
      SCLFLD(JP)=ISCL
C
C        INITIALIZE DISPLAY FEATURES AND UPDATE THE FILE HEADERS
C
      CALL DSINIT(JP)
      CALL UPDHED(0)
      IF(NFL.GT.MAXFLD) CALL CEDERX(505,1)
      IADFLD=JP
      RETURN
   90 CONTINUE
      IADFLD=0
      RETURN
      END
