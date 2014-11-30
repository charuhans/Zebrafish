function evaluate
close all;
fid = fopen('result.txt', 'w');
cd('theISV');
imagefiles = dir('*.tif');   

nfiles = length(imagefiles);    % Number of files found


 
    for ii=1:nfiles
       currentfilename = imagefiles(ii).name;
       currentimage = imread(currentfilename);
       [x, y] = find (currentimage < 0.5);
       if(size(x,1) > 0)
            [k , area]= convhull(x,y);
       else
           area = 0;
       end
       %bwch = bwconvhull(currentimage);
       %[a, b] = find(bwch < 0.5);
       result = [size(x,1) area];       
       fprintf(fid, '%s,', currentfilename);
       fprintf(fid, '%d, %d\n', result);
       
    end
fclose(fid);
cd ..
end