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
