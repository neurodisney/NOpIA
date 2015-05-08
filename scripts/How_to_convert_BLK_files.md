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

Define now the source directory with the files as well as the output directory where the converted files should be written to.

```{bash}
srcdir='/DATA/ACh_imaging/150430_wolf_rat/run00'
niidir='/DATA/ACh_imaging/nii/2015_04_30'

mkdir -p $niidir  # make sure this directory exists
```
Get a list of the `*blk` and `*bmp` files in this directory.

```{bash}
BLKlst=$(ls $srcdir/*.BLK)
BMPlst=$(ls $srcdir/*.bmp)
```
Now loop over the file list and convert the data.

```{bash}
for cfl in $BLKlst
do
	onm=$(basename $cfl | sed -e 's/.BLK//g') 
	blk2nii $cfl $niidir/$onm  # note that FOV and frame rate could be specified
done

for cfl in $BMPlst
do
	onm=$(basename $cfl | sed -e 's/.bmp//g') 
	bmp2nii $cfl $niidir/$onm .nii # note that FOV could be specified
done
```

After these steps a set of converted files should be found in the output directory that are in the `*nii.gz` format.

The steps described here are combined in the script `AOI_conv`.  This provides a shortcut to all the conversion steps by just using"

```{bash}
AOI_conv $srcdir $niidir
```

## matlab variant

The conversion could also be done from within Matlab. 

```{matlab}
nopia='/DATA/Git_contrib/NOpIA'
addpath([nopia,'/NIfTI_20140122']);  
addpath([nopia,'/tools']); 
AOI_blk2nii;
```

