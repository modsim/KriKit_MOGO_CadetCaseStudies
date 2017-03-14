function [yield, purity] = doSimulationAndCalculateYieldAndPurity(obj,processParameters)
    
    % x1 = initial step
    % x2 = first slope
    % x3 = second slope
    % Time Points when transition happens are fix!
    pGrad = processParameters(1:3);

    % Perform simulation if parameters have changed
    obj.modifyModelParams(pGrad);
    obj.SimulationResults = obj.sim.runWithParameters(obj.task, []);

    % SaveCurrent Process Parameters
    obj.SimulationResults.x = processParameters;
    
    obj.calculateYieldAndPurity();
    
    yield = obj.SimulationResults.Yield;
    purity = obj.SimulationResults.Purity;
end