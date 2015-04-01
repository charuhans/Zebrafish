clear all;
%I = 'C:\Users\charu\Documents\GitHubRes\Research\ReseachZebrafish\CadualVein\cvData - Copy - Copy\N1-0.1%DMSO x4-1.tif';
path = 'C:\Users\charu\Desktop\Zebrafish\+\seg';
cd(path);
imagefiles = dir('*.tif');   
nfiles = length(imagefiles);    % Number of files found
for i = 1:nfiles
    currentfilename = imagefiles(i).name;
    
    img = imread(currentfilename);
    name = strcat('0', num2str(i), '.tif');
    
    imwrite(img, name);
end