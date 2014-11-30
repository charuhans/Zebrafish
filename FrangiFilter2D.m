

function [outImY,whatScale] = FrangiFilter2D(I, options)
% This function FRANGIFILTER2D uses the eigenvectors of the Hessian to
% compute the likeliness of an image region to vessels, according
% to the method described by Frangi:2001 (Chapter 2).
%
% [J,Scale,Direction] = FrangiFilter2D(I, Options)
%
% inputs,
%   I : The input image (vessel image)
%   Options : Struct with input options,
%       .FrangiScaleRange : The range of sigmas used, default [1 8]
%       .FrangiScaleRatio : Step size between sigmas, default 2
%       .FrangiBetaOne : Frangi correction constant, default 0.5
%       .FrangiBetaTwo : Frangi correction constant, default 15
%       .BlackWhite : Detect black ridges (default) set to true, for
%                       white ridges set to false.
%       .verbose : Show debug information, default true
%
% outputs,
%   J : The vessel enhanced image (pixel is the maximum found in all scales)
%   Scale : Matrix with the scales on which the maximum intensity 
%           of every pixel is found
%   Direction : Matrix with directions (angles) of pixels (from minor eigenvector)   
%


defaultoptions = struct('ScaleRangeY', [0.5 3], 'ScaleRangeX', [0.5 3], 'ScaleRatio', 0.5, 'verbose',true,'BlackWhite',false);

% Process inputs
if(~exist('options','var')), 
    options=defaultoptions; 
else
    tags = fieldnames(defaultoptions);
    for i=1:length(tags)
         if(~isfield(options,tags{i})),  options.(tags{i})=defaultoptions.(tags{i}); end
    end
    if(length(tags)~=length(fieldnames(options))), 
        warning('Filter2D:unknownoption','unknown options found');
    end
end
I = imcomplement(I);
sigmas=options.ScaleRangeY(1):options.ScaleRatio:options.ScaleRangeY(2);
sigmas = sort(sigmas, 'ascend');


% Make matrices to store all filterd images

% Frangi filter for all sigmas
for i = 1:length(sigmas),
    % Show progress
    if(options.verbose)
        disp(['Current Frangi Filter Sigma: ' num2str(sigmas(i)) ]);
    end
    
    % Make 2D hessian
    [Dxx,Dxy,Dyy] = Hessian2D(I,sigmas(i));
    
    % Correct for scale
    Dxx = (sigmas(i)^2)*Dxx;
    Dxy = (sigmas(i)^2)*Dxy;
    Dyy = (sigmas(i)^2)*Dyy;
   
    % Calculate (abs sorted) eigenvalues and vectors
    [Lambda2,Lambda1,Ix,Iy, responseY]=eig2image(Dxx,Dxy,Dyy);


   
    % store the results in 3D matrices
    %ALLfilteredX(:,:,i) = responseX;
     ALLfilteredY(:,:,i) = responseY;
end

% Return for every pixel the value of the scale(sigma) with the maximum 
% output pixel value
if length(sigmas) > 1,
    %[outImX,whatScale] = max(ALLfilteredX,[],3);
    [outImY,whatScale] = max(ALLfilteredY(:,:,:),[],3);
%     [r, c] = find(outImY == 255);
%     idx = sub2ind(size(outImY), r,c);
%     outImY(idx)= 0;
    %outImX = reshape(outImX,size(I));
    outImY = reshape(outImY,size(I));
    if(nargout>1)
        whatScale = reshape(whatScale,size(I));
    end
    %if(nargout>2)
        %Direction = reshape(ALLangles((1:numel(I))'+(whatScale(:)-1)*numel(I)),size(I));
    %end
else
    %outImX = reshape(ALLfilteredX,size(I));
    outImY = reshape(ALLfilteredY,size(I));
    if(nargout>1)
            whatScale = ones(size(I));
    end
    %if(nargout>2)
        %Direction = reshape(ALLangles,size(I));
    %end
end
end
