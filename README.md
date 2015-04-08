# NOpIA
This repository provides processing tools that are related to the analysis of data from optical imaging experiments with neuromodulators.

These scripts require the following tools to be available:
* *Tools for NIfTI and ANALYZE image* by Jimmy Shen (http://www.mathworks.com/matlabcentral/fileexchange/8797)

The idea is to convert the optical imaging data into the nifti format which is well supported by several neuroimaging software packages. This will then allow to utilize their implementation for data processing and analysis.

Recommended installation would be FSL (http://fsl.fmrib.ox.ac.uk/fsl).

The tools provided here will utilize some tools that are available in MyFIA repository (https://github.com/wzinke/myfia).

Be aware, this is work in progress and it is not guaranteed that the functions will work robustly.

## converting data

The first steps requires the conversion of optical imaging data into the nifti format (http://nifti.nimh.nih.gov). Files required for this step are found in the 'tools' subdirectory.

* `AOI_read_vdaq.m`	 loads a *.blk file into matlab and stores the image data in a 4D matrix with the dimensions frame width, frame height, number of frames, and number of conditions. In addition, the header information is stored in a matlab struct.
* `AOI_blk2nii.m` saves the data in the nifti format. Each condition will be saved as seperate nifti file. The files are uncompressed and it is recommended to get them into *.nii.gz format by using either my `nii2gz` script or call the FSL tool `fslchfiletype` with the file type `NIFTI_GZ`.
* `AOI_bmp2nii.m` converts bitmap files with the reference images into nifti format.

## pre-processing data

Pre-processing will prepare the data by, for example, correcting for motion, aligning the block data to the reference image.

