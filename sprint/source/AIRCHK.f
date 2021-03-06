      SUBROUTINE AIRCHK(ALTMEAN,TRCKMEAN,DRFTMEAN,PTCHMEAN,ROLLMEAN,
     X                  TILTS,TILTFLG)
C
C     THIS SUBROUTINE CHECKS THE TRACK OF THE AIRCRAFT TO MAKE SURE
C     THAT IT IS FAIRLY CONSTANT. OTHER CHECKS AND MODS ALSO ARE PERFORMED.
C
      INCLUDE 'SPRINT.INC'
c-----PARAMETER (MAXEL=150,NID=129+3*MAXEL)

      DATA TRACKCHECK_MAX,ALTCHECK_MAX/8.0,0.5/

c      PARAMETER (MAXSKP=27,MXCNT=500,DEPS=25.0)
      PARAMETER (DEPS=45.0)
      COMMON /IDBLK/ID(NID)
      COMMON /AIRBRN/ ALATS(MAXEL),ALONS(MAXEL),IALTFLG,THE_TILT
      COMMON /TRANS/ X1,X2,XD,Y1,Y2,YD,Z1,Z2,ZD,NX,NY,NZ,XORG,YORG,
     X     ANGXAX,ZRAD,AZLOW,BAD,ASNF,ACSF,IAXORD(3),NPLANE,EDIAM
      DIMENSION ALTMEAN(MAXEL), TRCKMEAN(MAXEL),DRFTMEAN(MAXEL)
      DIMENSION PTCHMEAN(MAXEL),ROLLMEAN(MAXEL),TILTS(MAXEL)

      REAL TRACK_VOL_MEAN,DRIFT_VOL_MEAN,ALT_VOL_MEAN,PITCH_VOL_MEAN
      REAL ROLL_VOL_MEAN,TILT_VOL_MEAN
      REAL TRACKSUM,DRIFTSUM,ALTSUM,PITCHSUM,ROLLSUM,TILTSUM
      REAL TRACKSQUARED,DRIFTSQUARED,ALTSQUARED,PITCHSQUARED
      REAL ROLLSQUARED,TILTSQUARED
      REAL TRACKDIFF,DRIFTDIFF,ALTDIFF,PITCHDIFF
      REAL ROLLDIFF,TILTDIFF
      INTEGER  TILTFLG

      TRACK_VOL_MEAN = 0
      DRIFT_VOL_MEAN = 0
      ALT_VOL_MEAN   = 0
      PITCH_VOL_MEAN = 0
      ROLL_VOL_MEAN = 0
      TILT_VOL_MEAN  = 0
C
C     OUTPUT SOME ADDITIONAL POSITIONAL AND ORIENTATIONAL INFORMATION
C
c     (LJM - 8/17/09)
      print *,'AIRCHK:      iptr_int=',iptr_int
      print *,'AIRCHK: id(35),id(44)=',id(35),id(44)
      SCALE=FLOAT(ID(44))
      WRITE(*,15)
 15   FORMAT(/,5X,'SWEEP  MEAN TRACK  MEAN DRIFT  MEAN ALT',
     X     '  MEAN PITCH  MEAN ROLL  MEAN LAT    MEAN LON',
     X     '     X(KM)     Y(KM)    MEAN TILT')
      DO I=1,ID(35)
c
c     Calculate current aircraft (xac,yac) relative to first sweep
c     (lat,lon) position using current (lat,lon).
c         
         ANGX = 90.0 + TRCKMEAN(I)
         IF (ANGX.GT.360.0) ANGX=ANGX-360.0
         IF (I.EQ.1) THEN
            ORLAT= ALATS(1)
            ORLON=-ALONS(1)
            ALAT = ALATS(1)
            ALON =-ALONS(1)
            CALL LL2XYDRV(ALAT,ALON,XAC,YAC,ORLAT,ORLON,ANGX)
         ELSE
            ALAT = ALATS(I)
            ALON =-ALONS(I)
            CALL LL2XYDRV(ALAT,ALON,XAC,YAC,ORLAT,ORLON,ANGX)
         END IF
         WRITE(*,30)I,TRCKMEAN(I),DRFTMEAN(I),ALTMEAN(I),PTCHMEAN(I),
     X        ROLLMEAN(I),ALATS(I),ALONS(I),XAC,YAC,TILTS(I)
 30      FORMAT(5X,I3,3X,F8.2,4X,F8.2,3X,F8.3,3X,F8.2,4X,F8.2,3X,F9.4,
     X          3X,F9.4,2(2X,F8.3),3X,F8.2)
c         IF (ABS(ID(129)/SCALE - ID(129+(I-1)*3)/SCALE) .GT.DEPS)
c         IF (ABS(ID(IPTR_INT)/SCALE - ID(IPTR_INT+(I-1)*3)/SCALE) 
         IF (ABS(TRCKMEAN(1) - TRCKMEAN(I)) 
     X        .GT.DEPS)
     X        THEN
c            WRITE(*,20)ID(129)/SCALE,ID(129+(I-1)*3)/SCALE
c            WRITE(*,20)ID(IPTR_INT)/SCALE,ID(IPTR_INT+(I-1)*3)/SCALE
            WRITE(*,20)DEPS,TRCKMEAN(1),TRCKMEAN(I)
 20         FORMAT(5X,'++++WARNING TRACKMEAN HAS CHANGED MORE THAN '
     X           ,F8.1, ' DEG: TRACKMEAN(1)=',F8.2,' TRACKMEAN(SWEEP)='
     X           ,F8.2)
c-----------STOP
         END IF
      END DO

      DO I=1,ID(35)
         TRACK_VOL_MEAN = TRACK_VOL_MEAN + TRCKMEAN(I)
         DRIFT_VOL_MEAN = DRIFT_VOL_MEAN + DRFTMEAN(I)
         ALT_VOL_MEAN   = ALT_VOL_MEAN + ALTMEAN(I)
         PITCH_VOL_MEAN = PITCH_VOL_MEAN + PTCHMEAN(I)
         ROLL_VOL_MEAN  = ROLL_VOL_MEAN + ROLLMEAN(I)
         TILT_VOL_MEAN  = TILT_VOL_MEAN + TILTS(I)
      END DO
      TRACK_VOL_MEAN = TRACK_VOL_MEAN/ID(35)
      DRIFT_VOL_MEAN = DRIFT_VOL_MEAN/ID(35)
      ALT_VOL_MEAN   = ALT_VOL_MEAN/ID(35)
      PITCH_VOL_MEAN = PITCH_VOL_MEAN/ID(35)
      ROLL_VOL_MEAN  = ROLL_VOL_MEAN/ID(35)
      TILT_VOL_MEAN  = TILT_VOL_MEAN/ID(35)
      IF(TILTFLG .EQ. 2) THEN
         THE_TILT = TILT_VOL_MEAN
         PRINT *,"THE MEAN TILT WAS CHOSEN ",THE_TILT
      END IF

      PRINT *,' AIRCHK:'
      WRITE(*,33)TRACK_VOL_MEAN,DRIFT_VOL_MEAN,ALT_VOL_MEAN,
     X     PITCH_VOL_MEAN,ROLL_VOL_MEAN,TILT_VOL_MEAN
 33   FORMAT(2X,'VOL_MEAN=',F8.2,4X,F8.2,3X,F8.3,3X,F8.2,4X,F8.2,
     X     47X,F8.2)

      TRACKSUM = 0
      DRIFTSUM = 0
      ALTSUM   = 0
      PITCHSUM = 0
      ROLLSUM  = 0
      TILTSUM  = 0
      DO I=1,ID(35)
         TRACKDIFF =  TRACK_VOL_MEAN - TRCKMEAN(I)
         DRIFTDIFF =  DRIFT_VOL_MEAN - DRFTMEAN(I)
         ALTDIFF   =  ALT_VOL_MEAN   - ALTMEAN(I) 
         PITCHDIFF =  PITCH_VOL_MEAN - PTCHMEAN(I)
         ROLLDIFF  =  ROLL_VOL_MEAN - ROLLMEAN(I)
         TILTDIFF  =  TILT_VOL_MEAN  - TILTS(I) 
         TRACKSQUARED = TRACKDIFF * TRACKDIFF
         DRIFTSQUARED = DRIFTDIFF * DRIFTDIFF
         ALTSQUARED   = ALTDIFF * ALTDIFF
         PITCHSQUARED = PITCHDIFF * PITCHDIFF
         ROLLSQUARED  = ROLLDIFF * ROLLDIFF
         TILTSQUARED  = TILTDIFF * TILTDIFF
         TRACKSUM =  TRACKSUM + TRACKSQUARED
         DRIFTSUM =  DRIFTSUM + DRIFTSQUARED
         ALTSUM   =  ALTSUM   + ALTSQUARED      
         PITCHSUM =  PITCHSUM + PITCHSQUARED
         ROLLSUM  =  ROLLSUM  + ROLLSQUARED
         TILTSUM  =  TILTSUM  + TILTSQUARED      
      END DO 

      TRACKCHECK = SQRT(TRACKSUM/ID(35))
      DRIFTCHECK = SQRT(DRIFTSUM/ID(35))
      ALTCHECK   = SQRT(ALTSUM/ID(35))
      PITCHCHECK = SQRT(PITCHSUM/ID(35))
      ROLLCHECK  = SQRT(ROLLSUM/ID(35))
      TILTCHECK  = SQRT(TILTSUM/ID(35))
      WRITE(*,37)TRACKCHECK,DRIFTCHECK,ALTCHECK,PITCHCHECK,ROLLCHECK,
     X     TILTCHECK
 37   FORMAT(2X,'AVG_DIFF=',F8.2,4X,F8.2,3X,F8.3,3X,F8.2,4X,F8.2,
     X     47X,F8.2)
      IF(TRACKCHECK .GT. TRACKCHECK_MAX) THEN
         PRINT *,'TRACK ANGLE TEST FAILED IN AIRCHK',
     X        ' - AVG DIFF EXCEEDS ',TRACKCHECK_MAX,' Degrees'
c--------STOP
      END IF

      IF(ALTCHECK .GT. ALTCHECK_MAX) THEN
         PRINT *,'AIRCRAFT ALTITUDE VARIES TOO MUCH TO INTERPOLATE',
     X        ' - AVG DIFF EXCEEDS ',ALTCHECK_MAX,' km'
c--------STOP
      END IF      

C
C     SET ANGXAX TO BE TRACK
C
      ANGXAX = 90 + TRACK_VOL_MEAN
      IF (ANGXAX.GT.360.0) ANGXAX=ANGXAX-360.0
C
C     SET ALTITUDE OF AIRCRAFT, UNLESS USER WANTS TO OVERRIDE
C
      IF (IALTFLG.EQ.0) THEN
         ZRAD  = ALT_VOL_MEAN
         ID(46)=ZRAD*1000.
      END IF

      IF(TILTFLG .EQ. 1) THEN
         PRINT *,"USING THE MODE VALUE OF THE TILT IN INTERPOLATION"
         PRINT *,THE_TILT
      ELSE IF(TILTFLG .EQ. 2) THEN
         PRINT *,"USING THE MEAN VALUE OF THE TILT IN INTERPOLATION"
         PRINT *,THE_TILT
      END IF

      RETURN
      END














