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

if(~exist('bmpfile','var') || isempty(blkfile))
    [FileName,PathName] = uigetfile({'*.bmp'},'Load bitmap file');
    blkfile = fullfile(PathName,FileName);
end

if(~exist('niifile','var') || isempty(niifile))
    [PathName,FileName] = fileparts(blkfile);
    niifile = fullfile(PathName,FileName);
else
    [PathName,FileName] = fileparts(niifile);
    niifile = fullfile(PathName,FileName);
end

if(~exist('FOV','var'))
    FOV = [];
end

if(~exist('odt','var'))
    odt = [];
end

