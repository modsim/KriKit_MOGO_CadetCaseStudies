function [sim] = createModelNew(obj,colLength)
%CREATEMODEL Creates the model of the process and returns it
% The model parameters are taken from benchmark 2 of
% A. Püttmann, S. Schnittert, U. Naumann & E. von Lieres (2013).
% Fast and accurate parameter sensitivities for the general rate model of
% column liquid chromatography.
% Computers & Chemical Engineering, 56, 46–57.
% doi:10.1016/j.compchemeng.2013.04.021

    bp = obj.getBasicParams();
    model = ModelGRM(); % General Rate Model
    
    % Number of components including salt
    model.nComponents = 4;
    % Components are (in order): Salt, lysozyme, cytochrome, ribonuclease

    % Initial conditions (note that solid phase salt concentration has to
    % match ionic capacity to satisfy equilibrium assumption)
	model.initialMobileConcentration = [bp.initialSalt 0.0 0.0 0.0];
    model.initialSolidConcentration = [1.2e3 0.0 0.0 0.0];
    
    % Adsorption model
    model.kineticBindingModel = false; % Assume rapid equilibrium
    model.bindingModel = StericMassActionBinding();
    model.bindingParameters.SMA_LAMBDA     = 1.2e3; % Ionic capacity in mol / m_SP^3
    model.bindingParameters.SMA_KD         = [0.0 1000 1000 1000]; % Desorption rates
    model.bindingParameters.SMA_KA         = [0.0 35.5 1.59 7.7];  % Adsorption rates
    model.bindingParameters.SMA_NU         = [0.0 4.7 5.29 3.7];   % Characteristic charges

    model.bindingParameters.SMA_SIGMA      = [0.0 11.83 10.6 10.0];% Shielding factors 
    % Binding places which are not occupied but shielded from the outside
    % --> Not Occupied and not free --> Lost binding places
    % The first value in the vectors above is ignored since it corresponds
    % to salt, which is component 0.
    % Note that due to the rapid-equilibrium assumption the equilibrium
    % constant is given by k_a / k_d.
    
    % Transport parameters
    % Noise in the axial movement
    model.dispersionColumn          = 5.75e-8;                            % in m^2 / s
        % Film diffusion represents the how difficult it is to enter the
        % pores for a molecule. It is ofter indirect proportional to their
        % size. Film ... layer around the beats symbolizing the resistence
    model.filmDiffusion             = [6.9e-6 6.9e-6 6.9e-6 6.9e-6];      % in m / s
    model.diffusionParticle         = [7e-10 6.07e-11 6.07e-11 6.07e-11]; % in m^2 / s
    model.diffusionParticleSurface  = [0.0 0.0 0.0 0.0];                  % in m^2 / s
    model.interstitialVelocity      = 5.75e-4;                            % in m / s

    % Column geometry
    model.columnLength        = colLength; % in m
    model.particleRadius      = 4.5e-5;    % in m
    model.porosityColumn      = 0.37;
    model.porosityParticle    = 0.75;
    
    % Inlet configuration
    model.nInletSections = 5; % Load, Wash, Gradient1, Gradient2
    
    % Start and end times of the sections in seconds
    model.sectionTimes = [0.0, 10.0, bp.startTime, (bp.startTime + bp.endTime) * 0.5, bp.endTime,bp.endTime+1e3];
    % Sets continuity of transitions between two subsequent sections
    model.sectionContinuity = false(model.nInletSections-1, 1);
    
    % Spline coefficients are initialized with zeros. First index
    % determines the component, second one gives the section index
    model.sectionConstant       = zeros(model.nComponents, model.nInletSections);
    model.sectionLinear         = zeros(model.nComponents, model.nInletSections);
    model.sectionQuadratic      = zeros(model.nComponents, model.nInletSections);
    model.sectionCubic          = zeros(model.nComponents, model.nInletSections);

    % Sec 1: Load
    model.sectionConstant(1,1)  = bp.initialSalt;  % component 1 (salt)
    model.sectionConstant(2,1)  = 1.0;   % component 2
    model.sectionConstant(3,1)  = 1.0;   % component 3
    model.sectionConstant(4,1)  = 1.0;   % component 4

    % Sec 2: Wash
    model.sectionConstant(1,2)  = bp.initialSalt;  % component 1 (salt)

    % Sec 3: Gradient 1
    model.sectionConstant(1,3)  = 100;  % component 1 (salt)
    model.sectionLinear  (1,3)  = 0.2;  % component 1 (salt)

    % Sec 4: Gradient 2
    model.sectionConstant(1,4)  = model.sectionConstant(1,3) + (model.sectionTimes(4) - model.sectionTimes(3)) * model.sectionLinear(1,3);  % component 1 (salt)
    model.sectionLinear  (1,4)  = 0.5;  % component 1 (salt)
    
    % Sec 5: Const Level
    model.sectionConstant(1,5)  = bp.maxSalt;
    
    % Discretization is rather coarse for demonstration purposes
    % Attention: For real applications a finer discretization may be
    % adequate!
    disc = DiscretizationGRM();
    disc.nCellsColumn = 64;
    disc.nCellsParticle = 16;
    
    % Create simulator object and set the time points at which the solution
    % should be evaluated
    sim = Simulator(model, disc);
    sim.solutionTimes = linspace(0, bp.endTime+1e3, bp.endTime+1e3+1);
    
    % Set solver options
    sim.solverOptions.NTHREADS = 3;  % Use n-CPU cores for computation
    sim.solverOptions.WRITE_SOLUTION_COLUMN_INLET = true;    % Return the inlet profile too
    sim.solverOptions.time_integrator.INIT_STEP_SIZE = 1e-9; % Initial time step size when beginning a new section
    sim.solverOptions.time_integrator.MAX_STEPS = 500000;    % Maximum number of time steps before aborting
    sim.solverOptions.time_integrator.ABSTOL = 1e-9;  % Absolute error tolerance in time stepping
    sim.solverOptions.time_integrator.RELTOL = 0.0;   % Relative error tolerance in time stepping
end