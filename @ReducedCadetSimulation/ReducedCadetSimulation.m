classdef ReducedCadetSimulation<handle
    
    %% Public Members
    properties(GetAccess='public',SetAccess='public')
        % Target component is 2 (index would be 3 when including salt)
        idxTarget = 2;
        % Minimum purity constraint (95 %)
        minPurity = 0.95;
        % Length of the column in ?m?
        colLength = 0.014;
        % Threshold for complete elution in mM
        elutionLimit = 1e-6;   
        % Parameter names
        params = [{'sectionConstant'}, {'sectionLinear'}, {'sectionLinear'}, {'sectionConstant'}]; 
        % Component index of the parameters (1 = salt)
        comps = [1 1 1 1]; 
        % Section index of the parameters (3 = gradient1, 4 = gradient2)
        secs = [3 3 4 4];  
        % Specifiy linear parameter transform (takes all parameters to rougly
        % the same order of magnitude)
        transform = diag([0.1, 1000, 0.01, 0.01, 0.01]);
        % Specifiy linear parameter transform (takes all parameters to rougly
        % the same order of magnitude)
        invTransform = diag([10, 0.001, 100, 100, 100]);
        % Cadet Object (simulating etc.)
        sim = [];
        % Basic Simulation parameters
        bp = [];
        % Cadet object for doing several simulation tasks
        task = [];
        % Specify lower and upper bounds on parameters
        % Layout: start, slope1, slope2, len, collect start, collect stop
        lb = [0, 0.001, 120, 0, 0];
        ub = [500, 10, 1e6, 1e6, 1e6];
        % total injected mass of each component
        injMass = [];
        % Save the results of the last simulation
        % SimulationResults.x Contains the process parameters 
        % x1 = initial step
        % x2 = first slope
        % x3 = second slope
        % x4 = first cutting point
        % x5 = second cutting point
        SimulationResults = [];
        % Noise Ratio defines the relative pertubation of the outlet. No
        % negative values are allowed!
        NoiseRatio = 0;
        % Area under the curve of different components (size of
        % nComponents X 1). It contains structures with all relevant
        % information
        IntegralComponents = {};
        % Interpolation between simulation points
        SplineComponents = {};
        % minimal yield which should be achieved in order to call the
        % process "finished" (Needed for
        % "calculate_EndTime_AfterIntegration")
        MinNeededYield = 0.999;
        % Number of sample points evaluated in a random experimental
        % design
        nRandSamples =1e2;
        % Standard deviation of the cutting time points
        SD_CuttingTimePoints = 0;
        % function which providing information about valid purity and yield
        % value, e.g. minimal allowed value might exist. Function provide a
        % bollean vector as output
        InEqConstraintPurityYield = [];
        % If noise is applied to the initial inlet concetration a priori,
        % this vector contains the fixed but random distributed
        % concentration values
        FixInitialConc = ones(3,1);
    end
    
    %% Private Members
    properties(GetAccess='private',SetAccess='private')

    end
    
    %% Protected Members
    properties(GetAccess='protected',SetAccess='protected')
    end
    
    methods
        %% Constructor
        function obj = ReducedCadetSimulation()
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
        %% General Methods
        % ----------------------------------------------------------------
        [sim] = createModelNew(obj,colLength)
        % ----------------------------------------------------------------
        p = getBasicParams(obj)
        % ----------------------------------------------------------------
        [f, grad] = doSimulationAndCalculateYieldAndPurity(obj,x)
        % ----------------------------------------------------------------
        [] = modifyModelParams(obj, pGrad)
        % ----------------------------------------------------------------
        [] = modifyModelParamsP2HightNotGradient(obj, pGrad)
        % ----------------------------------------------------------------
        [samplePlan] = createLHSWithExtremePoints(obj, varargin)
        % ----------------------------------------------------------------
        [cuttingPoints,paretoSet] = determineCuttingPointsPareto_P_Y_EndTime_DeltaTime(obj,varargin)
        % ----------------------------------------------------------------
        function [] = calcIntegralAndSplineComponents(obj)
            % Initialization 
            nComponents = size(obj.SimulationResults.solution.outlet, 2)-1;
            obj.IntegralComponents = cell(nComponents,1);
            chromSpl = cell(nComponents,1);
            
            for iComponents = 1:nComponents
                % Interpolation inbetween simulation points
                chromSpl{iComponents} = interp1(obj.SimulationResults.solution.time, obj.SimulationResults.solution.outlet(:,iComponents+1), 'pchip', 'pp');
                
                % Integration under the interpolation curve
                obj.IntegralComponents{iComponents} = obj.ppint(chromSpl{iComponents});
                
            end
            obj.SplineComponents = chromSpl;
        end
        % ----------------------------------------------------------------
        function [] = calculateYieldAndPurity(obj)
            % Initialization
            masses = zeros(size(obj.SimulationResults.solution.outlet, 2)-1, 1);
            chromSpl = cell(size(masses));
            
            % Interpolate samples mass for each component
            for i = 1:length(masses)
                % Integration
                chromSpl{i} = interp1(obj.SimulationResults.solution.time, obj.SimulationResults.solution.outlet(:,i+1), 'pchip', 'pp');

                % Integrate entire spline (ppint) and take only part in defined
                % interval defined by pCut (ppval)
                masses(i) = diff(ppval(obj.ppint(chromSpl{i}), obj.SimulationResults.x(end-1:end)));
                if masses(i)<1e-10
                    masses(i)=1e-10;
                end
            end

            % Actual calculation
            f = masses(obj.idxTarget) / obj.injMass(obj.idxTarget);
            purity = masses(obj.idxTarget) / sum(masses);

            obj.SimulationResults.Yield = f;
            obj.SimulationResults.Purity = purity; 
        end
        % ----------------------------------------------------------------
        [] = calculateYieldAndPurityAfterIntegration(obj)
        % ----------------------------------------------------------------
        [randMatrix] = addNoiseToCuttingTime(obj,varargin)
        % ----------------------------------------------------------------
        [masses] = calculateMassesAfterIntegration(obj)
        % ----------------------------------------------------------------
        [] = plotChromatogram(obj)
        % ----------------------------------------------------------------
        [] = plotChromatograminOne(obj)
        % ----------------------------------------------------------------
        function []=doInit(obj,varargin)
            % Create the model
            obj.sim = obj.createModelNew(obj.colLength);
            obj.sim.model.sectionConstant(2:end,1) = obj.FixInitialConc;

            % Set parameters
            obj.sim.setParameters(obj.params, obj.comps, obj.secs, false(length(obj.params), 1));
            warning('off','MATLAB:subscripting:noSubscriptsSpecified')
            obj.task = obj.sim.prepareSimulation();
            warning('on','MATLAB:subscripting:noSubscriptsSpecified')
            
            % Save the parameters
            obj.bp = obj.getBasicParams();
        end
        % ----------------------------------------------------------------
        function pp = ppint(obj,pp)
        % PPINT Construct anti-derivative of piecewise polynomial
        % The constant of the anti-derivative is set as 0. In order to calculate
        % the correct anti-derivative of the i-th piece, we need to add the sum of
        % the definite integrals of all previous pieces. This is easy, since the
        % constant of the previous polynomial contains the sum of definite
        % integrals of its previous ones, and so on.
        % Note that the polynomial pieces of splines are shifted to their left
        % boundary.

            [breaks,coefs,l,k,d] = unmkpp(pp);
            % Take anti-derivative of each polynomial independently
            coefs = [coefs ./ repmat(size(coefs,2):-1:1, size(coefs,1), 1), zeros(size(coefs,1),1)];
            % Calculate constant term of each piece
            for i = 2:size(coefs,1)
                % Add definite integral of previous polynomial (note the coordinate
                % shift) to the sum of all of its previous pieces (saved in its
                % constant term).
                coefs(i, end) = diff(polyval(coefs(i-1,:), breaks(i-1:i) - breaks(i-1))) + coefs(i-1, end);
            end
            % Rebuild piecewise polynomial
            pp = mkpp(breaks,coefs,d);
        end
    end
    
end

