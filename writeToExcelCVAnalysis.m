function writeToExcelCVAnalysis(fileName, pathISV, pathISVSkel)
% Function Name:
%    writeToExcelCVAnalysis
%
% Description:
%   This function computes the properties of CV and save it in excel sheet
% 
% Pre requisite:
%   Expects MIJI in path of matlab
%
% Inputs:
%   fileName     : Name of chemical for name for excel sheet
%   pathCV       : Path to CV
%   pathBinaryCV : path to binary CV

   if nargin < 3
        error('Need path as an argument');
    end 
    warning('off', 'all');
    warning;
    close all;
    
    imagefiles  = dir([pathISV '*.tif']);      
    nfiles = length(imagefiles);    
    
    if nfiles < 1
         disp('Number of files found is 0');
         disp('Check if file xtension is tif');
         disp('Check if path for data files is correct. Path given:' + pathISV);
         error('Program cannot be executed');
    end  

    patterns = {'-0.1%', '-1nM','-10nM', '-20nM', '-25nM', '-30nM', '-35nM', '-40nM', '-50nM', '-80nM','-100nM','-250nM','-300nM','-350nM','-400nM', '-500nM','-1uM','-2uM','-2.5uM','-3.5uM','-4uM','-5uM', '-8uM',...
    '-10uM','-12.1uM','-20uM', '-30uM', '-40uM'};
    header = {'ImageName', 'AverageDiameterHoles', 'AverageAreaHoles', 'TotalAreaHoles', 'CountHoles', 'TotalAreaCV', 'OrientationCV', 'EquivDiameterCV', 'PerimeterCV', 'SolidityCVs'};
    letters = {'B','C','D','E','F','G','H','I','J'};
    headerWithUnits = {'AverageDiameterHole(pixels)', 'AverageAreaHole(pixels)', 'TotalAreaHole(pixels)', 'Count', 'TotalAreaCV(pixels)', 'OrientationCV(degree)',...
        'EquivDiameterCV(pixels)', 'PerimeterCV', 'SolidityCV'};
    numberOfCharts = 9;
    fileName = strcat(fileName, '_CV');

    % open an excel sheet
    xlswrite(fileName,header,1,'A1');
    xlswrite(fileName,header,2,'A1');  
    
    for j=1:length(imagefiles)
        names{j} = imagefiles(j).name;
    end
    names = names';
    names = cellstr(names);
    patterns = cellstr(patterns);

    excelCellIndexSheet1 = 2;
    excelCellIndexSheet2 = 2;    
    for k = 1:size(patterns,2)
         index = reshuffleFileNames(names, patterns{k});

         if(size(index, 1) > 0)
            [allResult, subNames, average] = processing(index, names, pathISV, pathISVSkel);

            excelCellNameSheet2 = strcat('A', num2str(excelCellIndexSheet2));
            xlswrite(fileName,subNames',2,excelCellNameSheet2);       
            excelCellParaSheet2 = strcat('B', num2str(excelCellIndexSheet2));
            xlswrite(fileName,allResult,2,excelCellParaSheet2);

            excelCellNameSheet1 = strcat('A', num2str(excelCellIndexSheet1));
            xlswrite(fileName,{patterns{k}},1,excelCellNameSheet1);
            excelCellParaSheet1 = strcat('B', num2str(excelCellIndexSheet1));
            xlswrite(fileName,average,1,excelCellParaSheet1);

            excelCellIndexSheet2 = excelCellIndexSheet2 + size(index, 1) + 1;
            excelCellIndexSheet1 = excelCellIndexSheet1 + 1;
         end
    end
    excelFileName = [pwd '\' fileName];
    ExcelPlotData(excelFileName, excelCellIndexSheet1, header, letters, headerWithUnits, numberOfCharts);
end

function [index] = reshuffleFileNames(names, str)
% Function Name:
%    reshuffleFileNames
%
% Description:
%   This function rearranges index of file in folder based on pattern
% 
% Pre requisite:
%   Expects MIJI in path of matlab
%
% Inputs:
%   names: list of bames
%   str   :  pattern 
    indices = strfind(names, str);
    index = find(~cellfun(@isempty,indices));
end

function [allResult, subNames, average] = processing(list, names, path, saveFolderName)
% Function Name:
%    processing
%
% Description:
%   This function reads CV, computes the mean of all properties and saves
%   binary image
% 
% Pre requisite:
%   Expects MIJI in path of matlab
%
% Inputs:
%   list: indexs based on chemical names
%   names          :  names of file
%   path           :  Path to CV data images
%   saveFolderName :  Path to save CV binary images
    subNames  = [];
    allResult = [];
    for ii=1:size(list,1)
        currentfilename = strcat(path, '\\', names{list(ii)});
        image = imread(currentfilename);
        if(~isValidImage(image))
            continue;
        end
        G = fspecial('gaussian',[3 3],4);
        %# Filter it
        image = imfilter(image,G,'same');
        [binary, result] = propertiesCV(image);
        subNames{ii} = names{list(ii)};
        allResult = [allResult; result];        

        newImageWrite = strcat(saveFolderName, '\', names{list(ii)});
        imwrite(binary,newImageWrite,'tif','Compression','none');
    end
    average = mean(allResult,1);
end

function valid = isValidImage(img)

    if(isempty(img) ||  size(find(img == 255),1) == (size(img,1) * size(img,2)))
         valid = false;
    else
        valid = true;
    end
end

function [binary1, result] = propertiesCV(dataImage)
% Function Name:
%    propertiesCV
%
% Description:
%   This function computes the properties of CV
% 
% Pre requisite:
%   Expects MIJI in path of matlab
%
% Inputs:
%   dataImage    : ISV data

    areaAvg = 0; eccAvg = 0; diaAvg = 0; 
    ecc = 0; area = 0; count = 0; dia = 0;
    max = 0; result = [];
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
