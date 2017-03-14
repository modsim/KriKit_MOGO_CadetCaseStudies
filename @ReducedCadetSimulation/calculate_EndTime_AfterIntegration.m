function [endTimePoint] = calculate_EndTime_AfterIntegration(obj)
   % Calculate yield and purity
    nComponents = size(obj.SimulationResults.solution.outlet, 2)-1;
    endTimePointVec = zeros(nComponents, 1);
    
    iPeakIsTerminated = 0;
    for iComponent = 1:nComponents
        nTimePoints = length(obj.SimulationResults.solution.time);
        maxMass = diff(ppval(obj.IntegralComponents{iComponent}, [0,obj.SimulationResults.solution.time(end)]));
        for iTimePoint = 1:nTimePoints
            massInt = diff(ppval(obj.IntegralComponents{iComponent}, [0,obj.SimulationResults.solution.time(iTimePoint)]));
            
            if massInt/maxMass>=obj.MinNeededYield
                endTimePointVec(iComponent) = obj.SimulationResults.solution.time(iTimePoint);
                iPeakIsTerminated = iPeakIsTerminated+1;
                break
            end
        end
%         iTimePoint = find(obj.SimulationResults.solution.outlet(:,iComponent+1)>1e-4,1,'last');
%         massInt = diff(ppval(obj.IntegralComponents{iComponent}, [0,obj.SimulationResults.solution.time(iTimePoint)]));
%         if massInt/obj.injMass(iComponent)>=0.999
%             endTimePointVec(iComponent) = obj.SimulationResults.solution.time(iTimePoint);
%         else
%             warning('Process has not yet ended')
%             keyboard
%         end
    end
    
    if iPeakIsTerminated<nComponents
        endTimePoint = obj.getBasicParams.endTime;
    else
        endTimePoint = max(endTimePointVec);
    end
    

end