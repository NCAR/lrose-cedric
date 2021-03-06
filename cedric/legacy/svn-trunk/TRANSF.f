      SUBROUTINE TRANSF(KRD,ITRHED,IBUF,RBUF,MAP,LPR,NST,ICORD)
C
C        COPIES,RENAMES AND DELETES SELECTED FIELDS
C
      INCLUDE 'CEDRIC.INC'      
      COMMON /VOLUME/ INPID(NID),ID(NID),NAMF(4,NFMAX),SCLFLD(NFMAX),
     X                IRCP(NFMAX),MAPVID(NFMAX,2),CSP(3,3),NCX(3),
     X                NCXORD(3),NFL,NPLANE,BAD
      CHARACTER*2 NAMF
C
      COMMON /IOTYPE/ ICDF
      COMMON /EDINFO/ IEDW(2,3),PEDW(2,3)
C
      COMMON /AXUNTS/ IUNAXS,LABAXS(3,3),SCLAXS(3,3),AXNAM(3)
      CHARACTER*4 AXNAM
      CHARACTER*2 NAM2(4)
      INTEGER MATCH,GRIDDED,NETCDF_OPEN
C
      COMMON /CDFNET/ ICDFID(MXCDF),IDIMDAT(4,MXCDF),IDIMID(1,MXCDF),
     X     IVAR(NFMAX+1,MXCDF),IFILE,ISYNFLG,ICDUNT(MXCDF),IUSWRP
      INTEGER RCODE
      DIMENSION IBUF(MAXPLN),RBUF(MAXPLN,2),ITRHED(NID),
     X          ILHD(10),MAP(MAXAXIS,3),XTRNS(3),LAX(3),
     X          NEWJ(NFMAX)
      CHARACTER*8 KRD(10),GFIELD(NFMAX)
      CHARACTER*1 CIBL,IOPTAB(4),NCMD,IYES,IREW,IDST,ISPAC,IWOP
      CHARACTER*2 NAME(4),IREQ,CHK,CTEMP4(4)
      CHARACTER*8 CTEMP,ITRAF(NFMAX),INVOL,IRUN,NAMINP
      LOGICAL NEWJ,IPARXY
      EQUIVALENCE (NCX(1),NX),(NCX(2),NY),(NCX(3),NZ)
      DATA IOPTAB/'T','R','D','W'/
      DATA LAX/'X','Y','Z'/
      DATA IREQ,IYES,IDST/'R=','Y','D'/
      DATA LASTLV/0/
      DATA CIBL/' '/

      
C
C        DETERMINE THE PROCESS TO BE INVOKED AND INITIALIZE
C
      print *,'TRANSF: icdf=',icdf
      READ (KRD,100)NCMD
  100 FORMAT(A1)
      IOPT=IFINDC(NCMD,IOPTAB,4,0)
      GO TO (10,50,60,10), IOPT
   10 CONTINUE
C
C        TRANSFER IN ADDITIONAL FIELDS
C
      IFILE=0
      IETIM=240000
      IF(IOPT.EQ.1) THEN
C
C        OLD TRANSFER COMMAND
C
      IWOP=CIBL
      READ (KRD,101)RUN,INVOL,RBTIM,RETIM,IREW,(ITRAF(I),I=1,4)
C  101 FORMAT(8X,F8.0,A8,2F8.0,A1,7X,4A8)
 101  FORMAT(/F8.0/A8/F8.0/F8.0/A1/A8/A8/A8/A8)
C
C        DECODE FIELD NAMES AND CHECK FOR UNIQUENESS
C

      NTRF=0
      DO 14 I=1,4
         IF(ITRAF(I).EQ.CIBL) GO TO 17
         NTRF=NTRF+1
   14 CONTINUE
   15 CONTINUE
      CALL KARDIN(KRD)
      DO 16 I=2,10
         IF(KRD(I).EQ.CIBL) GO TO 17
         NTRF=NTRF+1
         IF(NTRF.GT.NFMAX) THEN
            CALL CEDERX(505,1)
            RETURN
         END IF
  200    FORMAT(A8)
         ITRAF(NTRF)=KRD(I)
   16 CONTINUE
      GO TO 15
   17 CONTINUE
      ELSE IF(IOPT.EQ.4) THEN
C
C        WINDOWED TRANSFER FORMAT
C
         READ (KRD,111)IRUN,INVOL,RBTIM,RETIM,ISPAC,XTRNS,IWOP
C  111    FORMAT(8X,2A8,2F8.0,A1,7X,3F8.0,A1,7X)
 111     FORMAT(/A8/A8/F8.0/F8.0/A1/F8.0/F8.0/F8.0/A1)
         WRITE (CTEMP,200)IRUN
         READ (CTEMP,112)CHK
  112    FORMAT(A2)
         IF(CHK.EQ.IREQ) THEN
C
C           REWIND THE INPUT TAPE
C
            IREW=IYES
            WRITE (CTEMP,200)IRUN
            READ (CTEMP,114)RUN
  114       FORMAT(2X,F6.0)
         ELSE
C
C           NO INITIAL REWIND
C
            IREW=CIBL
            WRITE (CTEMP,200)IRUN
            READ (CTEMP,115)RUN
  115       FORMAT(F8.0)
         END IF
C
C        READ IN THE FIELD NAMES FOR TRANSFER
C
         NTRF=0
   11    CONTINUE
            CALL KARDIN(KRD)
            CALL COMCHK(LPR,KRD)
            IF(KRD(1).NE.'END') THEN
               DO 12 I=1,10
                  IF(KRD(I).EQ.CIBL) GO TO 12
                  NTRF=NTRF+1
                  IF(NTRF.GT.NFMAX) THEN
                     CALL CEDERX(505,1)
                     RETURN
                  END IF
                  ITRAF(NTRF)=KRD(I)
   12          CONTINUE
               GO TO 11
            END IF
         DO 13 I=1,3
            IF(ISPAC.EQ.IDST) THEN
C
C              DISTANCE SPACE TRANSLATION
C
               XTRNS(I)=XTRNS(I)/SCLAXS(I,IUNAXS)
            ELSE
C
C              INDEX SPACE TRANSLATION
C
               IF(CSP(3,I).LE.0.0) XTRNS(I)=0.0
               XTRNS(I)=XTRNS(I)*CSP(3,I)
            END IF
   13    CONTINUE
      END IF
      CALL WINSET(IEDW,PEDW,IWOP)
      IPARXY=(IEDW(1,1).NE.1.OR.IEDW(2,1).NE.NX.OR.
     X        IEDW(1,2).NE.1.OR.IEDW(2,2).NE.NY)
      LUN=RUN
      IF(LUN.LE.0) THEN
         CALL CEDERX(521,1)
         RETURN
      END IF
      IBTIM=RBTIM
      IF(RETIM.GT.0.0) IETIM=RETIM
      IF(INVOL.EQ.CIBL) INVOL='NEXT'
C
C        ACCESS VOLUME CONTAINING INPUT FIELDS
C

C SEE IF WE ARE TRANSFERING IN A USWRP NETCDF GRIDDED
CDATA SET.  IF WE HAVE A GRIDDED DATA SET THE ITRAF
CNAMES ARE TRANSFERED INTO GFIELD FOR USE IN 
CTHE NETCDF READING ROUTINES.

c      print *,'TRANSF: NTRF,GRIDDED,ITRAF=',NTRF,GRIDDED,ITRAF
      CALL CHKTNAME(NTRF,GRIDDED,ITRAF,GFIELD) 
      IF(GRIDDED .EQ. 1) THEN
         IUSWRP = 1
         NETCDF_OPEN = 1
         CALL svgdfldn(GFIELD(1),GFIELD(2))
      END IF
      DO I = 1,NID
         ITRHED(I) = 0
      END DO
      CALL SETVOL(LUN,INVOL,IBTIM,IETIM,LPR,LASTLV,IREW,ITRHED,
     X            ISTAT,GFIELD)

      IF (ISTAT.NE.0) RETURN
      WRITE(LPR,102)
  102 FORMAT(/' ALTERNATE INPUT TAPE VOLUME SUMMARY ...')
      CALL IMHSUM(LPR,ITRHED)
C
C     CHECK FOR INCOMPATIBLE COORDINATE SYSTEMS 
C
      MATCH = 0
      CALL CMPSCNTP(ID(16),ID(17),ITRHED(16),
     X                 ITRHED(17),MATCH)
      print *,'TRANSF - check #16 and 17: edit=',id(16),id(17)
      print *,'                           tran=',itrhed(16),itrhed(17)
      IF (ICORD.EQ.0 .AND. MATCH .EQ. 0) THEN
          PRINT *,"COORDINATE SYSTEMS DON'T MATCH IN TRANSF"
          CALL CEDERX(573,0)
      ENDIF 
      IF(IOPT.EQ.4) THEN
C
C        SUMMARY OF WINDOWED TRANSFER
C
         WRITE(LPR,116) (AXNAM(I),LABAXS(I,IUNAXS),I=1,3),XTRNS
  116    FORMAT(/3X,'INPUT STRUCTURE WILL BE TRANSLATED BY   (',
     X           A2,A4,',',A2,A4,',',A2,A4,')   (',F7.2,',',F7.2,
     X           ',',F7.2,')'/9X,'PRIOR TO TRANSFER.'//3X,
     X           'EXISTING EDIT FIELDS WILL BE MODIFIED ONLY AT ',
     X           'THOSE LOCATIONS WITHIN THE EDIT WINDOW.')
         SF=ITRHED(68)
         ITRHED(160)=ITRHED(160)+NINT(XTRNS(1)*SF)
         ITRHED(161)=ITRHED(161)+NINT(XTRNS(1)*SF)
         ITRHED(165)=ITRHED(165)+NINT(XTRNS(2)*SF)
         ITRHED(166)=ITRHED(166)+NINT(XTRNS(2)*SF)
         ITRHED(170)=ITRHED(170)+NINT(XTRNS(3)*1000.)
         ITRHED(171)=ITRHED(171)+NINT(XTRNS(3)*1000.)
         CALL SHOEDF(LPR)
      END IF

      CALL IDCMPR(ITRHED,ID,NID,IST)
      IF(IST.NE.0) THEN
         CALL CEDERX(512,1)
         RETURN
      END IF
C
C        CALCULATE INDICES SO THAT INPUT FILE INFO CAN BE TRANSFERRED
C           TO THE EDIT FILE SPATIAL STRUCTURE.
C
      CALL CRTMAP(ITRHED,NID,CSP,NCX,MAP,MAXAXIS,JST)
      IF(JST.EQ.2) THEN
         CALL CEDERX(512,1)
         RETURN
      END IF
C
C        DETERMINE THE EXISTENCE OF REQUESTED FIELDS
C
      IGOT=NTRF
      IF(IGOT.LE.0) GO TO 21
      NFLDS=ITRHED(175)
      DO 20 I=1,NTRF
         NEWJ(I)=.FALSE.
         WRITE (CTEMP,200)ITRAF(I)
         READ (CTEMP,103)NAME
  103    FORMAT(4A2)
         J=LOCFLDID(NAME,ITRHED(176),5,NFLDS,4)
         IF(J.EQ.0) GO TO 18
            JJ=IADFLD(NAME,ITRHED(175+J*5),LPR)
            IF (JJ.LT.0) RETURN
            NEWJ(I)=(JJ.NE.0)
            GO TO 20
   18    CONTINUE
         WRITE(LPR,104) ITRAF(I)
  104    FORMAT(5X,'+++  ',A8,' NOT PRESENT ON ALTERNATE INPUT VOLUME',
     X             '  +++')
         ITRAF(I)=CIBL
   19    CONTINUE
         IGOT=IGOT-1
   20 CONTINUE
   21 CONTINUE
      IF(IGOT.EQ.0) THEN
         WRITE(LPR,105)
  105    FORMAT(/5X,'+++  NO FIELDS TRANSFERRED  +++'/)
         GO TO 45
      END IF
C
C        PROCEED WITH THE TRANSFER
C
      NTX=ITRHED(162)
      NTY=ITRHED(167)
      NPLIN=ITRHED(301)
      DO 40 KOT=1,NZ
         KIN=MAP(KOT,3)
         DO 30 LF=1,NFLDS
            I1=171+(5*LF)
            I2=I1+3
            WRITE (CTEMP,103)(ITRHED(I),I=I1,I2)
            READ (CTEMP,200)NAMINP
            ICHK=IFINDC(NAMINP,ITRAF,NTRF,0)
            IF(ICHK.EQ.0) GO TO 30
 173        FORMAT(A2)
            WRITE(CTEMP4(1),173)ITRHED(I1)
            WRITE(CTEMP4(2),173)ITRHED(I1+1)
            WRITE(CTEMP4(3),173)ITRHED(I1+2)
            WRITE(CTEMP4(4),173)ITRHED(I1+3)
            JJ=LOCFLDID(CTEMP4,ID(176),5,NFL,4)
            IF( (KOT.LT.IEDW(1,3).OR.KOT.GT.IEDW(2,3)) .AND.
     X          (.NOT.NEWJ(ICHK)) ) GO TO 30
            IF(KIN.LE.0) GO TO 25
            IF(JST.NE.0) THEN
C
C              RESHUFFLE THE INFORMATION
C
 223           FORMAT(A2)
               WRITE(NAM2(1),223)ITRHED(I1)
               WRITE(NAM2(2),223)ITRHED(I1+1)
               WRITE(NAM2(3),223)ITRHED(I1+2)
               WRITE(NAM2(4),223)ITRHED(I1+3)
               CALL FETCHZ(LUN,IBUF,RBUF,NPLIN,LASTLV,LASTFD,KIN,ZLEV,
     X                     NAM2,BAD,ITRHED,ILHD)
               CALL RESHUF(RBUF,NX,NY,IBUF,NTX,NTY,MAP,MAXAXIS,BAD)
            ELSE
C
C              FETCH AND STORE
C
               WRITE(NAM2(1),223)ITRHED(I1)
               WRITE(NAM2(2),223)ITRHED(I1+1)
               WRITE(NAM2(3),223)ITRHED(I1+2)
               WRITE(NAM2(4),223)ITRHED(I1+3)
               CALL FETCHZ(LUN,RBUF,IBUF,NPLIN,LASTLV,LASTFD,KIN,ZLEV,
     X                     NAM2,BAD,ITRHED,ILHD)
            END IF
            IF((.NOT.NEWJ(ICHK)).AND.IPARXY) THEN
C
C              PARTIAL INTERSECTION IN (X,Y) OF TRANSFER AND EDIT FIELDS
C
               CALL FETCHD(LCM,ID,KOT,JJ,IBUF,RBUF(1,2),
     X                     NIX,NIY,3,BAD,RLEV,NST)
               L=0
               DO 24 J=1,NY
               DO 24 I=1,NX
                  L=L+1
                  IF(I.GE.IEDW(1,1).AND.I.LE.IEDW(2,1).AND.
     X               J.GE.IEDW(1,2).AND.J.LE.IEDW(2,2)) GO TO 24
                  RBUF(L,1)=RBUF(L,2)
   24          CONTINUE
            END IF
            GO TO 26
   25       CONTINUE
C
C              NO DATA FOR THIS LEVEL
C
               CALL CONFLD(RBUF,NPLANE,BAD)
   26       CONTINUE
            CALL PLACED(LCM,ID,KOT,JJ,IBUF,RBUF,NX,NY,3,BAD,NST)
   30    CONTINUE
   40 CONTINUE
   45 CONTINUE
C
C        POSITION INPUT TAPE PAST END OF VOLUME
C
      print *,'TRANSF-call skpvol: lun=',lun
      CALL SKPVOL(LUN,1)
      GO TO 90
   50 CONTINUE
      NETCDF_OPEN = 0
C
C        RENAME FIELDS
C
      DO 55 I=2,8,3
         IF(KRD(I).EQ.CIBL.OR.KRD(I+2).EQ.CIBL) GO TO 55
         READ (KRD(I),103)NAME
         JI=LOCFLDID(NAME,ID(176),5,NFL,4)
         IF(JI.EQ.0) THEN
            WRITE(LPR,106) KRD(I)
  106       FORMAT(5X,'+++  ',A8,' IS NOT A CURRENT EDIT FIELD  +++')
            GO TO 55
         END IF
         READ (KRD(I+2),103)NAME
         ICHK=LOCFLDID(NAME,ID(176),5,NFL,4)
         IF(ICHK.NE.0) THEN
            WRITE(LPR,107) KRD(I+2)
  107       FORMAT(5X,'+++  ',A8,' IS AN EXISTING EDIT FIELD NAME  +++')
            GO TO 55
         END IF
         WRITE(LPR,108) KRD(I),KRD(I+2)
  108    FORMAT(1X,A8,' WILL BE RENAMED ',A8)
         L=MAPVID(JI,2)
         CALL COPCX(NAMF(1,L),NAME,4)
         READ(NAME,127)ID(171+JI*5),ID(171+JI*5+1),ID(171+JI*5+2),
     X                 ID(171+JI*5+3)
 127     FORMAT(A2/A2/A2/A2)
C         CALL COPRX(ID(171+JI*5),NAME,4)
   55 CONTINUE
      GO TO 90
   60 CONTINUE
C
C        DELETE FIELDS
C
      DO 65 I=2,10
         IF(KRD(I).EQ.CIBL) GO TO 65
         READ (KRD(I),103)NAME
         JJ=ISUFLD(NAME,ISCL,LPR)
   65 CONTINUE
   90 CONTINUE
      NST=0
      CALL SHOEDF(LPR)
C
C     CLOSE NETCDF FILE
C
      IF (ICDF.EQ.2 .AND. NETCDF_OPEN .EQ. 1) THEN 
          CALL NETCLOS()
      END IF
  
      RETURN
      END
