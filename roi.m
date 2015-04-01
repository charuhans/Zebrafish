function ROI(saveAnatomyData, saveAnatomyBW, saveIsolateData, saveIsolateBW)
% Function Name:
%    ROI
%
% Description:
%   This function does the segmentation of whole embryo
% 
% Pre requisite:
%   Expects MIJI in path of matlab
%
% Inputs:
%   saveAnatomyData: Path where images are located
%   saveAnatomyBW  : Path where to save images
%   saveIsolateData: Path to individual zebrafish images
%   saveIsolateBW  : Path to individual zebrafish binary images

    if nargin < 4
        error('Need path as an argument');
    end 
    close all;
    imagefiles  = dir([saveAnatomyBW '*.tif']);   
    nfiles = length(imagefiles); 
    
    if nfiles < 1
         disp('Number of files found is 0');
         disp('Check if file xtension is tif');
         disp('Check if path for data files is correct. Path given:' + saveAnatomyBW);
         error('Program cannot be executed');
    end
 
    for idx = 1:nfiles
        currentfilename = strcat(saveAnatomyBW, '\', imagefiles(idx).name);     
        currentimage = imread(currentfilename);
        if(~isValidImage(currentimage))
            continue;
        end
        newFileName = strcat(saveAnatomyData, '\', imagefiles(idx).name);

        newImage = imread(newFileName);
        if(~isValidImage(newImage))
            continue;
        end
        BW = im2bw(currentimage,0.01);
        stats = regionprops(BW, 'Area', 'PixelIdxList', 'PixelList', 'BoundingBox', 'Orientation');
        width = stats(1).BoundingBox(1,3);
        neMin = 1;
        
        for region = 1 : length(stats)
            if(width < stats(region).BoundingBox(1,3))
                width = stats(region).BoundingBox(1,3);
                neMin = region;
            end
        end
        
        for region = 1 : length(stats)
            if(region ~= neMin)
%                 X = stats(region).PixelList(:,1);
%                 Y = stats(region).PixelList(:,2);
%                  for x = 1:  size(X,1)
%                      newImage(Y(x),X(x)) = 0;   
%                      currentimage(Y(x),X(x)) = 0;  
%                  end
                 newImage(Y, X)  = 0;
                 currentimage(Y, X)  = 0;
            end
        end
        newX = int32(stats(neMin).BoundingBox(1,1));
        newY = int32(stats(neMin).BoundingBox(1,2));
        newWidth = int32(stats(neMin).BoundingBox(1,3));
        newHeight = int32(stats(neMin).BoundingBox(1,4));
        newDimenssions = [isValid(newX, -75, 0), isValid(newY, -75, 0), isValid(newWidth , 160, size(currentimage,2)), isValid(newHeight, 120, size(currentimage,1))];
        subImage = imcrop(newImage, newDimenssions);
        subImageBW = imcrop(currentimage, newDimenssions);
        
        newImageNameWriteBW = strcat(saveIsolateBW,'\', imagefiles(idx).name);
        newImageNameWrite = strcat(saveIsolateData,'\', imagefiles(idx).name);
        
        imwrite(subImageBW,newImageNameWriteBW,'tif','Compression','none');
        imwrite(subImage,newImageNameWrite,'tif','Compression','none');
    end
end

function valid = isValidImage(img)

    if(isempty(img) ||  size(find(img == 255),1) == (size(img,1) * size(img,2)))
         valid = false;
    else
        valid = true;
    end
end


function newValue = isValid(value, range, limit)
    if(range < 0 )
        cond = value - (value + range);
    else
        cond = (value + range) - range;
    end    
    if(cond < limit)
        range = range - 1;
    end
    newValue = value + range;
end
         