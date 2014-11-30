function cleanImage(pathSkelData, pathData, saveDataCleanPath, saveDataPath)   
    warning('off','all');
    warning;
    close all;
     cd(pathSkelData);
    imagefiles = dir('*.tif');   
    nfiles = length(imagefiles);    % Number of files found
    
    for ii=1:nfiles
        % read original gray image
       currentfilename = imagefiles(ii).name;
       skelImage = imread(currentfilename);
       fileName = strcat(pathData, '\', currentfilename);
       dataImage = imread(fileName);
       clean = remove(skelImage, dataImage);
       
       newImageWrite = strcat(saveDataCleanPath, '\', currentfilename);
      
       imwrite(clean,newImageWrite,'tif','Compression','none');
       
       [outImY,whatScale] = FrangiFilter2D((clean));
       
       newImageWrite = strcat(saveDataPath, '\', currentfilename);
       A = im2double(outImY);
       A=A-min(A(:)); % shift data such that the smallest element of A is 0
       A=A/max(A(:)); % normalize the shifted data to 1 
       imwrite(A,newImageWrite,'png', 'BitDepth', 16);
    end
    
end



function image = remove(img, realImg)

    whitePixelArray_up = [];
    whitePixelArray_down = [];

    %scan the image from  top and store white pixels indices in an array
    for y = 1:size(img,2)
        for x  = 1:size(img,1)
            val = img(x,y);
            if(val == 0)
               %whitePixelArray_up(:,1) = x;
               %whitePixelArray_up(:,2) = y;   
               whitePixelArray_up = [ whitePixelArray_up; x y 0];
               break;
            end
        end
    end
    
    %scan the image from  bottom and store white pixels indices in an array
    for y = 1:size(img,2)
        for x  = size(img,1):-1:1
            val = img(x,y);
            if(val == 0)
               whitePixelArray_down = [ whitePixelArray_down; x y 0];
               break;
            end
        end
    end
    
    %we scanned from top and we have the distance between two points
    whitePixelArray_up = distance(whitePixelArray_up);

    %we scanned from bottom and we have the distance between two points
    whitePixelArray_down = distance(whitePixelArray_down);
    
    
    %max distance between points when looking from top
    max_up = max(whitePixelArray_up(:,3));
    
    %max distance between points when looking from down
    max_down = max(whitePixelArray_down(:,3));
    
    if(max_up > max_down)
        %we need to clean the top side
         x_index = find(whitePixelArray_up(:,3)== max_up);
         XY = [whitePixelArray_up(x_index,1) whitePixelArray_up(x_index,2)];
         
         isTop = 1;
    else
        %we need to clean the down side
         x_index = find(whitePixelArray_down(:,3)== max_down);
         XY = [whitePixelArray_down(x_index,1) whitePixelArray_down(x_index,2)];
         isTop = 0;
    end
    
    %now lets find which way is the head pointed, closer to zero or closer
    %to image width
    if(dist(1,XY(1,2)) < dist(size(img,2),XY(1,2)))
        %head is closer to image zero, clean everything from zero to this
        %point
        for i = 1 : XY(1,2)
            for j = 1 : size(img,1)
                %clean real Image
                realImg(j,i) = 0; %or 255 whatever is correct
            end
        end
        
        %lets clean the other side of the fish image too, opposite to head
        %section. this is closer to image width
        max_x_closeToWidth = max(whitePixelArray_up(:,2));
        for x_dim = max_x_closeToWidth : size(realImg,2)
          for y_dim = 1 : size(realImg, 1) %min_y_closeToZero
              realImg(y_dim,x_dim) = 0;
          end
        end        
    else
        %head is closer to image width
        for i = XY(1,2) : size(img,2)
            for j = 1 : size(img,1)
                %clean real Image
                realImg(j, i) = 0; %or 255 whatever is correct
            end
        end
        
        %lets clean the other side of the fish image too, opposite to head
        %section. this is closer to image zero width        
        min_x_closeToZero = min(whitePixelArray_up(:,2));
        for x_dim = 1 : min_x_closeToZero
          for y_dim = 1 : size(realImg, 1) %min_y_closeToZero
              realImg(y_dim,x_dim) = 0;
          end
        end
    end
    
    
        
    image = cleanRestOftheImage(realImg, whitePixelArray_up, whitePixelArray_down, isTop);
    
end


function [realImg] =   cleanRestOftheImage(realImg, whitePixelArray_up, whitePixelArray_down, isTop)
val = fix(size(whitePixelArray_down,1)/2);

DirVector1=[whitePixelArray_down(val,1) whitePixelArray_down(val,2)]-[whitePixelArray_down(val + 2,1) whitePixelArray_down(val + 2,2)];
DirVector2=[1,0]-[3,0];
angle =acos( dot(DirVector1,DirVector2)/norm(DirVector1)/norm(DirVector2) )*180/pi; 

    if(isTop == 1)
        
        for i = 1: size(whitePixelArray_up,1)
           x =  whitePixelArray_up(i,1);
           y = whitePixelArray_up(i,2);
           
           for j = 1 : x 
               realImg(j,y) = 0; %or 255 whatever is correct
           end
           
        end
        
        for x_dim =1: x 
          for y_dim = y:size(realImg, 2)
              realImg(x_dim,y_dim) = 0;
          end
        end
    else
        for i = 1: size(whitePixelArray_down,1)
           x =  whitePixelArray_down(i,1);
           y = whitePixelArray_down(i,2);
           
           for j =  x : size(realImg,1)
               realImg(j,y) = 0; %or 255 whatever is correct
           end
           
        end
        
        for x_dim = x : size(realImg,1)
          for y_dim = y:size(realImg, 2)
              realImg(x_dim,y_dim) = 0;
          end
        end
    end
    
    
    
    %realImg = imrotate(realImg,90 -angle);
end
    
function [arr] = distance(arr)

for x = 2 : size(arr,1)
   Array = [arr(x-1,1) arr(x-1, 2); arr(x,1) arr(x, 2)];
   distance = pdist(Array,'euclidean');
   arr(x,3) = distance;
end
end