      SUBROUTINE FETCHZ(INUNIT,RBUF,ITEM,NPLANE,LASTLV,LASTFD,NLEV,ZLEV
     X     ,NAMFLD,BAD,IHED,ILHD)
C     
C     
C     FETCHZ- ACCESSES DESIGNATED FIELDS AT A REQUESTED LEVEL
C     
C     FORMAL PARAMETERS..........
C     INUNIT- LOGICAL UNIT NUMBER OF INPUT TAPE
C     RBUF- BUFFER TO BE FILLED WITH DATA FROM DESIGNATED FIELDS
C     ITEM-TEMPORARY STORAGE
C     NPLANE- NUMBER OF DATA POINTS PER PLANE (EACH FIELD)
C     LASTLV- LAST LEVEL NUMBER ACCESSED IN CURRENT VOLUME
C     LASTFD- LAST FIELD NUMBER ACCESSED IN MOST RECENT LEVEL
C     NLEV- REQUESTED LEVEL NUMBER
C     ZLEV- HEIGHT (KM) OF REQUESTED LEVEL  (RETURNED)
C     NAMFLD- NAME OF DATA FIELD TO RETURN
C     BAD- SET UNUSABLE DATA TO BAD FOR PROCESSING
C     IHED-510 WORD CARTESIAN HEADER
C     ILHD-10 WORD LEVEL HEADER
C     
C     
      DIMENSION RBUF(NPLANE),ITEM(NPLANE),IHED(510),ILHD(10)
      CHARACTER*2 NAMFLD(4)
      INTEGER CVMGP
      DATA IZIPAK /32768/
      ICDF=1

C     
C     LOCATE POSITION OF REQUESTED FIELD
C     
      NUMFLD=LOCFLDID(NAMFLD,IHED(176),5,IHED(175),4)
      IF(NUMFLD.LE.0)GO TO 204
      
C     
C     CALCULATE HEIGHT (KM) OF REQUESTED LEVEL
C     
      ZLEV=(IHED(170) + (NLEV-1)*IHED(173)) * 0.001
C     
C     POSITION TAPE TO CORRECT LEVEL AND FIELD
C     
      NSKIP=0
      IF (NLEV.EQ.LASTLV) GOTO 20
      IF (LASTLV.EQ.0) LASTFD=IHED(175)
      NSKIP=(IHED(175)-LASTFD)*NPLANE*2
      IF (NSKIP.GT.0) CALL CSKPREC(INUNIT,NSKIP)
      LASTLV=LASTLV+1
      LASTFD=0
C
C     THE 20 IN THE FOLLOWING STATEMENT IS TO SKIP OVER LEVEL HEADERS 
C
      NSKIP=(NLEV-LASTLV)*(IHED(175)*NPLANE*2 + 20)
      IF (NSKIP.NE.0)  CALL CSKPREC(INUNIT,NSKIP)
      CALL PLANST(INUNIT,NLEV,ILHD,NST,ICDF)
      IF (NST.NE.0) GOTO 203
 20   CONTINUE
      NSKIP = (NUMFLD-LASTFD-1)*NPLANE*2
      SCALE=1.0/IHED(180+(NUMFLD-1)*5)
c      IF (NSKIP.GT.0)
c     X     WRITE(*,*)'***NLEV,LASTLV,NUMFLD,NSKIP,SCALE,IHED(175),
c     X     NPLANE,LASTFD=',NLEV,LASTLV,NUMFLD,NSKIP,SCALE,IHED(175),
c     X     NPLANE,LASTFD
      IF (NSKIP.NE.0) CALL CSKPREC(INUNIT,NSKIP)
      CALL CFETCHZ(INUNIT,RBUF,NPLANE,ITEM,BAD,SCALE,NST,NSKIP)
      CALL GBYTES(RBUF,ITEM,0,16,0,NPLANE)
      DO 15 I=1,NPLANE
         RBUF(I)=BAD
         IF (ITEM(I).EQ.IZIPAK) GOTO 15
         IX=ITEM(I)
         ITEM(I)=CVMGP(IX-65536,IX,IX-32768)
         RBUF(I)=ITEM(I)*SCALE
 15   CONTINUE
      LASTFD = NUMFLD
      LASTLV = NLEV
      RETURN
C     
C     ERROR EXITS
C     
 203  CONTINUE
      CALL TAPMES(INUNIT,NST)
      PRINT 403, NLEV,ZLEV
 403  FORMAT(///5X,'FETCHZ.....'/15X,'UNABLE TO LOCATE DATA AT LEVEL: ',
     X     I2,5X,'HEIGHT: ',F5.1,' KM'/////)
      CALL CEDERX(544,1)
 204  CONTINUE
      CALL TAPMES(INUNIT,NST)
      PRINT 404, NAMFLD,NLEV,ZLEV
 404  FORMAT(///5X,'FETCHZ.....'/15X,'UNABLE TO LOCATE FIELD :   ',A10,
     X     10X,'LEVEL: ',I2,5X,'HEIGHT: ',F5.1,' KM'/////)
      CALL CEDERX(545,1)
      END