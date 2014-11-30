function gaborTransform( pathISVBWData, pathISVDA0, pathISVDA5, pathISVDAN5, pathISVDA90)
close all;
cd(pathISVBWData)
close all;
imagefiles = dir('*.tif');   

nfiles = length(imagefiles);    % Number of files found

 
    for ii=1:nfiles
       currentfilename = imagefiles(ii).name;
       currentimage = imread(currentfilename);
       currentimage = imcomplement(currentimage);
       newFileName0 = strcat(pathISVDA0,'\', currentfilename);
       [result0, filter] = gaborfilter(currentimage, 15,4, [0], [0], 0.5, 0);
       
       A = im2double(result0);
       A=A-min(A(:)); % shift data such that the smallest element of A is 0
       A=A/max(A(:)); % normalize the shifted data to 1 


       imwrite(A,newFileName0,'png', 'BitDepth', 16);
       
       newFileNameN5 = strcat(pathISVDAN5,'\', currentfilename);
       [resultN5, filter] = gaborfilter(currentimage, 15,4, [-pi/25], [0], 0.5, 0);
       
       A = im2double(resultN5);
       A=A-min(A(:)); % shift data such that the smallest element of A is 0
       A=A/max(A(:)); % normalize the shifted data to 1 


       imwrite(A,newFileNameN5,'png', 'BitDepth', 16);
       
       newFileName5 = strcat(pathISVDA5,'\', currentfilename);
       [result5, filter] = gaborfilter(currentimage, 15,4, [pi/25], [0], 0.5, 0);
       
       A = im2double(result5);
       A=A-min(A(:)); % shift data such that the smallest element of A is 0
       A=A/max(A(:)); % normalize the shifted data to 1 
       imwrite(A,newFileName5,'png', 'BitDepth', 16);
       
       newFileName90 = strcat(pathISVDA90,'\', currentfilename);
       [result90, filter] = gaborfilter(currentimage, 15,2, [pi/2], [0], 0.5, 0);
       
       A = im2double(result90);
       A=A-min(A(:)); % shift data such that the smallest element of A is 0
       A=A/max(A(:)); % normalize the shifted data to 1 
       imwrite(A,newFileName90,'png', 'BitDepth', 16);
    end
       