function [] = finalSettings(obj)
    
    nObj = obj.KrigingAnalyzeObj.getnKrigingObjects;
    obj.KrigingAnalyzeObj.KrigingObjects{1}.setShowWaitingBar(false);

    obj.KrigingAnalyzeObj.setShowDetails(false);
    obj.KrigingAnalyzeObj.setShowData(false);
    obj.KrigingAnalyzeObj.determineParetoSet(1:nObj);

    obj.KrigingAnalyzeObj.setAccuracy(10);
    
    for iObj = 1:nObj
        obj.KrigingAnalyzeObj.setLBInputVarInterpolation(iObj,obj.InputDataRange(:,1))
        obj.KrigingAnalyzeObj.setUBInputVarInterpolation(iObj,obj.InputDataRange(:,2))
    end

end

