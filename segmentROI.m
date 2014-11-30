function segmentROI( pathIsolateData, pathIsolateBW, pathISVData)
close all;
cd(pathIsolateBW)
close all;
imagefiles = dir('*.tif');   

nfiles = length(imagefiles);    % Number of files found

 
    for ii=1:nfiles
       currentfilename = imagefiles(ii).name;
       currentimage = imread(currentfilename);
       newFileName = strcat(pathIsolateData,'\', currentfilename);
       
       newImage = imread(newFileName);
       
        % store the value of lower side of DA
       indexForMax = maxIndex(currentimage);
       % find cut value for DA in index
       cutValue = findCutValueForDA(currentimage, indexForMax);
       % get the da region
       daRegion = findDARegion(currentimage, cutValue);
     
       BWDAregion = im2bw(daRegion, 0.5);
       stats = regionprops(BWDAregion, 'Area', 'PixelIdxList');
       %%%subImageThreshold = imcrop(newImage,[1.5*size(newImage,2)/3 (2.0*size(newImage,1))/3 50 50]);
       %%%value = max(max(subImageThreshold));
       %[svals,idx] = sort(subImageThreshold(:),'descend'); % sort to vector
       %[value,i] = max(svals(svals~=max(svals)));
       %value
       %if(value > 30)
       %%%if(value > 10)
           %%%value = 10;
       %%%end
       
       for region = 1 : length(stats)
            if stats(region).Area < 500
             BWDAregion(stats(region).PixelIdxList) = 0;
            end
        end
       % work with daregion, find index for dargion       
       indexForMin = minIndex(BWDAregion);
       %find area above DA    
       aboveDAImage = findAreaAboveDA(newImage, indexForMin, 2);  %%%value is passed here
       %imshow(aboveDAImage);
      
       
     
       s = aboveDAImage;
       s = s - min(min(s));
       s = s/max(max(s))*255;
       s = uint8(s);  % Change to integer unit
       %cmap = colormap('gray');
       %imwrite(s, cmap, newImageNameWriteProcessO,'tif','Compression','none');
    
      
      
      currentimage1 = flipdim(currentimage ,1);
      newImage1 = flipdim(newImage ,1);
      indexForMax1 = maxIndex(currentimage1);
       % find cut value for DA in index
       cutValue1 = findCutValueForDA(currentimage1, indexForMax1);
       % get the da region
       daRegion1 = findDARegion(currentimage1, cutValue1);
       
       BWDAregion1 = im2bw(daRegion1, 0.5);
       stats1 = regionprops(BWDAregion1, 'Area', 'PixelIdxList');
     
       for region1 = 1 : length(stats1)
            if stats1(region1).Area < 500
             BWDAregion1(stats1(region1).PixelIdxList) = 0;
            end
        end
       % work with daregion, find index for dargion       
       indexForMin1 = minIndex(BWDAregion1);
       %find area above DA    
       aboveDAImage1 = findAreaAboveDA(newImage1, indexForMin1, 2);  %%%value is passed here
       s1 = aboveDAImage1;
       s1 = s1 - min(min(s1));
       s1 = s1/max(max(s1))*255;
       s1 = uint8(s1);  % Change to integer unit
       %cmap = colormap('gray');
       %imwrite(s, cmap, newImageNameWriteProcessO,'tif','Compression','none');
        newImageNameWriteProcessO = strcat(pathISVData, '\', currentfilename);
        [countNoFlip] = find( s > 1);
        [countWithFlip] = find( s1 > 1);
        if(size(countNoFlip,1) - size(countWithFlip,1) > 200)
            
            imwrite(s,newImageNameWriteProcessO,'tif','Compression','none', 'ColorSpace', 'rgb');
        else
            imwrite(s1,newImageNameWriteProcessO,'tif','Compression','none', 'ColorSpace', 'rgb');
        end
            
      
     
     % imwrite(s,newImageNameWriteProcessO,'tif','Compression','none', 'ColorSpace', 'rgb');
      % if there is an increase with lipping, flip image
       
       
    end
end

function [cutValue] = findCutValueForDA(image, index)

% scan from below increase x, the for each x increase y
% store x, y postion for which, diff(yprev - ynow) > 50
% from ynow, decrese y till black pixel is hit, y 
% remove all pixels previous to 
    cutValue = 0;
    for k = size(index,1):-1:11
        val1 = index(k,2);
        val2 = index(k-10,2);
        if(val1 - val2 > 25)
            cutValue = index(k - 10,1);
            break;
        end
    end
end

function [daRegion] = findDARegion(image, cutValue)

    daRegion = image;
    for i = 1: cutValue
        for j = 1: size(image,1)
            daRegion(j,i) = 0;
        end
    end
    
end

function index = minIndex(closeBW)
    k = 1;
    index = [];
    flag = 0;
    for i = 1: size(closeBW,2)
        for j = 1 : size(closeBW,1)
            if(closeBW(j,i) > 0)
                index(k,1) = i;
                index(k,2) = j + 4 ;
                %flag = 1;3
                k = k + 1;
                break;
            end 
        end
       % if(flag == 0)
        %    index(k,1) = i;
       %     index(k,2) = index(k - 1,2);
        %    k = k + 1;
        %end
       %flag = 0;
    end
end 

function  index = maxIndex(closeBW)
    k = 1; 
    index = [];
    for i = 1: size(closeBW,2)
        %for j = size(closeBW,1):-1:1
         for j = 1:size(closeBW,1)
            if(closeBW(j,i) > 0)
                index(k,1) = i;
                index(k,2) = j;
                %flag = 1;
                k = k + 1;
                break;
            end 
        end
    end
end

function output = findAreaAboveDA(image, index, value)
output = zeros(size(image,1), size(image,2));
    for k = 1:size(index,1)
        for i = 1: index(k,2)
            if(image(i, index(k,1))> value) && index(k,1)> (size(image,2)/4 - 50)
                output(i, index(k,1)) = image(i, index(k,1));
            end
        end
    end
    %output = ~bwareaopen(~output, 50);
end
