function [] = calculateYieldPurityConcentrationAfterIntegration(obj)
   % Calculate yield and purity
    nComponents = size(obj.SimulationResults.solution.outlet, 2)-1;
    masses = zeros(nComponents, 1);
    for iComponent = 1:nComponents
        masses(iComponent) = diff(ppval(obj.IntegralComponents{iComponent}, obj.SimulationResults.x(end-1:end)));
        if masses(iComponent)<1e-10
            masses(iComponent)=1e-10;
        end
    end

    yield = masses(obj.idxTarget) / obj.injMass(obj.idxTarget);
    purity = masses(obj.idxTarget) / sum(masses);
    concentration = masses(obj.idxTarget) / (obj.SimulationResults.x(end)-obj.SimulationResults.x(end-1));
    % Normalization
    concentration = concentration/obj.injMass(obj.idxTarget)*10;
    
    obj.SimulationResults.Yield = yield;
    obj.SimulationResults.Purity = purity; 
    obj.SimulationResults.Concentration = concentration; 
end