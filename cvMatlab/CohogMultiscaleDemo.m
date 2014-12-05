function  CohogMultiscaleDemo(path, options) 
%path = 'C:\Users\charu\Documents\GitHubRes\ReseachZebrafish\CadualVein\data';
defaultoptions = struct('angle', 360, 'binSize', 8, 'L', 3, 'verbose', true, 'negative',true);

% Process inputs
if(~exist('options','var')), 
    options=defaultoptions; 
else
    tags = fieldnames(defaultoptions);
    for i=1:length(tags)
         if(~isfield(options,tags{i})),  options.(tags{i})=defaultoptions.(tags{i}); end
    end
    if(length(tags)~=length(fieldnames(options))), 
        warning('CohogMultiscaleDemo:unknownoption','unknown options found');
    end
end
cd(path);
imagefiles = dir('*.tif');   
nfiles = length(imagefiles);    % Number of files found

cohog = [];

for i = 1:nfiles
    currentfilename = imagefiles(i).name;
    if(options.verbose)
        disp(['Current File Name: ' currentfilename ]);
    end
    cd(path);
    Img = imread(currentfilename);
    %Img = imresize(Img, 0.5);
    if negative  == true
        for count = 1:10
            xcoord = randi([1, size(Img, 1) - 64]);
            ycoord = randi([1, size(Img, 2) - 128]);
            subImg = imcrop(Img, [ xcoord, ycoord, 64, 128]);
            cd ../cvMatlab;
            p = CohogMultiscale(subImg,binSize,angle,L);
            cohog = [ cohog p];  
        end 
    else
        cd ../cvMatlab;
        p = CohogMultiscale(Img,binSize,angle,L);
        cohog = [ cohog p];   
    end
end

cohog = cohog';

s = sprintf('%s.txt','file.txt');
dlmwrite(s,cohog);
save('cohog.mat', 'cohog');

