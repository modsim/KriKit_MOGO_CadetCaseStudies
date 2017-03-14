function [cellObj]=initializeCellObj(varargin)
    cellObj = varargin{1};
    nMCMCLinks = varargin{2};
    noiseMatrix = varargin{3};
    nRandSamples = varargin{4};
    RandInjMassBool = varargin{5};
    ConsiderOnlyMaxExpectedImprovement = varargin{6};
    
    % Check Input
    if length(varargin)>7
        SD_CuttingTimePoint = varargin{8};
    else
        SD_CuttingTimePoint = 0;
    end
    
    % General Initialization
    cellObj.KrigingAnalyzeObj.setAccuracy(1e2);
    cellObj.UseLatinHyperCube=false;
    cellObj.nInputVar=5;
    cellObj.nGridLevel = 2;

%     cellObj.setExperimentName(strcat('Rand_',num2str(nMCMCLinks),'_nIter',num2str(nIter),'_Gradient2'))

    % Cadet Intitialization
    switch size(noiseMatrix,2)
        case 1
            cellObj.SdComponentInlet = noiseMatrix; % Not bigger then (1-MinNeededYield) otherwise, minimal needed yield is often never reached
        case 2
            cellObj.SdComponentInlet = noiseMatrix(:,1); % Not bigger then (1-MinNeededYield) otherwise, minimal needed yield is often never reached
            cellObj.SampleMeasurementNoise = noiseMatrix(:,1); 
        otherwise
    end
    cellObj.doInitCadetSetting
    cellObj.CadetObj.MinNeededYield = 0.95;

    % Define the values for the Kriging Settings
%     cellObj.defineKrigingSetting();
    cellObj.KrigingAnalyzeObj.setMinMax(1,1)
    cellObj.KrigingAnalyzeObj.setMinMax(2,1)
    cellObj.KrigingAnalyzeObj.setMinMax(3,1)
    cellObj.KrigingAnalyzeObj.setReferencePointHyperVolume(zeros(1,3));
    cellObj.CadetObj.nRandSamples = nRandSamples;
    cellObj.RandInjMassBool = RandInjMassBool;
    cellObj.KrigingAnalyzeObj.setnMCMCLinks(nMCMCLinks); 
    cellObj.KrigingAnalyzeObj.setnCutLinks(round(nMCMCLinks*0.1));
    cellObj.KrigingAnalyzeObj.setConsiderOnlyMaxExpectedImprovement(ConsiderOnlyMaxExpectedImprovement)
    cellObj.CadetObj.SD_CuttingTimePoints = SD_CuttingTimePoint;
    
%     cellObj.objFctChoice=10;
end