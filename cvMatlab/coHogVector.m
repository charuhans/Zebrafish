
function coHog = coHogVector(dir,L)

offset = [0 0; 1 0; 2 0; 3 0; 4 0;
         -4 1; -3 1; -2 1; -1 1; 0 1;
         1 1; 2 1; 3 1; 4 1; -3 2;
         -2 2; -1 2; 0 2; 1 2; 2 2;
         3 2; -3 3; -2 3; -1 3; 0 3;
         1 3; 2 3; 3 3; -1 4; 0 4; 1 4];

numCol = 2^(L);
numRow = 2^(L);

x = fix(size(dir,2)/(2^(L)));
y = fix(size(dir,1)/(2^(L)));

%get coHog feature
coHog = [];
%coHog = zeros((64*30+8)*numCol*numRow,1);
xx = 0; yy = 0; 
coHogMid = zeros((64*30+8),1);
rowNum = size(dir,1);
colNum = size(dir,2);
while xx+x <= size(dir,2)
    while yy +y <= size(dir,1)
       angleCell = dir(yy+1:yy+y,xx+1:xx+x); 

        for row = 1:size(angleCell,1)
           for col = 1:size(angleCell,2)
               i = dir(yy + row, xx + col);
               if(i ~= 0)
                   for indexOffset = 1:31
                      newRow = yy + row + offset(indexOffset,2);
                      newCol = xx + col + offset(indexOffset,1);
                      if(newRow > 0 && newRow <= rowNum && newCol > 0 && newCol <= colNum)
                         j = dir(newRow, newCol);
                         if (j ~= 0)
                             if(indexOffset == 1)
                                coHogMid(i, 1) = ...                                    
                                    coHogMid(i, 1)+ 1;%2*norm(i1); 
                                    
                             else
                                coHogMid(8 + (indexOffset-2)*64+i*j, 1) = ...
                                    coHogMid(8 + (indexOffset-2)*64+i*j, 1) + 1;%norm(i1 +  j1);
                                    
                             end
                         end
                      end
                   end
               end
           end
        end
        yy = yy + y;
        coHog = [coHog; coHogMid];
        coHogMid = zeros((64*30+8),1);
    end
    yy = 0; 
    xx = xx+x;    
end
%coHog = coHog/sum(coHog);
end