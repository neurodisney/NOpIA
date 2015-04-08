function [img_dat, hdr] = AOI_read_vdaq(blkfile, odt)
% Read a *.BLK file acquired with Vdaq into Matlab.
%  
% DESCRIPTION 
%    This function reads in a *.BLK file that was acquired with the Vdaq software
%    from Optical Imaging Ltd (http://www.opt-imaging.net/).
%
%    Based on the function in the Sunin34H031 toolbox by the courtesy of the
%    Roe-Lab and based on matlab code provided by Sagi Reuven from Optical
%    Imaging Ltd.
% 
% SYNTAX 
% [img_dat, hdr] = OI_read_vdaq(blkfile)
%
%   Input:
%         <blkfile>   Filename for a *.blk file 
%
%         <odt>       Data type of output image data
%
%   Output:
%         <img_dat>   4D matrix that contains the image data. 
%                     format: [x, y, time,condition
%                     
%         <hdr>  structure with basic header information of the *.blk file.
% REFERENCES 
%
% ......................................................................... 
% wolf zinke, wolfzinke@gmail.com 
%
% wolf zinke, 06.04.2015
%

% ____________________________________________________________________________ %
%% check input data, get file name is required
if(~exist('blkfile','var') || isempty(blkfile))
    [FileName,PathName] = uigetfile({'*.blk;*.BLK'},'Load Vdaq file');
    blkfile = fullfile(PathName,FileName);
end

if(~exist('odt','var'))
    odt = [];
end

% ____________________________________________________________________________ %
%% Read in the header information
fid = fopen(blkfile, 'r');

% DATA INTEGRITY 		
hdr.FileSize		  = fread(fid,1,'long');
hdr.CheckSum_Header   = fread(fid,1,'long'); % beginning with the lLen Header field
hdr.CheckSum_Data	  = fread(fid,1,'long');

hdr.LenHeader		  = fread(fid,1,'long');
hdr.VersionID		  = fread(fid,1,'float');
hdr.FileType		  = fread(fid,1,'long'); % RAWBLOCK_FILE: 11; DCBLOCK_FILE: 12; SUM_FILE: 13
hdr.FileSubtype	      = fread(fid,1,'long'); % FROM_VDAQ: 11; FROM_ORA: 12; FROM_DYEDAQ: 13

hdr.DataType          = fread(fid,1,'long');        
hdr.SizeOf            = fread(fid,1,'long');    
hdr.Width             = fread(fid,1,'long');    
hdr.Height            = fread(fid,1,'long');     
hdr.NFrames           = fread(fid,1,'long');  
hdr.NConds            = fread(fid,1,'long');       

hdr.InitialXBinFactor = fread(fid,1,'long'); % from data acquisition
hdr.InitialYBinFactor = fread(fid,1,'long'); % from data acquisition
hdr.XBinFactor        = fread(fid,1,'long'); % this file
hdr.YBinFactor        = fread(fid,1,'long'); % this file

hdr.UserName          = fread(fid,32,'*char')';
hdr.RecordingDate     = fread(fid,16,'*char')';

hdr.X1ROI             = fread(fid,1,'long');
hdr.Y1ROI             = fread(fid,1,'long');
hdr.X2ROI             = fread(fid,1,'long');
hdr.Y2ROI             = fread(fid,1,'long');

% LOCATE DATA AND REF FRAMES 	
hdr.StimOffs          = fread(fid,1,'long');
hdr.StimSize          = fread(fid,1,'long');
hdr.FrameOffs         = fread(fid,1,'long');
hdr.FrameSize         = fread(fid,1,'long');
hdr.RefOffs           = fread(fid,1,'long');
hdr.RefSize           = fread(fid,1,'long');          
hdr.RefWidth          = fread(fid,1,'long');
hdr.RefHeight         = fread(fid,1,'long');

hdr.WhichBlocks       = fread(fid,16,'ushort');
hdr.WhichFrames       = fread(fid,16,'ushort');

% DATA ANALYSIS		
hdr.LoClip            = fread(fid,1,'long');    
hdr.HiClip            = fread(fid,1,'long');     
hdr.LoPass            = fread(fid,1,'long');
hdr.HiPass            = fread(fid,1,'long');
hdr.OperationsPerformed = fread(fid,64,'*char')';

% ORA-SPECIFIC		
hdr.Magnification     = fread(fid,1,'float');
hdr.Gain              = fread(fid,1,'ushort');
hdr.Wavelength        = fread(fid,1,'ushort');
hdr.ExposureTime      = fread(fid,1,'long');
hdr.NRepetitions      = fread(fid,1,'long');
hdr.AcquisitionDelay  = fread(fid,1,'long');
hdr.InterStimInterval = fread(fid,1,'long');
hdr.CreationDate      = fread(fid,16,'char');
hdr.DataFilename      = fread(fid,64,'char');     
hdr.OraReserved       = fread(fid,256,'char');

hdr.IncludesRefFrame  = fread(fid,1,'long');
hdr.ListOfStimuli     = fread(fid,256,'*char')';
hdr.NVideoFramesPerDataFrame = fread(fid,1,'long');
hdr.NTrials           = fread(fid,1,'long');
hdr.ScaleFactor       = fread(fid,1,'long');

hdr.MeanAmpGain       = fread(fid,1,'float');       
hdr.MeanAmpDC         = fread(fid,1,'float');  

hdr.VdaqReserved      = fread(fid,256,'*char')';
hdr.User              = fread(fid,256,'*char')';
hdr.Comment           = fread(fid,256,'*char')';

fclose(fid);

% ____________________________________________________________________________ %
%% derive information about the data format
switch hdr.DataType
    case 11
        nbytes = 1;
        datatype = 'uchar';
        if(isempty(odt))
            odt = 'uint8'; 
        end
    case 12
        nbytes = 2;
        datatype = 'ushort';
        if(isempty(odt))
            odt = 'uint16'; 
        end
    case 13
        disp('warning: reading longs as ulongs')
        nbytes = 4;
        datatype = 'ulong';
        if(isempty(odt)) 
            odt = 'uint32'; 
        end
    case 14
        nbytes = 4;
        datatype = 'float';
        if(isempty(odt)) 
            odt = 'single'; 
        end
    otherwise
        error([num2str(hdr.DataType) ' is an unrecognized data type - has to be 11, 12, 23, or 14!'])
end

% ____________________________________________________________________________ %
%% check for dat consistencies
if(hdr.FrameSize ~= hdr.Width*hdr.Height*nbytes)
    disp('BAD HEADER!!! framesize does not match framewidth*frameheight*nbytes!');
    hdr.FrameSize  = ni*nj*nbytes;
end

% DIFFERENTIAL CAMERA? (then each condition stores one reference image
% between the differential data)
IncRefFrame = ( (hdr.FileSize-hdr.LenHeader) > (hdr.FrameSize*hdr.NFrames*hdr.NConds) );

if(IncRefFrame ~= hdr.IncludesRefFrame)
    warning('Mismatch in information about included reference frame!');
end

if(IncRefFrame)
    error('Current implementation does not account for a reference frame. Code needs to be adapted now!');
end

% ____________________________________________________________________________ %
%% read the image data
hdr.dt = odt;  % data type of image format

[file, msg] = fopen(blkfile, 'r', 'l'); %assume files are little-endian (PC or VAX)
if(file == -1)
    error(msg); 
end

fseek(fid, hdr.LenHeader, 'bof'); % skip 1716 byte header for VDAQ system (hdr.StimOffs)

imgblk = [hdr.Width*hdr.Height*hdr.NFrames*hdr.NConds];

img_dat = fread(fid,imgblk,[datatype,'=>',odt]); 
fclose(file);

% ____________________________________________________________________________ %
%% reshape vector into 4D array
img_dat = reshape(img_dat, hdr.Width,hdr.Height,hdr.NFrames,hdr.NConds);
img_dat = permute(img_dat, [2,1,3,4]);






