# NOpIA
This repository provides processing tools that are related to the analysis of data from optical imaging experiments with neuromodulators.

These scripts require the following tools to be available:
* *Tools for NIfTI and ANALYZE image* by Jimmy Shen
  http://www.mathworks.com/matlabcentral/fileexchange/8797

The idea is to convert the optical imaging data into the nifti format which is well supported by several neuroimaging software packages. This will then allow to utilize their implementation for data processing and analysis.

Recommended installation would be FSL (http://fsl.fmrib.ox.ac.uk/fsl).

Be aware, this is work in progress and it is not guaranteed that the functions will work robustly.

## converting data

The first steps requires the conversion of optical imaging data into the nifti format (http://nifti.nimh.nih.gov).
