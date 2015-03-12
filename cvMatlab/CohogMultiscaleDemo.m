function  CohogMultiscaleDemo(path, options) 
%path = 'C:\Users\charu\Documents\GitHubRes\ReseachZebrafish\CadualVein\data';
defaultoptions = struct('angle', 360, 'binSize', 8, 'level', 3, 'verbose', true, 'negative', false);

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
imagefiles = dir('*.png');   
nfiles = length(imagefiles);    % Number of files found

cohog = [];
start =  1;
last = fix(nfiles/2);
for i = start: last
    currentfilename = imagefiles(i).name;
    if(options.verbose)
        disp(['Current File Name: ' currentfilename ]);
    end
    cd(path);
    Img = imread(currentfilename);
    if size(Img,3) 
        Img = rgb2gray(Img);
    end
    cd ../../../../cvMatlab;
    %Img = imresize(Img, 0.5);
    if options.negative  == 1
        for count = 1:10
            xcoord = randi([1, size(Img, 2) - 95]);
            ycoord = randi([1, size(Img, 1) - 159]);
            subImg = imcrop(Img, [ xcoord, ycoord, 95, 159]);
            
            p = CohogMultiscale(subImg, options.binSize, options.angle, options.level);
            cohog = [ cohog p];  
        end 
    else
        %Img = imresize(Img, [160, 96]);
        p = CohogMultiscale(Img, options.binSize, options.angle, options.level);
        cohog = [ cohog p];   
    end
end

cohog = cohog';

%cd ../../../../cvMatlab;
save('cohogPosTest1.mat', 'cohog');

