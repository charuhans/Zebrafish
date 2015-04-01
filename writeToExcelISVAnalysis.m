function writeToExcelISVAnalysis(fileName, pathISV, pathISVSkeleton)
% Function Name:
%    writeToExcelISVAnalysis
%
% Description:
%   This function computes the properties of ISV and save it in excel sheet
% 
% Pre requisite:
%   Expects MIJI in path of matlab
%
% Inputs:
%   fileName     : Name of chemical for name for excel sheet
%   initialSegBW :  Path to binary ISV
%   saveISVData  :  Path to ISV skelton

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
    
    imagefiles  = dir([pathISVSkeleton '*.tif']);       
    
    if nfiles ~= length(imagefiles)
         message('Number of ISV images is not same as number of skeleton images');
         message('Number of files found is 0');
         message('Check if file xtension is tif');
         message('Check if path for data files is correct. Path given:' + pathISVSkeleton);
         return;
    end    
   
    patterns = {'-0.1%', '-1nM','-10nM', '-20nM', '-25nM', '-30nM', '-35nM', '-40nM', '-50nM', '-80nM','-100nM','-250nM','-300nM','-350nM','-400nM', '-500nM','-1uM','-2uM','-2.5uM','-3.5uM','-4uM','-5uM', '-8uM',...
        '-10uM','-12.1uM','-20uM', '-30uM', '-40uM'};
    header = {'ImageName', 'AverageDistanceISV', 'AverageAreaISV', 'AverageLengthISV', 'TotalAreaISV', 'CountISV'};
    letters = {'B','C','D','E','F'};
    headerWithUnits = {'AverageDistanceISV(pixels)', 'AverageAreaISV(pixels)', 'AverageLengthISV(pixels)' ,'TotalAreaISV(pixels)', 'Count'};
    numberOfCharts = 5;
    fileName = strcat(fileName, '_ISV');
   
    % open an excel sheet
    xlswrite(fileName,header,1,'A1');
    xlswrite(fileName,header,2,'A1');    
    
    for j=1:nfiles
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
            [allResult, subNames, average] = processing(index, names, pathISV, pathISVSkeleton);
            
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


function [allResult, subNames, average] = processing(list, names, pathISV, pathISVSkeleton)
% Function Name:
%    processing
%
% Description:
%   This function reads ISV, and ISV skeleton image and computes the mean of all properties
% 
% Pre requisite:
%   Expects MIJI in path of matlab
%
% Inputs:
%   list: indexs based on chemical names
%   names          :  names of file
%   pathISV        :  Path to ISV data images
%   pathISVSkeleton:  Path to ISV sksleton images

    subNames  = [];
    allResult = [];
    for ii=1:size(list,1)        
        currentfilename = strcat(pathISV, '\\', names{list(ii)});
        image = imread(currentfilename);        
        if(~isValidImage(image))
            continue;
        end
        currentfilename = strcat(pathISVSkeleton, '\\', names{list(ii)});
        skelImage = imread(currentfilename);
        if(~isValidImage(skelImage))
            continue;
        end
        [result] = propertiesISV(image, skelImage);
        subNames{ii} = names{list(ii)};
        allResult = [allResult; result];
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

function [result] = propertiesISV(dataImage, skeletonImage)
% Function Name:
%    propertiesISV
%
% Description:
%   This function computes the properties of ISV
% 
% Pre requisite:
%   Expects MIJI in path of matlab
%
% Inputs:
%   dataImage    : ISV data
%   skeletonImage:  ISV sksleton data

   areaCol = 0; minDist = 0; count = 0; areaColSkel = 0;
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
    
    if(~isempty(stats))
        result = [minDist/length(stats) areaCol/length(stats) areaColSkel/length(statsSkel) areaCol length(stats)];
    else
        result = [0 0 0 0 0];
    end

end


