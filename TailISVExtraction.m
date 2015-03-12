function TailISVExtraction(saveIsolateData, initialSegBW, saveISVData, saveSkeleton)
% Function Name:
%    TailExtraction
%
% Description:
%   This function does the tail segmentation and computes ISV skeleton 
% 
% Pre requisite:
%   Expects MIJI in path of matlab
%
% Inputs:
%   saveIsolateData: Path to individual isolated images
%   initialSegBW   : Path where to save binary images for tail + head
%   saveISVData    :  Path to isv images
%   saveSkeleton   : Path to head + tail skeleton

   if nargin < 4
        error('Need path as an argument');
    end 
    warning('off','all');
    warning;
    close all;
    imagefiles  = dir([saveIsolateData '*.tif']);      
    nfiles = length(imagefiles); 
    
    if nfiles < 1
         disp('Number of files found is 0');
         disp('Check if file xtension is tif');
         disp('Check if path for data files is correct. Path given:' + saveIsolateData);
         error('Program cannot be executed');
    end
    
    for idx = 1:nfiles        
        dataName = strcat(saveIsolateData, imagefiles(idx).name);
        MIJ.run('Open...', strcat('path=[', dataName, ']'));
        MIJ.run('Enhance Contrast...', 'saturated=[15] normalize');
        MIJ.run('Gaussian Blur...', 'sigma=[6]');
        MIJ.run('Auto Threshold', 'method=Intermodes background=Light calculate black');
        MIJ.run('Convert to Mask');
	    MIJ.run('Analyze Particles...', 'size=150-Infinity circularity=0.00-1.00 show=Masks');
        MIJ.run('Fill Holes');
        fileName = strcat(initialSegBW, imagefiles(idx).name);
        image = MIJ.getCurrentImage();
        image = uint8(255*mat2gray(image));
        imwrite(image,fileName,'tif','Compression','none');
        
        MIJ.run('Smooth');
		MIJ.run('Skeletonize (2D/3D)');
        MIJ.run('Invert');
        fileNameSkel = strcat(saveSkeleton, imagefiles(idx).name);
        image = MIJ.getCurrentImage();
        image = uint8(255*mat2gray(image));
        imwrite(image,fileNameSkel,'tif','Compression','none');   
        
        MIJ.run('Close');       
        MIJ.run('Close');        
        
        MIJ.run('Open...', strcat('path=[', dataName, ']'));
        MIJ.run('Enhance Contrast...', 'saturated=[15] normalize');
        image = MIJ.getCurrentImage();
        image = uint8(255*mat2gray(image));
        imwrite(image,dataName,'tif','Compression','none');
        MIJ.run('Close');
        
        currentimage1 = imread(fileName);
        currentimage1 = logical(currentimage1);
        currentimage2 = imread(dataName);
        currentimage2(currentimage1) = 0;
        fileNameISV = strcat(saveISVData, imagefiles(idx).name);
        imwrite(currentimage2,fileNameISV,'tif','Compression','none');  
        
        
    end