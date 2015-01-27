function IntialRoiExtraction( pathData, saveWholeBW)
% Function Name:
%    IntialRoiExtraction
%
% Description:
%   This function does the segmenattion of whole embryo
% 
% Pre requisite:
%   Expects MIJI in path of matlab
%
% Inputs:
%   pathData    : Path where images are located
%   saveWholeBW : Path where to save images
%
% Outputs:
%   success: If images were saved.

    if nargin < 2
        disp('Need path as an argument');
        return;
    end
    warning('off','all');
    warning;
    close all;
    imagefiles  = dir([pathData '*.tif']);      
    nfiles = length(imagefiles); 
    
    if nfiles < 1
         warning('Number of files found is 0');
         warning('Check if file xtension is tif');
         warning('Check if path for data files is correct. Path given:' + pathData);
         return;
    end
    
    for idx = 1:nfiles
        dataName = strcat(pathData, '\\', imagefiles(idx).name);
        data = imread(dataName);
        img8 = uint8(data / 256);
        imwrite(img8,dataName,'tif','Compression','none');     
    end
    
    for idx = 1:nfiles
       dataName = strcat(pathData, '\\', imagefiles(idx).name);       
       MIJ.run('Open...', dataName);
       MIJ.run('Gaussian Blur...', 'sigma=[10]');
       MIJ.run('Enhance Contrast...', 'saturated = [10] normalize');
       MIJ.run('Auto Threshold', 'method = Triangle background = Light calculate black');
       MIJ.run('Convert to Mask');
       MIJ.run('Fill Holes');
       MIJ.run('Invert');
       bw = MIJ.getCurrentImage();
       fileName = strcat(saveWholeBW, '\', imagefiles(idx).name);
       imwrite(bw,fileName,'tif','Compression','none');       
    end

end

