      SUBROUTINE RITER(RBUF,NX,NY,K,ZLEV,ITIT,KPLN,NSTEP,NSIG,KPRINT)
C
C
C        RITER- LISTS OUT DATA FIELDS FROM A 2-D PLANE ONTO UNIT  IPR
C
C
C        INPUT PARAMETERS.....
C
C        RBUF- ARRAY CONTAINING DATA FIELDS TO BE LISTED
C        NX- NUMBER OF DATA POINTS ALONG THE X-AXIS
C        NY- NUMBER OF DATA POINTS ALONG THE Y-AXIS
C        K- 2-D PLANE NUMBER
C        ZLEV- CONSTANT DISTANCE (KM) FROM ORIGIN OF THE 2-D PLANE
C        ITIT- 80 CHARACTER TITLE DESCRIBING THE LISTED FIELDS
C        KPLN- NUMBER OF FIELDS TO LIST
C        NSTEP- NUMBER OF FIELDS TO SKIP BETWEEN LISTED FIELDS
C        NSIG- NUMBER OF DIGITS TO THE RIGHT OF DECIMAL FOR DISPLAY
C        KPRINT- 'YES' TO LIST DATA FIELDS
C                (OTHERWISE RETURN IMMEDIATELY)
C
C
      DIMENSION RBUF(NX,NY,1), ITIT(10)
c      CHARACTER*20 JFMT
c      CHARACTER*10 IFMT
C
C        IPR- LOGICAL UNIT NUMBER FOR OUTPUT OF DATA FIELD LISTINGS
C
      DATA IPR/6/
C
C        LINES- MAXIMUM NUMBER OF CHARACTERS ACROSS PAGE
C
      DATA LINES/124/
      RETURN
C      IF(KPRINT.NE.'Y')RETURN
C
C        CALCULATE DATA FORMAT AND LIST OUT APPROPRIATE TITLING INFORMATION
C
C      NWID=NSIG+7
C      IF(NSIG.LE.0)NWID=5
C      NCOL=LINES/NWID
C      WRITE (IFMT,201)NCOL,NWID
C  201 FORMAT(*(4X,*,I2,*I*,I2,*)*)
C      WRITE (JFMT,202)NCOL,NWID,NSIG
C  202 FORMAT(*(1X,I2,1X,*,I2,*F*,I2,*.*,I2,* )*)
C      WRITE(IPR,100) K,ZLEV,ITIT
C  100 FORMAT('1',5X,*PLANE NUMBER:*,I4,10X,*CONSTANT VALUE= *,F6.1* KM*,
C     :    /20X,10A8)
C      L=1
C
C        LOOP ONCE FOR EACH FIELD TO BE LISTED
C
C      DO 20 LOOP=1,KPLN
C      WRITE(IPR,101)
C  101 FORMAT(//)
C      M=0
C      I1=1
C   10 CONTINUE
C
C        LIST OUT NEXT PART OF THE FIELD
C
C      M=M+1
C      J=NY
C      I2=I1+NCOL-1
C      IF(I2.GT.NX)I2=NX
C      WRITE(IPR,102) LOOP, M
C  102 FORMAT(///20X,*FIELD NO. *,I2,80X,*PART. *,I2/)
C      WRITE(IPR,IFMT) (I, I=I1,I2)
C   15 CONTINUE
C      WRITE(IPR,JFMT) J, (RBUF(I,J,L),  I=I1,I2)
C      J=J-1
C      IF(J.GT.0)GO TO 15
C      I1=I2+1
C      IF(I1.LE.NX)GO TO 10
C      L=L+NSTEP
C   20 CONTINUE
C      RETURN
      END
