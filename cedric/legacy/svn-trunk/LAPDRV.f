      SUBROUTINE LAPDRV (KRD,IBUF,OBUF,RBUF,IPR,NST)
C
C        LAPLACIAN SOLUTION DRIVER
C
      INCLUDE 'CEDRIC.INC'
C
      COMMON /AXUNTS/ IUNAXS,LABAXS(3,3),SCLAXS(3,3),AXNAM(3)
      CHARACTER*4 AXNAM
      COMMON /VOLUME/ INPID(NID),ID(NID),NAMF(4,NFMAX),SCLFLD(NFMAX),
     X                IRCP(NFMAX),MAPVID(NFMAX,2),CSP(3,3),NCX(3),
     X                NCXORD(3),NFL,NPLANE,BAD
      CHARACTER*2 NAMF,NAMINF(4,2),NAMOUF(4)
      CHARACTER*1 IFAX,IBL
      DIMENSION IBUF(MAXPLN),OBUF(MAXPLN),RBUF(MAXPLN,5),
     X          IFLD(2),PAR(2),PDEF(2),NAX(3),LAX(3)
C
      CHARACTER*(*) KRD(10)
      EQUIVALENCE (NCX(1),NX),(NCX(2),NY),(NCX(3),NZ)
      EQUIVALENCE (NAX(1),I1),(NAX(2),I2),(NAX(3),I3)
C
      LOGICAL NEWJ
C
      DATA IBL/' '/
      DATA LAX/'X','Y','Z'/
      DATA IDFSCL/100.0/
      DATA PDEF/ 0.0001, 1000.0 /

      IF(ID(162) .GT. 256) THEN
         PRINT *,"THE NUMBER OF GRID POINTS IN X IS",
     X           "IS TOO LARGE FOR LAPLACIAN.  ONLY 256",
     X            "POINTS ARE ALLOWED AT PRESENT."
         CALL FLUSH_STDOUT
      ENDIF

      IF(ID(167) .GT. 256) THEN
         PRINT *,"THE NUMBER OF GRID POINTS IN Y IS",
     X           "IS TOO LARGE FOR LAPLACIAN.  ONLY 256",
     X            "POINTS ARE ALLOWED AT PRESENT."
         CALL FLUSH_STDOUT
      ENDIF

C
C   INITIALIZATION:
C

      READ (KRD,100)NAMOUF,NAMINF,PAR,IFAX,USRSCL
C100   FORMAT(8X,12A2,2F8.0,16X,A1,7X,F8.0)
 100  FORMAT(/4A2/4A2/4A2/F8.0/F8.0///A1/F8.0)
C
      DO 10 I=1,2
         IFLD(I) = LOCFLDID(NAMINF(1,I),ID(176),5,NFL,4)
         IF (IFLD(I).EQ.0) THEN
            CALL CEDERX(501,1)
            RETURN
         END IF
10    CONTINUE
C
      IF (NAMOUF(1).EQ.IBL) THEN
         CALL CEDERX(520,1)
         RETURN
      END IF
      IUSCL=NINT(USRSCL)
      IF(IUSCL.LE.0) IUSCL=IDFSCL
      I = IADFLD(NAMOUF,IUSCL,IPR)
      IF (I.LT.0) RETURN
      IF (I.EQ.0) THEN
         NEWJ = .FALSE.
      ELSE
         NEWJ = .TRUE.
         IFLD(1) = LOCFLDID(NAMINF(1,1),ID(176),5,NFL,4)
         IFLD(2) = LOCFLDID(NAMINF(1,2),ID(176),5,NFL,4)
      END IF
      JFLD = LOCFLDID(NAMOUF,ID(176),5,NFL,4)
      ISCL = ID( 175 + 5*JFLD )
C
C     INPUT PARAMETERIZATION
C
      DO 15 I=1,2
         IF(PAR(I).LE.0.0) PAR(I)=PDEF(I)
   15 CONTINUE
      EPS=PAR(1)
      ITMX=IFIX(PAR(2))
C
      CALL SETAXS(NAX,IFAX,IPR)
      N1=NCX(I1)
      N2=NCX(I2)
      N3=NCX(I3)
      CALL SHOEDF(IPR)
      WRITE(IPR,101) NAMINF,NAMOUF,ISCL,EPS,ITMX
101   FORMAT(/3X,'LAPLACIAN SOLVER COMMAND- PARAMETERS ...'/
     X        8X,'1-      DF/DX INPUT FIELD: ',4A2/
     X        8X,'2-      DF/DY INPUT FIELD: ',4A2/
     X        8X,'3- DERIVED FUNCTION FIELD: ',4A2,' SCALED BY',I6/
     X        8X,'4-   RELATIVE ERROR (EPS):',E9.2/
     X        8X,'5- MAX. NO. OF ITERATIONS: ',I8/
     X        3X,'SOLUTION DERIVED FOR ALL LOCATIONS ',
     X           'WITHIN THE VOLUME.')
C
      DO 50 LEV = 1,N3
         RKM = CSP(1,I3) + (LEV-1) * CSP(3,I3)
C
C        FETCH INPUT FIELDS
C
         CALL FETCHD(IEDFL,ID,LEV,IFLD(1),IBUF,RBUF(1,1),
     X               NIX,NIY,I3,BAD,ZLEV,NST)
         CALL FETCHD(IEDFL,ID,LEV,IFLD(2),IBUF,RBUF(1,2),
     X               NIX,NIY,I3,BAD,ZLEV,NST)
         CALL LAPSOL(RBUF(1,1),RBUF(1,2),OBUF,RBUF(1,3),RBUF(1,4),
     X              RBUF(1,5),N1,N2,CSP(3,I1),CSP(3,I2),EPS,ITMX,
     X              BAD,ITER,TOL,KST)
         WRITE(IPR,102) AXNAM(I3),LEV,RKM,LABAXS(3,1),ITER,TOL
  102    FORMAT(5X,A1,' AT PLANE ',I3,5X,F7.2,' ',A4,8X,'ITER=',I4,
     X             5X,'REL. ERR=',F8.4)
         CALL PLACED(IEDFL,ID,LEV,JFLD,IBUF,OBUF,N1,N2,I3,
     X               BAD,NST)
50    CONTINUE
C
      NST = 0
      RETURN
      END