function [globalUncertainity,globalUncertainityNorm,HV] = updateCalcOfParetoCurve(cellObj,nRealizations,iIter,iKrigingEstimation,globalUncertainityMatrix,globalUncertainityNormMatrix,HVMatrix)
    cellObj.KrigingAnalyzeObj.predictParetoCurve(1:3,nRealizations,(10^3),30);
    globalUncertainity=cellObj.KrigingAnalyzeObj.getGlobalParetoUncertainity;
    globalUncertainityNorm=cellObj.KrigingAnalyzeObj.getGlobalParetoUncertainityNorm;
    HV=Hypervolume_MEX(-cellObj.OutputData,[0,0,0]);
    
    cellObj.GlobalUncertainity(iKrigingEstimation) = globalUncertainity;
    cellObj.GlobalUncertainityNorm(iKrigingEstimation) = globalUncertainityNorm;
    cellObj.HVVec(iKrigingEstimation) = HV;
    
    
end

