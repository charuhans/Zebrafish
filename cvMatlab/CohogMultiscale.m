function [pyramindCoHog] = CohogMultiscale(I, bin, angle, L, options)
pyramindCoHog = [];

%defaultoptions = struct('ScaleRange', [1 10], 'ScaleRatio', 2, 'verbose',true, 'BlackWhite',true);
% positive
defaultoptions = struct('PyramidRange', [0 0], 'ScaleRatio', 1, 'verbose',true, 'BlackWhite',true, 'Margin', 3);
% negative 
%defaultoptions = struct('PyramidRange', [1 4], 'ScaleRatio', 1, 'verbose',true, 'BlackWhite',true, 'Margin', 0);

% Process inputs
if(~exist('options','var')), 
    options=defaultoptions; 
else
    tags = fieldnames(defaultoptions);
    for i=1:length(tags)
         if(~isfield(options,tags{i})),  options.(tags{i}) = defaultoptions.(tags{i}); end
    end
    if(length(tags)~=length(fieldnames(options))), 
        warning('CohogMultiscale:unknownoption','unknown options found');
    end
end

sigmas=options.PyramidRange(1):options.ScaleRatio:options.PyramidRange(2);
sigmas = sort(sigmas, 'ascend');
nAngle = angle/bin;

% filter for all sigmas
for i = 1:length(sigmas),
    % Show progress
    if(options.verbose)
        disp(['Current Filter Sigma: ' num2str(sigmas(i))]);
    end
    % pyramid decomposition
    gaussPyramid = vision.Pyramid('PyramidLevel', sigmas(i));
    J = step(gaussPyramid, im2single(I));
    % Convert the gradient vectors to polar coordinates (angle and magnitude).
    [Gx,Gy] = gradient(double(J));
    Gr = sqrt((Gx.*Gx)+(Gy.*Gy));
    index = Gx == 0;
    Gx(index) = 1e-5;
    YX = Gy./Gx;
    if angle == 180, A = ((atan(YX)+(pi/2))*180)/pi; end
    if angle == 360, A = ((atan2(Gy,Gx)+pi)*180)/pi; end
    A = ceil(A./nAngle);
    A = imcrop(A, [fix(options.Margin/2^(i - 1)), fix(options.Margin/2^(i - 1)), size(A,2) - fix(options.Margin/2^(i - 2)) - 1, size(A,1) - fix(options.Margin/2^(i - 2)) - 1]);
    coHog = coHogVector(A,L);
    pyramindCoHog = [pyramindCoHog; coHog];
end
    
    
   
    