function cleanUp(pathSkelData, pathData, saveDataCleanPath, saveDataPath)   

close all;
cd(pathSkelData)
close all;
imagefiles = dir('*.tif');   

nfiles = length(imagefiles);    % Number of files found

 
    for ii=1:nfiles
       currentfilename = imagefiles(ii).name;
       currentimage = imread(currentfilename);
       currentimage = imcomplement(currentimage);
       fileName = strcat(pathData,'\', currentfilename);
       image = imread(fileName);
       image = imcomplement(image);
       newFileName = strcat(pathISV,'\', currentfilename);
       upStorage = ones(size(currentimage,2),1);
       upStorage = size(currentimage,1)*upStorage;
       downStorage = ones(size(currentimage,2),1);
       
      for i = 1: size(currentimage,2)
        for j = 1 : size(currentimage,1)
            if(currentimage(j,i) > 0)
                upStorage(i) = j;
                break;
            end 
        end
      end
      
       for i = 1:size(currentimage,2)
        for j = size(currentimage,1):-1:1
            if(currentimage(j,i) > 0)
                downStorage(i) = j;
                break;
            end 
        end
       end
     upStorage =  removeOutliers(upStorage, 1);
     downStorage =  removeOutliers(downStorage, -1);
     midStorage = fix((upStorage + downStorage)/2);
       
     img = currentimage;
     img = middleOfBottom(img, midStorage, downStorage);
     %img = oneThirdOfTop(img, midStorage, upStorage);
     
     BW = bwareaopen(img, 75);
     imwrite(BW,newFileName,'tif','Compression','none');
     upStorage = [];
     upStorage = [];
     midStorage = [];
     
    end
  
end

% if looking from top flag is +1
% if looking from bottom flag is -1
function [storage] = removeOutliers(storage, flag)
    
 for i = 2: size(storage,1)
     if(flag == 1)
         if(storage(i) - storage(i-1) > 10)
             storage(i) = storage(i - 1);
         end
     end
     if(flag == -1)
         if(storage(i) - storage(i-1) < -6)
             storage(i) = storage(i - 1);
         end
     end
    
 end
end

function [currentImage] = middleOfBottom(currentImage, midPointArray, downArray)
    midOfBottomAndMiddle = fix((midPointArray+downArray)/2);
    
    for i = 1:size(currentImage,2)
        for j = midPointArray(i):midOfBottomAndMiddle(i)
            currentImage(j,i) = 0;
        end
    end
end
  

function [currentImage] = oneThirdOfTop(currentImage, midPointArray, upArray)
    midOfDownAndMiddle = fix((midPointArray+upArray)/2);
  
    for i = 1:size(currentImage,2)
        for j = midOfDownAndMiddle(i):midPointArray(i)
            currentImage(j,i) = 0;
        end
    end
end

