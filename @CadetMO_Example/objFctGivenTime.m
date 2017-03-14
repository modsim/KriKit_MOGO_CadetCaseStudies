function [y] = objFctGivenTime(obj,varargin)

    %% Initialization
    nObj = obj.KrigingAnalyzeObj.getnKrigingObjects;
    inputParameters = varargin{1};
    nPara = size(inputParameters,1);
    % Only one simulation each unique gradient parameter set
    uniqueGrad = unique(inputParameters(:,1:3),'rows');
    nGrad = size(uniqueGrad,1);
    y = zeros(nPara,nObj+5);
    idxVecTrue = zeros(nPara,1);
    
    %% Actual Simulation/Calculation
    idxCounter = 1;
    
    for iGrad = 1:nGrad
        obj.objFctCadet_Purity_Yield_EndTime_DeltaTime(uniqueGrad(iGrad,:));
        
        pGradIdx = find(all(bsxfun(@eq,inputParameters(:,1:3),uniqueGrad(iGrad,:)),2));
        nParaUnique = length(pGradIdx);
        [~,peakindex] = max(obj.CadetObj.SimulationResults.solution.outlet(:, 1+2));
        peakTime = obj.CadetObj.SimulationResults.solution.time(peakindex);
        endTimePoint = obj.CadetObj.calculate_EndTime_AfterIntegration;
        
        for iPara = 1:nParaUnique
            [inputParametersNoisy] = addNoiseToCuttingTime(obj.CadetObj,inputParameters(pGradIdx(iPara),4:5),[obj.InputDataRange(4,:);obj.InputDataRange(5,:)]);
            idxVecTrue(idxCounter) = find(all(bsxfun(@eq,inputParameters,inputParameters(pGradIdx(iPara),:)),2));
            obj.CadetObj.SimulationResults.x(4:5) = [peakTime-inputParametersNoisy(1),peakTime+inputParametersNoisy(2)];
            obj.CadetObj.calculateYieldAndPurityAfterIntegration

            switch nObj
                case 2
                    y(idxCounter,:) = [obj.CadetObj.SimulationResults.Purity,...
                                       obj.CadetObj.SimulationResults.Yield,...
                                       inputParameters(pGradIdx(iPara),:)];
                case 3
                    y(idxCounter,:) = [obj.CadetObj.SimulationResults.Purity,...
                                       obj.CadetObj.SimulationResults.Yield,...
                                       1-endTimePoint/(obj.CadetObj.getBasicParams.endTime+1e3),...
                                       inputParameters(pGradIdx(iPara),:)];
                otherwise
                    error('nObj = %i not possible\n')
            end
            idxCounter = idxCounter +1;
        end
    end

    idxVecTrueBackUp = idxVecTrue;
    [sortIdx,idxVecTrue]=sort(idxVecTrue);
    yBackUp = y;
    y = y(idxVecTrue,:);
    
end

