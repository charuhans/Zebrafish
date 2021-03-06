function run(fileName, pathData, pathMIJI)
    
    rmpath(pathMIJI);
    addpath(pathMIJI);
    Miji(false);
    cd(pathData);
    %cd ..;
    currentFolder = pwd;
    
    mkdir('pathAnatomyData');
    mkdir('pathAnatomyBW');
    mkdir('isolateData');
    mkdir('isolateBW');
    mkdir('isvData');
    mkdir('isvBW');
    mkdir('isvClean');
    mkdir('skeleton');
    mkdir('isvSkeleton');
    mkdir('isv');
    mkdir('isvX');
    mkdir('isvAll');
    mkdir('wholeSegBW');
    mkdir('initialSegBW');
    mkdir('cv');
    mkdir('cvBW');
 
    saveWholeBW = strcat(currentFolder,'\', 'wholeSegBW','\');
    saveAnatomyData = strcat(currentFolder,'\', 'pathAnatomyData','\');
    saveAnatomyBW = strcat(currentFolder,'\', 'pathAnatomyBW','\');
    saveIsolateData = strcat(currentFolder , '\', 'isolateData','\');
    saveIsolateBW = strcat(currentFolder , '\', 'isolateBW','\');
    saveISVData = strcat(currentFolder , '\', 'isvData','\');
    saveISVBW = strcat(currentFolder , '\', 'isvBW','\');
    saveSkeleton = strcat(currentFolder , '\', 'skeleton','\'); 
    saveISVSkeleton = strcat(currentFolder , '\', 'isvSkeleton','\'); 
    saveISV = strcat(currentFolder , '\', 'isv','\');
    saveISVX = strcat(currentFolder , '\', 'isvX','\');
    saveISVAll = strcat(currentFolder , '\', 'isvAll','\');
    saveISVClean = strcat(currentFolder , '\', 'isvClean','\');
    saveCV = strcat(currentFolder , '\', 'cv','\');
    saveCVBW = strcat(currentFolder , '\', 'cvBW','\');
    saveInitialSegBW = strcat(currentFolder , '\', 'initialSegBW','\');    
    
    IntialRoiExtraction(pathData, saveWholeBW);
    AnatomyExtraction1(pathData, saveWholeBW, saveAnatomyData, saveAnatomyBW); 
    ROI(saveAnatomyData, saveAnatomyBW, saveIsolateData, saveIsolateBW);
    TailISVExtraction(saveIsolateData, saveInitialSegBW, saveISVData, saveSkeleton);
    caudalVein(saveSkeleton, saveIsolateData, saveInitialSegBW, saveCV);
    cleanImage(saveSkeleton, saveISVData, saveISVClean);
    mergeUpdated(saveISVClean, saveISV, saveISVX, saveISVAll, saveISVBW);
    skeletonISV(saveISVBW, saveISVSkeleton);
    writeToExcelCVAnalysis(fileName, saveCV, saveCVBW);
    writeToExcelISVAnalysis(fileName, saveISVBW, saveISVSkeleton);
    
end