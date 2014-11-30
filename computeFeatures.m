function computeFeatures( saveISVBW)   
fName = 'result.txt';         %# A file name
fid = fopen(fName,'w');            %# Open the file

warning('off','all');
warning;
close all;
cd(saveISVBW);
imagefiles = dir('*.tif');   
nfiles = length(imagefiles);    % Number of files found

for ii=1:nfiles
    areaCol = 0;
    mind = 0;
    area = 0;
    count = 0;
   currentfilename = imagefiles(ii).name;
   dataImage = imread(currentfilename);

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
            mind = mind + val;
    end
    result = [mind/length(stats) areaCol/length(stats) areaCol length(stats)];       
   fprintf(fid, '%s,', currentfilename);
   fprintf(fid, '%d, %d, %d, %d\n', result);
  
end
fclose(fid);
end
        
         
       