function cv(pathBW, pathWholeBW, pathData)

%  mkdir('pathAnatomyData');
%  mkdir('pathAnatomyBW');
%  mkdir('isolateData');
%  mkdir('isolateBW');
%  mkdir('isvData');
%  %mkdir('isvBW');
%  mkdir('isvDA');
%  %mkdir('skeleton');
%  mkdir('isv');
currentFolder = pwd;

saveAnatomyData = strcat(currentFolder,'\', 'pathAnatomyData');
saveAnatomyBW = strcat(currentFolder,'\', 'pathAnatomyBW');
saveIsolateData = strcat(currentFolder , '\', 'isolateData');
saveIsolateBW = strcat(currentFolder , '\', 'isolateBW');
saveSkeleton = strcat(currentFolder , '\', 'skeleton');
saveCV = strcat(currentFolder , '\', 'CV');

% anatomyExtraction1(pathData, pathWholeBW, saveAnatomyData, saveAnatomyBW);
% cd(currentFolder);
% roi(saveAnatomyData, saveAnatomyBW, saveIsolateData, saveIsolateBW)
% cd(currentFolder);
% only added for caudal vein
caudalVein(saveSkeleton, saveIsolateData, pathBW, saveCV);
cd(currentFolder);
end