function [] = estimateNoise(obj,varargin)
    if ~isempty(varargin)
        startingPoint = varargin{1};
    else
        startingPoint = -1;
    end
    obj.KrigingAnalyzeObj.KrigingObjects{1}.estimateVariance
    obj.KrigingAnalyzeObj.KrigingObjects{1}.calcCovariogramMatrix
    obj.KrigingAnalyzeObj.setShowDetails(true)
    obj.KrigingAnalyzeObj.KrigingObjects{1}.setMaxSizeOfPredictions(10e3)

    if startingPoint>=0
        obj.KrigingAnalyzeObj.KrigingObjects{1}.generateNoiseModel(startingPoint)
    else
        obj.KrigingAnalyzeObj.KrigingObjects{1}.generateNoiseModel
    end
    
    obj.KrigingAnalyzeObj.KrigingObjects{1}.setMaxSizeOfPredictions(1e2)
end

