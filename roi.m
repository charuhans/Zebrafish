function roi(pathAnatomyData, pathAnatomyBW, pathIsolateData, pathIsolateBW)

close all;
cd(pathAnatomyBW);
imagefiles = dir('*.tif'); 
nfiles = length(imagefiles);    % Number of files found

 
    for ii=1:nfiles
       currentfilename = imagefiles(ii).name;
       currentimage = imread(currentfilename);
       newFileName = strcat(pathAnatomyData,'\', currentfilename);

       newImage = imread(newFileName);
        %BW = currentimage;
        BW = im2bw(currentimage,0.01);
        stats = regionprops(BW, 'Area', 'PixelIdxList', 'PixelList', 'BoundingBox', 'Orientation');
        width = stats(1).BoundingBox(1,3);
        neMin = 1;

        for region = 1 : length(stats)
            if(width < stats(region).BoundingBox(1,3))
                width = stats(region).BoundingBox(1,3);
                neMin = region;
            end
        end
        for region = 1 : length(stats)
            if(region ~= neMin)
                X = stats(region).PixelList(:,1);
                Y = stats(region).PixelList(:,2);
                
                 for x = 1:  size(X,1)
                     newImage(Y(x),X(x)) = 0;   
                     currentimage(Y(x),X(x)) = 0;  
                 end
            end
        end
        
        newX = int32(stats(neMin).BoundingBox(1,1));
        newY = int32(stats(neMin).BoundingBox(1,2));
        newWidth = int32(stats(neMin).BoundingBox(1,3));
        newHeight = int32(stats(neMin).BoundingBox(1,4));
        %Rot
        newDimenssions = [isValid(newX, -75, 0), isValid(newY, -75, 0), isValid(newWidth , 160, size(currentimage,2)), isValid(newHeight, 120, size(currentimage,1))];
        %PTK
        %newDimenssions = [isValid(newX, -50, 0), isValid(newY, -50, 0), isValid(newWidth , 125, size(currentimage,2)), isValid(newHeight, 80, size(currentimage,1))];

        subImage = imcrop(newImage, newDimenssions);
        subImageBW = imcrop(currentimage, newDimenssions);
        %subImage = imcrop(newImage, stats(neMin).BoundingBox);
        %subImageBW = imcrop(currentimage, stats(neMin).BoundingBox);
        %imshow(subImage);
        %if(width > 450)
            newImageNameWriteBW = strcat(pathIsolateBW,'\', currentfilename);
            newImageNameWrite = strcat(pathIsolateData,'\', currentfilename);
            imwrite(subImageBW,newImageNameWriteBW,'tif','Compression','none');
            imwrite(subImage,newImageNameWrite,'tif','Compression','none');
       % end
    end
        
     
end


function newValue = isValid(value, range, limit)

    if(range < 0 )
        cond = value - (value + range);
    else
        cond = (value + range) - range;
    end
    
    if(cond < limit)
        range = range - 1;
    end
    newValue = value + range;

end
         