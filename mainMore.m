function mainMore(pathBW, pathWholeBW, pathData)


 currentFolder = pwd;
 
 saveAnatomyData = strcat(currentFolder,'\', 'pathAnatomyData');
 saveAnatomyBW = strcat(currentFolder,'\', 'pathAnatomyBW');
 saveIsolateData = strcat(currentFolder , '\', 'isolateData');
 saveIsolateBW = strcat(currentFolder , '\', 'isolateBW');
 saveISVData = strcat(currentFolder , '\', 'isvData');
 saveISVBW = strcat(currentFolder , '\', 'isvBW');
 saveISVDA0 = strcat(currentFolder , '\', 'isvDA0');
 saveISVDAN5 = strcat(currentFolder , '\', 'isvDAN5');
 saveISVDA90 = strcat(currentFolder , '\', 'isvDA90');
 saveISVDA5 = strcat(currentFolder , '\', 'isvDA5');
 saveISVDA90BW = strcat(currentFolder , '\', 'isvDA90BW');
 saveISV = strcat(currentFolder , '\', 'isv');



% gaborTransform( saveISVBW,saveISVDA0,saveISVDA5,saveISVDAN5, saveISVDA90 )
% cd(currentFolder);
cleanUp(saveISVDA90BW, saveISVBW, saveISVDA90BW);
 cd(currentFolder);
end