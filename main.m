function main(pathBW, pathWholeBW, pathData)

%  mkdir('pathAnatomyData');
%  mkdir('pathAnatomyBW');
%  mkdir('isolateData');
%  mkdir('isolateBW');
%  mkdir('isvData');
%  %mkdir('isvBW');
%  mkdir('isvDA');
%  %mkdir('skeleton');
%  mkdir('isv');
%  mkdir('isvDA5');
%  mkdir('isvDAN5');
%  mkdir('isvDA0');
%  mkdir('isvDA90');
%  mkdir('isvDA90BW');
%  mkdir('isvDAAll');
%  mkdir('theISV');
%  mkdir('isvBWHole');
%  mkdir('initialSegBW');
 currentFolder = pwd;
 
 saveAnatomyData = strcat(currentFolder,'\', 'pathAnatomyData');
 saveAnatomyBW = strcat(currentFolder,'\', 'pathAnatomyBW');
 saveIsolateData = strcat(currentFolder , '\', 'isolateData');
 saveIsolateBW = strcat(currentFolder , '\', 'isolateBW');
 saveISVData = strcat(currentFolder , '\', 'isvData');
 saveISVBW = strcat(currentFolder , '\', 'isvBW');
 saveBW = strcat(currentFolder , '\', 'BW');
 saveSkeleton = strcat(currentFolder , '\', 'skeleton');
 
 saveISV = strcat(currentFolder , '\', 'isv');
 saveISVClean = strcat(currentFolder , '\', 'isvClean');


%anatomyExtraction1(pathData, pathWholeBW, saveAnatomyData, saveAnatomyBW);  
%cd(currentFolder);   
%roi(saveAnatomyData, saveAnatomyBW, saveIsolateData, saveIsolateBW)
%cd(currentFolder);

cleanImage(saveSkeleton, saveISVData, saveISVClean, saveISV);
cd(currentFolder);
merge( saveISV, saveISVBW);
cd(currentFolder);
computeFeatures(saveISVBW);
cd(currentFolder);

% cd(currentFolder);
% new main
% intialROIExtraction
% anatomyExtraction1(pathData, pathWholeBW, saveAnatomyData, saveAnatomyBW);  
% cd(currentFolder);   
% ROI(saveAnatomyData, saveAnatomyBW, saveIsolateData, saveIsolateBW)
% cd(currentFolder);
% tailExtraction(saveIsolateData, saveInitialSegBW, saveISVData, saveSkeleton);
% cd(currentFolder);
% caudalVein(saveSkeleton, saveIsolateData, pathBW, saveCV);
% cd(currentFolder);
% cleanImage(saveSkeleton, saveISVData, saveISVClean, saveISV);
% cd(currentFolder);
% merge( saveISV, saveISVBW);
% cd(currentFolder);
% computeFeatures(saveISVBW);
% cd(currentFolder);
% [success] = ChartData(ResultFile, excelCellIndexSheet1, header)
end