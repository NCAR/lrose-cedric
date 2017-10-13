      SUBROUTINE RAYIN(NWCT,MBYTE,NST,SWAPPING)
C     
C     READ ONE RAY (UP TO 4 RECORDS) OF PACKED 16 BIT INFORMATION
C     INTO NBUF AND UNPACK INFORMATION INTO IBUF ON SUCCESSIVE CALLS
C     Note: The 1024 here in CALL GBYTES refers to number of gates
C           for the FOF RP3-7 processors. Leave it hard-wired. See
C           other GBYTES calls with specific numbers. (LJM)
C     
      INCLUDE 'SPRINT.INC'
c      PARAMETER (IDIM=64/WORDSZ)
c      PARAMETER (NIOB=85000,MAXIN=8500,MAXLEN=MAXIN/4)

c      PARAMETER (MAXSKP=27)

      COMMON /SETAZM/ USAZ1,USAZ2,USGAP,USINC,IFOR36,IFORDR
      COMMON /AZSUB/ AT1,AT2,IFLAG,IFLADJ

      COMMON /CINP/IUN,ISKP,ORLAT,ORLON
      COMMON /CINPC/ NMRAD,ITAP,TAPE_UNIT
      CHARACTER*4 NMRAD
      CHARACTER*8 ITAP
      CHARACTER*8 TAPE_UNIT

      COMMON /IO/KPCK(NIOB),KOUT(MAXIN),IBUF(MAXIN),NTBUF(MAXLEN,4),
     X     IZ8(17),ILSTREC
      COMMON /FXTABL/ IFXTAB,ISKIP,IACCPT,FTABLE(MAXSKP),ITRAN

      COMMON /CPRO/KDAY,KBTIM,KETIM,IROV,ISWMTH,FXSTOL
      COMMON /CPROC/ IREORD(3)
      CHARACTER*1 IREORD

      COMMON /FORMAT/ IRP,IBLOCK
      DIMENSION NBIT(16),NBUF(IDIM,MAXLEN,4)
      DATA MODE,NTYPE,IBITS,NBITS,IBEG,RP7SCL,IREC
     X     /1,2,0,16,0,182.044444,0/
      DATA IEOF,FXSAV,NOREC/0,0.0,0/
      DATA IUNKP,ITOO/-1,0/
      DATA PXMIT/55.0/
      SAVE INREC,INSTAT
C     
C     ENTRY  NWRAY
C     
      ENTRY NWRAY(NWCT,MBYTE,NST,SWAPPING)
      NWDCNT = MAXIN

      NST=0
      print *,'RAYIN-NWRAY: irp,ibeg,iun=',irp,ibeg,iun
      print *,'RAYIN-NWRAY: nwct,mbyte,nst,swapping=',
     +     nwct,mbyte,nst,swapping
      IF (IUN.NE.IUNKP) THEN
C
C     NEED TO FLUSH INPUT BUFFER IF A NEW UNIT IS BEING ACCESSED
C
         IBEG=0
         IUNKP=IUN
      END IF
 5    IF (IRP.EQ.1 .AND. IBEG.NE.0) GOTO 100
 10   CONTINUE

      print *,'RAYIN-NWRAY blocking (1)SUN, 0(COS): iblock=',iblock
      IF (IBLOCK.EQ.1) THEN
C
C     SUN FORTRAN BLOCKING
C
         CALL RDSUNREC(NBUF,NWDS,SWAPPING)
         print *,'RAYIN: after rdsunrec, nwds,swapping=',nwds,swapping
c         print *,'RAYIN: after rdsunrec, nbuf=',nbuf
         nwds=3719
         print *,'RAYIN: after rdsunrec, nwds,swapping=',nwds,swapping
         IF (NWDS.GT.0) NWDS=INT((NWDS-1)/8) + 1
         IF (NWDS.GT.MAXIN) THEN
           WRITE(*,12)NWDS
 12        FORMAT(/,'+++NWDS=',I6,' IS TOO BIG IN RAYIN+++'/)
           STOP
         END IF
      ELSE IF (IBLOCK.EQ.0) THEN
C
C     COS BLOCKING
C
         CALL RDCOSREC(NBUF,NWDS)
         IF (NWDS.GT.MAXIN) THEN
           WRITE(*,12)NWDS
           STOP
         END IF
      END IF
      IF (NWDS.LE.0) THEN
         IREC=0
         IEOF=IEOF+1
         NST=1
c
c********Change .GE. to .GT. to fix Brodzik's problem with two EOF's in a
c********row between 1.5 deg and rest of volume scan that should have been 
c********appended.  ljm (9/20/1999)
c
         IF (IEOF.GT.2) THEN
            IEOF=0
            NST=3
         END IF
         RETURN
      END IF
 100  CONTINUE
      IEOF=0
C     
C     READ OTHER RECORDS IF NEEDED
C     
      INSTAT=NST
C     
C     UNIVERSAL FORMAT
C     
      IF (IRP.EQ.0) THEN
C
C     SWAP BYTES FOR LITTLE ENDIAN MACHINES
C
C     SCALE FOR THE FIXED ANGLE IN UF
         SCLFX=1/64.
         IF (MBYTE.EQ.1) THEN
            IF (WORDSZ.EQ.32) THEN
               CALL SWAP32(NBUF,NWDS*2)
            ELSE
               CALL SWAP64(NBUF,NWDS)
            END IF
         END IF
         CALL GBYTES(NBUF,NWCT,NBITS,NBITS,0,1)
         CALL GBYTES(NBUF,IBUF,IBITS,NBITS,IBITS,NWCT)

c--------debugging routine to print UF beam housekeeping (ljm)
c        CALL UFREC(IBUF,NWCT)
c--------debugging (ljm)
C
C     SEE IF BEAM SHOULD BE DISCARDED BECAUSE OF AZIMUTH SUBSECTIONING
C
         IF (IFLAG.EQ.1) THEN
            BMAZIM=FLOAT(IBUF(33))/64.
            IF (IFLADJ.EQ.1 .AND. BMAZIM.LT.USAZ2) BMAZIM=BMAZIM+360.0
            IF (BMAZIM.LT.AT1 .OR. BMAZIM.GT.AT2)  GOTO 5
         END IF

C
C     GET CHARS IN CORRECT FORMAT 
C
         CALL UFCHARS(IBUF,MAXIN,MBYTE)
C     
C     MOD HERE TO HANDLE UF CREATION ERROR WHERE NOREC WAS INCORRECT ON TAPE
C     
         NOREC=1
         INREC=1
C
C     SEE IF VOLUME HAS CHANGED; SOME OF THE TESTING IS NECESSARY FOR
C     RHI SCANS WHERE THE FIXED ANGLE CAN BE BETWEEN 0 AND 360 AND MAY
C     EVEN CROSS 0/360. THERE IS THE ASSUMPTION THAT AZIM. ANGLES PROGRESS
C     IN A COUNTER CLOCKWISE FASHION.
C
         IF (ISWMTH.EQ.1) THEN
            IF ((((FXSAV - IBUF(36)*SCLFX).GT.FXSTOL .AND. 
     X           (FXSAV - IBUF(36)*SCLFX).LT. 180.0) .OR. 
     X           ((IBUF(36)*SCLFX - FXSAV).GT.180.0) .OR. 
     X           IBUF(35).NE.MODES) .AND. IREC.NE.0) THEN
               FXSAV=IBUF(36)*SCLFX
               MODES=IBUF(35)
               NST=1
               IREC=0
               RETURN
            ELSE
               FXSAV=IBUF(36)*SCLFX
               MODES=IBUF(35)
               IREC=1
            END IF
         END IF
         IF (NOREC.EQ.1) GOTO 250
         DO 125 I=2,NOREC
            IM1=I-1
c            CALL RDTAPE(IUN,MODE,NTYPE,NBUF(1,1,I),NWDCNT)
c            CALL IOWAIT(IUN,NST,IWDS)
c            GOTO (125,150,50,150)NST+1
 125     CONTINUE
c         GOTO 200
c 150     CONTINUE
c         NOREC=IM1
c         INSTAT=NST
C     
C     UNPACK RECORDS OF RAY
C     
 200     CONTINUE
         IF (INREC.GT.NOREC) THEN
            IF (INSTAT.EQ.0) THEN
               IBUF(9)=0
               RETURN
            ELSE
               NST=INSTAT
               RETURN
            ENDIF
         ENDIF
C     
         CALL GBYTES(NBUF(1,1,INREC),NWCT,NBITS,NBITS,0,1)
         CALL GBYTES(NBUF(1,1,INREC),IBUF,IBITS,NBITS,IBITS,NWCT)
C
C     SEE IF BEAM SHOULD BE DISCARDED BECAUSE OF AZIMUTH SUBSECTIONING
C
         IF (IFLAG.EQ.1) THEN
            BMAZIM=FLOAT(IBUF(33))/64.
            IF (IFLADJ.EQ.1 .AND. BMAZIM.LT.USAZ2) BMAZIM=BMAZIM+360.0
            IF (BMAZIM.LT.AT1 .OR. BMAZIM.GT.AT2) THEN
               INREC=INREC+1
               GOTO 400
            END IF
         END IF
         
         GOTO 250
C     
C     RP3 - RP7 FIELD FORMAT
C     
      ELSE IF (IRP.EQ.1) THEN
C     SCALE FOR THE FIXED ANGLE IN FIELD FORMAT
         SCLFX=1/182.044444
         IF (IBEG.EQ.-1) IBEG=0
         INREC=1
         ITOT=0
         IF (MBYTE.EQ.1 .AND. IBEG.EQ.0) THEN
C
C     LITTLE ENDIAN; SWAP THE BYTES
C
            IF (WORDSZ.EQ.32) THEN
               CALL SWAP32(NBUF,NWDS*2)
            ELSE
               CALL SWAP64(NBUF,NWDS)
            END IF
         END IF
         CALL GBYTES(NBUF,NWCT,(1024+IBEG),16,0,1)
         CALL GBYTES(NBUF,IBUF,IBEG,16,0,NWCT)
         CALL GBYTES(NBUF,NBIT,(1096+IBEG),8,8,6)
         IF (IBUF(68).GT.6) THEN
C
C     READ IN REST OF PARAMETER DESCRIPTORS FROM SECOND PART OF HOUSEKEEPING
C
            CALL GBYTES(NBUF,NBIT(7),(2568+IBEG),8,8,(IBUF(68)-6))
         END IF
         DO 500 I=1,IBUF(68)
            ITOT=NBIT(I)+ITOT
 500     CONTINUE


         I=0
         IOFF=0
         NRG=IBUF(15)
         NCNT=NRG*IBUF(68)
         IF ((NCNT+(NWCT+1)).GT.MAXIN) THEN

C     ERROR, LOGICAL RECORD IS TOO BIG

            WRITE(*,507)
 507        FORMAT(//,'+++ERROR IN RAYIN: LOGICAL RECORD OF INPUT ',
     X               'FIELD FORMAT DATA TOO BIG.+++')
            WRITE(*,508)NWCT,NRG,IBUF(68),IBEG,NWDS
 508        FORMAT('NWCT=',I12,' NRG=',I12,' IBUF(68)=',I12,
     X             ' IBEG=',I12,' NWDS=',I12)
            STOP
         END IF
C
C     CHECK FOR LARGER HOUSEKEEPING FORMAT
C
         IF (IBUF(65).GT.256) THEN
            WRITE(*,523)
 523        FORMAT(/'+++SPRINT DOES NOT RECOGNIZE THIS INPUT DATA',
     X              ' FORMAT+++')
            STOP
         END IF
         DO 510 IFLD=1,IBUF(68)
            CALL GBYTES(NBUF,IBUF((NWCT+1)+I),(IOFF+IBEG+(NWCT*16)),
     X           NBIT(IFLD),(ITOT-NBIT(IFLD)),NRG)
            IOFF=IOFF+NBIT(IFLD)
            I=I+NRG
 510     CONTINUE
         NLRPR=ICEDAND(ICEDSHFT(IBUF(67),-8),255)
         NLR=ICEDAND(IBUF(67),255)
C
C     CHECK FOR CONSISTENCY BETWEEN HOUSEKEEPING VARS. AND WORDS READ IN
C
         IF ((IBUF(66)*NLRPR) .GT. NWDS*4) THEN
            NLRPR=MIN0(NWDS*4/IBUF(66),NLRPR)
            WRITE(*,600)
 600        FORMAT(/,5X,'+++NUMBER OF LOG. REC./PHY. REC. NOT CORRECT.',
     X             ' ERROR HAS BEEN CORRECTED+++')
            ITOO=ITOO+1
            IF (ITOO.GE.10) THEN
               WRITE(*,610)
 610           FORMAT(/,5X,'+++TOO MANY RECORD ERRORS+++')
               STOP
            END IF
         END IF
C     
C     CHECK TO SEE IF THIS RECORD CONTAINS MORE THAN ONE BEAM OF DATA
C     
         IF (NLR.NE.NLRPR) THEN
            IBEG=IBEG+(IBUF(66)*16)
         ELSE
            IBEG=0
         END IF
         
         IF ((NLRPR*IBUF(66))/4..GT.MAXIN) THEN
C
C     ERROR, PHYSICAL RECORD IS TOO BIG
C
            WRITE(*,607)
 607        FORMAT(//,'+++ERROR IN RAYIN: PHYSICAL RECORD OF INPUT ',
     X               'FIELD FORMAT DATA TOO BIG.+++')
            WRITE(*,608)NWCT,IBEG,NCNT,NLRPR
 608        FORMAT('NWCT,IBEG,NCNT,NLRPR=',4I6)
            STOP
         END IF
C
C     IF CP-2 WITH RP-6 PROCESSOR, CHECK THAT AVG. POWER IS HIGH ENOUGH.
C     NEEDED FOR SCUM EXPERIMENT (SCMS).
C
         IDRADR=IBUF(63)
         IDPROC=IBUF(62)
         IF (IDRADR.EQ.2 .AND. IDPROC.EQ.6) THEN
            PAVG=FLOAT(IBUF(18))/10.
C           MAKE IT A TRANSITION BEAM, IF NEEDED
            IF (PAVG.LT.PXMIT) IBUF(61)=1
         END IF

C
C     SEE IF USER WANTS BEAM DISCARDED BECAUSE IT IS FLAGGED AS A
C     'TRANSITION' BEAM
C
         IF (ITRAN.EQ.2 .AND. IBUF(61).EQ.1) GOTO 5
C
C     SEE IF BEAM SHOULD BE DISCARDED BECAUSE OF AZIMUTH SUBSECTIONING
C
         IF (IFLAG.EQ.1) THEN
            BMAZIM=FLOAT(IBUF(10))/RP7SCL
            IF (IFLADJ.EQ.1 .AND. BMAZIM.LT.USAZ2) BMAZIM=BMAZIM+360.0
            IF (BMAZIM.LT.AT1 .OR. BMAZIM.GT.AT2) GOTO 5
         END IF
C
C     SEE IF VOLUME HAS CHANGED; SOME OF THE TESTING IS NECESSARY FOR
C     RHI SCANS WHERE THE FIXED ANGLE CAN BE BETWEEN 0 AND 360 AND MAY
C     EVEN CROSS 0/360. THERE IS THE ASSUMPTION THAT AZIM. ANGLES PROGRESS
C     IN A COUNTER CLOCKWISE FASHION.
C
         IF ((((FXSAV - IBUF(31)*SCLFX).GT.FXSTOL .AND. 
     X        (FXSAV - IBUF(31)*SCLFX).LT. 180.0) .OR. 
     X        ((IBUF(31)*SCLFX - FXSAV).GT.180.0) .OR. 
     X        IBUF(26).NE.MODES) .AND. IREC.NE.0) THEN
            FXSAV=IBUF(31)*SCLFX
            MODES=IBUF(26)
            NST=1
            IREC=0
            RETURN
         ELSE
            FXSAV=IBUF(31)*SCLFX
            MODES=IBUF(26)
            IREC=1
         END IF
      END IF

      GOTO 250
C     
C     ENTRY RDRAY
C     
      ENTRY RDRAY(NWCT,NST)
C     
C     UNPACK RECORDS OF RAY
C     
 400  CONTINUE
      IF (INREC.GT.NOREC) THEN
         IF (INSTAT.EQ.0) THEN
            IBUF(9)=0
            RETURN
         ELSE
            NST=INSTAT
            RETURN
         ENDIF
      ENDIF
C     
      CALL GBYTES(NBUF(1,1,INREC),NWCT,NBITS,NBITS,0,1)
      CALL GBYTES(NBUF(1,1,INREC),IBUF,IBITS,NBITS,IBITS,NWCT)
C
C     SEE IF BEAM SHOULD BE DISCARDED BECAUSE OF AZIMUTH SUBSECTIONING
C
         IF (IFLAG.EQ.1) THEN
            BMAZIM=FLOAT(IBUF(33))/64.
            IF (IFLADJ.EQ.1 .AND. BMAZIM.LT.USAZ2) BMAZIM=BMAZIM+360.0
            IF (BMAZIM.LT.AT1 .OR. BMAZIM.GT.AT2) THEN
               INREC=INREC+1
               GOTO 400
            END IF
         END IF
 250  CONTINUE
      INREC=INREC+1
      NST=0
      RETURN
      END