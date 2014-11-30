function writeToExcelCVAnalysis(path)
warning('off');
%pathForAdding = strcat('..\', path, '\');
addpath(pwd);
folderListing = dir(path); % get list of all subfloder one level
isub = [folderListing(:).isdir]; % returns logical vector
nameFolds = {folderListing(isub).name}';
nameFolds(ismember(nameFolds,{'.','..'})) = [];
patterns = {'-0.1%', '-1nM','-10nM', '-20nM', '-25nM', '-30nM', '-35nM', '-40nM', '-50nM', '-80nM','-100nM','-250nM','-300nM','-350nM','-400nM', '-500nM','-1uM','-2uM','-2.5uM','-3.5uM','-4uM','-5uM', '-8uM',...
    '-10uM','-12.1uM','-20uM', '-30uM', '-40uM'};
header = {'ImageName', 'AverageDiameterHoles', 'AverageAreaHoles', 'TotalAreaHoles', 'CountHoles', 'TotalAreaCV', 'OrientationCV', 'EquivDiameterCV', 'PerimeterCV', 'SolidityCVs'};
dataFolderName = 'CV';
saveFolderName = 'BinaryCV';
% open an excel sheet with same name as folder + CV
for i = 1:size(nameFolds,1)
    names = [];
    folder = string(char(nameFolds(i,1))); 
    fprintf('folder name: %s \n', folder);       
    pathData = strcat(path,'\', folder, '\', dataFolderName);
    
    cd(pathData);
    xlswrite(folder,header,1,'A1');
    xlswrite(folder,header,2,'A1');
    imagefiles = dir('*.tif');
    
    for j=1:length(imagefiles)
        names{j} = imagefiles(j).name;
    end
    names = names';
    names = cellstr(names);
    patterns = cellstr(patterns);
    % call function to compute sub folder 
    
    excelCellIndexSheet1 = 2;
    excelCellIndexSheet2 = 2;    
    for k = 1:size(patterns,2)
         index = reshuffleFileNames(names, patterns{k});
         
         if(size(index, 1) > 0)
            [allResult, subNames, average] = processing(index, names, path, folder, saveFolderName);
            
            excelCellNameSheet2 = strcat('A', num2str(excelCellIndexSheet2));
            xlswrite(folder,subNames',2,excelCellNameSheet2);       
            excelCellParaSheet2 = strcat('B', num2str(excelCellIndexSheet2));
            xlswrite(folder,allResult,2,excelCellParaSheet2);
            
            excelCellNameSheet1 = strcat('A', num2str(excelCellIndexSheet1));
            xlswrite(folder,{patterns{k}},1,excelCellNameSheet1);
            excelCellParaSheet1 = strcat('B', num2str(excelCellIndexSheet1));
            xlswrite(folder,average,1,excelCellParaSheet1);
            
            excelCellIndexSheet2 = excelCellIndexSheet2 + size(index, 1) + 1;
            excelCellIndexSheet1 = excelCellIndexSheet1 + 1;
            
         end
    end
    excelFileName = [pwd '\' folder '.xls'];
    ChartData(excelFileName, excelCellIndexSheet1, header);
end
cd(path);
end

function [index] = reshuffleFileNames(names, str)
indices = strfind(names, str);
index = find(~cellfun(@isempty,indices));
end

function [allResult, subNames, average] = processing(list, names, path, folder, saveFolderName)
pathForAdding = strcat('..\', path, '\');
addpath(pathForAdding);
subNames  = [];
allResult = [];
for ii=1:size(list,1)
    currentfilename = names{list(ii)};
    image = imread(currentfilename);
    G = fspecial('gaussian',[3 3],4);
    %# Filter it
    image = imfilter(image,G,'same');
    [binary, result] = propertiesCV(image);
    %filenames = [ currentfilename;filenames];
    subNames{ii} = currentfilename;
    allResult = [allResult; result];        

    newImageWrite = strcat(path,'\', folder , '\', saveFolderName, '\', currentfilename);
    imwrite(binary,newImageWrite,'tif','Compression','none');
end
average = mean(allResult,1);
end

function [binary1, result] = propertiesCV(dataImage)
areaAvg = 0;
eccAvg = 0;
diaAvg = 0;
ecc = 0;
area = 0;
count = 0;
dia = 0;
max = 0;
result = [];
thresh = mean2(dataImage);
binary1 = im2bw(dataImage,thresh/255);


totalSize = size(find(binary1 > 0),1);
% find shape properties 
G = fspecial('gaussian',[5 5],6);
binaryProp = imfilter(binary1,G,'same');
binaryProp = im2bw(binaryProp, mean2(binaryProp)/255); 
binaryProp = imfill(binaryProp,'holes');
bw = bwlargestblob(binaryProp,8);
%bw = imcomplement(bw);
sr = regionprops(bw, 'Orientation', 'EquivDiameter', 'Eccentricity', 'ConvexArea', 'Perimeter', 'Solidity');
binary = padarray(binary1,[10 10]);
binary = imcomplement(binary);
stats = regionprops(binary, 'All');
% find area of each blob
for region = 1 : length(stats)
    area = stats(region).Area;
    if(area > max)
        max = area;
        index = region;
    end
% %     X = stats(region).PixelList(:,1);
% %     Y = stats(region).PixelList(:,2);
% %     % get boundary condition
% %     anyX0 = any(X == 1);anyY0 = any(Y == 1);anyXw = any(X == size(binary,2));anyYh = any(Y == size(binary,1));
% % 
% %     % elminate boundary data from 3 images
% %     if (anyX0 ~= 0 || anyY0 ~= 0|| anyXw ~= 0|| anyYh ~= 0)  
% %         for x = 1: size(X,1)
% %              binary(Y(x),X(x)) = 0;  
% %         end
% %     end
end

for region = 1 : length(stats) 
    if(region ~= index)
        area = stats(region).Area;
        if(area > 35)
            areaAvg =  areaAvg + stats(region).Area;
            eccAvg = eccAvg + stats(region).Eccentricity;
            diaAvg = diaAvg + stats(region).EquivDiameter;
            count = count + 1;
        end
    end
end
%out=out-min(out(:)); % shift data such that the smallest element of A is 0
%out=out/max(out(:)); % normalize the shifted data to 1
    
if(count > 0)
    result = [diaAvg/count areaAvg/count areaAvg count totalSize scaleOrientation(sr.Orientation + 90) sr.EquivDiameter sr.Perimeter sr.Solidity];
else
    result = [0 0 0 0 totalSize scaleOrientation(sr.Orientation + 90) sr.EquivDiameter sr.Perimeter sr.Solidity];
end

end

function [bwWholeSubImage] = bwlargestblob(im,connectivity)

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

bwWholeSubImage = outim;

end

function angle = scaleOrientation(orientation)
% scale 0 - 75 to 105 - 180
if ( orientation < 75)
    scale = ( 180 - 105) /( 75 - 0);
    angle = (scale * orientation) + 105;
else
    angle = orientation;
end
end
