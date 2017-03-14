function [f, purity] = doSimulationAndCalculateYield(obj,processParameters)
    
    % Inverse transform from optimizer to simulator space
%     processParameters = processParameters * obj.invTransform';
    
    % x1 = initial step
    % x2 = first slope
    % x3 = second slope
    % Time Points when transition happens are fix!
    pGrad = processParameters(1:3);
%     % Cutting point indicate the time points after the simulation for
%     % measureing the conentration and purity of the desired product
%     pCut = processParameters(4:5);

    % Perform simulation if parameters have changed
    obj.modifyModelParams(pGrad);
    obj.SimulationResults = obj.sim.runWithParameters(obj.task, []);
%     save
    nTimePoints = size(obj.SimulationResults.solution.outlet,1);
    nComponents = size(obj.SimulationResults.solution.outlet,2);
    obj.SimulationResults.solution.outlet = obj.SimulationResults.solution.outlet + obj.NoiseRatio*obj.SimulationResults.solution.outlet.*randn(nTimePoints,nComponents);
    obj.SimulationResults.solution.outlet(obj.SimulationResults.solution.outlet<0)=0;
    obj.SimulationResults.x = processParameters;
    
    obj.calculateYieldAndPurity();
    
end