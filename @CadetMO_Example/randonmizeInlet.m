function [] = randonmizeInlet(obj,varargin)
% function [] = randonmizeInlet(sdComponentInlet)
    sdComponentInlet = varargin{1};

    % Randomize Inlet 
    randNumbers = randn(3,1);
    obj.CadetObj.sim.model.sectionConstant(2:end,1) = ...
        obj.CadetObj.sim.model.sectionConstant(2:end,1) + ...
        obj.CadetObj.sim.model.sectionConstant(2:end,1).*randNumbers.*sdComponentInlet;
    obj.CadetObj.sim.model.sectionConstant(obj.CadetObj.sim.model.sectionConstant(:,1)<=0,1)=1e-10;

    % Make simulation ready
    warning('off','MATLAB:subscripting:noSubscriptsSpecified')
    obj.CadetObj.task = obj.CadetObj.sim.prepareSimulation();
    warning('on','MATLAB:subscripting:noSubscriptsSpecified')
end