function []=saveResults(cellObj,index)
    

    nIter = size(cellObj,1);
    % Assume same number of sequential optimization steps and objects
    nOptIter = length(cellObj{1}.GlobalUncertainity); 
    nObj = cellObj{1}.KrigingAnalyzeObj.getnKrigingObjects;
    
    % Add First Row
    globalUncertainityMatrix = zeros(nIter,nOptIter);
    globalUncertainityNormMatrix = zeros(nIter,nOptIter);
    HVMatrix = zeros(nIter,nOptIter);
    
    for iIter=1:nIter
        globalUncertainityMatrix(iIter,:) = cellObj{iIter}.GlobalUncertainity;
        globalUncertainityNormMatrix(iIter,:) = cellObj{iIter}.GlobalUncertainityNorm;
        HVMatrix(iIter,:) = cellObj{iIter}.HVVec;
        cellObj{iIter}.KrigingAnalyzeObj.removeKrigingObject(1:nObj);
    end
    for iIter=1:nIter
        cellObj{iIter}.KrigingAnalyzeObj.addKrigingObject(1,'Purity');
        cellObj{iIter}.KrigingAnalyzeObj.addKrigingObject(1,'Yield');
        cellObj{iIter}.KrigingAnalyzeObj.addKrigingObject(1,'Process Time');
    end
    
    save(strcat('FinalResults_',num2str(floor(index))))
end