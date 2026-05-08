function t_temporalDynamicsFixationalEMphotocurrentDemo(options)
% Demo the interactions b/n fixationalEM, phototransduction, and mRGC temporal dynamics
%
% Description:
%   Demo the interactions b/n fixationalEM, phototransduction, and mRGC temporal dynamics
%
% History:
%    05/04/26  NPC  Wrote it.
%
% Examples:
%{

    % mRGCMosaic crop params
    % The input cone mosaic is much larger
    cropParams = struct( ...
        'sizeDegs', [0.25 0.25], ...
        'eccentricityDegs', [-6 0]);

    % No cropping
    sceneCropParams = [];


    % ========== VSS 2026 HDR scene  ======================================
    % Distant forest, luminance range: 17-230 (mean: 10)
    HDRdatabaseYear = 2004
    HDRimageName = 'scene1';
    sceneCropParams = struct(...
        'positionDegs', [1 0], ...
        'sizeDegs', [4 4], ...          % grab a 6x6 patch,
        'imageFOVdegs', 2.0, ...        % scale it to a 1x1 patch
        'meanLuminanceCdM2', 10 ...     % and asdjust its mean luminance
    );
    % -====================================================================



    % ========== Close-up of 2 flowers, luminance range: 12-116 (mean: 6) =========
    HDRdatabaseYear = 2002;
    HDRimageName = 'scene1';

    % Focus on flower in the middle of the image
    sceneCropParams = struct(...
        'positionDegs', [0.5 -1], ...
        'sizeDegs', [7 7], ...          % grab a 6x6 patch,
        'imageFOVdegs', 3.0, ...        % scale it to a 1x1 patch
        'meanLuminanceCdM2', 30 ...     % and asdjust its mean luminance
    );
    % -====================================================================


   


    % Garden with central flower, luminance range: 34-417 (mean 30)
    HDRimageName = 'scene3';
    sceneCropParams = struct(...
        'positionDegs', [1.1 0.2], ...
        'sizeDegs', [2 2], ...
        'imageFOVdegs', 2.0);


    % Big flower, luminance range: 22-120
    HDRimageName = 'scene4';

    
    % City view, luminance range: 14-89
    HDRimageName = 'scene7';

    % Hotel building, luminance range: 31-202
    HDRimageName = 'scene7';

    % Barn door, luminance range: 17-198
    HDRimageName = 'scene8';


    % ----------------------------------------------------

    
    % Photocurrent params
    photocurrentParams = struct(...
        'osBiophysicalModelWarmUpTimeSeconds',  1.0, ...
        'osBiophysicalModelTemporalResolutionSeconds',  1e-5, ...
        'temporalResolutionSeconds', 1/1000);

    % Eye movement params
    eyeMovementParams = struct(...
        'microSaccadeMeanIntervalSeconds', 250/1000,...
        'trialDurationSeconds', 5.0, ...
        'nTrials', 1);

   
    % Where to load the derived inner retina filters
    mRGCtemporalFiltersSources = struct(...
        'rootDir', fullfile(localDropboxDir(),'IBIO_rgcMosaicResources/denovo/intermediateFiles/ONcenterMidgetRGCmosaics/TTFresponses'),...
        'derivedInnerRetinaImpulseResponseCenterDataFile', 'IR30_Fig6_(ON)_cnt_direct_spot_Achromatic@0.5C_40CdM2.mat',...
        'derivedInnerRetinaImpulseResponseSurroundDataFile', 'IR30_Fig6_(ON)_srnd_direct_annulus_Achromatic@0.5C_40CdM2.mat'...
    );


    % What to do
    recomputeInputConeMosaicSimulation = ~true;
    recomputeMRGCmosaicSimulation = true;


    % Run the simulation
    t_temporalDynamicsFixationalEMphotocurrentDemo(...
        'cropParams', cropParams, ...
        'sceneCropParams', sceneCropParams, ...
        'HDRdatabaseYear', HDRdatabaseYear, ...
        'HDRimageName', HDRimageName, ...
        'photocurrentParams', photocurrentParams, ...
        'eyeMovementParams', eyeMovementParams, ...
        'rgcMosaicName', 'JCNpaperTemporal7DegsMosaic', ...
        'opticsSubjectName', 'JCNpaperDefaultSubject', ...
        'visualizeMRGCmosaic',true, ...
        'recomputeInputConeMosaicSimulation', recomputeInputConeMosaicSimulation, ...
        'recomputeMRGCmosaicSimulation', recomputeMRGCmosaicSimulation, ...
        'mRGCtemporalFiltersSources', mRGCtemporalFiltersSources, ...
        'visualizeResponsesOfInputConesToRGCindex', 30, ...
        'overlaySceneInsetOnTopOfRetinalImage', false);

        

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

    % Submosaic to use
    options.cropParams = [];

    % Sub-scene to use
    options.sceneCropParams = [];

    % Different options for the optics
    options.opticsForTTFresponses = [];

    % Wavefront spatial samples
    options.opticsWavefrontSpatialSamples = [];

    % Display params
    options.meanLuminanceCdM2 (1,1) double = 60;
    options.displayType (1,:) char = '';
    options.displayLuminanceHeadroomPercentage (1,1) double = 5/100;
    options.adjustBackgroundChromaticityToEqualizeLandMconeExcitations (1,1) logical = false;
    options.coneFundamentalsOptimizedForStimPosition (1,1) logical = false;


    % Spatial position params
    options.stimulusPixelSizeAsFractionOfConeAperture (1,1) double = 0.5;
    options.stimulusMaxSupportDegs (1,:) double = [];
    options.stimulusPositionDegs (1,:) double = [];
    options.stimulusSizeDegs (1,:) double = [];

    % Photocurrent (full biophysical model) params
    options.photocurrentParams (1,1) = struct(...
        'osBiophysicalModelWarmUpTimeSeconds',  1.0, ...
        'osBiophysicalModelTemporalResolutionSeconds',  1e-5, ...
        'temporalResolutionSeconds', 1/1000);

    options.eyeMovementParams (1,1) = struct(...
        'microSaccadeMeanIntervalSeconds', 250/1000,...
        'trialDurationSeconds', 5.0, ...
        'nTrials', 1);


    % Nonlinearities
    options.mRGCNonLinearityParamsStruct = [];
    options.mRGCsOperateOnBackgroundAdaptedPhotocurrents (1,1) logical = true;


    % mRGC temporal filters source file
    options.mRGCtemporalFiltersSources = [];

    % Source HDR image
    options.HDRdatabaseYear (1,:) double =  2004;
    options.HDRimageName (1,:) char = 'scene1';

    % Visualizations
    options.visualizeMRGCmosaic (1,1) logical = false;

    options.visualizeResponsesOfInputConesToRGCindex (1,:) double = [];

    % ---- Choices of actions to perform ----
    options.recomputeInputConeMosaicSimulation (1,1) logical = false;
    options.recomputeMRGCmosaicSimulation (1,1) logical = false;


    % Whether to close previously open figures
    options.closePreviouslyOpenFigures (1,1) logical = true;

    options.overlaySceneInsetOnTopOfRetinalImage logical = false;
end

    % Set flags from key/value pairs
    
    % Mosaic specifiers for selecting a prebaked mRGC mosaic
    rgcMosaicName = options.rgcMosaicName;
    coneMosaicSpecies = options.coneMosaicSpecies;
    opticsSubjectName = options.opticsSubjectName;
    targetVisualSTFdescriptor = options.targetVisualSTFdescriptor;
    
    % Mosaic cropping
    cropParams = options.cropParams;
    sceneCropParams = options.sceneCropParams;
    
    % Optics to employ for the computations
    opticsForTTFresponses = options.opticsForTTFresponses;
    opticsWavefrontSpatialSamples = options.opticsWavefrontSpatialSamples;
    
    % Display params
    meanLuminanceCdM2 = options.meanLuminanceCdM2;
    displayType = options.displayType;
    displayLuminanceHeadroomPercentage = options.displayLuminanceHeadroomPercentage;
    coneFundamentalsOptimizedForStimPosition = options.coneFundamentalsOptimizedForStimPosition;
    adjustBackgroundChromaticityToEqualizeLandMconeExcitations = options.adjustBackgroundChromaticityToEqualizeLandMconeExcitations;
    
    % Spatial params
    stimulusPixelSizeAsFractionOfConeAperture = options.stimulusPixelSizeAsFractionOfConeAperture;
    stimulusMaxSupportDegs = options.stimulusMaxSupportDegs;
    stimulusPositionDegs = options.stimulusPositionDegs;
    stimulusSizeDegs =  options.stimulusSizeDegs;
    
    
    % Photocurrent params
    photocurrentParams = options.photocurrentParams;
    
    % Eye movement params
    eyeMovementParams = options.eyeMovementParams;


    mRGCsOperateOnBackgroundAdaptedPhotocurrents = options.mRGCsOperateOnBackgroundAdaptedPhotocurrents;
    
    % Nonlinearities
    mRGCNonLinearityParamsStruct = options.mRGCNonLinearityParamsStruct;
    
    % mRGC filter sources
    mRGCtemporalFiltersSources = options.mRGCtemporalFiltersSources; 

    % Source HDR image
    HDRdatabaseYear = options.HDRdatabaseYear;
    HDRimageName = options.HDRimageName;
    
    recomputeInputConeMosaicSimulation = options.recomputeInputConeMosaicSimulation;
    recomputeMRGCmosaicSimulation = options.recomputeMRGCmosaicSimulation;


    % Visualizations
    visualizeMRGCmosaic = options.visualizeMRGCmosaic;
    visualizeResponsesOfInputConesToRGCindex = options.visualizeResponsesOfInputConesToRGCindex;

    overlaySceneInsetOnTopOfRetinalImage = options.overlaySceneInsetOnTopOfRetinalImage;
    
    % Close previously open figures
    closePreviouslyOpenFigures = options.closePreviouslyOpenFigures;
    
    if (closePreviouslyOpenFigures)
        % Close any stray figs
        close all;
    end
    

    exportVisualizationRootDirectory = ISETBioPaperAndGrantCodeFigureDirForScript(mfilename);
    exportVisualizationPDFdirectory = 'staticPDFs';
    exportVisualizationVideoDirectory = 'videos';
    exportDataDirectory = 'data';

    theDataFileName = sprintf('alldata_%2.0fCdM2.mat', sceneCropParams.meanLuminanceCdM2);


    if (recomputeInputConeMosaicSimulation)
        demoEngine.compute.inputConeMosaicActivation(coneMosaicSpecies, opticsSubjectName, rgcMosaicName, targetVisualSTFdescriptor, ...
            opticsForTTFresponses, opticsWavefrontSpatialSamples, cropParams, sceneCropParams, ...
            photocurrentParams, eyeMovementParams, HDRdatabaseYear, HDRimageName, ...
            visualizeMRGCmosaic, ...
            exportVisualizationRootDirectory, exportVisualizationPDFdirectory, ...
            exportVisualizationVideoDirectory, exportDataDirectory, theDataFileName);
    end

    if (recomputeMRGCmosaicSimulation)
        demoEngine.compute.mRGCmosaicActivation(theDataFileName, mRGCtemporalFiltersSources, ...
            exportVisualizationRootDirectory, exportVisualizationPDFdirectory, ...
            exportVisualizationVideoDirectory, exportDataDirectory, ...
            visualizeResponsesOfInputConesToRGCindex);
    end

    % Load previously computed data and render video / static images
    demoEngine.visualize.simulationAnimationsAndStaticRenderings(...
        theDataFileName, visualizeResponsesOfInputConesToRGCindex, ...
        overlaySceneInsetOnTopOfRetinalImage, ...
        exportVisualizationRootDirectory, exportVisualizationPDFdirectory, ...
        exportVisualizationVideoDirectory, exportDataDirectory);
   
end








