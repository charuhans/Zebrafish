function caudalVein(skelFolder, saveIsolateData, initialSegBW, saveCV)

% Function Name:
%    caudalVein
%
% Description:
%   This function does the segmentation of caudalVein region
% 
%
% Inputs:
%   saveIsolateData : Path to individual isolated images
%   skelFolder      : Path to head + tail skeleton
%   initialSegBW    : Path where to save binary images for tail + head
%   saveCV          : Path to save cv images

    if nargin < 4
        error('Need path as an argument');
    end 
    warning('off','all');
    warning;
    close all;    
    imagefiles  = dir([skelFolder '*.tif']);      
    nfiles = length(imagefiles); 
    
    if nfiles < 1
         disp('Number of files found is 0');
         disp('Check if file xtension is tif');
         disp('Check if path for data files is correct. Path given:' + skelFolder);
         error('Program cannot be executed');
    end    
    
    for ii=1:nfiles
        % read original gray image
        currentfilename = strcat(skelFolder, '\', imagefiles(ii).name);     
        skelImage = imread(currentfilename);    
        %currentfilename = imagefiles(ii).name;
        %skelImage = imread(currentfilename);
        fileName = strcat( saveIsolateData, '\', imagefiles(ii).name);
        dataImage = imread(fileName);
        fileNameBW = strcat(initialSegBW, '\', imagefiles(ii).name);
        BWImage = imread(fileNameBW);
        %fprintf('image name: %s \n', imagefiles(ii).name);
        newDatatImage = dataImage;
        newDatatImage(~BWImage) = 0;
        clean = remove(skelImage, newDatatImage);        
        newImageWrite = strcat(saveCV, '\',imagefiles(ii).name);
        A = uint8(255*mat2gray(clean));
        imwrite(A,newImageWrite,'tif','Compression','none'); 
    end

end

function newImage = remove(img, realImg)
% Function Name:
%    remove
%
% Description:
%   This function removes the head region based on skeleton
% 
%
% Inputs:
%   img      : skeleton image
%   realImg  : Path to image
% Output:
%   newImage: image without head

    whitePixelArray_up = [];
    whitePixelArray_down = [];

    %scan the image from  top and store white pixels indices in an array
    for y = 1:size(img,2)
        for x  = 1:size(img,1)
            val = img(x,y);
            if(val == 0)
                whitePixelArray_up = [ whitePixelArray_up; x y 0];
                break;
            end
        end
    end

    %scan the image from  bottom and store white pixels indices in an array
    for y = 1:size(img,2)
        for x  = size(img,1):-1:1
            val = img(x,y);
            if(val == 0)
                whitePixelArray_down = [ whitePixelArray_down; x y 0];
                break;
            end
        end
    end

    %we scanned from top and we have the distance between two points
    whitePixelArray_up = distance(whitePixelArray_up);

    %we scanned from bottom and we have the distance between two points
    whitePixelArray_down = distance(whitePixelArray_down);


    %max distance between points when looking from top
    max_up = max(whitePixelArray_up(:,3));

    %max distance between points when looking from down
    max_down = max(whitePixelArray_down(:,3));

    if(max_up > max_down)
        %we need to clean the top side
        x_index = find(whitePixelArray_up(:,3)== max_up);
        XY = [whitePixelArray_up(x_index,1) whitePixelArray_up(x_index,2)];    
        isTop = 1;
    else
        %we need to clean the down side
        x_index = find(whitePixelArray_down(:,3)== max_down);
        XY = [whitePixelArray_down(x_index,1) whitePixelArray_down(x_index,2)];
        isTop = 0;
    end

    %now lets find which way is the head pointed, closer to zero or closer to
    %image width
    if(dist(1,XY(1,2)) < dist(size(img,2),XY(1,2)))
        %head is closer to image zero, clean everything from zero to this point
        for i = 1 : XY(1,2) + 100
            for j = 1 : size(img,1)
                %clean real Image
                realImg(j,i) = 0; %or 255 whatever is correct
            end
        end
        isOrigin = 1;

        %lets clean the other side of the fish image too, opposite to head
        %section. this is closer to image width
        max_x_closeToWidth = max(whitePixelArray_up(:,2));
        for x_dim = max_x_closeToWidth: size(realImg,2)
            for y_dim = 1 : size(realImg, 1) %min_y_closeToZero
                realImg(y_dim,x_dim) = 0;
            end
        end
    else
        %head is closer to image width
        for i = XY(1,2) - 100: size(img,2)
            for j = 1 : size(img,1)
                %clean real Image
                realImg(j, i) = 0; %or 255 whatever is correct
            end
        end
        isOrigin = 0;
        %lets clean the other side of the fish image too, opposite to head
        %section. this is closer to image zero width
        min_x_closeToZero = min(whitePixelArray_up(:,2));
        for x_dim = 1 : min_x_closeToZero
            for y_dim = 1 : size(realImg, 1) %min_y_closeToZero
                realImg(y_dim,x_dim) = 0;
            end
        end
    end

    [bwImg, realImg] = bwlargestblob(realImg,4);
    index = findIndex(bwImg, isTop, isOrigin);


    % compute slope
    slope = gradient(index(:,2))./gradient(index(:,1));
    %smooth slope
    smoothSlope = smooth(slope, 25);
    % keep slopeds around center (centre - 100, centre + 100)
    shift = 75;
    centre = fix(size(smoothSlope,1))/2;
    if (centre - shift < 0)
        shift = fix(size(smoothSlope,1))/2 - 10;
        subsetSmoothSlope = smoothSlope(centre - shift: centre + shift , 1);
    else
        subsetSmoothSlope = smoothSlope(centre - shift: centre + shift , 1);
    end
    % find local min and max on subset
    subsetSmoothSlope = smooth(subsetSmoothSlope, 25);
    [ymax,imax,ymin,imin] = extrema(subsetSmoothSlope);
    location = caudalVeinPoint(ymax,imax,ymin,imin);
    % if transdormed location lies near edges
    if (location > 125 || location < 25)
        transforedLocation = centre;
    else
        transforedLocation = location + centre - shift;
    end


    if(~isOrigin)
        newDimenssions = [0,0,transforedLocation, size(realImg,1)];
        newImage = imcrop(realImg, newDimenssions);
    else
        newDimenssions = [transforedLocation, 0, size(realImg,2) - transforedLocation, size(realImg,1)];
        newImage = imcrop(realImg, newDimenssions);
    end

end

function [arr] = distance(arr)
% Function Name:
%    distance
%
% Description:
%   Compute euclidean distance between pair of array element
% 
%
% Inputs:
%   arr  : elemnts of image
% Output
%   arr  : elemnts of image with airwise diatance

    for x = 2 : size(arr,1)
        Array = [arr(x-1,1) arr(x-1, 2); arr(x,1) arr(x, 2)];
        distance = pdist(Array,'euclidean');
        arr(x,3) = distance;
    end
end

function [bwWholeSubImage, dataImg] = bwlargestblob(im,connectivity)
% Function Name:
%    bwlargestblob
%
% Description:
%   Find largest blob
% 
%
% Input:
%   im  : input image
%   connectivity: image connectivity
% Output
%   dataImg  : cropped image keepig largest blob
%   bwWholeSubImage  : cropped binary image keepig largest blob
    
    dataImg = im;
    if size(im,3)>1,
        error('bwlargestblob accepts only 2 dimensional images');
    end

    [imlabel totalLabels] = bwlabel(im,connectivity);
    sizeBlob = zeros(1,totalLabels);

    for i=1:totalLabels,
        sizeBlob(i) = length(find(imlabel==i));
    end
    [~, largestBlobNo] = max(sizeBlob);

    outim = zeros(size(im),'uint8');
    outim(imlabel==largestBlobNo) = 1;
    stats = regionprops(outim,'BoundingBox');
    newDimenssions = [stats(1).BoundingBox(1,1)  , stats(1).BoundingBox(1,2) , stats(1).BoundingBox(1,3), stats(1).BoundingBox(1,4)];
    % crop wholeBW image

    % crop the BWImage
    bwWholeSubImage = imcrop(outim, newDimenssions);
    dataImg = imcrop(dataImg, newDimenssions);
    bwWholeSubImage = 255*bwWholeSubImage;
    end

function index =  findIndex(im, isTop, isOrigin)
% Function Name:
%    findIndex
%
% Description:
%   Find largest blob
% 
%
% Input:
%   im      : input image
%   isTop   : if tail faces top
%   isOrigin: if head is near origin
% Output
%   index  : where head meets tail region

    if(isTop == 0)
        startIndex = size(im,1);
        rateIndex  = -1;
        endIndex = 1;
    else
        startIndex = 1;
        rateIndex  = 1;
        endIndex = size(im,1);
    end

    k = 1;
    index = [];
    for i = 1: size(im,2)
        for j = startIndex:rateIndex:endIndex
            if(im(j,i) > 0)
                index(k,1) = i;
                index(k,2) = j;
                k = k + 1;
                break;
            end
        end
    end    
end

 function location = caudalVeinPoint(ymax,imax,ymin,imin) 
% Function Name:
%    caudalVeinPoint
%
% Description:
%   Compute point of caudal vain start
% 
%
% Inputs:
%   ymax  : maxima in y direction for slope
%   ymin  : minima in y direction for slope
%   imax  : maxima in x direction for slope
%   imin  : minima in x direction for slope
% Output
%   location  : point where caudal vein starts

    % start with size of maximum
    % for each element find an element close to max >
    % find an element close to max <
    allDifference = [];
    for i = 1:size(imax,1)
        lessIndex = sort(imin(imin < imax(i,1)));
        moreIndex = sort(imin(imin > imax(i,1)));

        % find which has maximum difference store that
        changeBelow = -50; 
        changeAbove = -50;
        if size(lessIndex, 1) > 0
            minBelow = ymin(imin == lessIndex(size(lessIndex, 1),1));
            changeBelow = ymax(imax  == imax(i,1)) - minBelow;
        end

        if size(moreIndex,1) > 0
            minAbove = ymin(find(imin == moreIndex(1, 1),1));
            changeAbove = ymax(imax == imax(i,1)) - minAbove;
        end
        % find the max among both and store the location of max an min
        change = max(changeBelow, changeAbove);
        if ( change == changeBelow) 
            xValue = lessIndex(size(lessIndex, 1));
        else
            xValue = moreIndex(1, 1);
        end

        value = [imax(i,1), xValue, change];
        allDifference = [allDifference; value];
        value = [];

    end  
    % look at the change direction and get the max change 
    if (size(allDifference,2) > 2)
        allChange = allDifference(:,3);
        [~, index] = max(allChange);
        location = fix((allDifference(index,1) + allDifference(index,2))/2);
    else
        location = 0;
    end

end