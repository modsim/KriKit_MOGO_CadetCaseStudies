function [randMatrix] = addNoiseToCuttingTime(obj,varargin)
% This function can be used if the smapling time points are noisy
% (inaccurate measurement) 
    
    % Initialization
    randMatrix = varargin{1};
    rangeOfTime = varargin{2};
    
    % Error checking
    if ~size(randMatrix,2)==2
        error('randMatrix must be of length 2 (=#rows)')
    end
    if ~all(size(rangeOfTime)==[2,2])
        error('rangeOfTime must be of size 2X2')
    end
    
    % Noise calculation
    randMatrix = randMatrix + randn(size(randMatrix,1),2)*obj.SD_CuttingTimePoints;
    
    % Check Bounds
    randMatrix(randMatrix(:,1)<rangeOfTime(1,1),1) = rangeOfTime(1,1);
    randMatrix(randMatrix(:,2)<rangeOfTime(2,1),2) = rangeOfTime(2,1);
end

