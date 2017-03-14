function []=generateInputDataRange(obj,varargin)
    percentageVariationIni = varargin{1};
    if length(varargin)>1
        doSimulation = varargin{2};
    else
        doSimulation = true;
    end

    factorMaxSalt = 5;
    maxSalt = 1.5e3;
    InputDataRangeOriginal = [obj.CadetObj.bp.initialSalt,maxSalt/factorMaxSalt;...
                       obj.CadetObj.bp.initialSalt,maxSalt;
                       obj.CadetObj.bp.startTime+1e1,obj.CadetObj.bp.endTime-obj.CadetObj.bp.startTime-1e1;
                       5e0,1e3;...
                       5e0,1e3];
                   
    % You can set cellObj.UseLatinHyperCube (if =0 then random sampling is used)
    obj.InputDataRange=adjustIniRange(InputDataRangeOriginal,1:3,percentageVariationIni);
    if doSimulation
        obj.generateInitialSimulations(1:3)
    end
    obj.InputDataRange=InputDataRangeOriginal;
end