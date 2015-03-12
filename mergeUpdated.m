function mergeUpdated(saveCleanISV, saveISV, saveISVX, saveISVAll, saveISVBW)   
% Function Name:
%    mergeUpdated
%
% Description:
%   This function removes head and tail region
% 
%
% Inputs:
%   saveISV     : ISV image path
%   saveISVBW   : Binary ISV image path

    if nargin < 5
        error('Need path as an argument');
    end 
    warning('off', 'all');
    warning;
    close all;
    
    imagefiles  = dir([saveCleanISV '*.tif']);      
    nfiles = length(imagefiles);    
    
    if nfiles < 1
         disp('Number of files found is 0');
         disp('Check if file xtension is tif');
         disp('Check if path for data files is correct. Path given:' + saveCleanISV);
         error('Program cannot be executed');
    end
     
    for ii=1:nfiles
        colDist = []; colAngle = []; colArea = []; minDists = []; minDistsIx = [];
        currentfilename = strcat(saveCleanISV, '\', imagefiles(ii).name);     
        dataImage = imread(currentfilename);        
        [outImY, outIm, outImX] = Filter2D(dataImage);
        
        currentfilenameISV = strcat(saveISV, '\', imagefiles(ii).name);  
        A = uint8(255*mat2gray(outImY));
        imwrite(A, currentfilenameISV ,'Compression','none');
        
        currentfilenameX = strcat(saveISVX, '\', imagefiles(ii).name);  
        A = uint8(255*mat2gray(outImX));
        imwrite(A, currentfilenameX ,'Compression','none');
        
        currentfilenameY = strcat(saveISVBW, '\', imagefiles(ii).name); 
        A = uint8(255*mat2gray(outImY));
        imwrite(A, currentfilenameY ,'Compression','none');
        
        currentfilenameAll = strcat(saveISVAll, '\', imagefiles(ii).name);     
        A = uint8(255*mat2gray(outIm));
        imwrite(A, currentfilenameAll ,'Compression','none');        
         
        bwY = binarize(currentfilenameY);
        bwX = binarize(currentfilenameX);
        bwAll = binarize(currentfilenameAll);   
                
        % remove small elements
        bwY = bwareaopen(bwY, 20);
        bwX = bwareaopen(bwX, 400);
        bwAll = bwareaopen(bwAll, 20);
       
        % apply open/close operation on bwX
        seLine = strel('line',12,5);
        bwXOpen = imopen(bwX,seLine);
        
        seLine = strel('line',12,5);
        bwXClose = imclose(bwXOpen,seLine);
        bwXClose = bwareaopen(bwXClose, 300);
       
        % remove region from bwY that are in bwX 
       [labeledImage, ~] = bwlabel(bwXClose, 8); 
       stats = regionprops(labeledImage, 'All');
       for region = 1 : length(stats)
        bwY(labeledImage == region) = 0;           
       end
       
       % apply close operation on bwX
       seLine = strel('line',8,90);
       bwYClose = imclose(bwY,seLine);
       
       % apply close operation on bwAll
       seLine = strel('line',5,90);
       bwAllClose = imclose(bwAll,seLine);
       
       bw = and(bwYClose, bwAllClose);
       bw = bwareaopen(bw, 50);
       
       % remove the region with high count, its an outlier
       [labeledImage, ~] = bwlabel(bw, 8); 
       stats = regionprops(labeledImage, 'Area', 'Eccentricity');
       
       for region = 1 : length(stats)
           if(stats(1).Area < 100)
               bw(labeledImage == 1) = 0;
           end
           if(stats(length(stats)).Area < 100)
               bw(labeledImage == length(stats)) = 0;
           end
           if(stats(region).Area > 400)
               bw(labeledImage == region) = 0;
           end
           if(stats(region).Eccentricity < 0.8)
               bw(labeledImage == region) = 0;
           end               
       end

       stats = regionprops(bw, 'All');          
       % remove the region with high count, its an outlier
       % find the closest regions according to distance between centeroid 
       for region = 1 : length(stats)
          first  = stats(region).Centroid; 
          rowDist = [];
          for inregion = 1 : length(stats)
              dist = pdist2(first, stats(inregion).Centroid);              
              rowDist = [ rowDist dist];     
          end
          colDist = [ colDist; rowDist];
       end

      % among obtained centeroid, find slope
      % if slope is  closerto 1, merge regions

      [minDists,minDistsIx] = sort(colDist,2) ;
          
      if(size(colDist,2) > 3)
          minDists = minDists(:, 2:4);
          minDistsIx = minDistsIx(:, 2:4);

          %returns slope between two closer centroids and ratio of their areas
          [colSlope,colAreaRatio]  = findAngleRatio(minDistsIx, stats);

          %returns regions numbers that needs to be merged
          [image, regionAssociation] = removeOutliers(colSlope, colAreaRatio, minDistsIx, bw, stats);

          %connect these areas that need to be merged
          image = mergeAreas(regionAssociation, image, stats);

      else
          image = bw;
      end
      
       [labeledImage, ~] = bwlabel(image, 8); 
       stats = regionprops(labeledImage, 'Area');
       for region = 1 : length(stats)
           if(stats(region).Area > 400)
               image(labeledImage == region) = 0;
           end
       end
       newImageWrite = strcat(saveISVBW, '\', imagefiles(ii).name);
       imwrite(image,newImageWrite,'tif','Compression','none');
    end
end

function image = binarize(path)
% Function Name:
%    binarize
%
% Description:
%   binarizes image and saves it
% 
% Inputs:
%   path : path to images

    MIJ.run('Open...', strcat('path=[', path, ']'));
    MIJ.run('Auto Local Threshold', 'method=Niblack radius=15 parameter_1=0 parameter_2=0 white');
    %MIJ.run('Invert');
    image = MIJ.getCurrentImage(); 
    image = uint8(image / 256);
    image = im2uint8(image*255);
    imwrite(image,path,'tif','Compression','none');
    MIJ.run('Close');
end


%merges all the areas that were broken due to image preprocessing
function [image] = mergeAreas(regionAssociation, image, stats)
% Function Name:
%    mergeAreas
%
% Description:
%   merges all the areas that were broken due to image preprocessing
% 
%
% Inputs:
%   regionAssociation : mapping reflection which isv the region belong to
%   image             : input  image 
%   stats             : stats about each region

    for i = 1: size(regionAssociation,1)
        region_1 = regionAssociation(i,1);
        region_2 = regionAssociation(i,2);
        
        extrema_1 = stats(region_1).Extrema;
        extrema_2 = stats(region_2).Extrema;
        
         centroid_1y = stats(region_1).Centroid(2);
         centroid_2y = stats(region_2).Centroid(2);
         
         if(centroid_1y < centroid_2y)
             %region 1 is on the top
             bottom_right = extrema_1(5,:);
             bottom_left = extrema_1(6,:);
             top_left = extrema_2(1,:);
             top_right = extrema_2(2,:);
         else
             %region1 is on the bottom
             bottom_right = extrema_2(5,:);
             bottom_left = extrema_2(6,:);
             top_left = extrema_1(1,:);
             top_right = extrema_1(2,:);
         end
         
        %we have extremas now we need to join them by a line in image(not
        %just plot)

        %get pts for the line
        rightPts = getLinePts(top_right, bottom_right);
        leftPts = getLinePts(top_left, bottom_left);
        
        %put lines on the image
        image(leftPts(:,2), leftPts(:,1) ) = 255;
        image(rightPts(:,2), rightPts(:,1) ) = 255;
    end
end

function [linePts] = getLinePts(pt1, pt2)
    nPts = ceil(pdist2(pt1, pt2))*2;
    x1 = pt1(1);
    x2 = pt2(1);
    y2 = pt2(2);
    y1 = pt1(2);
    %listOfPoints = fix([x1:(x2-x1)/(nPts-1):x2;y1:(y2-y1)/(nPts-1):y2]);
    listOfPoints = fix([linspace(x1,x2,nPts);linspace(y1,y2,nPts)]);

    A = listOfPoints';
    [q i j] = unique(A,'rows');
    linePts = A((i),:);
end

%final result should be matrix with index association between regions to be
%merged based on slope and area ratio
function [image, regionAssociation] = removeOutliers(colSlope, colAreaRatio, minDistsIx, image, stats)
% Function Name:
%    removeOutliers
%
% Description:
%   Get regions to be merged or removed
% 
%
% Inputs:
%   colSlope    : associated region slope
%   colAreaRatio: associated region area ratio
%   minDistsIx  : index with min distance
%   image       : merged image
%   stats       : stats for each region
% 
% Output:
%   regionAssociation : mapping reflection which isv the region belong to
%   image             : image without outlier

    regionAssociation = []; newColSlope = []; newColAreaRatio = [];
    
    for i = 1 : size(colSlope,1)
        slope_1 = colSlope(i,1);
        slope_2 = colSlope(i,2);
        
        ratio_1 = colAreaRatio(i,1);
        ratio_2 = colAreaRatio(i,2);
        
        %if slope is greter than 1.5 and one region is more than 1/4 of
        %another then they should be merged
        
        %closest regions
        if(slope_1 > 1.6 && (ratio_1 <= 4 && (1/ratio_1) <= 4))
            regionAssociation = [regionAssociation; i minDistsIx(i,1)];
        end
        
        %second closest regions
        if(slope_2 > 1.6 && (ratio_2 <=4 && (1/ratio_2) <= 4))
            regionAssociation = [regionAssociation; i minDistsIx(i,2)];
        end
    end
    
    for i = 1 : size(colSlope,1)
        
        ratio_1 = colAreaRatio(i,1);
        ratio_2 = colAreaRatio(i,2);
        
        
        % regions to be removed
        if(ratio_1 > 5  || (1/ratio_1) > 5)
            area1 = stats(i).Area;
            area2 = stats(minDistsIx(i,1)).Area;
            if(area1 < area2)
                image(stats(i).PixelList(:,2),stats(i).PixelList(:,1))  = 0;
            else
                image(stats(minDistsIx(i,1)).PixelList(:,2), stats(minDistsIx(i,1)).PixelList(:,1)) = 0;
            end
        end
        
        if(ratio_2 > 5  || (1/ratio_2) > 5)
            area1 = stats(i).Area;
            area2 = stats(minDistsIx(i,2)).Area;
            if(area1 < area2)
                image(stats(i).PixelList(:,2),stats(i).PixelList(:,1))  = 0;
            else
                image(stats(minDistsIx(i,2)).PixelList(:,2), stats(minDistsIx(i,2)).PixelList(:,1)) = 0;
            end
        end
    end
    
    %remove duplicate associations
    regionAssociation = sort(regionAssociation,2);
    A =  sort(regionAssociation, 2);
    [q i j] = unique(A,'rows');
    regionAssociation = A(sort(i),:);
    
end


function [colAngle, colArea] = findAngleRatio(mat, stats)
% Function Name:
%    findAngleRatio
%
% Description:
%   Find angle btween centeroid of each region
% 
% Input:
%   mat: asssoctaion matrix
%   stats: stats for each region
%
% Output:
%   colAngle : angle of region to merged
%   colArea : area of each region

colAngle = []; colArea = [];
    for region = 1 : size(mat,1)
        first  = stats(region).Centroid; 
        firstA  = stats(region).Area; 
        rowAngle = [];
        rowArea = [];
        for inregion = 1 : size(mat,2)
           second = stats(mat(region, inregion)).Centroid;
           secondA = stats(mat(region, inregion)).Area;
           %CosTheta = dot(first,second)/(norm(first)*norm(second));
           CosTheta = abs((first(2) - second(2))/( first(1) - second(1)));
           areaRatio = firstA/secondA;
            %angle =acos( dot(DirVector1,DirVector2)/norm(DirVector1)/norm(DirVector2) )*180/pi; 
            rowAngle = [ rowAngle CosTheta]; 
            rowArea = [ rowArea areaRatio]; 
        end
        colAngle = [ colAngle; rowAngle];
        colArea = [ colArea; rowArea];
    end
end
        
    
    


