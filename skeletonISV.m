function skeletonISV( pathData, pathSkeletonISV)
% Function Name:
%    skeletonISV
%
% Description:
%   This function does the skeletonization of ISV, and does pruning
% 
% Pre requisite:
%   Expects MIJI in path of matlab
%
% Inputs:
%   pathData    : Path where binsary ISV images are located
%   pathSkeletonISV : Path where to save ISV skeleton images
%
% Outputs:
%   success: If images were saved.

    if nargin < 2
        error('Need path as an argument');
    end
    warning('off','all');
    warning;
    close all;
    imagefiles  = dir([pathData '*.tif']);      
    nfiles = length(imagefiles); 
    
    if nfiles < 1
         disp('Number of files found is 0');
         disp('Check if file xtension is tif');
         disp('Check if path for data files is correct. Path given:' + pathData);
         error('Program cannot be executed');
    end
    
    for idx = 1:nfiles
       dataName = strcat(pathData, '\\', imagefiles(idx).name);   
       MIJ.run('Open...', strcat('path=[', dataName, ']'));
       MIJ.run('Invert');
       MIJ.run('Skeletonize (2D/3D)');
       MIJ.run('Analyze Particles...', 'size=5-Infinity circularity=0.00-1.00 show=Masks');
	   MIJ.run('Analyze Skel', 'prune=none calculate');
       bw = MIJ.getCurrentImage();
       fileName = strcat(pathSkeletonISV, '\', imagefiles(idx).name);
       bw = uint8(bw / 256);
       bw = im2uint8(bw*255);
       imwrite(bw,fileName,'tif','Compression','none');  
       MIJ.run('Close');
       MIJ.run('Close');
       MIJ.run('Close');
       MIJ.run('Close');
    end

end

