      SUBROUTINE HSTLBL(KJ,RLEV,FAVG,FSTD,NP,M1,M2,M3,M4,FMN,FMX,
     X     L3,ITYP,NBINS,MED)
C     
C     THIS SUBROUTINE DOES THE LABELLING FOR THE HISTOGRAM PLOTS
C     
      
      INCLUDE 'CEDRIC.INC' 
      PARAMETER (MAXBIN=1003)
      CHARACTER*8 OOPT,OOPTA,NOWDAT,ICOL,IMED
      COMMON /VOLUME/ INPID(NID),ID(NID),NAMF(4,NFMAX),SCLFLD(NFMAX),
     X     IRCP(NFMAX),MAPVID(NFMAX,2),CSP(3,3),NCX(3),
     X     NCXORD(3),NFL,NPLANE,BAD
      CHARACTER*2 NAMF
      COMMON /DSPECS/ IWIND(2,3),PWIND(2,3),NCWORD(3),IFLDW(NFMAX),
     X     SCLFAC(NFMAX),NSYMCD(2,NFMAX),WIDCD(NFMAX),
     X     ZREFCD(NFMAX),THKLIN(NFMAX)
      COMMON /HSTBUF/ IBINS(MAXBIN),KBINS(MAXBIN)
      COMMON /HSTOPT/ IMED,ICOL,TPER,OOPT,IMEDA(NFMAX),ICOLA(NFMAX),
     X     TPERA(NFMAX),OOPTA(NFMAX),FDORD(NFMAX),ICUR,SYMCD(2,NFMAX)
      COMMON /AXUNTS/ IUNAXS,LABAXS(3,3),SCLAXS(3,3),AXNAM(3)
      CHARACTER*4 AXNAM
      DIMENSION ICOLMAP(9),IAXIS(3)
      REAL MED
      DATA ICOLMAP /1,61,5,8,25,38,32,2,60/
      DATA IAXIS /'X','Y','Z'/
      CHARACTER*8 FNAM1,FNAM2,COL1,COL2,NCOLORS(9)
      CHARACTER*80 LABEL
      DATA NCOLORS / 'WHITE', 'GREY', 'PURPLE', 'BLUE', 'GREEN', 
     X     'YELLOW','BROWN','MAGENTA','RED' /
      
C     
C     DECODE THE FIELD NAMES, BAR COLORS AND SCALE FACTORS
C     
      
      
      CALL GSCLIP(0)

C     Test CALL PLCHMQ with CPUX vs. CFUX

      LABEL = 'THIS IS A TEST OF (CPUX,CPUY) vs. (CFUX,CFUY)'
      RCPUX = CPUX(60)
      RCPUY = CPUY(1010)
      RCFUX = CFUX(60./1023.)
      RCFUY = CFUY(1010./1023.)
      print *,'HSTLBL: LABEL=',label
      print *,'HSTLBL: rcpux, rcpuy=',rcpux,rcpuy
      print *,'HSTLBL: rcfux, rcfuy=',rcfux,rcfuy
      CALL PLCHMQ(CPUX(60),CPUY(1010),LABEL,12.,0.,-1.)
      CALL PLCHMQ(CFUX(60./1023.),CFUY(990./1023.),LABEL,12.,0.,-1.)


C     
C     FOR CURRENT FIELD
C     
      JJ=KJ
      IJ=FDORD(JJ)
      IV=MAPVID(IJ,2)
      WRITE(FNAM1,20)(NAMF(I,IV),I=1,4)
 20   FORMAT(4A2)
      
      SCL1=SCLFAC(IV)
      OOPT=OOPTA(IV)
      
      IRES=0
      ICOL1=ICOLA(IV)
      IF (ICOL1.GT.0) IRES=LOCINT(ICOL1,ICOLMAP,1,9,1)
      IF (IRES.GT.0) THEN
         COL1=NCOLORS(IRES)
      ELSE
         COL1=' '
      END IF
      
C     IF (OOPT.EQ.'O') THEN
C     
C     FOR PREVIOUS FIELD
C     
C     JJ=JJ-1
C     IJ=FDORD(JJ)
C     IV=MAPVID(IJ,2)
C     WRITE(FNAM2,20)(NAMF(I,IV),I=1,4)
C     
C     SCL2=SCLFAC(IV)
C     
C     IRES=0
C     ICOL2=ICOLA(IV)
C     IF (ICOL2.GT.0) IRES=LOCINT(ICOL2,ICOLMAP,1,9,1)
C     IF (IRES.GT.0) THEN
C     COL2=NCOLORS(IRES)
C     ELSE
C     COL2=' '   
C     END IF
C     
C     END IF
      
C     
C     NORMAL DISPLAY
C
C     Input to PLTCHMQ must be reals; CPUX and CPUY are obsolete
C     Converted all [CPUX(IX),CPUY(IY)] to [RX,RY] so that CALL
C     PLCHMQ uses fractional coordinates for labels (LJM - 07/23/2012)
C     
      CALL DATEE(NOWDAT)
      LL=1
      CALL GETSET(FL,FR,FB,FT,UL,UR,UB,UT,LL)
      CALL SET(0.,1.,0.,1.,0.,1.,0.,1.,1)
      IF (ITYP.EQ.1) THEN
C     
C     FOR A SLICE OF THE DATA
C     
         WRITE(LABEL,101)(ID(I),I=116,121),(ID(I),I=125,127),
     X        (ID(I),I=13,15),AXNAM(L3),RLEV,LABAXS(L3,IUNAXS),
     X        FNAM1
 101     FORMAT(I2.2,'/',I2.2,'/',I2.2,6X,I2.2,2(':',I2.2),'-',
     X        I2.2,2(':',I2.2),7X,3A2,7X,A2,'=',F7.2,' ',A4,6X,A8)
         RX=60./1024.
         RY=970/1024.
         CALL PLCHMQ(RX,RY,LABEL,12.,0.,-1.)
         WRITE (LABEL,102)NOWDAT,SCL1,IBINS(NBINS+1)
 102     FORMAT('(AS OF ',A8,').     SCALE FACTOR:',F8.2,
     X        '  BAD VALUES: ',I8)
         RX=10./1024.
         RY=945./1024.
         print *,'HSTLBL: rx,ry,label=',rx,ry,label
         CALL PLCHMQ(RX,RY,LABEL,12.,0.,-1.)
         CALL SET(FL,FR,FB,FT,UL,UR,UB,UT,1)
         IF (IMEDA(IV).EQ.1 .AND. MED.EQ.-999.0) THEN
C     
C     IF MEDIAN IS REQUESTED BUT OUTSIDE RANGE OF BINS CHOSEN BY USER
C     
            RX=50./1024.
            RY=7./1024.
            CALL PLCHMQ(RX,RY,'MEDIAN OUTSIDE RANGE',
     X           12.,0.,-1.)
         END IF
      ELSE 
C     
C     FOR THE WHOLE VOLUME
C     
         WRITE(LABEL,103)(ID(I),I=116,121),(ID(I),I=125,127),
     X        (ID(I),I=13,15),
     X        FNAM1
 103     FORMAT(I2.2,'/',I2.2,'/',I2.2,6X,I2.2,':',I2.2,':',I2.2,'-',
     X        I2.2,':',I2.2,':',I2.2,7X,3A2,7X,'VOLUME',6X,A8)
         RX=60./1024.
         RY=970./1024.
         print *,'HSTLBL: rx,ry,label=',rx,ry,label
         CALL PLCHMQ(RX,RY,LABEL,12.,0.,-1.)
         WRITE (LABEL,122)NOWDAT,SCL1,KBINS(NBINS+1)
 122     FORMAT('(AS OF ',A8,').     SCALE FACTOR:',F8.2,
     X        '  BAD VALUES: ',I8)
         RX=10./1024.
         RY=945./1024.
         print *,'HSTLBL: rx,ry,label=',rx,ry,label
         CALL PLCHMQ(RX,RY,LABEL,12.,0.,-1.)
         IF (IMEDA(IV).EQ.1 .AND. MED.EQ.-999.0) THEN
C     
C     IF MEDIAN IS REQUESTED BUT OUTSIDE RANGE OF BINS CHOSEN BY USER
C     
            RX=50./1024.
            RY=7./1024.
            CALL PLCHMQ(RX,RY,'MEDIAN OUTSIDE RANGE',
     X           12.,0.,-1.)
         END IF
      END IF
      
C     
C     NOW LIST THE STATISTICAL INFORMATION
C     
      WRITE(LABEL,110)
 110  FORMAT(4X,'MEAN',5X,'STDV',7X,'N',4X,'I1',5X,'I2',5X,'J1',5X,
     X     'J2',10X,'MIN',6X,'MAX')
      RX=10./1024.
      RY=900./1024.
      print *,'HSTLBL, rx,ry,label=',rx,ry,label
      CALL PLCHMQ(RX,RY,LABEL,12.,0.,-1.)

      WRITE(LABEL,120)FAVG,FSTD,NP,M1,M2,M3,M4,FMN,FMX
 120  FORMAT(F8.2,1X,F8.2,1X,I8,2X,I3,4X,I3,4X,I3,4X,I3,
     X     7X,F8.2,1X,F8.2)
      RX=10./1024.
      RY=875./1024.
      print *,'HSTLBL, rx,ry,label=',rx,ry,label
      CALL PLCHMQ(RX,RY,LABEL,12.,0.,-1.)
      
C     ELSE 
CC    
CC    OVERLAY PLOT
CC    
C     CALL DATEE(NOWDAT)
C     IF (ITYP.EQ.1) THEN
CC    
CC    FOR A PLANE OF THE DATA
CC    
C     WRITE(LABEL,201)(ID(I),I=116,121),(ID(I),I=125,127),
C     X           (ID(I),I=13,15),AXNAM(L3),RLEV,LABAXS(L3,IUNAXS)
C     201        FORMAT(I2,'/',I2,'/',I2,6X,I2,2I3,'-',I2,2I3,7X,3A2,7X,
C     X           A2,'=',F7.2,' ',A4,6X)
C     CALL PLCHMQ(CPUX(60),CPUY(970),LABEL,12.,0.,-1.)
C     CALL DATEE(NOWDAT)
C     WRITE (LABEL,202)NOWDAT,SCL1,SCL2
C     202        FORMAT('(AS OF ',A8,').     SCALE FACTOR1:',F8.2,
C     X           '     SCALE FACTOR2:',F8.2)
C     CALL PLCHMQ(CPUX(10),CPUY(945),LABEL,12.,0.,-1.)
C     
C     IF (COL1.NE.' ') THEN
C     WRITE(LABEL,210)FNAM1,COL1
C     210           FORMAT('FIELD 1:',A8,3X,'(',A8,')')
C     ELSE
C     WRITE(LABEL,220)FNAM1
C     220           FORMAT('FIELD 1:',A8)
C     END IF
C     CALL PLCHMQ(CPUX(10),CPUY(920),LABEL,12.,0.,-1.)
C     
C     IF (COL2.NE.' ') THEN
C     WRITE(LABEL,230)FNAM2,COL2
C     230           FORMAT('FIELD 2:',A8,3X,'(',A8,')')
C     ELSE
C     WRITE(LABEL,240)FNAM2
C     240           FORMAT('FIELD 2:',A8)
C     END IF
C     CALL PLCHMQ(CPUX(10),CPUY(895),LABEL,12.,0.,-1.)
C     
C     
C     ELSE
CC    
CC    VOLUME SUMMARY
CC    
C     
C     WRITE(LABEL,203)(ID(I),I=116,121),(ID(I),I=125,127),
C     X           (ID(I),I=13,15)
C     203        FORMAT(I2,'/',I2,'/',I2,6X,I2,2I3,'-',I2,2I3,7X,3A2,7X,
C     X           'VOLUME',6X)
C     CALL PLCHMQ(CPUX(60),CPUY(970),LABEL,12.,0.,-1.)
C     WRITE (LABEL,202)NOWDAT,SCL1,SCL2
C     CALL PLCHMQ(CPUX(10),CPUY(945),LABEL,12.,0.,-1.)
C     IF (COL1.NE.' ') THEN
C     WRITE(LABEL,210)FNAM1,COL1
C     ELSE
C     WRITE(LABEL,220)FNAM1
C     END IF
C     CALL PLCHMQ(CPUX(10),CPUY(920),LABEL,12.,0.,-1.)
C     
C     IF (COL2.NE.' ') THEN
C     WRITE(LABEL,230)FNAM2,COL2
C     ELSE
C     WRITE(LABEL,240)FNAM2
C     END IF
C     CALL PLCHMQ(CPUX(10),CPUY(895),LABEL,12.,0.,-1.)
C     END IF
C     END IF
C     
      CALL GSCLIP(1)
      
      RETURN
      
      END
