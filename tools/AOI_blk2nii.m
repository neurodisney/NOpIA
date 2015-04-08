function AOI_blk2nii(blkfile, niifile, frame_rate, FOV, odt)
% Convert a *.BLK file into a *.nii file.
%  
% DESCRIPTION 
%    This function reads in a *.BLK file that was acquired with the Vdaq software
%    from Optical Imaging Ltd (http://www.opt-imaging.net/) and saves it in the 
%    nifti format (http://nifti.nimh.nih.gov/).
%
%   Be aware, that 
% 
%    Based on the function frame2nii by wolf zinke (2008).
%
% SYNTAX 
%   AOI_blk2nii(blkfile, niifile, frame_rate, FOV, odt)
%
%   Input:
%         <blkfile>     Filename for a *.blk file 
%
%         <niifile>     Filename for the nifit output file
%
%         <frame_rate>  frame rate in seconds 
%
%         <FOV>         Field of view in mm (currently only squared FoV supported)
%
%         <odt>         Data type of output image data
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

if(~exist('blkfile','var') || isempty(blkfile))
    [FileName,PathName] = uigetfile({'*.blk;*.BLK'},'Load Vdaq file');
    blkfile = fullfile(PathName,FileName);
end

if(~exist('niifile','var') || isempty(niifile))
    [PathName,FileName] = fileparts(blkfile);
    niifile = fullfile(PathName,FileName);
else
    [PathName,FileName] = fileparts(niifile);
    niifile = fullfile(PathName,FileName);
end

if(~exist('frame_rate','var') || isempty(frame_rate))
    frame_rate = 1;
end

if(~exist('FOV','var'))
    FOV = [];
end

if(~exist('odt','var'))
    odt = [];
end

% ____________________________________________________________________________ %
%% get the *.blk data
[img_dat, hdr] = AOI_read_vdaq(blkfile, odt);

% ____________________________________________________________________________ %
%% prepare the image header information

% pre-allocate data with the correct matrix dimensions
nii_img = nan([hdr.Width, hdr.Height, 1, hdr.NFrames]); % use this trick to define a z-dimentsion of 1 since it is 2D data

% get pixel size
if(~isempty(FOV))
    if(hdr.Width ~= hdr.Height)
        warning('Currently only equal width and height of FoV supported!');
        pxlsz = 1;
    else
        pxlsz = FOV/hdr.Width;
    end
else
    pxlsz = 1;
end

vxlsz = repmat(pxlsz,1,3);

% determine the data type (this is necessary because the matlab tools for nifti
% can not cope with the data type as string.

switch hdr.dt
    case 'uint8'
        dt = 2;
        
    case 'int16'
        dt = 4;
      
    case 'int32'
        dt = 8;
       
    case 'float32'
        dt = 16;
              
    case 'float64'
        dt = 64;
        
    case 'RGB24'
        dt = 128;
        
    case 'int8'
        dt = 256;
        
    case 'RGB96'
        dt = 511;
        
    case 'uint16'
        dt = 512;
     
    case 'uint32'
        dt = 768;       
end

% ____________________________________________________________________________ %
%% loop over all available conditions and save these in seperate files
for(c = 1:hdr.NConds)
    
    if(hdr.NConds>1)
        cfl = [niifile,'_cnd',sprintf('%02d',c),'.nii'];
    else
        cfl = [niifile,'.nii'];
    end
    
    % prepare nifti data
    nii_img(:,:,1,:) = img_dat(:,:,:,c);
    nii = make_nii(nii_img, vxlsz, [], dt, 'optical imaging frame data');
    
    % adapt header information
    nii.hdr.pixdim(5) = frame_rate;  

    % save the file
    save_nii(nii, cfl);
end


