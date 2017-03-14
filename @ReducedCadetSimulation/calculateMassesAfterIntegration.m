function [masses] = calculateMassesAfterIntegration(obj)
   % Initialization
    nComponents = size(obj.SimulationResults.solution.outlet, 2)-1;
    masses = zeros(nComponents, 1);
    
    % Interpolatie the mass for ech component
    for iComponent = 1:nComponents
        masses(iComponent) = diff(ppval(obj.IntegralComponents{iComponent}, obj.SimulationResults.x(end-1:end)));
        if masses(iComponent)<1e-10
            masses(iComponent)=1e-10;
        end
    end
end