function runAll(path, pathMIJI)

folderListing = dir(path); % get list of all subfloder one level
folderListing = folderListing(arrayfun(@(x) x.name(1), folderListing) ~= '.');
isub = [folderListing(:).isdir]; % returns logical vector
nameFolds = {folderListing(isub).name}';

for i = 1:size(nameFolds,1)
    folder = string(char(nameFolds(i,1))); 
    fprintf('folder name: %s \n', folder);       
    pathData = strcat(path, folder, '\');
    run(folder, pathData, pathMIJI);  
end
