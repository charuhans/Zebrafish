function [Dxx,Dxy,Dyy] = Hessian2D(I,sig)
%  This function Hessian2 Filters the image with 2nd derivatives of a 
%  Gaussian with parameter Sigma.
% 
% [Dxx,Dxy,Dyy] = Hessian2(I,Sigma);
% 
% inputs,
%   I : The image, class preferable double or single
%   Sigma : The sigma of the gaussian kernel used
%
% outputs,
%   Dxx, Dxy, Dyy: The 2nd derivatives
%
% example,
%   I = im2double(imread('moon.tif'));
%   [Dxx,Dxy,Dyy] = Hessian2(I,2);
%   figure, imshow(Dxx,[]);
%
% Function is written by D.Kroon University of Twente (June 2009)

if nargin < 2, sig = 1; end

kernelSize = 0;

if sig>=1
    kernelSize = 8*sig + 1;
else
    kernelSize = 7;
end
    
kernVal = fix(ceil(kernelSize/2.0) - 1);

for x = -kernVal:kernVal    
    xp(x+kernVal + 1) = x;
    gp(x+kernVal + 1) = (1/(sqrt(2*pi)*sig))*exp(-((x*x)/(2*(sig*sig))));
end
    xp = [];

for x = -kernVal:kernVal
    xp(x+kernVal + 1) = x;
    dgp(x+kernVal + 1) = -(x/(sqrt(2*pi)*sig^3))*exp(-((x*x)/(2*(sig*sig))));
end

xp = [];
sig2 = sig*sig;
sig5 = sig*sig*sig*sig*sig;
     
for x = -kernVal:kernVal  
    xp(x+kernVal + 1) = x;
    ddgp(x+kernVal +1) = (x*x - sig2)/((sqrt(2*pi))*sig5)*exp(-1*x*x/(2*sig2));
end



s00 = filter2(gp, I);
s00 = filter2(gp', s00);

    s10 = filter2(gp', I);
    s10 = filter2(dgp, s10);

    s01 = filter2(gp, I);
    s01 = filter2(dgp', s01);

    Dxy = filter2(dgp, I);
    Dxy = filter2(dgp', Dxy);

    Dxx = filter2(gp', I);
    Dxx = filter2(gp', Dxx);
    Dxx = filter2(ddgp, Dxx);

    Dyy = filter2(gp, I);
    Dyy = filter2(gp, Dyy);
    Dyy = filter2(ddgp', Dyy); 

