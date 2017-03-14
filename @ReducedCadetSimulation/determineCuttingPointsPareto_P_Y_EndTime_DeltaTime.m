function [cuttingPoints,paretoSet] = determineCuttingPointsPareto_P_Y_EndTime_DeltaTime(obj,varargin)
% [cuttingPoints,paretoSet] = determineCuttingPointsParetoSet(rangeOfTime,minMax,useLattinHyperCube)
    
    % Define Input 
    rangeOfTime = varargin{1};
    minMax = varargin{2};
    useLattinHyperCube = varargin{3};
    
    % Intiialization
    nOutVariableDepnedingOnTime = 2;
    nRandSamples = obj.nRandSamples;
    nAddedExtremePoints = 2;
    
    % Add two extreme points
    outputMatrix = zeros(nRandSamples+nAddedExtremePoints,nOutVariableDepnedingOnTime);
    obj.calcIntegralAndSplineComponents
    
    % Construct design
    if useLattinHyperCube
        % In case of inequality constraint, a lot more time values have to
        % be checked in order to be sure that valid points are found
        if ~isempty(obj.InEqConstraintPurityYield)
            nRandSamplesBackUp = obj.nRandSamples;
            obj.nRandSamples = 1e4;
            nRandSamples = obj.nRandSamples;
        end
        
        randMatrix = createLHSWithExtremePoints(obj);
        
        if ~isempty(obj.InEqConstraintPurityYield)
            obj.nRandSamples = nRandSamplesBackUp;
        end

    else
        % On a grid
        nPointsEachDirection = floor(sqrt(nRandSamples));
        linVec = linspace(0,1,nPointsEachDirection);
        [t1,t2] = ndgrid(linVec,linVec);
        randMatrix = [t1(:),t2(:)];
        
        % Fill remaining points with random samples
        randMatrixRemaining = rand(nRandSamples-nPointsEachDirection,2);
        randMatrix = [randMatrix;randMatrixRemaining];
    end
    
    % Scaling
    randMatrix(:,1) = randMatrix(:,1)*(rangeOfTime(1,2)-rangeOfTime(1,1)) + rangeOfTime(1,1);
    randMatrix(:,2) = randMatrix(:,2)*(rangeOfTime(2,2)-rangeOfTime(2,1)) + rangeOfTime(2,1);
    
    % Add Extreme Points Manually
    if ~useLattinHyperCube
        randMatrix = [randMatrix;rangeOfTime(1,1),rangeOfTime(1,1);rangeOfTime(1,2),rangeOfTime(1,2)];
    end
    
    % Find Time point with maximal concnetration of desired component
    [~,peakindex] = max(obj.SimulationResults.solution.outlet(:, 1+obj.idxTarget));
    peakTime = obj.SimulationResults.solution.time(peakindex);
    
    % Add Noise and Hold Bounds
    [randMatrixNoisys] = addNoiseToCuttingTime(obj,randMatrix,rangeOfTime);
    
    % Limit maximum time
    if any(randMatrixNoisys(:,2)+peakTime>(obj.bp.endTime+1e3))
        warning('t2+peakTime out of range')
        randMatrixNoisys(randMatrixNoisys(:,2)+peakTime>obj.bp.endTime+1e3,2)=obj.bp.endTime+1e3;
    end
        
    % Calculate Purity and Yield
    for iSample = 1:nRandSamples+nAddedExtremePoints
        obj.SimulationResults.x(4:5) = [peakTime-randMatrixNoisys(iSample,1),peakTime+randMatrixNoisys(iSample,2)];
        
        obj.calculateYieldAndPurityAfterIntegration
        
        % Formulate the output, normalize everything to [0,1] and
        % reformulate it to a maximization problem
        outputMatrix(iSample,:) = [obj.SimulationResults.Purity,...
                                   obj.SimulationResults.Yield];
    end
    [endTimePoint]=obj.calculate_EndTime_AfterIntegration;
    
    % Consider Only sample which lead to at least x% Purity (Not Used as
    % initial parameter do not always lead to feasible solutions) 
    if ~isempty(obj.InEqConstraintPurityYield)
        goodPurityBool = obj.InEqConstraintPurityYield(outputMatrix);
        nValid = sum(goodPurityBool);
        if nValid<obj.nRandSamples
            warning('Not Enough valid samples. Sample array is completed with random samples')
            
            idxInvalid = find(~goodPurityBool);
            idxRand = randperm(length(idxInvalid),obj.nRandSamples-nValid);
            goodPurityBool(idxInvalid(idxRand)) = true;
        else
            % Deactivate randomly point until exact nRandSamples are chosen
            idxValid = find(goodPurityBool);
            idxRand = randperm(nValid,nValid-obj.nRandSamples);
            goodPurityBool(idxValid(idxRand)) = false;
        end
    else
        goodPurityBool = outputMatrix(:,1)>=0;
    end
    randMatrixGoodPurity = randMatrix(goodPurityBool,:);
    cuttingPoints = randMatrixGoodPurity;
    

    % Add end time point of the entire process (only depends on the
    % gradiend parameter and conseqeuntly no random calculation is needed)
    paretoSet = [outputMatrix(goodPurityBool,:),...
                 repmat(1-endTimePoint/(obj.getBasicParams.endTime+1e3),sum(goodPurityBool),1)];
end

