function features( saveISVBW, saveSkeletonISV) 
% Function Name:
%    computeFeatures
%
% Description:
%   This function computes the features of ISV
% 
%
% Inputs:
%   saveISVBW    : Path where binsary ISV images are located
%   saveSkeletonISV : Path where ISV skeleton images are located
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
         message('Number of files found is 0');
         message('Check if file xtension is tif');
         message('Check if path for data files is correct. Path given:' + pathData);
         return;
    end
    
   


for ii=1:nfiles
   areaCol = 0; minDist = 0;
   count = 0;
   areaColSkel = 0;
   currentfilename = strcat(saveISVBW, '\\', imagefiles(idx).name);
   dataImage = imread(currentfilename);
    
   currentfilename = strcat(saveSkeletonISV, '\\', imagefiles(idx).name);
   skeletonImage = imread(currentfilename);

   bw = im2bw(dataImage,0.01);
   stats = regionprops(bw, 'All');

   % find area of each blob
   for region = 1 : length(stats)
       area = stats(region).Area;
       if(area < 750)
        areaCol =  areaCol + area;
        count = count + 1;
       end

   end

   % find distance
    for region = 1 : length(stats)
      first  = stats(region).Centroid; 
      rowDist = [];
      for inregion = 1 : length(stats)
          dist = pdist2(first, stats(inregion).Centroid);              
          rowDist = [ rowDist dist];      
      end
        if(size(rowDist,2) > 1)
        % find the distance b/w centeroid
            [minDists] = sort(rowDist,2) ;
            val = minDists(:, 2);
        else
            val = 0;
           
        end
            minDist = minDist + val;
    end
    
   bw = im2bw(skeletonImage,0.01);
   statsSkel = regionprops(bw, 'All');

   % find area of each blob for skeleton
   for region = 1 : length(statsSkel)
       area = statsSkel(region).Area;
       if(area < 100)
        areaColSkel =  areaColSkel + area;
        count = count + 1;
       end

   end
   %result = [minDist/length(stats) areaCol/length(stats) areaColSkel/length(statsSkel) areaCol length(stats)]; 
   result = [areaCol/length(stats) areaColSkel/length(statsSkel) areaCol length(stats)]; 
   features = [ features; result];
  
end
save('poistive.mat', features);
end
        
         
       