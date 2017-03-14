function [endTimePoint] = calculate_P_Y_EndTime_AfterInt(obj)
   % Calculate yield and purity
    nComponents = size(obj.SimulationResults.solution.outlet, 2)-1;
    masses = zeros(nComponents, 1);
    endTimePointVec = zeros(nComponents, 1);
    for iComponent = 1:nComponents
        
        masses(iComponent) = diff(ppval(obj.IntegralComponents{iComponent}, obj.SimulationResults.x(end-1:end)));
        if masses(iComponent)<1e-10
            masses(iComponent)=1e-10;
        end
        
%         nTimePoints = length(obj.SimulationResults.solution.time);
%         for iTimePoint = 1:100:nTimePoints
%             massInt = diff(ppval(obj.IntegralComponents{iComponent}, [0,obj.SimulationResults.solution.time(iTimePoint)]));
%             if massInt/obj.injMass(iComponent)>=0.999
%                 endTimePointVec(iComponent) = obj.SimulationResults.solution.time(iTimePoint);
%                 break
%             end
%         end
        iTimePoint = find(obj.SimulationResults.solution.outlet(:,iComponent+1)>1e-4,1,'last');
        massInt = diff(ppval(obj.IntegralComponents{iComponent}, [0,obj.SimulationResults.solution.time(iTimePoint)]));
        if massInt/obj.injMass(iComponent)>=0.999
            endTimePointVec(iComponent) = obj.SimulationResults.solution.time(iTimePoint);
        else
            warning('Process has not yet ended')
            keyboard
        end
    end
    
    endTimePoint = max(endTimePointVec);
    
    yield = masses(obj.idxTarget) / obj.injMass(obj.idxTarget);
    purity = masses(obj.idxTarget) / sum(masses);

    obj.SimulationResults.Yield = yield;
    obj.SimulationResults.Purity = purity; 
end