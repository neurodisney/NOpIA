# File Conversion: `*.blk` to `*.nii.gz`

This document provides a brief description about the conversion of image files acquired with the Imager software to the NifTI format that is use as standard for MRI data processing. 

The core tools currently are matlab scripts that can be found in `NOpIA/tools`:

*  `AOI_blk2nii.m`    (commandline wrapper: `blk2nii`)
*  `AOI_bmp2nii.m` (commandline wrapper: `bmp2nii`)

The first tool converts the image data that was acquired with the `Vdaq` program, and the second tool converts bitmap images that were produced as reference images. Conversion of files acquired with the `LongDaq` program is not implemented yet.

## example 

In the following, the process of data conversion is demonstrated with an example data set. It assumes that the processing is done in a Unix terminal (using `BASH`) because i simplifies the data handling a lot.

### set path
The `BASH` environments needs to know where to find the tools. Therefore, the tools directory needs to be added to the known paths. This can be done for the current session from the command line, or this code could be added to the `~/.bash_profile`. Change the assignment for `ToolDir` that it matches your system configuration.

```{bash}
ToolDir='/DATA/Git_contrib/NOpIA/tools'
PATH=$ToolDir:${PATH}
export PATH 
```