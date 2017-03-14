close all
clear
rng('shuffle')
clc

% This script represents the case study used in the article
% "Multi-Objective Global Optimization (MOGO): Algorithm and Case Study in
% Gradient Elution Chromatography" (Freier2017)
%
% Requirements: 
% 1. KriKit Toolbox, avaiable under https://github.com/modsim/KriKit
% 2. CADET Version 2.3.2: https://github.com/modsim/CADET
% 3. Statistics and Machine Learning Toolbox (MATLAB)
%
% Make sure before running script: 
% Add Class "CadetMO_Example" to your paths
% Add Class "ReducedCadetSimulation" to your paths
% Add Folder "inNeed" to your paths


%% Intitialization
% Decide how often optimization shall be repeated
nOptimizationRuns = 1;
% number of optimization iterations
maxKrigingEstimations = 3;
% Number of realization used for conditional simulation. The higher the
% better the quality
nRealizations = 500;
% Standard deviation for relative feed noise
SdComponentInlet = ones(3,1)*0.000;
% Decide if loaded concentration shall be known (=false). If false, the
% yield is not noisy at all
RandInjMassBool = true;
% Number of different cutting times used for the investiagtion of sampling
% time dependency
nRandSamples = 1e1;
% Adjust range in which input variables for initial experiments shall be
% varied. (max = 0.5, mean +-50% around center point = 100% of allowed
% range)
percentageVariationIni = 0.5;
% Number of Links generated during DRAM
nMCMCLinks = 1e4+1;
% If true, only link in MCMC is used which leads to maximal expected
% improvement. Only possible in case of sequential optimization
ConsiderOnlyMaxExpectedImprovement = true;
% Maximal number of iteration until the cooling down statregy shal be
% finished
iterMax = 1;
% initial value for the degree of expected improvement
maxValue = 50;
% Threshold for globl normed uncertainity which is used for stopping the
% optimization
thresholdGU = -0.043; % Negative means deactivation
nObjects = 3;
% Number of experiment(simulation) performed in each iteration
nParallelExpEachIteration = 1;

% Go to a folder where the results can be saved
try
    cd test
catch
    mkdir test
end

nWorkers = 2;
try
    pool1 = parpool(nWorkers);
catch ex
    warning(ex.message)
    delete(gcp)
    pool1 = parpool(nWorkers);
end

% Create cell array for parallel computation
cellObj = cell(nOptimizationRuns,1);

%% ################## Optimization Process ################## 
timeVec = cell(nOptimizationRuns,1);
parfor iOpt =1:nOptimizationRuns
    
    timeVec{iOpt} = tic;
    % degreeGradient is used for the cooling down strategy. The degree
    % represents the amplifier for the standard deviation.
    degreeGradient = sort([maxValue,linspace(1,maxValue,iterMax-1),ones(1,maxKrigingEstimations-iterMax)],'descend');

    % General Initialization
    cellObj{iOpt} = CadetMO_Example(nObjects);
        % The number of realizations indicated the number of conditional
        % simulations used for the estimation of the global model
        % uncertainty
    cellObj{iOpt}.nRealizations = nRealizations;
    cellObj{iOpt} = initializeCellObj(cellObj{iOpt},nMCMCLinks,SdComponentInlet,nRandSamples,RandInjMassBool,ConsiderOnlyMaxExpectedImprovement);
    cellObj{iOpt}.KrigingAnalyzeObj.setnNewSamples(nParallelExpEachIteration);
    fprintf('Initial Simulations (iIter = %i)\n',iOpt);
    
    
    % Perform initial experiments based on a full factorial design with one
    % cneter point. The full factorial design is placed in a hyper cube
    % where the each length can be adjusted by percentageVariationIni
    cellObj{iOpt}.generateInputDataRange(percentageVariationIni);

    % Create initial kriging model based on initial simulation data
    cellObj{iOpt}.calcKriging
    cellObj{iOpt}.setVariableNames({'p_1','p_2','p_3','{\Delta}t_1','{\Delta}t_2'},...
                                    {'Purity','Yield','Process Time'})
    cellObj{iOpt}.finalSettings();

    % Estimation of the initial pareto Front and global uncertainity
    cellObj{iOpt}.estimateParetoCurve(1)

    %% Loop investigation
    for iKrigingEstimation=2:maxKrigingEstimations
        fprintf('iIter: %i - iKriging: %i -nSamples: %i - DG: %g\n',iOpt,iKrigingEstimation,size(cellObj{iOpt}.InputData,1),degreeGradient(iKrigingEstimation))
        
        % Apply cooling down strategy
        cellObj{iOpt}.KrigingAnalyzeObj.setDegreeOfExpectedImprovement(degreeGradient(iKrigingEstimation));
        
        % New Samples are either chosen based on MCMC sampling using the
        % expected improvement as probability function
        cellObj{iOpt}.KrigingAnalyzeObj.determineParetoSet([1,2,3])
        nCurrentSamples = size(cellObj{iOpt}.OutputData,1);
        cellObj{iOpt}.calcAndSaveNewSamples(iKrigingEstimation);

        % Update Kriging model
        cellObj{iOpt}.calcKriging;
        cellObj{iOpt}.SaveCurrentCovarParameter(iKrigingEstimation);
        
        % Estimate global model uncertainty
        cellObj{iOpt}.estimateParetoCurve(iKrigingEstimation)

        % Display Results
        fprintf('iIter: %i - iKriging: %i - HyperVol: %g - Uncertainity: %g - Global: %g\n',...
                iOpt,...
                iKrigingEstimation,...
                cellObj{iOpt}.HVVec(iKrigingEstimation),...
                cellObj{iOpt}.GlobalUncertainity(iKrigingEstimation),...
                cellObj{iOpt}.GlobalUncertainityNorm(iKrigingEstimation))

        % Check if optimization can be stopped
        if cellObj{iOpt}.GlobalUncertainityNorm(iKrigingEstimation)<thresholdGU
            break
        end

        % Save intermediate results
        cellObj{iOpt}.saveTmpResults(iOpt);
        cellObj{iOpt}.saveObject(iOpt);
        
    end
end

% Final Saving
saveResults(cellObj,1)
