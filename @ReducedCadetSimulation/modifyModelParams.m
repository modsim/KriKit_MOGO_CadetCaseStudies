function [] = modifyModelParams(obj, pGrad)
%MODIFYMODELPARAMETERS Modifies the model parameters subject to given
% process parameters.

    % Check for vector input
    len = pGrad(3);
    slope1 = pGrad(2);
    start = pGrad(1);

    % Set length of first gradient
    obj.task.model.inlet.SECTION_TIMES(4) = obj.task.model.inlet.SECTION_TIMES(3) + len;
    
    % Set start and slope for first gradient
    obj.task.model.inlet.sec_002.CONST_COEFF(1) = start;
    obj.task.model.inlet.sec_002.LIN_COEFF(1) = slope1;

    % Set start and slope for second gradient (continuity requires that
    % start(grad2) = end(grad1).
    obj.task.model.inlet.sec_003.CONST_COEFF(1) = start + slope1 * len;
    obj.task.model.inlet.sec_003.LIN_COEFF(1) = (obj.bp.maxSalt - start - slope1 * len) / (obj.bp.endTime - len - obj.bp.startTime);
end