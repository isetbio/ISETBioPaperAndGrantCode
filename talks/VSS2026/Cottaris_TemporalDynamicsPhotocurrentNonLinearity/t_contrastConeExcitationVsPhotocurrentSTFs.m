function t_contrastConeExcitationVsPhotocurrentSTFs(options)
% Examples used to generate material for the VSS2026 talk

% History:
%    03/20/26  NPC  Wrote it.

% Examples:
%{

    % ---- Example 1 ----

    % Croner&Kaplan conditions: 4 Hz, 25% contrast, 40 cd/m2

    % Key params: (1) temporal frequency  
    evenlyDividedTemporalFrequenciesFor150HzRefreshRate = [...
        1; ...
        2; ...
        3.947372; ...
        7.5; ...
        10.7143; ...
        15; ...
        18.75; ...
        25; ...
        37.5];

    % The Croner&Kaplan temporal frequency
    targetTemporalFrequencyHz = 4.0;
    [~,idx] = min(abs(evenlyDividedTemporalFrequenciesFor150HzRefreshRate-targetTemporalFrequencyHz));
    stimulusTFHz = evenlyDividedTemporalFrequenciesFor150HzRefreshRate(idx);


    % Key params: (2) mean luminance
    examinedLuminancesCdM2  = 100; % [15  40  100  250];
    
    % Key params: (3) contrast
    examinedContrastLevels = 0.25; % [0.15 0.25 0.5 0.75 1.0];

    % Chromaticity: (4) chromaticity
    stimChromaticity = 'Achromatic';

    % SF support
    sfSupport = [0.1 0.2 logspace(log10(0.4), log10(40), 12)];

    
    % For Lee et al:
    %stimContrast('Achromatic') = 0.60;
    %stimContrast('LconeIsolating') = 0.25;   % MAX ACHIEVABLE L-cone isolating ON 'CRT-Sony-HorwitzLab', which is a SONY CRT, like Lee et al
    %stimContrast('MconeIsolating') = 0.33;   % MAX ACHIEVABLE M-cone isolating ON 'CRT-Sony-HorwitzLab', which is a SONY CRT, like Lee et al

    
    % Choose the increment in the spatial phase of the drifting gratings
    %based on the temporal frequency and the CRT refresh rate

    CRTrefreshHz = 150;    
    % Optimal for the 150 Hz CRT of Lee&Shapley 2012. Their 2.5 Hz stimulus would correspond to 6 degs.
    spatialPhaseIncrementDegsOptimal = 360 / (CRTrefreshHz / stimulusTFHz)
    spatialPhaseIncrementDegs = spatialPhaseIncrementDegsOptimal
    
    framesNumPerPeriod = 360/ spatialPhaseIncrementDegs;
    frameDurationSeconds = (1/stimulusTFHz)/framesNumPerPeriod;

    % Photocurrent response temporal support (0.5 msec)
    pCurrentTemporalResolutionSeconds = 0.5/1000;

    % Parameters of the biophysical outer segment model for photocurrent
    photocurrentParams = struct(...
        'osBiophysicalModelWarmUpTimeSeconds', max([1.5 1.0+3*1/stimulusTFHz]), ...
        'osBiophysicalModelTemporalResolutionSeconds', 1.0000e-05, ...
        'temporalResolutionSeconds', pCurrentTemporalResolutionSeconds);



    visualizedRGCindices = nan; % all RGCs
    visualizedRGCindices = [-156 -264 -282 -303];  % all but these RGCs
    visualizedRGCindices = [1:10:550 557];  % specific RGCs

    % Analyzed cells' target center cone purity, [] for all
    targetedCenterPurityRange = [] 

    % Analyzed cells' target center cone numerosity
    % e.g., [1 2]. If set to [], we will target RGCs with any center numerosity
    targetedCenterConeNumerosityRange = []

    % Analyzed cells' surround purity range
    % e.g., [0.4 0.6] to checks cells with around 50/50 L/M cone net weight in their surrounds)
    % set to [] for all surround purities
    targetedSurroundPurityRange = [];     

    % Analyzed cells' radial eccentricity range
    % e.g., [4.9 5.5]; If set to empty we will examine all cells
    targetedRadialEccentricityRange = [];



    % Actions to perform
    computeInputConeMosaicResponses = ~true;                             % computation stage 1
    computeInputConeMosaicResponsesBasedOnConeExcitations = ~true;       % computation sub-stage 1A: compute the cone excitations
    computeInputConeMosaicResponsesBasedOnPhotocurrents = ~true;         % computation sub-stage 1B: compute the photocurrents
    visualizeMosaicResponses = ~true;                                    % set this to true to visualize the dynamic cone mosaic response during step 1A

    
    computeMRGCMosaicResponses = true;                                   % computation stage 2:  compute the mRGC responses
    onlyInspectInputConeMosaicResponses = ~true;                          % when this is true, and computeMRGCMosaicResponses , we visualize individual traces of cone excitation/photocurrents

    visualizeSinusoidalFitsForPhotocurrentBasedMRGCresponses = ~true;   
    analyzeSTFresponsesForTargetCells = true;                           % compute the STFs and visualize the population BPIs for cone excitations vs photocurrents
    visualizeConeExcitationVsPhotocurrentSTFs = true;                   %visualize cone excitation and photocurrent based STFs in individualmRGCs

    
  
    for iLum = 1:numel(examinedLuminancesCdM2)
    for iContrast = 1:numel(examinedContrastLevels)

        meanLuminanceCdM2 = examinedLuminancesCdM2(iLum);
        stimContrast = examinedContrastLevels(iContrast);

        % Extra string to be added to the generated response filenames so as to encode
        % stimulus TF, mean luminance and contrast
        extraInfoEncodedInFileName = sprintf('%1.1fHz_%2.0fCDM2_%2.0f%%',stimulusTFHz, meanLuminanceCdM2, 100*stimContrast);

        % Do it.
        t_contrastConeExcitationVsPhotocurrentSTFs(...
            'STFtemporalFrequencyHz', stimulusTFHz, ...
            'STFmeanLuminanceCdM2', meanLuminanceCdM2, ...
            'STFchromaticity', stimChromaticity, ...
            'STFcontrast', stimContrast, ...
            'STFsfSupport', sfSupport, ...
            'spatialPhaseIncrementDegs', spatialPhaseIncrementDegs, ...
            'photocurrentParams', photocurrentParams, ...
            'extraInfoEncodedInFileName', extraInfoEncodedInFileName, ...
            'computeInputConeMosaicResponses', computeInputConeMosaicResponses, ...
            'computeInputConeMosaicResponsesBasedOnConeExcitations',computeInputConeMosaicResponsesBasedOnConeExcitations, ...
            'computeInputConeMosaicResponsesBasedOnPhotocurrents', computeInputConeMosaicResponsesBasedOnPhotocurrents, ...
            'visualizeMosaicResponses', visualizeMosaicResponses, ...      
            'onlyInspectInputConeMosaicResponses', onlyInspectInputConeMosaicResponses, ...
            'computeMRGCMosaicResponses', computeMRGCMosaicResponses, ...  
            'visualizeSinusoidalFitsForPhotocurrentBasedMRGCresponses', visualizeSinusoidalFitsForPhotocurrentBasedMRGCresponses, ...
            'analyzeSTFresponsesForTargetCells', analyzeSTFresponsesForTargetCells, ...
            'visualizeConeExcitationVsPhotocurrentSTFs', visualizeConeExcitationVsPhotocurrentSTFs, ...
            'visualizedRGCindices', visualizedRGCindices, ...
            'targetedCenterPurityRange', targetedCenterPurityRange, ...
            'targetedCenterConeNumerosityRange', targetedCenterConeNumerosityRange, ...
            'targetedSurroundPurityRange', targetedSurroundPurityRange, ...
            'targetedRadialEccentricityRange', targetedRadialEccentricityRange, ...
            'exportPDFdirectory', 'local', ...
            'exportVideoDirectory', 'local');
        
    end  %  iContrast 
    end  %  iLum




    % ----- Example 2 ----
    cropParams =  struct(...
            'eccentricityDegs', [2 0], ...
            'sizeDegs', [0.5 0.5] ...
        );

    opticsForSTFresponses = struct(...
            'type', 'refractionResidualWithRespectToNativeOptics',...
            'refractiveErrorDiopters', 0.20 ...
        );

    t_contrastConeExcitationVsPhotocurrentSTFs(...
        'cropParams', cropParams, ...
        'opticsForSTFresponses, opticsForSTFresponses);
%}

arguments

    % ---- Mosaic specifiers for selecting a prebaked mRGC mosaic ------
    
    % See RGCMosaicConstructor.helper.utils.initializeRGCMosaicGenerationParameters
    % for what is available and to add new mosaics
    options.rgcMosaicName (1,:) char = 'JCNpaperNasal2DegsTinyMosaic';


    % ---- Which species to employ ----
    % Choose between {'macaque', 'human'}. If 'macaque' is chosen, the input
    % cone mosaic has a 1:1 L/M cone ratio.
    options.coneMosaicSpecies  (1,:) char {mustBeMember(options.coneMosaicSpecies,{'human','macaque'})} = 'human';


    % ----- Which subject optics to employ -----
    options.opticsSubjectName (1,:) ...
        char ...
        {...
        mustBeMember(options.opticsSubjectName, ...
            { ...
            'JCNpaperDefaultSubject' ...
            'JCNpaperSecondSubject' ...
            'VSS2024TalkFirstSubject' ...
            'VSS2024TalkSecondSubject' ...
            'JCNpaperStrehlRatio_0.87' ...
            'JCNpaperStrehlRatio_0.72' ...
            'JCNpaperStrehlRatio_0.59' ...
            'JCNpaperStrehlRatio_0.60' ...
            'JCNpaperStrehlRatio_0.27' ...
            'JCNpaperStrehlRatio_0.23' ...
            'JCNpaperStrehlRatio_0.21' ...
            'JCNpaperStrehlRatio_0.19' ...
            'JCNpaperStrehlRatio_0.09' ...
            } ...
            ) ...
        } ...
        = 'JCNpaperDefaultSubject';


    % ------ targetVisualSTF options ----
    % Options are : {'default', 'x1.3 RsRcRatio'}
    % These are with respect to the macaque data of the Croner & Kaplan '95 study
    % 'default': target the mean Rs/Rc, and the mean Ks/Kc (Rs/Rc)^2
    % See RGCMosaicConstructor.helper.surroundPoolingOptimizerEngine.generateTargetVisualSTFmodifiersStruct
    % for all existing options
    options.targetVisualSTFdescriptor (1,:) char = 'default';

    % Submosaic to map
    options.cropParams = [];

    % Different options for the optics
    options.opticsForSTFresponses = [];

    % STF params
    options.STFmeanLuminanceCdM2 (1,1) double = 100;
    options.STFbackgroundXYchromaticity (1,2) double = [0.436, 0.476];
    options.STFchromaticity (1,:) char{mustBeMember(options.STFchromaticity, {'LconeIsolating' 'MconeIsolating' 'Achromatic'})} = 'Achromatic';
    options.STFsfSupport (1,:) double = logspace(log10(0.05), log10(50), 15);
    options.STFtemporalFrequencyHz (1,1) double = 10;
    options.STFcontrast (1,1) double = 0.5;
    options.STForientationDeltaDegs (1,1) double = 90;

    options.extraInfoEncodedInFileName (1,:) char = '';

    options.displayType (1,:) char = 'CRT-Sony-HorwitzLab';
    options.displayLuminanceHeadroomPercentage (1,1) double = 200/100;
    options.coneFundamentalsOptimizedForStimPosition (1,1) logical = false;

    % Photocurrent (full biophysical model) params
    options.photocurrentParams (1,1) = struct(...
        'osBiophysicalModelWarmUpTimeSeconds',  1.0, ...
        'osBiophysicalModelTemporalResolutionSeconds',  1e-5, ...
        'temporalResolutionSeconds',  5/1000);

    % Decreasing the spatial phase increment results in higher temporal resolution, and vice versa
    options.spatialPhaseIncrementDegs (1,1) double = 30;

    % Visualizations
    options.visualizeStimulusSequence (1,1) logical = false;

    % Whether to visualize exemplar cone excitation & photocurrent responses
    options.onlyInspectInputConeMosaicResponses (1,1) logical = false;

    % set this to true to visualize the dynamic cone mosaic response during step 1A
    options.visualizeMosaicResponses (1,1) logical = false;

    options.visualizeSinusoidalFitsForPhotocurrentBasedMRGCresponses (1,1) logical = false;
    options.visualizeConeExcitationVsPhotocurrentSTFs (1,1) logical = false;

    % ---- Choices of actions to perform ----

    % Whether to compute the input cone mosaic STF responses (stage 1)
    options.computeInputConeMosaicResponses (1,1) logical = false;

    % Whether to compute the cone excitations-based input cone mosaic STF responses 
    % (computation sub-stage 1A)
    options.computeInputConeMosaicResponsesBasedOnConeExcitations (1,1) logical = false;

    % Whether to compute the photocurrents-based input cone mosaic STF responses
    % (computation sub-stage 1B)
    options.computeInputConeMosaicResponsesBasedOnPhotocurrents (1,1) logical = false;

    % Whether to compute the mRGC mosaic STF responses
    % (computation stage 2)
    options.computeMRGCMosaicResponses (1,1) logical = false;
    
    % Whether to analyze the STF responses for select target mRGCs
    options.analyzeSTFresponsesForTargetCells(1,1) logical = false;

    % Analyzed cells' target center purity range
    % e.g. [1 1], for only 100% single cone type. 
    % Set to [] for all center purities
    options.targetedCenterPurityRange (1,:) double = [];   

    % Analyzed cells' target center cone numerosity
    % e.g., [1 2]. If set to [], we will target RGCs with any center numerosity
    options.targetedCenterConeNumerosityRange (1,:) double = [];

    % Analyzed cells' surround purity range
    % e.g., [0.4 0.6] to checks cells with around 50/50 L/M cone net weight in their surrounds)
    % set to [] for all surround purities
    options.targetedSurroundPurityRange (1,:) double = [];      

    % Analyzed cells' radial eccentricity range
    % e.g., [4.9 5.5]; If set to empty we will examine all cells
    options.targetedRadialEccentricityRange (1,:) double = [];

    % Which RGCs to visualize cone excitations vs photocurrent STFs
    options.visualizedRGCindices (1,:) double = [];

    % Directory where to save PDFs (separate for each mRGC)
    options.exportPDFdirectory (1,:) char = '';

    % Directory where to export video of analysis for all mRGCs
    options.exportVideoDirectory (1,:) char = '';

end % arguments
   

exportPDFdirectory = options.exportPDFdirectory;
exportVideoDirectory = options.exportVideoDirectory;

if (strcmp(exportPDFdirectory, 'local'))
    exportPDFdirectory = fullfile(ISETBioPaperAndGrantCodeRootDirectory, mfilename);
end

if (strcmp(exportVideoDirectory, 'local'))
    exportVideoDirectory = fullfile(ISETBioPaperAndGrantCodeRootDirectory, mfilename);
end

t_mRGCMosaicSTFcomputation(...
    'rgcMosaicName', options.rgcMosaicName, ...
    'coneMosaicSpecies', options.coneMosaicSpecies, ...
    'opticsSubjectName', options.opticsSubjectName, ...
    'targetVisualSTFdescriptor', options.targetVisualSTFdescriptor, ...
    'cropParams', options.cropParams, ...
    'opticsForSTFresponses', options.opticsForSTFresponses, ...
    'STFchromaticity', options.STFchromaticity, ...
    'STFcontrast', options.STFcontrast, ...
    'STForientationDeltaDegs', options.STForientationDeltaDegs, ...  
    'STFtemporalFrequencyHz', options.STFtemporalFrequencyHz, ...                          
    'STFsfSupport', options.STFsfSupport, ...    
    'STFmeanLuminanceCdM2', options.STFmeanLuminanceCdM2, ...              
    'STFbackgroundXYchromaticity', options.STFbackgroundXYchromaticity, ...          
    'displayType', options.displayType, ...                   
    'displayLuminanceHeadroomPercentage', 200/100, ...         
    'spatialPhaseIncrementDegs', options.spatialPhaseIncrementDegs, ... 
    'coneFundamentalsOptimizedForStimPosition', options.coneFundamentalsOptimizedForStimPosition, ...
    'photocurrentParams', options.photocurrentParams, ...
    'extraInfoEncodedInFileName', options.extraInfoEncodedInFileName, ...  
    'computeInputConeMosaicResponses', options.computeInputConeMosaicResponses, ...                        
    'computeInputConeMosaicResponsesBasedOnConeExcitations', options.computeInputConeMosaicResponsesBasedOnConeExcitations, ...
    'computeInputConeMosaicResponsesBasedOnPhotocurrents',  options.computeInputConeMosaicResponsesBasedOnPhotocurrents, ...
    'visualizeMosaicResponses', options.visualizeMosaicResponses, ...                                  
    'onlyInspectInputConeMosaicResponses', options.onlyInspectInputConeMosaicResponses, ...                           
    'computeMRGCMosaicResponses', options.computeMRGCMosaicResponses, ...                       
    'visualizeSinusoidalFitsForPhotocurrentBasedMRGCresponses', options.visualizeSinusoidalFitsForPhotocurrentBasedMRGCresponses, ...
    'visualizeConeExcitationVsPhotocurrentSTFs', options.visualizeConeExcitationVsPhotocurrentSTFs, ...
    'analyzeSTFresponsesForTargetCells', options.analyzeSTFresponsesForTargetCells, ...
    'targetedCenterPurityRange', options.targetedCenterPurityRange, ...     
    'targetedCenterConeNumerosityRange', options.targetedCenterConeNumerosityRange, ... 
    'targetedSurroundPurityRange', options.targetedSurroundPurityRange, ...    
    'targetedRadialEccentricityRange', options.targetedRadialEccentricityRange, ...
    'visualizedRGCindices', options.visualizedRGCindices , ...
    'exportPDFdirectory', exportPDFdirectory, ...
    'exportVideoDirectory', exportVideoDirectory);