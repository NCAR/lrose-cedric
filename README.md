# LROSE CEDRIC

This repository includes the CEDRIC, SPRINT, PPI, CEDIO, and GRID2PS tools for radar data analysis

## DOI

The DOI for lrose-cedric is:

* [https://doi.org/10.5065/cnth-sa86](https://doi.org/10.5065/cnth-sa86)

The DOI entry information is stored at:

* [https://search.datacite.org/works/10.5065/cnth-sa86](https://search.datacite.org/works/10.5065/cnth-sa86)

## Cedric

An NCAR/MMM supported mesoscale data analysis program that processes datasets on regular Cartesian and longitude-latitude grids. The analysis options include many numerical operations such as algebraic, filtering, and Doppler radar wind synthesis, both ground-based and airborne, as well as graphical operations. Several REMAPpings (interpolations) are possible: XYE --> XYZ, LLE--> LLZ, XYE <--> LLE, and XYZ <--> LLZ, where XY (LL) is a regular Cartesian (longitude-latitude) grid. Z (E) refers to a constant height (elevation angle) surface. CEDRIC uses its own self-describing, binary format as well as the network Common Data Format (netCDF) that was developed by NASA and UCAR's UNIDATA. CEDRIC can ingest Mudras data (pure format) from Reorder or Sprint interpolation software. The synthesized data can be saved in Mudras or Netcdf format for further processing. Graphical output is saved as gmeta file and can be viewed using NCAR IDT software. Please refer to the CEDRIC documentation for further information.

## Sprint

Sprint is an NCAR/MMM program to interpolate radar measurements taken at spherical coordinates (range, azimuth, and elevation) to regularly-spaced Cartesian or longitude-latitude grids, in either constant height or constant elevation angle surfaces. It accepts radar data in any of the EOL field, univeral, DORADE, or NEXRAD Level II formats. SPRINT outputs interpolated data in pure binary format readable by CEDRIC. A description of the CEDRIC binary format can be found in Appendix D of the documentation for SPRINT or CEDRIC. Data from PPI scans can be interpolated to Cartesian or longitude-latitude grids, either at constant height or constant elevation angle surfaces. Both airborne helical scans and constant-azimuth (RHI) scans from ground-based radars are only interpolated to Cartesian grids (X, Y, and Z).

## Building

The CEDRIC software can be configured and compiled using the 'configure'
script, generated with the GNU autoconf tools.  See the file INSTALL for
generic information about running configure.  This file is contains release
notes and specific instructions for building CEDRIC.

CEDRIC can be built as two separate executables, gcedric or cedric.
'gcedric' can generate plots of radar data and analysis products using the
NCAR Graphics package, so NCAR Graphics must be installed when gcedric is
compiled.  The 'cedric' executable is built without any support for
plotting and does not require NCAR Graphics.  Both executables are built
from the same source files, except the source code which requires NCAR
Graphics is not compiled if the preprocessor symbol CEDRIC_USE_NCARG is not
defined to 1.  Both cedric and gcedric can read the same input files and
output the same data files, except only gcedric will output any graphical
plots.  This file contains instructions for building one or both
executables.

## Requirements

### Linux FORTRAN

Currently CEDRIC is only developed on Linux with GNU Fortran (gfortran).
Note that gfortran is an entirely different compiler from the older g77.
CEDRIC depends upon a 32-bit FORTRAN native integer type, but it compiles
on both 32-bit and 64-bit machine architectures.

### NetCDF

Both CEDRIC applications require the NetCDF library, either NetCDF 3 or 4.
The NetCDF output is always the classic NetCDF 3 format.

### NCAR Graphics (required only for generating plots)

NCAR Graphics is required to build gcedric, but not for the non-graphical
cedric application.

### Building with or without NCAR Graphics

The configure script provides the option --with-ncarg to specify whether to
compile gcedric and its support for NCAR Graphics.  It can be used like so:

```
 configure --with-ncarg
```

 Enable building with NCAR Graphics support.  This is the default.  The
 configure script attempts to locate an installation of NCAR Graphics by
 searching common locations.  It first tries to link with NCAR Graphics in
 the standard system directories, and then looks in common locations like
 /opt/local/ncarg, /usr/local/ncarg, and /opt/local.

```
 configure --with-ncarg=/opt/local/ncarg-5.2.1
```

 Enable NCAR Graphics and specify the directory in which NCAR Graphics is
 installed.  The configure script generates the right compiler includes and
 library options to link with NCAR Graphics in that location.  The
 configure script exits with an error if a test link fails.

```
 configure --with-ncarg=no
```

 Disable NCAR Graphics.  The configure script does not search for NCAR
 Graphics and the 'gcedric' application will not be compiled.

## NetCDF compile settings

The configure script by default expects the netcdf headers and libraries to
be found by the compiler in the standard system locations.  If the default
settings are not correct, then they can be overridden in the environment or
on the configure command line with these variables:

 NETCDFINCS	   Compiler include path option to find netcdf headers. 
 NETCDFLIBS	   Linker library options for netcdf libraries.
 NETCDFLIBDIR	   The directory to search for the default netcdf libraries.

For example, this command configures the compile to use the standard
netcdf4 libraries and dependencies but adds the given directory to the
library search path:

```
 configure NETCDFLIBDIR=/opt/local/netcdf/lib NETCDFINCS=-I/opt/local/netcdf/include
```

This command overrides all the netcdf-related compile settings to build
against a custom netcdf3 installation (the HDF libraries are omitted).

```
 configure NETCDFLIBS='-L/home/me/netcdf/lib -lnetcdff -lnetcdf -ludunits2' \
 	   NETCDFINCS='-I/home/me/netcdf/include'
```

## Running Make

Once the configure script runs successfully, build the executables by
running 'make' from the top level directory.  The non-graphical 'cedric'
application will be in source/cedric, and if NCAR graphics was enabled,
then gcedric will be in source/gcedric.

If you want to install the executables into the bin directory configured by
the {prefix} option, run 'make install'.

## Tests

The full CEDRIC source tree includes some examples which can be used for
testing.  Run 'make check' to run the tests.  The tests run cedric (and
gcedric if enabled) and compare the output with known good output files.
The tests fail if there are any unexpected differences.  Sometimes these
differences are insignificant, such as differences in decimal formatting.

## Release Notes
 
April 2, 2013

Here is a summary of the changes in the CEDRIC source code for this release:

 All .f files renamed to .F to follow the gfortran convention that .F
 source files need to be processed with the preprocessor.

 All references to NCAR Graphics calls are wrapped in preprocesser
 conditionals based on the definition of CEDRIC_USE_NCARG.

 Implicit conversions from CHARACTER type to INTEGER in DATA statements
 have been replaced with Hollerith constants.  The Hollerith extension is
 supported by gfortran whereas the automatic conversion to INTEGER type is
 not.

 All references to the 32-bit or 64-bit distinction for the value of WORDSZ
 have been removed.  Instead WORDSZ is always 32-bit, which corresponds to
 the native INTEGER size for almost all of the known FORTRAN compilers.

 The sbytes and gbytes routines are now built within the CEDRIC source tree
 and linked directly into CEDRIC, rather than relying on the NCAR graphics
 library.  Only the 32-bit-INTEGER implementation was included, so they are
 not the correct implementation if WORDSZ does not equal 32 bits.  However,
 as alluded to above, I don't think we will be targetting any FORTRAN
 compilers for which INTEGER size is not 32 bits.
© 2020 GitHub, Inc.
