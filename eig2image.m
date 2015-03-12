function [Lambda1,Lambda2,Ix,Iy, responseY, responseX]=eig2image(Dxx,Dxy,Dyy)
% This function eig2image calculates the eigen values from the
% hessian matrix, sorted by abs value. And gives the direction
% of the ridge (eigenvector smallest eigenvalue) .
% 
% [Lambda1,Lambda2,Ix,Iy ,responseY, responseX]=eig2image(Dxx,Dxy,Dyy)
%

%
% | Dxx  Dxy |
% |          |
% | Dxy  Dyy |

Dxx = im2double(Dxx);
Dxy = im2double(Dxy);
Dyy = im2double(Dyy);

ThetaInDegrees = [];
% Compute the eigenvectors of J, v1 and v2
tmp = ((Dxx - Dyy).^2 + 4*Dxy.^2);
tmp = sqrt(double(tmp));
v2x = 2*Dxy; v2y = Dyy - Dxx + tmp;

% Normalize
mag = sqrt(v2x.^2 + v2y.^2); i = (mag ~= 0);
v2x(i) = v2x(i)./mag(i);
v2y(i) = v2y(i)./mag(i);

% The eigenvectors are orthogonal
v1x = -v2y; 
v1y = v2x;

% Compute the eigenvalues
mu1 = 0.5*(Dxx + Dyy + tmp);
mu2 = 0.5*(Dxx + Dyy - tmp);

% Sort eigen values by  value (Lambda1)<(Lambda2)
check=(mu2)>(mu1);
check1=(mu1)>(mu2);


Lambda1=mu1; Lambda1(check)=mu2(check);
Lambda2=mu2; Lambda2(check)=mu1(check);

Ix=v1x; Ix(check)=v2x(check);
Iy=v1y; Iy(check)=v2y(check);

I1x=v1x; I1x(check1)=v2x(check1);
I1y=v1y; I1y(check1)=v2y(check1);

ThetaInDegrees = computeAngle(Ix, Iy);
[ responseY] = computeResponse(ThetaInDegrees, Lambda1);

%ThetaInDegrees1 = computeAngle(I1x, I1y);
responseX = computeResponseX(ThetaInDegrees, Lambda1);


end


function ThetaInDegrees = computeAngle(Ix, Iy)
    ThetaInDegrees = zeros(size(Ix));
    
    u = [ 1 0]';
    for x = 1:size(Ix,2)
        for y  = 1:size(Ix,1)
            v = [Ix(y,x) Iy(y,x)];
            CosTheta = dot(u,v)/(norm(u)*norm(v));
            ThetaInDegrees(y,x) = acos(CosTheta)*180/pi;
        end
    end
        
end

function [response] = computeResponse(ThetaInDegrees, Lambda1)
    response = zeros(size(Lambda1));
    
    for x = 1:size(Lambda1,2)
        for y  = 1:size(Lambda1,1)
            if((Lambda1(y,x) > 0  && ThetaInDegrees(y, x) > 45 && ThetaInDegrees(y, x) < 135))
           %if(Lambda1(y,x) > 5 && (ThetaInDegrees(y, x) > 30 && ThetaInDegrees(y, x) < 135))
           %if(Lambda1(y,x) >10 && (ThetaInDegrees(y, x) < 45 || ThetaInDegrees(y, x) > 150))
                response(y,x) = Lambda1(y,x);
           else
                response(y,x) = 0;  
                    
            end
        end
    end
        
end

function response = computeResponseX(ThetaInDegrees, Lambda1)
    response = zeros(size(Lambda1));
    
    for x = 1:size(Lambda1,2)
        for y  = 1:size(Lambda1,1)
           if(Lambda1(y,x) > 0 && (ThetaInDegrees(y, x) < 45 || ThetaInDegrees(y, x) > 135))
                response(y,x) = (Lambda1(y,x));
           else
                response(y,x) = 0;  
                    
            end
        end
    end
        
end




