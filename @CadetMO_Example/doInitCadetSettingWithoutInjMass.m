function [] = doInitCadetSettingWithoutInjMass(obj)
    warnStateGrid = warning('off', 'MATLAB:interp1:ppGriddedInterpolant');
    warnStatePchip = warning('off', 'MATLAB:interp1:UsePCHIP');

    % Target component is 2 (index would be 3 when including salt)
    obj.CadetObj.idxTarget = 2;
    % Minimum purity constraint (95 %)
    obj.CadetObj.minPurity = 0.95;
    % Length of the column in ?m?
    obj.CadetObj.colLength = 0.014;
    % Threshold for complete elution in mM
    obj.CadetObj.elutionLimit = 1e-6;   

    % Parameters for the CADET solver
    obj.CadetObj.params = [{'sectionConstant'}, {'sectionLinear'}, {'sectionLinear'}, {'sectionConstant'}]; % Parameter names
    obj.CadetObj.comps = [1 1 1 1]; % Component index of the parameters (1 = salt)
    obj.CadetObj.secs = [3 3 4 4];  % Section index of the parameters (3 = gradient1, 4 = gradient2)
    
    % Note that CADET is currently not able to compute the derivative with
    % respect to length of the gradient. This derivative will be computed
    % finite differences. However, due to continuity of the gradients, the
    % derivative with respect to the starting concentration of gradient 2
    % is required. 

    % Specifiy linear parameter transform (takes all parameters to rougly
    % the same order of magnitude)
    obj.CadetObj.transform = diag([0.1, 1000, 0.01, 0.01, 0.01]);
    obj.CadetObj.invTransform = diag([10, 0.001, 100, 100, 100]);


    % Specify lower and upper bounds on parameters
    % Layout: start, slope1, slope2, len, collect start, collect stop
    obj.CadetObj.lb = [obj.CadetObj.bp.initialSalt, 0.001, 120, 0, 0];
    obj.CadetObj.ub = [500, 10, obj.CadetObj.bp.endTime - obj.CadetObj.task.model.inlet.SECTION_TIMES(3) - 120, obj.CadetObj.bp.endTime, obj.CadetObj.bp.endTime];

end