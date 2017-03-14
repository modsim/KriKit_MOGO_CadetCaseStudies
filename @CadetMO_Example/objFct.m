function [y] = objFct(obj,varargin)

    nObj = obj.KrigingAnalyzeObj.getnKrigingObjects;
    inputParameters = varargin{1};
    [y1,y2] = obj.objFctCadet_Purity_Yield_EndTime_DeltaTime(inputParameters);
    y = [y1(:,1:nObj),y2];
    
    if size(inputParameters,1)>=1&&size(inputParameters,2)==5
        nPara = size(inputParameters,1);
        [~,peakindex] = max(obj.CadetObj.SimulationResults.solution.outlet(:, 1+2));
        peakTime = obj.CadetObj.SimulationResults.solution.time(peakindex);
        endTimePoint = obj.CadetObj.calculate_EndTime_AfterIntegration;
        for iPara = 1:nPara
            [inputParametersNoisy] = addNoiseToCuttingTime(obj.CadetObj,inputParameters(iPara,4:5),[obj.InputDataRange(4,:);obj.InputDataRange(5,:)]);

            obj.CadetObj.SimulationResults.x(4:5) = [peakTime-inputParametersNoisy(1),peakTime+inputParametersNoisy(2)];
            obj.CadetObj.calculateYieldAndPurityAfterIntegration

            switch nObj
                case 2
                    y = [y;...
                        obj.CadetObj.SimulationResults.Purity,...
                        obj.CadetObj.SimulationResults.Yield,...
                        inputParameters(iPara,:)];
                case 3
                    y = [y;...
                        obj.CadetObj.SimulationResults.Purity,...
                        obj.CadetObj.SimulationResults.Yield,...
                        1-endTimePoint/(obj.CadetObj.getBasicParams.endTime+1e3),...
                        inputParameters(iPara,:)];
                otherwise
                    error('nObj = %i not possible\n')
            end
        end
    end


end

