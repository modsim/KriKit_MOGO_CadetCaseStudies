function [paretoSetTotal,inputParameterSetWithCuttingPoints] = objFctCadet_Purity_Yield_EndTime_DeltaTime(obj,varargin)

    % Initialization
    inputParameterSets = varargin{1};
    if size(inputParameterSets,1)==obj.nInputVar&&size(inputParameterSets,2)~=obj.nInputVar
        inputParameterSets = inputParameterSets';
    end
    inputParameterSets = inputParameterSets(:,1:3);
    nParametersSet = size(inputParameterSets,1);
    inputParameterSetWithCuttingPoints = [];
    paretoSetTotal = [];
    
    % Perform simulation for all input parameter sets
    for iParameterSet = 1:nParametersSet
        
        % Reset Model
        obj.CadetObj.doInit
        
        % Apply noise w.r.t. inlet concentration
        obj.randonmizeInlet(obj.SdComponentInlet);
        if obj.RandInjMassBool
            obj.doInitCadetSetting
        else
            obj.doInitCadetSettingWithoutInjMass
        end
        
        % Set model parameter to current parameter set
        obj.CadetObj.modifyModelParamsP2HightNotGradient(inputParameterSets(iParameterSet,:));
        
        % Run simulation
        obj.CadetObj.SimulationResults = obj.CadetObj.sim.runWithParameters(obj.CadetObj.task, []);
        
        % Apply noise to chromatogram curve
        rowRand = size(obj.CadetObj.SimulationResults.solution.outlet,1);
        colRand = size(obj.CadetObj.SimulationResults.solution.outlet,2)-1;
        nObj = obj.KrigingAnalyzeObj.getnKrigingObjects;
        randValues = bsxfun(@times,randn(rowRand,colRand),obj.SampleMeasurementNoise);
        obj.CadetObj.SimulationResults.solution.outlet = ...
                     [obj.CadetObj.SimulationResults.solution.outlet(:,1),...
                      obj.CadetObj.SimulationResults.solution.outlet(:,2:end) + randValues];
        obj.CadetObj.SimulationResults.x = [inputParameterSets(iParameterSet,:),0,0];
        
        % Calculate cutting point and associated purity as well as yield 
        [cuttingPoints,paretoSet] = obj.CadetObj.determineCuttingPointsPareto_P_Y_EndTime_DeltaTime(...
                                                    [obj.InputDataRange(4,:);obj.InputDataRange(5,:)],...
                                                    obj.KrigingAnalyzeObj.getMinMax(1:nObj),...
                                                    obj.UseLHSForObj);
        nParetoPoints = size(cuttingPoints,1);
        
        % Combine current data set with previous data set
        if ~isempty(cuttingPoints)&&~isempty(paretoSet)
            paretoSetTotal = [paretoSetTotal;paretoSet];
            inputParameterSetWithCuttingPoints = [inputParameterSetWithCuttingPoints;repmat(inputParameterSets(iParameterSet,:),nParetoPoints,1),cuttingPoints];
        else
            warning('No Pareto Set')
        end
    end
    
end

