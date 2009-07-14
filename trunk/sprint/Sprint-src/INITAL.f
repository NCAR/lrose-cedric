      SUBROUTINE INITAL(ICRTST,INPTST)

      INCLUDE 'SPRINT.INC'
c      PARAMETER (MAXEL=150,NID=129+3*MAXEL)
c      PARAMETER (MAXFLD=16)

      LOGICAL IS360
      COMMON /IDBLK/ ID(NID)
      COMMON/ADJUST/INFLD(MAXFLD,3),SCLIF(MAXFLD,2),NIF,IOFLD(MAXFLD,3),
     X     SCLOF(MAXFLD,2),NOF,SCLAZ,SCLRNG,SCLEL,UNSCAZ,UNSCRG,UNSCEL,
     X     LOWAZ,IZAD,IS360,MINAZ,MAXAZ,METSPC(MAXFLD),IWFLD(MAXFLD),
     X     NFLI,SCLNYQ,UNSNYQ
      COMMON /FNAMES/ CINFLD(MAXFLD),CIOFLD(MAXFLD)
      CHARACTER*8 CINFLD, CIOFLD
      COMMON /TRANS/ X1,X2,XD,Y1,Y2,YD,Z1,Z2,ZD,NX,NY,NZ,XORG,YORG,
     X   ANGXAX,ZRAD,AZLOW,BAD,ASNF,ACSF,IAXORD(3),NPLANE,EDIAM
      COMMON /AXUNIT/ IFIXAX,IUNAXS,LABAXS(3,3),SCLAXS(3,3),AXNAM(3),
     X     ORDER_LABL
      CHARACTER*8 AXNAM
      CHARACTER*11 ORDER_LABL
      COMMON /SCNDAT/ ELB(MAXEL),DEI(MAXEL),KDIR(MAXEL),KNDREC(MAXEL),
     X     NEL,IEL1,IEL2,KEL,KPEL,ISD,ELTOL,RNOT,DRG,NG,MAXRD,
     X     CFAC(MAXFLD)
      CHARACTER*2 CTEMP
      

      DO I=1,NID
c         ID(I)=0
         ID(I)=IBAD
c         ID(I)=538984255
      END DO

      NIF =0
      NOF =0
      NFLI=0

      BAD  =-99.
      ELTOL=0.4
      EDIAM=12751.273

      UNSCAZ=20.
      UNSCRG=128.
      UNSCEL=127.
      UNSNYQ=15.

      IUNAXS=1
      IS360=.FALSE.
      ICRTST=-1
      INPTST=-1
      SCLAZ=1./UNSCAZ
      SCLRNG=1./UNSCRG
      SCLEL=1./UNSCEL
      SCLNYQ=1./UNSNYQ

      CTEMP='NO'
      READ(CTEMP,77) ID(25)
 77   FORMAT(A2)
      CTEMP='N-'
      READ(CTEMP,77) ID(26)
      CTEMP='EX'
      READ(CTEMP,77) ID(27)
      CTEMP='IS'
      READ(CTEMP,77) ID(28)
      CTEMP='TE'
      READ(CTEMP,77) ID(29)
      CTEMP='NT'
      READ(CTEMP,77) ID(30)
      
      RETURN
      END
