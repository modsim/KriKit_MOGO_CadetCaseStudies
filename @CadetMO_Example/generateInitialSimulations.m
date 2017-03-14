function [] = generateInitialSimulations(obj,varargin)
% function [] = generateInitialSimulations(indicesParaOfInterest)
    
    % Intitialization
    nPara = size(obj.InputDataRange,1);
    if ~isempty(varargin)
        indicesParaOfInterest = varargin{1};
    else
        indicesParaOfInterest = 1:nPara;
    end
%     obj.resetData
    
    if obj.UseLatinHyperCube
        % Lattin HyperCube Portion
        iniPoints = lhsdesign(10*obj.nInputVar,obj.nInputVar);
        iniPoints = bsxfun(@times,iniPoints,obj.InputDataRange(:,2)'-obj.InputDataRange(:,1)');
        iniPoints = bsxfun(@plus,iniPoints,obj.InputDataRange(:,1)');
        
    else
        % InputDataRange has to be defined a priori 
        min1RunX = obj.InputDataRange(1,1);
        max1RunX = obj.InputDataRange(1,2);
        
        % Define Sample Plan
        if obj.nInputVar==1
            centerPoint = min1RunX+(max1RunX-min1RunX)/2;
            iniPoints = [min1RunX;max1RunX;centerPoint];
        else
            iniPoints  = createNDGRID(obj.InputDataRange(indicesParaOfInterest,1),obj.InputDataRange(indicesParaOfInterest,2),obj.nGridLevel);
            centerPoint = mean(obj.InputDataRange(indicesParaOfInterest,:),2)';
            iniPoints = [iniPoints;centerPoint];
        end
    end
    
    if ~isempty(obj.InequalityConstraintHandle)
       iniPoints = obj.deleteInvalidSamples(iniPoints); 
    end
    
    % Initialitation
    outputProto = obj.objFct(iniPoints);
    obj.OutputData = outputProto(:,1:end-obj.nInputVar);
        
    % Save Input Data
    obj.InputData = outputProto(:,end-obj.nInputVar+1:end);

    obj.SaveInputDataOverIterations{1} = obj.InputData;
    obj.SaveOutputDataOverIterations{1} = obj.OutputData;
end

