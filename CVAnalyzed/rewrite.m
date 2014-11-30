clear all;
%I = 'C:\Users\charu\Documents\GitHubRes\Research\ReseachZebrafish\CadualVein\cvData - Copy - Copy\N1-0.1%DMSO x4-1.tif';
path = 'C:\Users\charu\Documents\GitHubRes\Research\ReseachZebrafish\CadualVein\-';
cd(path);
imagefiles = dir('*.tif');   
nfiles = length(imagefiles);    % Number of files found
for i = 1:nfiles
    currentfilename = imagefiles(i).name;
    currentfilename
    img = imread(currentfilename);
    name = strcat('00', num2str(i + 50), '.tif');
    
    imwrite(img, name);
end