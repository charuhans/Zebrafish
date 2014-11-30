function anatomyExtraction1(pathData, pathWholeBW, saveDataPath, saveBWPath)   
    warning('off','all');
    warning;
    close all;
     cd(pathData);
    imagefiles = dir('*.tif');   
    nfiles = length(imagefiles);    % Number of files found
    
    for ii=1:nfiles
        % read original gray image
       currentfilename = imagefiles(ii).name;
       dataImage = imread(currentfilename);
       
       
       
       % read whole binary image
       fileName = strcat(pathWholeBW, '\', currentfilename);
       BwWholeImage = imread(fileName);
       
       
       BwWhole = im2bw(BwWholeImage,0.01);
       %stats = regionprops(BW, 'Area', 'PixelIdxList', 'PixelList', 'BoundingBox', 'Orientation');
       stats = regionprops(BwWhole, 'Area', 'PixelIdxList', 'PixelList', 'BoundingBox', 'Orientation');
       
       for regionAll = 1 : length(stats)
           
              [ bwSubImageRotated, subImageRotated] = eliminateBoundaryData( regionAll, stats, BwWhole, dataImage);
              
              bwSubImageRotated = im2bw(bwSubImageRotated,0.01);
              statsSub = regionprops(bwSubImageRotated, 'Area',  'PixelList');
              
              % keep largest blob
              %[bwSubImageRotated, subImageRotated] = keepLargestBlob(bwSubImageRotated, subImageRotated, statsSub);
                  
              bwNewImageNameWrite = strcat(saveBWPath, '\','N', num2str(regionAll), '-', currentfilename);
              newImageNameWrite = strcat(saveDataPath, '\', 'N', num2str(regionAll), '-', currentfilename);
              if(max(max(subImageRotated)) > 10)
                  subImageRotated=subImageRotated-min(subImageRotated(:)); % shift data such that the smallest element of A is 0
                  subImageRotated=subImageRotated/max(subImageRotated(:)); % normalize the shifted data to 1 
                  
                  %imshow(subImageRotated);
                  imwrite(subImageRotated,newImageNameWrite,'tif','Compression','none');                        
                  imwrite(bwSubImageRotated,bwNewImageNameWrite,'tif','Compression','none');
              end
            
        end
             %imwrite(BW,currentfilename,'tif','Compression','none');
             %imwrite(dataImage,newFileName,'tif','Compression','none');
    end
    
end


function [ bwSubImageRotated, subImageRotated] = eliminateBoundaryData( regionAll, stats, BwWhole, dataImage)

bwSubImageRotated= [];
subImageRotated = [];
X = stats(regionAll).PixelList(:,1);
Y = stats(regionAll).PixelList(:,2);

% get boundary condition
anyX0 = any(X == 1);anyY0 = any(Y == 1);anyXw = any(X == size(BwWhole,2));anyYh = any(Y == size(BwWhole,1));

% elminate boundary data from 3 images
if (stats(regionAll).Area < 30000 || stats(regionAll).Area > 145000 || anyX0 ~= 0 || anyY0 ~= 0|| anyXw ~= 0|| anyYh ~= 0)  

    for x = 1:  size(X,1)
         BwWhole(Y(x),X(x)) = 0;   
         %BW(Y(x),X(x)) = 0;
         dataImage(Y(x),X(x)) = 0;
    end

else
     [bwSubImageRotated, subImageRotated] = cropRotate(regionAll, stats, dataImage, BwWhole);                

end 
end

function [bwSubImageRotated, subImageRotated] = cropRotate(regionAll, stats, dataImage, BwWhole)


% get bounding box diminssion of remaining data 
newDimenssions = [stats(regionAll).BoundingBox(1,1)  , stats(regionAll).BoundingBox(1,2) , stats(regionAll).BoundingBox(1,3)  + 5, stats(regionAll).BoundingBox(1,4) + 5];
% crop wholeBW image

% crop the BWImage
bwWholeSubImage = imcrop(BwWhole, newDimenssions);
% crop the BWImage
%bwSubImage = imcrop(BWImage, newDimenssions);
% crop the dataImage
subImage = imcrop(dataImage, newDimenssions);
bwWholeSubImage = im2bw(bwWholeSubImage,0.01);
statsWhole = regionprops(bwWholeSubImage, 'Area',  'PixelList');

[bwSubImageRotated, subImageRotated] = keepLargestBlob(bwWholeSubImage, subImage, statsWhole);

% rotate the BWImage to align the image
bwSubImageRotated = imrotate(bwSubImageRotated,-(stats(regionAll).Orientation));

% crop and rotate data image with same dimenssion and
% angle

subImageRotated = imrotate(subImageRotated,-(stats(regionAll).Orientation));
end

function [bwSubImageRotated1, subImageRotated1] = keepLargestBlob(bwSubImageRotated, subImageRotated, statsSub)

bwSubImageRotated1 = zeros(size(bwSubImageRotated, 1), size(bwSubImageRotated, 2), 1); 
subImageRotated1 = zeros(size(subImageRotated, 1), size(subImageRotated, 2), 1);
if(size(statsSub,1) > 1)
  areaCount = statsSub(1).Area;
  neMax = 1;

  for regionCount = 2 : length(statsSub)
    if(areaCount < statsSub(regionCount).Area)
        areaCount = statsSub(regionCount).Area;
        neMax = regionCount;
    end
  end
  for regionSub = 1 : length(statsSub)
        if(regionSub == neMax)
            
            X = statsSub(regionSub).PixelList(:,1);
            Y = statsSub(regionSub).PixelList(:,2);
            
%             for i = 1: size(bwSubImageRotated,2)
%                 for j = 1: size(bwSubImageRotated,1)
%                     for x = 1: size(X,1)
%                         if( j ~= Y(x) && i ~= X(x))
%                             bwSubImageRotated(j,i) = 0;
%                             subImageRotated(j,i) = 0;
%                         end
%                     end
%                 end
%             end

              for x = 1: size(X,1)
                  bwSubImageRotated1(Y(x),X(x)) = bwSubImageRotated(Y(x),X(x));   
                  subImageRotated1(Y(x),X(x)) = subImageRotated(Y(x),X(x));  
              end
        end
  end

else
    X = statsSub(1).PixelList(:,1);
    Y = statsSub(1).PixelList(:,2);
     for x = 1: size(X,1)
                  bwSubImageRotated1(Y(x),X(x)) = bwSubImageRotated(Y(x),X(x));   
                  subImageRotated1(Y(x),X(x)) = subImageRotated(Y(x),X(x));  
     end
end
    
end