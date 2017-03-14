function [] = calculateYieldAndPurityAfterIntegration(obj)
% Run "calcIntegralAndSplineComponents()" before in order to calculate
% "IntegralComponents"

    % Initialization
    nComponents = size(obj.SimulationResults.solution.outlet, 2)-1;
    masses = zeros(nComponents, 1);
    
    % Interpolate samples mass for each component
    for iComponent = 1:nComponents
        masses(iComponent) = diff(ppval(obj.IntegralComponents{iComponent}, obj.SimulationResults.x(end-1:end)));
        if masses(iComponent)<1e-10
            masses(iComponent)=1e-10;
        end
    end

    % Actual calculation
    yield = masses(obj.idxTarget) / obj.injMass(obj.idxTarget);
    purity = masses(obj.idxTarget) / sum(masses);

    obj.SimulationResults.Yield = yield;
    obj.SimulationResults.Purity = purity; 
end