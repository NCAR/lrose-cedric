# LROSE CEDRIC
This repository includes the CEDRIC, SPRINT, PPI, CEDIO, and GRID2PS tools for radar data analysis

## Cedric

An NCAR/MMM supported mesoscale data analysis program that processes datasets on regular Cartesian and longitude-latitude grids. The analysis options include many numerical operations such as algebraic, filtering, and Doppler radar wind synthesis, both ground-based and airborne, as well as graphical operations. Several REMAPpings (interpolations) are possible: XYE --> XYZ, LLE--> LLZ, XYE <--> LLE, and XYZ <--> LLZ, where XY (LL) is a regular Cartesian (longitude-latitude) grid. Z (E) refers to a constant height (elevation angle) surface. CEDRIC uses its own self-describing, binary format as well as the network Common Data Format (netCDF) that was developed by NASA and UCAR's UNIDATA. CEDRIC can ingest Mudras data (pure format) from Reorder or Sprint interpolation software. The synthesized data can be saved in Mudras or Netcdf format for further processing. Graphical output is saved as gmeta file and can be viewed using NCAR IDT software. Please refer to the CEDRIC documentation for further information.

## Sprint

Sprint is an NCAR/MMM program to interpolate radar measurements taken at spherical coordinates (range, azimuth, and elevation) to regularly-spaced Cartesian or longitude-latitude grids, in either constant height or constant elevation angle surfaces. It accepts radar data in any of the EOL field, univeral, DORADE, or NEXRAD Level II formats. SPRINT outputs interpolated data in pure binary format readable by CEDRIC. A description of the CEDRIC binary format can be found in Appendix D of the documentation for SPRINT or CEDRIC. Data from PPI scans can be interpolated to Cartesian or longitude-latitude grids, either at constant height or constant elevation angle surfaces. Both airborne helical scans and constant-azimuth (RHI) scans from ground-based radars are only interpolated to Cartesian grids (X, Y, and Z).
