function [] = doInitCadetSetting(obj)
    obj.doInitCadetSettingWithoutInjMass


    % Calculate total injected mass of each component
    % SECTION_TIMES ... Array containing the the spanned time for each
    %                   section (Load, Wash, Gradient1, Gradient2). 
    % sec_000.CONST_COEFF ... Array which conataints the constant
    %                   concentration of each component during the loading
    %                   step (section 0) 
    obj.CadetObj.injMass = obj.CadetObj.task.model.inlet.SECTION_TIMES(2) .* obj.CadetObj.task.model.inlet.sec_000.CONST_COEFF(2:end);
end