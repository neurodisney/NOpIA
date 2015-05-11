# Basic processing steps

This description assumes that the imaging data is already converted to the `*.nii.gz` format. This file format is the standard for neuroimaging software packages and now allows using these (e.g. [FSL](http://fsl.fmrib.ox.ac.uk/fsl/fslwiki/), [AFNI](http://afni.nimh.nih.gov/afni/) or [PyMVPA](http://www.pymvpa.org/); se a;so [NiPype](http://nipy.sourceforge.net/nipype/) as neat option to controll the processing stream). 

However, there is one caveat which has to be accounted for: typical neuroimaging data consists of 3D volumes which might be extended in the fourth dimension of time. Optical imaging data just is two dimensional and might get its third dimension as time. The file conversion results in files that are interpreted as 3D volumes, though the third dimension, z, has an extend of 1. Anyway, avoid anything that tries to align or orient 3D data.

In the following, several preprocessing are described. They are currently not a standard stream but show how certain things could be realized. This description has more the purpose to summarize various options and by this provide a list of things that might be worth to look into in order to check the feasibility of the various approaches.

 To see how a specific pre-processing example check ** *FILE NEEDS TO BE ADDED!* **

## Current example data

Assume that the current data consists of five Blocks with 4 condition each, and reference images were obtained at the start of the experiment with red and green light. The following files are in the sample data set (session 2015_04_30), and in the following it is assumed that the current working directory is the data directory of this session, therefore it is not necessary to specify the full paths of the data files.

```
green_initial.nii.gz   led_E0B1_cnd04.nii.gz  led_E0B3_cnd04.nii.gz
led_E0B0_cnd01.nii.gz  led_E0B2_cnd01.nii.gz  led_E0B4_cnd01.nii.gz
led_E0B0_cnd02.nii.gz  led_E0B2_cnd02.nii.gz  led_E0B4_cnd02.nii.gz
led_E0B0_cnd03.nii.gz  led_E0B2_cnd03.nii.gz  led_E0B4_cnd03.nii.gz
led_E0B0_cnd04.nii.gz  led_E0B2_cnd04.nii.gz  led_E0B4_cnd04.nii.gz
led_E0B1_cnd01.nii.gz  led_E0B3_cnd01.nii.gz  red_initial.nii.gz
led_E0B1_cnd02.nii.gz  led_E0B3_cnd02.nii.gz
led_E0B1_cnd03.nii.gz  led_E0B3_cnd03.nii.gz
```

## reduction of FoV and downsampling

It might be worth to consider downsampling and cropping the field of view (FoV) early on to speed up the subsequent processing steps. This is especially usefull when setting up and testing the routines.

Both steps could be easily done with FSL tools.

### cropping 

I would recommend to crop the reference images less strong to give some space for image alignment. FSL provides the `fslroi` tool that allows to extract a rectangular region. However, it is not possible to rotate the box. If this should be done, it might be better to rotate and crop the *.bmp file prior image conversion.

```{bash}
	fsllroi green_initial green_initial_crop 210 300 80 290 0 1 0 1
	fslroi red_initial red_initial_crop 210 300 80 290 0 1 0 1

	for cfl in $(ls -1 led_E0B[[0-5]_cnd*[0-5].nii.gz)
	do
		cnm=$(remove_ext $cfl)
		fslroi $cnm ${cnm}_crop 215 280 85 280 0 1 0 -1
	done
```

### downsampling

The quick and dirty down sampling by a factor of 2 could be done with `fslmaths`:

```{bash}
	for cfl in $(ls -1 *_crop.nii.gz)
	do
		fslmaths $cfl -subsamp2 $cfl
	done
```

Another option uses `flirt` and allows to specify the resulting pixel size. The downsampling steps are tricky because it is not clear how this will be done, i.e. if and to what extend pixels will be averaged to create a new, larger pixel. For flirt, it might be a good option to apply spatial smoothing first.

```{bash}
	for cfl in $(ls -1 *_crop.nii.gz)
	do
		flirt -in $cfl -ref $cfl -init $FSLDIR/etc/flirtsch/ident.mat   -applyisoxfm -out $cfl
	done
```

## motion correction and co-registration

Motion correction tries to find a transformation of the image in a way that a cost function gets minimized. This transformation could be a rigid body transformation that determines translation and rotation parameters. It also could be affine (shearing and scalling) or a nonparametric warping. There is a variety of different routines available for image alignement. It needs to be compared which one is most suitable for 2D optical imaging data.

### FSL

[FSL](http://fsl.fmrib.ox.ac.uk/fsl/fslwiki/) has several routines for image co-registration ([flirt](http://fsl.fmrib.ox.ac.uk/fsl/fslwiki/FLIRT) and [fnirt](http://fsl.fmrib.ox.ac.uk/fsl/fslwiki/FNIRT)) and motion correction ([mcflirt](http://fsl.fmrib.ox.ac.uk/fsl/fslwiki/MCFLIRT)). However, there are only limitted options to force these tools to cope with 2D data. Therefore, it might be a quick and dirty option to get some co-registration working but this likely is sub-optimal. *I am not wasting time on this for now!*

### AFNI

[AFNI](http://afni.nimh.nih.gov/afni/) has one routine for 3D image alignement ([3dvolreg](http://afni.nimh.nih.gov/pub/dist/doc/program_help/3dvolreg.html)). However, they also provide a wrapper script ([2dwarper](http://afni.nimh.nih.gov/pub/dist/doc/program_help/@2dwarper.Allin.html)) that performs the registration (including warping) on 2D images of a time series. This might be a good option to try.

The other promising option is [imreg](http://afni.nimh.nih.gov/pub/dist/doc/program_help/imreg.html) that is specific for 2d images.

### ANT

[ANT](http://stnava.github.io/ANTs/) is a very sophisticated package for medical image co-registration that has the option to specify image dimensionality. This might be a good way to avoid problems with 3D options.

### ImageJ

[ImageJ](http://rsb.info.nih.gov/ij/) might be tailored best to cope with 2D images and it has several extensions for image registration. It might be worth to try these and check the outcome. Though ImageJ itself does not use nifti format, there is an extension available to teach ImageJ to do so: [NIfTi Input/Output](http://rsb.info.nih.gov/ij/plugins/nifti.html) 

* [StackReg](http://bigwww.epfl.ch/thevenaz/stackreg/) 
* [TurboReg](http://bigwww.epfl.ch/thevenaz/turboreg/)
* [template Matching](https://sites.google.com/site/qingzongtseng/template-matching-ij-plugin) 

### R

R is developping fast and recently gets stronger in medical image processing. Might be worth to keep an eye on it, see for example this overview of [Medical Image Analysis](http://cran.r-project.org/web/views/MedicalImaging.html).

## spatial image smoothing 

To reduce the impact of shot noise image data should be spatially smoothed. Since optical imaging utilizes blood oxygenation, some spatial spread of the signal would be assumed. A simple and straight forward smooting could be realized with `fslmaths`.

Another option that might be worth looking into is the [susan](http://fsl.fmrib.ox.ac.uk/fsl/fslwiki/SUSAN) tools which should preserve structures in the smoothing process. This might help to keep blood vessels seperated from brain tissue.








## averaging data files and subtractions

## temporal filtering


