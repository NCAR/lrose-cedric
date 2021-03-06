      SUBROUTINE CHANGE(KRD,IBUF,RBUF,IPR,NST)
C
C        PERFORMS CHANGING OF DATA ON TWO CONSTANT Z-PLANE DATA
C
C          IBUF- SCRATCH BUFFER F0R I/O
C          OBUF- AUXILLIARY BUFFER FOR DATA MANIPULATION
C          RBUF- I/O DATA BUFFER
C        MAXPLN- MAXIMUM DIMENSION OF RBUF,OBUF
C           ITT- TERMINAL UNIT NUMBER
C           IPR- PRINT FILE UNIT NUMBER
C           NST- STATUS FLAG:  0- O.K.
C
      INCLUDE 'CEDRIC.INC'
      DIMENSION IBUF(MAXPLN),RBUF(MAXPLN),LAX(3),INDIC(3),DIST(3)
      CHARACTER*2 NAMINF(4)
      CHARACTER*(*) KRD(10)
      COMMON /VOLUME/ INPID(NID),ID(NID),NAMF(4,NFMAX),SCLFLD(NFMAX),
     X                IRCP(NFMAX),MAPVID(NFMAX,2),CSP(3,3),NCX(3),
     X                NCXORD(3),NFL,NPLANE,BAD
      CHARACTER*2 NAMF
      COMMON /AXUNTS/ IUNAXS,LABAXS(3,3),SCLAXS(3,3),AXNAM(3)
      CHARACTER*4 AXNAM
      LOGICAL ICHECK
      CHARACTER*1 ISPAC,IDST,ILL
      CHARACTER*3 IBADTS
      CHARACTER*8 CIVALUE
      EQUIVALENCE (NCX(1),NX), (NCX(2),NY)
      DATA LAX/'X','Y','Z'/
      DATA IDST,ILL,IBADTS/'D','L','BAD'/
C
C        INITIALIZATION OF CHANGING PARAMETERS
C
      READ (KRD,100)NAMINF,ISPAC,DIST,CIVALUE 
C  100 FORMAT(8X,4A2,A1,7X,3F8.0,A8)
 100  FORMAT(/4A2/A1/F8.0/F8.0/F8.0/A8)
      IFLD=LOCFLDID(NAMINF,ID(176),5,NFL,4)
      IF(IFLD.EQ.0) THEN
         CALL CEDERX(501,1)
         RETURN
      END IF
      VALUE=BAD
      IF(CIVALUE(1:3).NE.IBADTS) THEN
         READ (CIVALUE,101)VALUE
  101    FORMAT(F8.0)
      END IF
      ICHECK=.FALSE.
      IF(ISPAC.EQ.ILL) THEN
C
C     DIST(1) IS LONGITUDE IN DECIMAL DEGREES
C     DIST(2) IS LATITUDE  IN DECIMAL DEGREES (DIST(3) IS KMSL)
C     ASSUME THAT LAT OR LON =0 ARE INVALID
C
         IF(ID(33).EQ.ID(67).OR.ID(36).EQ.ID(67) .OR.
     X      ID(33).EQ. 0    .OR.ID(36).EQ. 0    ) THEN
            CALL CEDERX(569,0)
            GO TO 90
         END IF
C
C        CONVERT (LAT,LON) TO (X,Y)
C
         REFLAT=ABS(ID(33)+(ID(34)/60.)+(ID(35)/3600.))
         REFLON=ABS(ID(36)+(ID(37)/60.)+(ID(38)/3600.))
         XLON=DIST(1)
         XLAT=DIST(2)
         ANGXAX=ID(40)/REAL(ID(69))
         CALL LL2XYDRV(XLAT,XLON,DIST(1),DIST(2),REFLAT,REFLON,ANGXAX)
      END IF
      DO 3 I=1,3
      IF(CSP(3,I).LE.0.0) THEN
         INDIC(I)=1
      ELSE IF(ISPAC.EQ.IDST.OR.ISPAC.EQ.ILL) THEN
C
C        DISTANCE SPACE
C
         DKM=DIST(I)/SCLAXS(I,IUNAXS)
         INDIC(I)=(DKM-CSP(1,I))/CSP(3,I) + 1.5
      ELSE
C
C        INDEX SPACE
C
         INDIC(I)=DIST(I)
      END IF
      IF(INDIC(I).LE.0.OR.INDIC(I).GT.NCX(I)) THEN
         WRITE(IPR,102) AXNAM(I)
  102    FORMAT(8X,'+++  ',A1,'-AXIS LOCATION OUT OF RANGE  +++')
         ICHECK=.TRUE.
      END IF
      DIST(I)=CSP(1,I)+(INDIC(I)-1)*CSP(3,I)
      DIST(I)=DIST(I)*SCLAXS(I,IUNAXS)
    3 CONTINUE
      IF(ICHECK) THEN
         CALL CEDERX(502,0)
         GO TO 90
      END IF
C
C        BRING IN THE FIELD TO BE CHANGED, ALTER IT AND STORE.
C
      CALL FETCHD(IEDFL,ID,INDIC(3),IFLD,IBUF,RBUF,
     X            N1,N2,3,BAD,ZLEV,NST)
      INDIM=INDIC(1)+N1*(INDIC(2)-1)
      OLDVAL=RBUF(INDIM)
      RBUF(INDIM)=VALUE
      CALL PLACED(IEDFL,ID,INDIC(3),IFLD,IBUF,RBUF,
     X            NX,NY,3,BAD,NST)
C
C        GENERATE A SUMMARY
C
      WRITE(IPR,103) NAMINF,(AXNAM(I),LABAXS(I,IUNAXS),I=1,3),
     X               (INDIC(I),I=1,3),(DIST(I),I=1,3),OLDVAL,CIVALUE
  103 FORMAT(1X,4A2,' AT LOCATION:  (',A2,A4,',',A2,A4,',',A2,A4,')',
     X  '  (',I3,',',I3,',',I3,')  (',F7.2,',',F7.2,',',F7.2,')'/
     X  10X,'CHANGED FROM ',F9.3,' TO ',A8)
   90 CONTINUE
      NST=0
      RETURN
      END
