function AOI_bmp2nii(bmpfile, niifile, FOV, odt)
% Convert a bitmap file into a *.nii file.
%
% DESCRIPTION
%
% SYNTAX
%
%
% REFERENCES
%
% .........................................................................
% wolf zinke, wolfzinke@gmail.com
%
% wolf zinke, 07.04.2015

% ____________________________________________________________________________ %
%% check input data, get file name is required

if(~exist('bmpfile','var') || isempty(bmpfile))
    [FileName,PathName] = uigetfile({'*.bmp'},'Load bitmap file');
    bmpfile = fullfile(PathName,FileName);
end

if(~exist('niifile','var') || isempty(niifile))
    [PathName,FileName] = fileparts(bmpfile);
    niifile = fullfile(PathName,[FileName,'.nii']);
%  else
%      [PathName,FileName] = fileparts(niifile);
%      niifile = fullfile(PathName,[FileName,'.nii']);
end

if(~exist('FOV','var'))
    FOV = [];
end

% ____________________________________________________________________________ %
%% read the image file
img =imread(bmpfile);

H = size(img,1);
W = size(img,2);

nii_img = nan([W, H, 1]); % use this trick to define a z-dimentsion of 1 since it is 2D data
nii_img(:,:,1) = img(:,:,:,1);


% get pixel size
if(~isempty(FOV))
    if(H ~= W)
        warning('Currently only equal width and height of FoV supported!');
        pxlsz = 1;
    else
        pxlsz = FOV/W;
    end
else
    pxlsz = 1;
end

vxlsz = repmat(pxlsz,1,3);

% prepare nifti data
nii = make_nii(nii_img, vxlsz, [], [], 'optical imaging bitmap data');

% adapt header information
nii.hdr.pixdim(5) = 1;

% save the file
save_nii(nii, niifile);


