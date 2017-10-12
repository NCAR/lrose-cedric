# -*- makefile -*-
#

if MAKE_WITH_NCARG
bin_PROGRAMS = cedric gcedric
noinst_LIBRARIES = libcedric.a libgcedric.a
else
bin_PROGRAMS = cedric
noinst_LIBRARIES = libcedric.a
endif

FSRCS = \
	AIRCHK.f \
	ANALYT.f \
	ANLACT.f \
	ANLREP.f \
	AZMFIL.f \
	BACKREC.f \
	BEAMIN.f \
	BLDDES.f \
	BLHED.f \
	BLKDAT.f \
	CARTAP.f \
	CEDLOG.f \
	CEDUTIL.f \
	CHKMSG.f \
	COMBIN.f \
	CONFLD.f \
	CRTOUT.f \
	CRTSET.f \
	CRTTCP.f \
	DMPCHAR.f \
	DMPFLOAT.f \
	DMPINTGR.f \
	DOFILT.f \
	DORSWP.f \
	DORVOL.f \
	DUMBUF.f \
	DUMP.f \
	FEETCL.f \
	FFDUMP.f \
	FFSCL.f \
	FILLAZ.f \
	FILTER.f \
	FLAT.f \
	FXTABLE.f \
	GENAZM.f \
	GETNAME.f \
	HEDSET.f \
	HEDSHF.f \
	IGET16.f \
	IGET8.f \
	IGETAI.f \
	IGETCP.f \
	IGETCP2.f \
	IGTDAT.f \
	IMHSUM.f \
	INHSUM.f \
	INITAL.f \
	INITVOL.f \
	INPFIL.f \
	INTCHK.f \
	INTERP.f \
	IPKDAT.f \
	IPUT16.f \
	IPUT8.f \
	IPUTAI.f \
	IPUTCP.f \
	IQUAD.f \
	ITPFLD.f \
	ITPFLDC.f \
	IVVPCK.f \
	IVVUNP.f \
	KARDIN.f \
	LAT_LON.f \
	LL2XY.f \
	LL2XYDRV.f \
	LOADBMS.f \
	LOCATE.f \
	LOCATEC.f \
	MACHSIZ.f \
	METHOD.f \
	MTHSUM.f \
	NEXSWP.f \
	NEXVOL.f \
	OUTFIL.f \
	OUTPCK.f \
	PROFIL.f \
	RADAR.f \
	RANF.f \
	RAYIN.f \
	RDRYDK.f \
	README \
	RITER.f \
	RNGFIL.f \
	RPNCAR.f \
	RSCART.f \
	SCNEND.f \
	SCNSET.f \
	SETVOL.f \
	SHILBL.f \
	SHIRBL.f \
	SINSRT.f \
	SKPFFVOL.f \
	SKPVOL.f \
	STRID.f \
	SWAPEM.f \
	SWAPEMC.f \
	TAPOUT.f \
	TPQERX.f \
	TRPARVOL.f \
	TRPD.f \
	TRPPPI.f \
	TRPVOL.f \
	UFCART.f \
	UFCHARS.f \
	UFDUMP.f \
	UFNCAR.f \
	UFREC.f \
	UNCODE.f \
	USRORIGIN.f \
	VERSOUT.f \
	VERTCHK.f \
	VUNF.f \
	WRRYDK.f \
	gbytes.f \
	i1mach.f \
	sbytes.f


# These modules depend on the CEDRIC_USE_NCARG macro.
MAINSRCS = CEDRIC.F CEDERX.F KARDIN.F STATS.F 

GBYTESSRCS = \
 gbytes/gbytes.f \
 gbytes/sbytes.f \
 gbytes/i1mach.f \
 gbytes/logic32.c

CSRCS = \
	CCOSIN.c \
	CDATE.c \
	CINITCOS.c \
	COUT.c \
	SUNFOR.c \
	dorade.c \
	ishift.c \
	myio.c \
	nexrad.c

#
# FORTRAN include does not look in /usr/include by default, so it must be
# specified if that is where netcdf.inc is located.
#
FINCLUDES = -I/usr/include -I../../../include
AM_FFLAGS = -g -O0 -std=legacy $(DEFINES) -fno-range-check \
          -fsecond-underscore $(NETCDFINCS) $(FINCLUDES)
AM_CFLAGS = -g -O0 $(DEFINES) $(NETCDFINCS) -I../../../include
AM_LDFLAGS = -L../../../lib

libcedric_a_SOURCES = $(FSRCS) $(CSRCS) $(MDVSRCS) $(GBYTESSRCS)

cedric_SOURCES = $(MAINSRCS)
cedric_FFLAGS = -DCEDRIC_USE_NCARG=0 $(AM_FFLAGS)
cedric_LDADD = $(NETCDFLIBS) libcedric.a

if MAKE_WITH_NCARG
libgcedric_a_SOURCES = $(NGSRCS)
gcedric_SOURCES = $(MAINSRCS)
gcedric_FFLAGS = -DCEDRIC_USE_NCARG=1 $(AM_FFLAGS) $(NCARGINCS)
gcedric_LDADD = libcedric.a libgcedric.a libcedric.a $(NCARGLIBS) $(XLIBS) $(NETCDFLIBS)
endif
