classdef CadetMO_Example<MOGO
    %KRIGINGSUPERCLASS Summary of this class goes here
    %   Detailed explanation goes here
    
    %% Public Members
    properties(GetAccess='public',SetAccess='public')
       
       
       %% These Variables are very special for the example
       % used for Cadet simulation
       CadetObj = [];
       % Choose which obj-function should be used
       objFctChoice = 1;
       % use Latin Hypercube for initial experiments. If false, use full
       % factorial
       UseLatinHyperCube = false;
       % If UseLatinHyperCube is false, than nGridLevel defines the number
       % of input values for each input variable in the full factorial
       % design
       nGridLevel = 3;
       % If true than the cutting time dependency is estimated using a
       % Latin hyper cube sampling. If not than a grid design is applied
       UseLHSForObj = true;
       % If inequality contraint is applied, all invalid points are removed
       % from initial experimental design
       InequalityConstraintHandle = {};
       % Standard deviation for noisy feed (relative noise)
       SdComponentInlet = zeros(1,3);
       % Standard deviation which is applied directly to chromatogram curve
       % 
       SampleMeasurementNoise = zeros(1,3);
       % If true, SdComponentInlet is also applied to chromatogram. Meaning
       % that yield is correctly calculated (otherwise the preassumed
       % concentration is used for normalization)
       RandInjMassBool = false;
    end
    
    %% Private Members
    properties(GetAccess='private',SetAccess='private')

    end
    
    %% Protected Members
    properties(GetAccess='protected',SetAccess='protected')
        
    end
    
    methods
        %% Constructor
        function obj = CadetMO_Example(varargin)
            
            if isempty(varargin)
                nObject = 1;
            else
                nObject = varargin{1};
            end
                
            % Remove all objects so far
            obj.KrigingAnalyzeObj.removeKrigingObject(1:obj.KrigingAnalyzeObj.getnKrigingObjects)
            
            % Initialize all objects by choosing the most important settings
            for iObject = 1:nObject
                obj.KrigingAnalyzeObj.addKrigingObject(1,horzcat('Obj ',num2str(iObject)))
                obj.KrigingAnalyzeObj.KrigingObjects{iObject}.setNormInput(true)
                obj.KrigingAnalyzeObj.KrigingObjects{iObject}.setNormOutput(false)
                obj.KrigingAnalyzeObj.KrigingObjects{iObject}.setShowDetails(true)
            end
            
            obj.CadetObj = ReducedCadetSimulation;
            obj.CadetObj.doInit
            
            
        end
        %% Copy Operator for a shallow copy
        % ----------------------------------------------------------------
        function copy = copyObj(obj)
        % Create a shallow copy of the calling object.
            copy = eval(class(obj));
            meta = eval(['?',class(obj)]);
            for p = 1: size(meta.Properties,1)
                    pname = meta.Properties{p}.Name;
                try
                    eval(['copy.',pname,' = obj.',pname,';']);
                catch
                    error(['\nCould not copy ',pname,'.\n']);
%                     fprintf(['\nCould not copy ',pname,'.\n']);
                end
            end
        end
        % ----------------------------------------------------------------
        [] = randonmizeInlet(obj,varargin);
        % ----------------------------------------------------------------
        [newLHS]=deleteInvalidSamples(obj,originalLHS);
        % ----------------------------------------------------------------
        [] = doInitCadetSetting(obj);
        % ----------------------------------------------------------------
        [] = doInitCadetSettingWithoutInjMass(obj);
        % ----------------------------------------------------------------
        [] = finalSettings(obj)
        % ----------------------------------------------------------------
        [] = generateInitialSimulations(obj,varargin)
        % ----------------------------------------------------------------
        [] = estimateNoise(obj,varargin)
        % ----------------------------------------------------------------
        []=generateInputDataRange(obj,varargin)
        % ----------------------------------------------------------------
        [newSamplePoint] = calcAndSaveNewSamples_MutualEI(obj,varargin)
        % ----------------------------------------------------------------
        [output] = objFct(obj,varargin)
        % ----------------------------------------------------------------
        [y] = objFctGivenTime(obj,varargin)
        % ----------------------------------------------------------------
        [paretoSetTotal,inputParameterSetWithCuttingPoints] = objFctCadet_Purity_Yield_EndTime_DeltaTime(obj,varargin);
        % ----------------------------------------------------------------
        [] = performInitialExp(obj,varargin)
        % ----------------------------------------------------------------
        [] = generateInitialKrigingModel(obj,varargin)
        % ----------------------------------------------------------------
        [] = designAndPerformNewExperiments(obj,varargin)
    end
end

