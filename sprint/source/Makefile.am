# makefile.am for sprint
#

bin_PROGRAMS = sprint

SRCS = AIRCHK.f	ANALYT.f	ANLACT.f	ANLREP.f	AZMFIL.f \
      BACKREC.f	BEAMIN.f	BLDDES.f	BLHED.f	        BLKDAT.f \
      CARTAP.f	CCOSIN.c	CDATE.c		CEDLOG.f	CEDUTIL.f \
      CHKMSG.f	CINITCOS.c	COMBIN.f	CONFLD.f 	COUT.c \
      CRTOUT.f	CRTSET.f	CRTTCP.f	DOFILT.f	DORSWP.f \
      DORVOL.f 	DUMBUF.f	FEETCL.f	FFSCL.f		FILLAZ.f \
      FILTER.f	FLAT.f		FXTABLE.f	GENAZM.f	GETNAME.f \
      HEDSET.f	HEDSHF.f	IGETCP2.f	IGET16.f	IGET8.f \
      IGETAI.f	IGETCP.f	IGTDAT.f	IMHSUM.f	INHSUM.f \
      INITAL.f	INITVOL.f	INPFIL.f	INTCHK.f	INTERP.f \
      IPKDAT.f	IPUT16.f	IPUT8.f		IPUTAI.f	IPUTCP.f \
      IQUAD.f	ITPFLD.f	ITPFLDC.f	IVVPCK.f	IVVUNP.f \
      KARDIN.f	LAT_LON.f	LL2XY.f		LL2XYDRV.f	LOADBMS.f \
      LOCATE.f  UFREC.f		DUMP.f		UFDUMP.f	FFDUMP.f \
      LOCATEC.f	MACHSIZ.f	METHOD.f	MTHSUM.f	NEXSWP.f \
      NEXVOL.f	OUTFIL.f	OUTPCK.f	PROFIL.f 	RADAR.f	 \
      RANF.f	RAYIN.f		RDRYDK.f	RITER.f		RNGFIL.f \
      RPNCAR.f	RSCART.f	SCNEND.f	SCNSET.f 	SETVOL.f \
      SHILBL.f	SHIRBL.f	SINSRT.f	SKPFFVOL.f	SKPVOL.f \
      STRID.f	SUNFOR.c	SWAPEM.f	SWAPEMC.f	TAPOUT.f \
      TPQERX.f	TRPARVOL.f	TRPD.f		TRPPPI.f	TRPVOL.f   \
      UFCART.f	UFCHARS.f	UFNCAR.f	UNCODE.f	USRORIGIN.f  \
      VERSOUT.f	VERTCHK.f	VUNF.f		WRRYDK.f	dorade.c \
      myio.c	nexrad.c	DMPCHAR.f       DMPFLOAT.f      DMPINTGR.f \
      gbytes.f  sbytes.f	ishift.c	i1mach.f

# compile flags

AM_CFLAGS = -I.
AM_CFLAGS += -I../../../include
AM_CFLAGS += -I$(prefix)/include
AM_CFLAGS += -I/usr/include
AM_CFLAGS += -g -O0

AM_FFLAGS = $(AM_CFLAGS)
AM_FFLAGS += -std=legacy
AM_FFLAGS += -fno-range-check
AM_FFLAGS += -fsecond-underscore
AM_FFLAGS += $(NETCDFINCS)

# link flags

AM_LDFLAGS = -L.
AM_LDFLAGS += -L../../../lib
AM_LDFLAGS += -L$(prefix)/lib
AM_LDFLAGS += -Wl,-rpath=$(prefix)/lib

sprint_SOURCES = $(SRCS)

