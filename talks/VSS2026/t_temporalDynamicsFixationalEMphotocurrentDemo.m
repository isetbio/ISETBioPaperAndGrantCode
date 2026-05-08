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


   

    % Distant forest, luminance range: 17-230 (mean: 10)
    HDRdatabaseYear = 2004
    HDRimageName = 'scene1';
    sceneCropParams = struct(...
        'positionDegs', [1 0], ...
        'sizeDegs', [4 4], ...          % grab a 6x6 patch,
        'imageFOVdegs', 2.0, ...        % scale it to a 1x1 patch
        'meanLuminanceCdM2', 30 ...     % and asdjust its mean luminance
    );



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

    % Run the simulation

    photocurrentParams = struct(...
        'osBiophysicalModelWarmUpTimeSeconds',  1.0, ...
        'osBiophysicalModelTemporalResolutionSeconds',  1e-5, ...
        'temporalResolutionSeconds', 1/1000);

    eyeMovementParams = struct(...
        'microSaccadeMeanIntervalSeconds', 250/1000,...
        'trialDurationSeconds', 5.0, ...
        'nTrials', 1);

    recomputeInputConeMosaicSimulation = ~true;
    recomputeMRGCmosaicSimulation = ~true;

    % Where to load the derived inner retina filters
    mRGCtemporalFiltersSources = struct(...
        'rootDir', fullfile(localDropboxDir(),'IBIO_rgcMosaicResources/denovo/intermediateFiles/ONcenterMidgetRGCmosaics/TTFresponses'),...
        'derivedInnerRetinaImpulseResponseCenterDataFile', 'IR30_Fig6_(ON)_cnt_direct_spot_Achromatic@0.5C_40CdM2.mat',...
        'derivedInnerRetinaImpulseResponseSurroundDataFile', 'IR30_Fig6_(ON)_srnd_direct_annulus_Achromatic@0.5C_40CdM2.mat'...
    );

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
        'visualizeResponsesOfInputConesToRGCindex', 30)

        

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

    options.exportVisualizationPDF (1,1) logical = false;
    options.exportVisualizationPNG (1,1) logical = false;
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

    exportVisualizationPDF = options.exportVisualizationPDF;
    exportVisualizationPNG = options.exportVisualizationPNG;
    
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
        runTheInputConeMosaicSimulation(coneMosaicSpecies, opticsSubjectName, rgcMosaicName, targetVisualSTFdescriptor, ...
            opticsForTTFresponses, opticsWavefrontSpatialSamples, cropParams, sceneCropParams, ...
            photocurrentParams, eyeMovementParams, HDRdatabaseYear, HDRimageName, ...
            visualizeMRGCmosaic, ...
            exportVisualizationRootDirectory, exportVisualizationPDFdirectory, ...
            exportVisualizationVideoDirectory, exportDataDirectory, theDataFileName);
    end

    if (recomputeMRGCmosaicSimulation)
        runTheMRGCmosaicSimulation(theDataFileName, mRGCtemporalFiltersSources, ...
            exportVisualizationRootDirectory, exportVisualizationPDFdirectory, ...
            exportVisualizationVideoDirectory, exportDataDirectory, ...
            visualizeResponsesOfInputConesToRGCindex);
    end

    % Video
    visualizeTheData(theDataFileName, visualizeResponsesOfInputConesToRGCindex, ...
            exportVisualizationRootDirectory, exportVisualizationPDFdirectory, ...
            exportVisualizationVideoDirectory, exportDataDirectory, ...
            visualizeResponsesOfInputConesToRGCindex);
   
end


function visualizeTheData(theDataFileName, visualizeResponsesOfInputConesToRGCindex, ...
            exportVisualizationRootDirectory, exportVisualizationPDFdirectory, ...
            exportVisualizationVideoDirectory, exportDataDirectory, targetMRGCindex)
    
    % Load the data
    theDataFileName = fullfile(exportVisualizationRootDirectory, exportDataDirectory, theDataFileName);
    load(theDataFileName, ...
        'theMRGCmosaic', ...
        'theConeMosaicSpatioTemporalExcitationResponse', ...
        'theConeExcitationsResponseTemporalSupportSeconds', ...
        'theScene', 'sceneCropParams', 'theRetinalImage', 'theFixationalEMObj', ...
        'theConeMosaicSpatioTemporalPhotocurrentResponses', ...
        'thePhotocurrentResponseTemporalSupportSeconds', ...
        'theMRGCmosaicResponseDictionary');
    

    visualizeMRGCtraces(theMRGCmosaicResponseDictionary, targetMRGCindex, ...
        exportVisualizationRootDirectory, exportVisualizationPDFdirectory, sprintf('mRGCresponseTraces_%2.0fCdM2.pdf', sceneCropParams.meanLuminanceCdM2));

    visualizeConeExcitationsStimulusModulationAndFixationalEMs(...
        theMRGCmosaicResponseDictionary, targetMRGCindex, ...
        theMRGCmosaic.inputConeMosaic, ...
        theConeMosaicSpatioTemporalPhotocurrentResponses, ...
        thePhotocurrentResponseTemporalSupportSeconds, ...
        theRetinalImage, theFixationalEMObj, ...
        exportVisualizationRootDirectory, ...
        exportVisualizationVideoDirectory, ...
        sprintf('photoCurrentsMovie_%2.0fCdM2.pdf', sceneCropParams.meanLuminanceCdM2));

    visualizeConeExcitationsStimulusModulationAndFixationalEMs(...
        theMRGCmosaicResponseDictionary, targetMRGCindex, ...
        theMRGCmosaic.inputConeMosaic, ...
        theConeMosaicSpatioTemporalExcitationResponse, ...
        theConeExcitationsResponseTemporalSupportSeconds, ...
        theRetinalImage, theFixationalEMObj, ...
        exportVisualizationRootDirectory, ...
        exportVisualizationVideoDirectory, ...
        sprintf('coneExcitationsMovie_%2.0fCdM2.pdf', sceneCropParams.meanLuminanceCdM2));


    if (~isempty(visualizeResponsesOfInputConesToRGCindex))
        % Compute photocurrents for cone indices that provide input to a single mRGC
        theTargetMRGCindex = visualizeResponsesOfInputConesToRGCindex(1);

        surroundConnectivityVector = full(squeeze(theMRGCmosaic.rgcRFsurroundConeConnectivityMatrix(:, theTargetMRGCindex)));
        surroundConeIndices = find(surroundConnectivityVector > theMRGCmosaic.minSurroundWeightForInclusionInComputing);
        coneIndicesToVisualize = surroundConeIndices;
    else
        coneIndicesToVisualize = 1:theMRGCmosaic.inputConeMosaic.conesNum;
    end


    theMRGCmosaic.inputConeMosaic.visualize(...
        'outlinedconeswithindices', coneIndicesToVisualize);

   

for idx = 1:numel(coneIndicesToVisualize)

    iCone = coneIndicesToVisualize(idx);
    theSingleConeExcitationCountsResponse = squeeze(theConeMosaicSpatioTemporalExcitationResponse(1,:,iCone));
    % Convert excitation counts to excitation rates
    theSingleConeExcitationRateResponse = theSingleConeExcitationCountsResponse(:) / theMRGCmosaic.inputConeMosaic.integrationTime;
    clear 'theSingleConeExcitationCountsResponse'

    % Mean cone excitation rate over the entire course of stimulation
    theSingleConeBackgroundConeExcitationRate = mean(theSingleConeExcitationRateResponse);

    switch (theMRGCmosaic.inputConeMosaic.coneTypes(iCone))
        case cMosaic.LCONE_ID
            theConeColor = [1 0 0];
        case cMosaic.MCONE_ID
            theConeColor = [0 1 0];
        case cMosaic.SCONE_ID
            theConeColoe = [0 0 1];
    end

    


    % Compute the photocurrent response
    [theSingleConePhotocurrentDifferentialResponse, ...
     thePhotocurrentResponseTemporalSupportSeconds, theSingleConePhotocurrentBackgroundTransientResponse,...
     theConeOSbiophysModels{iCone}] = cMosaic.photocurrentFromConeExcitationRateUsingBiophysicalOSmodel(...
            eccentricityDegsOfOSbiophysicalModel, ...
            theSingleConeExcitationRateResponse, ...
            theSingleConeBackgroundConeExcitationRate, ...
            theMRGCmosaic.inputConeMosaic.integrationTime, ...  % the timebase of the cone excitation rate signal
            photocurrentParams.temporalResolutionSeconds,  ...  % the timebase of the returned photocurrent signal
            'osTimeStepSeconds', photocurrentParams.osBiophysicalModelTemporalResolutionSeconds, ...  % the time base for running the osBiophysical model
            'skipAssertions', skipAssertions, ...
            'theConeOSbiophysModel', theConeOSbiophysModels{iCone});
    
    
    hFig = figure(100);
    set(hFig, 'Name', sprintf('cone %d', iCone), 'Position', [10 10 1500 1000]);
    ax = subplot('Position', [0.05 0.05 0.93 0.45]);
    cla(ax);
    yyaxis(ax, 'left');
    stairs(ax, theConeExcitationsResponseTemporalSupportSeconds, theSingleConeExcitationRateResponse, 'k-', 'Color', theConeColor, 'LineWidth', 1.5);

    set(ax, 'YLim', [0 50000], 'YTick', [0 10 20 30 40 50]*1e3);
    set(ax, 'XTick', 0:0.5:5)
    ylabel(ax, 'isomerization rate (R*/sec)')
    xlabel(ax, 'time (seconds)');


    % The full pCurrent = differential + transient
    theSingleConePhotocurrentResponse = theSingleConePhotocurrentDifferentialResponse + theSingleConePhotocurrentBackgroundTransientResponse;

    yyaxis(ax, 'right');
    
    plot(ax, thePhotocurrentResponseTemporalSupportSeconds, theSingleConePhotocurrentResponse, '--', 'Color', theConeColor, 'LineWidth', 1.5);
    set(ax, 'YLim', [-100 0]);
    set(ax, 'XTick', 0:0.5:5);
    ylabel(ax, 'photocurrent (pAmps)');
    drawnow;

    ax2 = subplot('Position', [0.05 0.55 0.93 0.4]);
    plot(ax2, thePhotocurrentResponseTemporalSupportSeconds, theSingleConePhotocurrentDifferentialResponse, '--', 'Color', theConeColor, 'LineWidth', 1.5);
    set(ax2, 'YLim', [-50 50]);
    set(ax2, 'XTick', 0:0.5:5);
    ylabel(ax2, 'differential photocurrent (pAmps)');

    

end % iCone



    % Visualize
    theVideoFilename = sprintf('coneExcitationsfEMretinalImageCombo_%s',strrep(thePDFfileName, '/.pdf', ''));
    
    visualizeConeExcitationsStimulusModulationAndFixationalEMs(...
        theMRGCmosaic.inputConeMosaic, theConeMosaicSpatioTemporalExcitationResponse, ...
        theConeExcitationsResponseTemporalSupportSeconds, ...
        theRetinalImage, theFixationalEMObj, ...
        exportVisualizationRootDirectory, ...
        exportVisualizationVideoDirectory, ...
        theVideoFilename);

end


function runTheMRGCmosaicSimulation(theDataFileName, mRGCtemporalFiltersSources, exportVisualizationRootDirectory, exportVisualizationPDFdirectory, ...
            exportVisualizationVideoDirectory, exportDataDirectory, theTargetmRGCindex)
    
    % Load the mRGC temporal filters
    theSourceFile = fullfile(...
        mRGCtemporalFiltersSources.rootDir, mRGCtemporalFiltersSources.derivedInnerRetinaImpulseResponseCenterDataFile);
    d = load(theSourceFile, 'theDerivedInnerRetinaFiniteTimeImpulseResponseData');
    innerRetinaCenterImpulseResponseData = d.theDerivedInnerRetinaFiniteTimeImpulseResponseData;
    

    theSourceFile = fullfile(...
        mRGCtemporalFiltersSources.rootDir, mRGCtemporalFiltersSources.derivedInnerRetinaImpulseResponseSurroundDataFile);
    d = load(theSourceFile, 'theDerivedInnerRetinaFiniteTimeImpulseResponseData');
    innerRetinaSurroundImpulseResponseData = d.theDerivedInnerRetinaFiniteTimeImpulseResponseData;


    assert(all(abs(innerRetinaCenterImpulseResponseData.temporalSupportSeconds(:)-innerRetinaSurroundImpulseResponseData.temporalSupportSeconds(:)))<10*eps, ...
        'temporal supports of center and surround do not match');

    % Normalize to unit peak amplitude
    innerRetinaCenterImpulseResponseData.amplitude = innerRetinaCenterImpulseResponseData.amplitude / max(abs(innerRetinaCenterImpulseResponseData.amplitude(:)));
    innerRetinaSurroundImpulseResponseData.amplitude = innerRetinaSurroundImpulseResponseData.amplitude / max(abs(innerRetinaSurroundImpulseResponseData.amplitude(:)));
    

    innerRetinaTemporalFilters = struct(...
        'temporalSupportSeconds', innerRetinaCenterImpulseResponseData.temporalSupportSeconds, ...
        'centerImpulseResponseFunction', innerRetinaCenterImpulseResponseData.amplitude, ...
        'surroundImpulseResponseFunction', innerRetinaSurroundImpulseResponseData.amplitude);
        
    clear('innerRetinaSurroundImpulseResponseData', 'innerRetinaCenterImpulseResponseData');

    figure(5555);
    plot(innerRetinaTemporalFilters.temporalSupportSeconds, innerRetinaTemporalFilters.centerImpulseResponseFunction, 'r-', 'LineWidth', 1.5);
    hold on;
    plot(innerRetinaTemporalFilters.temporalSupportSeconds, innerRetinaTemporalFilters.surroundImpulseResponseFunction, 'b-', 'LineWidth', 1.5);
    

    temporalFrequencySupportHz = 0:0.5:200;
    params = RGCmodels.BenardeteKaplan1997.figure6CenterSurroundFilterParams('ON');

    theTargetCascadedFilterTTF = RGCmodels.BenardeteKaplan1997.oneStageHighPassNstageLowPassFilterCascadeTTF(...
                params.centerIR.pVector, temporalFrequencySupportHz);
    theCenterImpulseResponseData = RGCMosaicConstructor.temporalFilterEngine.sampledTTFtoTemporalImpulseFunction(...
                    theTargetCascadedFilterTTF, temporalFrequencySupportHz, ...
                    'causal', false, ...
                    'upsample', 1);



    theTargetCascadedFilterTTF = RGCmodels.BenardeteKaplan1997.oneStageHighPassNstageLowPassFilterCascadeTTF(...
                params.surroundIR.pVector, temporalFrequencySupportHz);
    theSurroundImpulseResponseData = RGCMosaicConstructor.temporalFilterEngine.sampledTTFtoTemporalImpulseFunction(...
                    theTargetCascadedFilterTTF, temporalFrequencySupportHz, ...
                    'causal', false, ...
                    'upsample', 1);


    centerAmplitude = interp1(theCenterImpulseResponseData.temporalSupportSeconds, theCenterImpulseResponseData.amplitude, innerRetinaTemporalFilters.temporalSupportSeconds);
    surroundAmplitude = interp1(theSurroundImpulseResponseData.temporalSupportSeconds, theSurroundImpulseResponseData.amplitude, innerRetinaTemporalFilters.temporalSupportSeconds);

    BenardeteKaplanFig6ONfilters = struct(...
        'temporalSupportSeconds', innerRetinaTemporalFilters.temporalSupportSeconds, ...
        'centerImpulseResponseFunction', centerAmplitude, ...
        'surroundImpulseResponseFunction', surroundAmplitude);

    figure(5556);
    plot(BenardeteKaplanFig6ONfilters.temporalSupportSeconds, BenardeteKaplanFig6ONfilters.centerImpulseResponseFunction, 'r-', 'LineWidth', 1.5);
    hold on;
    plot(BenardeteKaplanFig6ONfilters.temporalSupportSeconds, BenardeteKaplanFig6ONfilters.surroundImpulseResponseFunction, 'b-', 'LineWidth', 1.5);
    

    % Load the data
    theDataFileName = fullfile(exportVisualizationRootDirectory, exportDataDirectory, theDataFileName);
    load(theDataFileName, ...
        'theMRGCmosaic', ...
        'theConeMosaicSpatioTemporalExcitationResponse', ...
        'theConeExcitationsResponseTemporalSupportSeconds', ...
        'theScene', 'theRetinalImage', 'theFixationalEMObj', ...
        'theConeMosaicSpatioTemporalPhotocurrentResponses', ...
        'thePhotocurrentResponseTemporalSupportSeconds');



    % compute cone modulations from excitations
    meanConeExcitations = mean(theConeMosaicSpatioTemporalExcitationResponse, 3);
    theConeMosaicSpatioTemporalModulationsResponse = bsxfun(@times, bsxfun(@minus, theConeMosaicSpatioTemporalExcitationResponse, meanConeExcitations), 1./meanConeExcitations);


    % Compute the mRGC mosaic response (cone excitations + no filtering)
    [theMRGCmosaicResponse, ~, theMRGCMosaicResponseTemporalSupportSeconds] = ...
        theMRGCmosaic.compute(...
            theConeMosaicSpatioTemporalModulationsResponse, ...
            theConeExcitationsResponseTemporalSupportSeconds);

    theMRGCmosaicResponseDictionary = containers.Map();
    theMRGCmosaicResponseDictionary('cone modulations alone') = struct(...
        'theMRGCmosaicResponse', theMRGCmosaicResponse, ...
        'theTemporalSupportSeconds', theMRGCMosaicResponseTemporalSupportSeconds);
        

    % Compute the mRGC mosaic response (cone excitations + no filtering) - OFF cell
    theMRGCmosaicResponse = theMRGCmosaic.compute(...
            theConeMosaicSpatioTemporalModulationsResponse, ...
            theConeExcitationsResponseTemporalSupportSeconds, ...
            'flipLinearResponsePolarityForCellsWithIndices', theTargetmRGCindex);

    theMRGCmosaicResponseDictionary(sprintf('cone modulations alone (mRGC #%d with flipped polarity)', theTargetmRGCindex)) = struct(...
        'theMRGCmosaicResponse', theMRGCmosaicResponse, ...
        'theTemporalSupportSeconds', theMRGCMosaicResponseTemporalSupportSeconds);

            

    % Cone excitations + BK filter
    [theMRGCmosaicResponse, ~, theMRGCMosaicResponseTemporalSupportSeconds] = ...
        theMRGCmosaic.compute(...
            theConeMosaicSpatioTemporalModulationsResponse, ...
            theConeExcitationsResponseTemporalSupportSeconds, ...
            'withCenterSurroundTemporalFilters', BenardeteKaplanFig6ONfilters);

    theMRGCmosaicResponseDictionary('cone modulations + BK filters') = struct(...
        'theMRGCmosaicResponse', theMRGCmosaicResponse, ...
        'theTemporalSupportSeconds', theMRGCMosaicResponseTemporalSupportSeconds);




    % Cone modulation + BK filter (OFF cell)
    theMRGCmosaicResponse = theMRGCmosaic.compute(...
            theConeMosaicSpatioTemporalModulationsResponse, ...
            theConeExcitationsResponseTemporalSupportSeconds, ...
            'withCenterSurroundTemporalFilters', BenardeteKaplanFig6ONfilters, ...
            'flipLinearResponsePolarityForCellsWithIndices', theTargetmRGCindex);

    theMRGCmosaicResponseDictionary(sprintf('cone modulations + BK filters (mRGC #%d with flipped polarity)', theTargetmRGCindex)) = struct(...
        'theMRGCmosaicResponse', theMRGCmosaicResponse, ...
        'theTemporalSupportSeconds', theMRGCMosaicResponseTemporalSupportSeconds);



    % Compute the mRGC mosaic response (photocurrents - only)
    [theMRGCmosaicResponse, ~, theMRGCMosaicResponseTemporalSupportSeconds] = ...
        theMRGCmosaic.compute(...
            theConeMosaicSpatioTemporalPhotocurrentResponses, ...
            thePhotocurrentResponseTemporalSupportSeconds);

    theMRGCmosaicResponseDictionary('photocurrents only') = struct(...
        'theMRGCmosaicResponse', theMRGCmosaicResponse, ...
        'theTemporalSupportSeconds', theMRGCMosaicResponseTemporalSupportSeconds);


    % Compute the mRGC mosaic response (photocurrents - only) - OFF cell
    theMRGCmosaicResponse = theMRGCmosaic.compute(...
            theConeMosaicSpatioTemporalPhotocurrentResponses, ...
            thePhotocurrentResponseTemporalSupportSeconds);

    theMRGCmosaicResponseDictionary(sprintf('photocurrents only (mRGC #%d with flipped polarity)', theTargetmRGCindex)) = struct(...
        'theMRGCmosaicResponse', theMRGCmosaicResponse, ...
        'theTemporalSupportSeconds', theMRGCMosaicResponseTemporalSupportSeconds);


    % Compute the mRGC mosaic response (photocurrents + inner retina filter)
    [theMRGCmosaicResponse, ~, theMRGCMosaicResponseTemporalSupportSeconds] = ...
        theMRGCmosaic.compute(...
            theConeMosaicSpatioTemporalPhotocurrentResponses, ...
            thePhotocurrentResponseTemporalSupportSeconds, ...
            'withCenterSurroundTemporalFilters', innerRetinaTemporalFilters);

    theMRGCmosaicResponseDictionary('photocurrents + inner retina filter cascade') = struct(...
        'theMRGCmosaicResponse', theMRGCmosaicResponse, ...
        'theTemporalSupportSeconds', theMRGCMosaicResponseTemporalSupportSeconds);


    % Compute the mRGC mosaic response (photocurrents + inner retina filter) - OFF cell
    theMRGCmosaicResponse = theMRGCmosaic.compute(...
            theConeMosaicSpatioTemporalPhotocurrentResponses, ...
            thePhotocurrentResponseTemporalSupportSeconds, ...
            'withCenterSurroundTemporalFilters', innerRetinaTemporalFilters, ...
            'flipLinearResponsePolarityForCellsWithIndices', theTargetmRGCindex);

    theMRGCmosaicResponseDictionary(sprintf('photocurrents + inner retina filter cascade (mRGC #%d with flipped polarity)', theTargetmRGCindex)) = struct(...
        'theMRGCmosaicResponse', theMRGCmosaicResponse, ...
        'theTemporalSupportSeconds', theMRGCMosaicResponseTemporalSupportSeconds);




    % Compute the mRGC mosaic response (photocurrents + inner retina filter, surround-only)
    theMRGCmosaicResponse = theMRGCmosaic.compute(...
            theConeMosaicSpatioTemporalPhotocurrentResponses, ...
            thePhotocurrentResponseTemporalSupportSeconds, ...
            'withCenterSurroundTemporalFilters', innerRetinaTemporalFilters, ...
            'deactivatedCenter', true);

    theMRGCmosaicResponseDictionary('photocurrents + inner retina filter cascade - surround only') = struct(...
        'theMRGCmosaicResponse', theMRGCmosaicResponse, ...
        'theTemporalSupportSeconds', theMRGCMosaicResponseTemporalSupportSeconds);



    % Compute the mRGC mosaic response (photocurrents + inner retina filter, center-only)
    theMRGCmosaicResponse = theMRGCmosaic.compute(...
            theConeMosaicSpatioTemporalPhotocurrentResponses, ...
            thePhotocurrentResponseTemporalSupportSeconds, ...
            'withCenterSurroundTemporalFilters', innerRetinaTemporalFilters, ...
            'deactivatedSurround', true);

    theMRGCmosaicResponseDictionary('photocurrents + inner retina filter cascade - center only') = struct(...
        'theMRGCmosaicResponse', theMRGCmosaicResponse, ...
        'theTemporalSupportSeconds', theMRGCMosaicResponseTemporalSupportSeconds);



    % Compute the mRGC mosaic response (cone modulations + inner retina
    % filter) - CONTROL
    [theMRGCmosaicResponse, ~, theMRGCMosaicResponseTemporalSupportSeconds] = ...
        theMRGCmosaic.compute(...
            theConeMosaicSpatioTemporalModulationsResponse, ...
            theConeExcitationsResponseTemporalSupportSeconds, ...
            'withCenterSurroundTemporalFilters', innerRetinaTemporalFilters);

    theMRGCmosaicResponseDictionary('modulations + inner retina filter cascade') = struct(...
        'theMRGCmosaicResponse', theMRGCmosaicResponse, ...
        'theTemporalSupportSeconds', theMRGCMosaicResponseTemporalSupportSeconds);



    % Append theMRGCmosaicResponseDictionary
    save(theDataFileName, ...
        'theMRGCmosaicResponseDictionary', ...
        '-append');


end


function visualizeMRGCtraces(theMRGCmosaicResponseDictionary, targetRGCindex, ...
    exportVisualizationRootDirectory, exportVisualizationPDFdirectory, thePDFfileName)


    ff = PublicationReadyPlotLib.figureComponents('1x1 giant rectangular-double wide mosaic', ...
        'darkScheme', true);

    RedBlueLUT = zeros(1024,3);
    RedBlueLUT(513,:) = ff.legendBackgroundColor;
    RedBlueLUT(514:1024,1) = ff.legendBackgroundColor(1) + (1-ff.legendBackgroundColor(1))*(1:511)/511;
    RedBlueLUT(514:1024,2) = ff.legendBackgroundColor(2);
    RedBlueLUT(514:1024,3) = ff.legendBackgroundColor(3);

    RedBlueLUT(512:-1:1,1) = ff.legendBackgroundColor(1);
    RedBlueLUT(512:-1:1,2) = ff.legendBackgroundColor(2);
    RedBlueLUT(512:-1:1,3) = ff.legendBackgroundColor(3) + (1-ff.legendBackgroundColor(3))*(1:512)/512;


    if (1==2)
        hFig = figure(5000); clf;
        theAxes = PublicationReadyPlotLib.generatePanelAxes(hFig,ff);
        ax = theAxes{1,1};
    
        [theTemporalSupportSeconds, theMRGCmosaicSpatioTemporalResponse] = retrieveTheSpatioTemporalMRGCmosaicResponses(...
            theMRGCmosaicResponseDictionary, ...
            'cone modulations + BK filters', ...
             0,0, []);
        
    
        mRGCsNum = size(theMRGCmosaicSpatioTemporalResponse,2);
        imagesc(theTemporalSupportSeconds*1e3, 1:mRGCsNum, theMRGCmosaicSpatioTemporalResponse')
    
        timeLimits = [0 5.0*1e3];
        yLims = [1 mRGCsNum];
        set(ax, 'XLim', timeLimits, 'YLim', yLims, 'CLim', max(theMRGCmosaicSpatioTemporalResponse(:))*[-1 1]);
        xlabel(ax, 'time (msec)');
        ylabel(ax, 'mRGC index');
        colormap(ax, RedBlueLUT)
        colorbar(ax, 'east');
    
        PublicationReadyPlotLib.offsetAxes(ax,ff, timeLimits, yLims);
        PublicationReadyPlotLib.applyFormat(ax,ff);
    
        % Export figure
        theVisualizationPDFfilename = fullfile(exportVisualizationPDFdirectory, 'ConeModulations_BKfilters_XTresponse.pdf');
                
        % Generate the path if we need to
        RGCMosaicConstructor.filepathFor.augmentedPathWithSubdirs(...
              exportVisualizationRootDirectory, theVisualizationPDFfilename, ...
              'generateMissingSubDirs', true);
            
        thePDFfileName = fullfile(exportVisualizationRootDirectory, theVisualizationPDFfilename);
        NicePlot.exportFigToPDF(thePDFfileName, hFig, 300, 'beVerbose');



    
    
        hFig = figure(5001); clf;
        theAxes = PublicationReadyPlotLib.generatePanelAxes(hFig,ff);
        ax = theAxes{1,1};
    
    
        % Retrieve the data
        [theTemporalSupportSeconds, theMRGCmosaicSpatioTemporalResponse] = retrieveTheSpatioTemporalMRGCmosaicResponses(...
            theMRGCmosaicResponseDictionary, ...
            'photocurrents + inner retina filter cascade', ...
            0,0, []);
    
        mRGCsNum = size(theMRGCmosaicSpatioTemporalResponse,2);
        imagesc(theTemporalSupportSeconds*1e3, 1:mRGCsNum, theMRGCmosaicSpatioTemporalResponse')
    
        timeLimits = [0 4000];
        yLims = [1 mRGCsNum];
        set(ax, 'XLim', timeLimits, 'YLim', yLims, 'CLim', max(theMRGCmosaicSpatioTemporalResponse(:))*[-1 1]);
        xlabel(ax, 'time (msec)');
        ylabel(ax, 'mRGC index');
        colormap(ax, RedBlueLUT)
        colorbar(ax, 'east');
        PublicationReadyPlotLib.offsetAxes(ax,ff, timeLimits, yLims);
        PublicationReadyPlotLib.applyFormat(ax,ff);
    
        % Export figure
        theVisualizationPDFfilename = fullfile(exportVisualizationPDFdirectory, 'Photocurrents_InnerRetinaFilterCascade_XTresponse.pdf');
                
        % Generate the path if we need to
        RGCMosaicConstructor.filepathFor.augmentedPathWithSubdirs(...
              exportVisualizationRootDirectory, theVisualizationPDFfilename, ...
              'generateMissingSubDirs', true);
            
        thePDFfileName = fullfile(exportVisualizationRootDirectory, theVisualizationPDFfilename);
        NicePlot.exportFigToPDF(thePDFfileName, hFig, 300, 'beVerbose');
    
    
    
        hFig = figure(5002); clf;
        theAxes = PublicationReadyPlotLib.generatePanelAxes(hFig,ff);
        ax = theAxes{1,1};
    
        % Retrieve the data
        [theTemporalSupportSeconds, theMRGCmosaicSpatioTemporalResponse] = retrieveTheSpatioTemporalMRGCmosaicResponses(...
            theMRGCmosaicResponseDictionary, ...
            'photocurrents only', ...
            0,0, []);
    
    
        mRGCsNum = size(theMRGCmosaicSpatioTemporalResponse,2);
        imagesc(theTemporalSupportSeconds*1e3, 1:mRGCsNum, theMRGCmosaicSpatioTemporalResponse');
    
        timeLimits = [0 4000];
        yLims = [1 mRGCsNum];
        set(ax, 'XLim', timeLimits, 'YLim', yLims, 'CLim', max(theMRGCmosaicSpatioTemporalResponse(:))*[-1 1]);
        xlabel(ax, 'time (msec)');
        ylabel(ax, 'mRGC index');
        colormap(ax, RedBlueLUT);
        colorbar(ax, 'east');
    
        PublicationReadyPlotLib.offsetAxes(ax,ff, timeLimits, yLims);
        PublicationReadyPlotLib.applyFormat(ax,ff);
    
        % Export figure
        theVisualizationPDFfilename = fullfile(exportVisualizationPDFdirectory, 'Photocurrents_Only_XTresponse.pdf');
                
        % Generate the path if we need to
        RGCMosaicConstructor.filepathFor.augmentedPathWithSubdirs(...
              exportVisualizationRootDirectory, theVisualizationPDFfilename, ...
              'generateMissingSubDirs', true);
            
        thePDFfileName = fullfile(exportVisualizationRootDirectory, theVisualizationPDFfilename);
        NicePlot.exportFigToPDF(thePDFfileName, hFig, 300, 'beVerbose');


    end



    % Get ready for publication-quality visualization
    hFig = figure(6000); clf;
    ff = PublicationReadyPlotLib.figureComponents('1x1 giant rectangular-double wide mosaic', ...
        'darkScheme', true);
    theAxes = PublicationReadyPlotLib.generatePanelAxes(hFig,ff);
    ax = theAxes{1,1};
    hold(ax,'on')

    c = brewermap(6, 'blues');
    color1 = c(6,:);
    c = brewermap(6, 'reds');
    color2 = c(6,:);


    % The cone modulations + the Benardete & Kaplan original filter
    theLegends{1} = 'cone modulations + BK filters';

    [theTemporalSupportSeconds, theResponse] = retrieveTheSpatioTemporalMRGCmosaicResponses(...
        theMRGCmosaicResponseDictionary, ...
        theLegends{1}, ...
        0,0, ...
        targetRGCindex);

    plot(ax, theTemporalSupportSeconds*1e3, theResponse/max(abs(theResponse)), 'k-', 'Color', color1, 'LineWidth', 3.0);
    pHandles(1) = plot(ax, theTemporalSupportSeconds(1:2:end)*1e3, theResponse(1:2:end)/max(abs(theResponse)), 'o-',...
        'Color', color1.^0.5, 'MarkerSize', 10, 'MarkerFaceColor', color1, 'MarkerEdgeColor', color1.^0.5, 'LineWidth', 2.0);


    % The photocurrent + derived inner retina filter cascade
    theLegends{2} = 'photocurrents + inner retina filter cascade';
    theResponseBias = 0.15;
    theResponseDelay = 12/1000;

    [theTemporalSupportSeconds, theResponse] = retrieveTheSpatioTemporalMRGCmosaicResponses(...
        theMRGCmosaicResponseDictionary, ...
        theLegends{2}, ...
        theResponseBias, theResponseDelay, ...
        targetRGCindex);

    plot(ax, theTemporalSupportSeconds*1e3, theResponse/max(abs(theResponse)), 'k-', 'Color', color2, 'LineWidth', 3.0);
    pHandles(numel(pHandles)+1) = scatter(ax, theTemporalSupportSeconds(1:2:end)*1e3, theResponse(1:2:end)/max(abs(theResponse)), 100,...
        'Color', color2.^0.5, 'MarkerFaceAlpha', 0.8, 'MarkerFaceColor', color2, 'MarkerEdgeColor', color2.^0.5, 'LineWidth', 2.0);


    legend(ax, pHandles, theLegends, 'Location', 'NorthOutside', 'NumColumns', 2);

    timeLimits = [0 4000];
    responseLimits = [-1.0 1.0];
    set(ax, 'XLim', timeLimits, 'YLim', responseLimits, 'XTick', 0:250:5000, 'YTick', -1:0.5:1);
    xlabel(ax, 'time (msec)');
    ylabel(ax, 'mRGC response');

    PublicationReadyPlotLib.offsetAxes(ax,ff, timeLimits, responseLimits);
    PublicationReadyPlotLib.applyFormat(ax,ff);


    % Export figure
    theVisualizationPDFfilename = fullfile(exportVisualizationPDFdirectory, thePDFfileName);
            
    % Generate the path if we need to
    RGCMosaicConstructor.filepathFor.augmentedPathWithSubdirs(...
          exportVisualizationRootDirectory, theVisualizationPDFfilename, ...
          'generateMissingSubDirs', true);
        
    thePDFfileName = fullfile(exportVisualizationRootDirectory, theVisualizationPDFfilename);
    NicePlot.exportFigToPDF(thePDFfileName, hFig, 300, 'beVerbose');

end





function [theTemporalSupportSeconds, theResponse] = ...
        retrieveTheSpatioTemporalMRGCmosaicResponses(theMRGCmosaicResponseDictionary, theDataSetLabel, ...
        theResponseBias, theResponseDelay, targetRGCindex)
    
    minTimeToStabilizeSeconds = 300/1000;
    maxTimeToVisualize = 4500/1000;

    d = theMRGCmosaicResponseDictionary(theDataSetLabel);
    if (isempty(targetRGCindex))
        theResponse = squeeze(d.theMRGCmosaicResponse(1,:,:));
    else
        theResponse = squeeze(d.theMRGCmosaicResponse(1,:,targetRGCindex));
    end

    theTemporalSupportSeconds = d.theTemporalSupportSeconds;

    idx = find((theTemporalSupportSeconds>=minTimeToStabilizeSeconds) & (theTemporalSupportSeconds<=maxTimeToVisualize));    
    theTemporalSupportSeconds = theTemporalSupportSeconds(idx);
    theTemporalSupportSeconds = theTemporalSupportSeconds - theTemporalSupportSeconds(1);

    theTemporalSupportSeconds = theTemporalSupportSeconds + theResponseDelay;
    theResponse = theResponse(idx) + theResponseBias;
end




function runTheInputConeMosaicSimulation(coneMosaicSpecies, opticsSubjectName, rgcMosaicName, targetVisualSTFdescriptor, ...
        opticsForTTFresponses, opticsWavefrontSpatialSamples, cropParams, sceneCropParams, ...
        photocurrentParams, eyeMovementParams, HDRdatabaseYear, HDRimageName, ......
        visualizeMRGCmosaic, ...
        exportVisualizationRootDirectory, exportVisualizationPDFdirectory, exportVisualizationVideoDirectory, ...
        exportDataDirectory, theDataFileName)


    % Load the mRGCmosaic specified by the passed parameters:
    %   coneMosaicSpecies, opticsSubjectName, rgcMosaicName, targetVisualSTFdescriptor
    % and generate the optics that were used to synthesize the mosaic
    [theMRGCmosaic, theOptics, thePSFatTheMosaicEccentricity] = mRGCMosaic.loadPrebakedMosaic(...
            coneMosaicSpecies, opticsSubjectName, rgcMosaicName, targetVisualSTFdescriptor, ...
            'computeTheMosaicOptics', true, ...
            'opticsToEmploy', opticsForTTFresponses, ...
            'wavefrontSpatialSamples', opticsWavefrontSpatialSamples, ...
            'cropParams', cropParams);

    % Plot a smaller region of the mRGC mosaic with the PSF superimposed
    narrowDomainVisualizationLimits(1:2) = theMRGCmosaic.eccentricityDegs(1) + [-0.5 0.5]*theMRGCmosaic.sizeDegs(1);
    narrowDomainVisualizationLimits(3:4) = theMRGCmosaic.eccentricityDegs(2) + [-0.5 0.5]*theMRGCmosaic.sizeDegs(2);
    narrowDomainVisualizationTicks = struct(...
        'x', -30:0.2:0, ...
        'y', -10:0.2:10);
    
    
    if (visualizeMRGCmosaic)
        fancyMosaicVisualization(theMRGCmosaic, thePSFatTheMosaicEccentricity, ...
            narrowDomainVisualizationLimits, ...
            narrowDomainVisualizationTicks, ...
            exportVisualizationRootDirectory, ...
            exportVisualizationPDFdirectory);
    end


    % Load an HDR scene
    [theScene, spatialSupportXdegs, spatialSupportYdegs] = loadMachnesterDataBaseScene(...
        HDRdatabaseYear, sprintf('%s.mat', HDRimageName));

    % Visualize scene and its luminance map
    figNo = 1;
    thePDFfileName = sprintf('%s_%d_%s_original.pdf', 'Manchester', HDRdatabaseYear, HDRimageName);
    visualizeHDRscene(theScene, spatialSupportXdegs, spatialSupportYdegs, sceneCropParams, figNo,...
        exportVisualizationRootDirectory, ...
        exportVisualizationPDFdirectory, ...
        thePDFfileName);

    % Crop the scene
    if (~isempty(sceneCropParams))
        [theScene, spatialSupportXdegs, spatialSupportYdegs] = ...
            cropScene(theScene, spatialSupportXdegs, spatialSupportYdegs, ...
            sceneCropParams);
    end

    % Visualize cropped scene and its luminance map
    figNo = 2;
    visualizeHDRscene(theScene, spatialSupportXdegs, spatialSupportYdegs, [], figNo, ...
        exportVisualizationRootDirectory, ...
        exportVisualizationPDFdirectory, ...
        sprintf('%s_%d_%s_cropped.pdf', 'Manchester', HDRdatabaseYear, HDRimageName));



    % Compute the retinal image
    theRetinalImage = oiCompute(theOptics,theScene,'pad value','mean');


    theMRGCmosaic.inputConeMosaic.integrationTime = 5/1000;

    % Instantiate a fixational eye movement object for generating
    % fixational eye movements that include drift and microsaccades.
    fixEMobj = fixationalEM();

    % Generate microsaccades with a mean interval of  150 milliseconds
    % Much more often than the default, just for video purposes.
    fixEMobj.microSaccadeMeanIntervalSeconds = eyeMovementParams.microSaccadeMeanIntervalSeconds;
    
    % Compute nTrials of emPaths for this mosaic
    % Here we are fixing the random seed so as to reproduce identical eye
    % movements whenever this script is run.
    theFixationalEMObj = generateFixationalEyeMovements(...
        eyeMovementParams.trialDurationSeconds, eyeMovementParams.nTrials, theMRGCmosaic.inputConeMosaic);


    % Compute the cone mosaic excitation responses
    [theConeMosaicSpatioTemporalExcitationResponse, ~, ~, ~, theConeExcitationsResponseTemporalSupportSeconds] = ...
            theMRGCmosaic.inputConeMosaic.compute(theRetinalImage, ...
            'withFixationalEyeMovements', true);


    % Compute mean cone excitation rates.
    % Must be < 30,000 R*/sec to avoid significant bleaching
    meanConeExcitationRates = mean(theConeMosaicSpatioTemporalExcitationResponse,2)/ theMRGCmosaic.inputConeMosaic.integrationTime;
    
    maxConeExcitationRates = max(theConeMosaicSpatioTemporalExcitationResponse,2)/ theMRGCmosaic.inputConeMosaic.integrationTime;
    
    fprintf('Range of mean cone excitation rates: %f - %f * 10000 (R*/sec)\n', min(meanConeExcitationRates(:))/1e3, max(meanConeExcitationRates(:))/1e3);
    fprintf('Range of max cone excitation rates: %f - %f * 10000 (R*/sec)\n', min(maxConeExcitationRates(:))/1e3, max(maxConeExcitationRates(:))/1e3);
    
    
    if (max(meanConeExcitationRates) > 30*1000)
        error('some mean cone excitation rates were > 30000')
    end



    % Compute the photocurrents
    
    % Allocate memory for each cone mosaic OS biophys model
    nCones = size(theConeMosaicSpatioTemporalExcitationResponse,3);
    theConeOSbiophysModels = cell(1,nCones);
    
    eccentricityDegsOfOSbiophysicalModel = sqrt(sum(theMRGCmosaic.inputConeMosaic.eccentricityDegs(:).^2));


    skipAssertions = false;
    iCone = 1;
    iTrial = 1;
    % Retrieve this cone's excitations count response 
    theSingleConeExcitationCountsResponse = squeeze(theConeMosaicSpatioTemporalExcitationResponse(iTrial,:,iCone));
    
    % Convert it to a cone excitation rate response
    theSingleConeExcitationRateResponse = theSingleConeExcitationCountsResponse(:) / theMRGCmosaic.inputConeMosaic.integrationTime;
    
    % Compute the cone's mean excitation rate over the entire course of stimulation
    theSingleConeBackgroundConeExcitationRate = mean(theSingleConeExcitationRateResponse);
    
    % Compute the first cone's photocurrent response just to get the number of time
    % bins and also conduct the assertions
    [~, thePhotocurrentResponseTemporalSupportSeconds] = cMosaic.photocurrentFromConeExcitationRateUsingBiophysicalOSmodel(...
        eccentricityDegsOfOSbiophysicalModel, ...
        theSingleConeExcitationRateResponse, ...
        theSingleConeBackgroundConeExcitationRate, ...
        theMRGCmosaic.inputConeMosaic.integrationTime, ...  % the timebase of the cone excitation rate signal
        photocurrentParams.temporalResolutionSeconds,  ...  % the timebase of the returned photocurrent signal
        'osTimeStepSeconds', photocurrentParams.osBiophysicalModelTemporalResolutionSeconds, ...  % the time base for running the osBiophysical model
        'skipAssertions', skipAssertions, ...
        'theConeOSbiophysModel', theConeOSbiophysModels{iCone});


    % Allocate memory for the cone mosaic photocurrent response
    theConeMosaicSpatioTemporalPhotocurrentResponses = zeros(eyeMovementParams.nTrials, numel(thePhotocurrentResponseTemporalSupportSeconds), nCones);
    
    skipAssertions = true;
    
    for iTrial = 1:eyeMovementParams.nTrials
        parfor iCone = 1:nCones
        
            if (mod(iCone-1,100)==0)
                fprintf('Computing photocurrent for cone %d of %d (trial: %d of %d)\n', iCone, nCones, iTrial, eyeMovementParams.nTrials);
            end

            % Retrieve this cone's excitations count response 
            theSingleConeExcitationCountsResponse = squeeze(theConeMosaicSpatioTemporalExcitationResponse(iTrial,:,iCone));
        
            % Convert it to a cone excitation rate response
            theSingleConeExcitationRateResponse = theSingleConeExcitationCountsResponse(:) / theMRGCmosaic.inputConeMosaic.integrationTime;
        
            % Compute the cone's mean excitation rate over the entire course of stimulation
            theSingleConeBackgroundConeExcitationRate = mean(theSingleConeExcitationRateResponse);
        
            % Compute the cone's photocurrent response
            [theSingleConePhotocurrentDifferentialResponse, ~, ...
             theSingleConePhotocurrentBackgroundTransientResponse, ...
             theConeOSbiophysModels{iCone}] = cMosaic.photocurrentFromConeExcitationRateUsingBiophysicalOSmodel(...
                    eccentricityDegsOfOSbiophysicalModel, ...
                    theSingleConeExcitationRateResponse, ...
                    theSingleConeBackgroundConeExcitationRate, ...
                    theMRGCmosaic.inputConeMosaic.integrationTime, ...  % the timebase of the cone excitation rate signal
                    photocurrentParams.temporalResolutionSeconds,  ...  % the timebase of the returned photocurrent signal
                    'osTimeStepSeconds', photocurrentParams.osBiophysicalModelTemporalResolutionSeconds, ...  % the time base for running the osBiophysical model
                    'skipAssertions', skipAssertions, ...
                    'theConeOSbiophysModel', theConeOSbiophysModels{iCone});
            
            theConeMosaicSpatioTemporalPhotocurrentResponses(iTrial,:,iCone) = theSingleConePhotocurrentDifferentialResponse;
        end
    end
    
    theDataFileName = fullfile(exportVisualizationRootDirectory, exportDataDirectory, theDataFileName);

    save(theDataFileName, ...
        'theMRGCmosaic', ...
        'sceneCropParams', ...
        'theConeMosaicSpatioTemporalExcitationResponse', ...
        'theConeExcitationsResponseTemporalSupportSeconds', ...
        'theScene', 'theRetinalImage', 'theFixationalEMObj', ...
        'theConeMosaicSpatioTemporalPhotocurrentResponses', ...
        'thePhotocurrentResponseTemporalSupportSeconds', ...
        '-v7.3');

    fprintf('Saved everything to %s', theDataFileName);
end



%
% HELPER FUNCTIONS
%

function visualizeConeExcitationsStimulusModulationAndFixationalEMs(...
    theMRGCmosaicResponseDictionary, targetRGCindex, ...
    theConeMosaic, theNeuralResponses, temporalSupportSeconds, ...
    theRetinalImage, theFixationalEMOb, ...
    exportVisualizationRootDirectory, ...
    exportVisualizationVideoDirectory, ...
    theVideoFileName)


    domainVisualizationLimits(1:2) = theConeMosaic.eccentricityDegs(1) + 0.41 * theConeMosaic.sizeDegs(1) * [-1 1];
    domainVisualizationLimits(3:4) = theConeMosaic.eccentricityDegs(2) + 0.31 * theConeMosaic.sizeDegs(2) * [-1 1];
    domainVisualizationTicks = struct(...
        'x', theConeMosaic.eccentricityDegs(1) + 0.4 * theConeMosaic.sizeDegs(1) * [-1  0 1], ...
        'y', theConeMosaic.eccentricityDegs(2) + 0.3 * theConeMosaic.sizeDegs(2) * [-1  0  1]);

    xLims = domainVisualizationLimits(1:2)-mean(domainVisualizationLimits(1:2));
    xTicks = domainVisualizationTicks.x - mean(domainVisualizationLimits(1:2));
    yLims = domainVisualizationLimits(3:4)-mean(domainVisualizationLimits(3:4));
    yTicks = domainVisualizationTicks.y - mean(domainVisualizationLimits(3:4));


    stimulusIlluminance = oiGet(theRetinalImage, 'illuminance');
    retinalImage = oiGet(theRetinalImage, 'rgbimage');
    illuminanceRange = [min(stimulusIlluminance(:)) max(stimulusIlluminance(:))];

    oiPixelWidthDegs = oiGet(theRetinalImage, 'wangular resolution');
    oiWidthPixels = oiGet(theRetinalImage, 'cols');
    oiSupport = (1:oiWidthPixels)*oiPixelWidthDegs;
    oiSupport = oiSupport - mean(oiSupport);

    
    theVideoFileName = fullfile(exportVisualizationVideoDirectory, theVideoFileName);
            
    % Generate the path if we need to
    RGCMosaicConstructor.filepathFor.augmentedPathWithSubdirs(...
          exportVisualizationRootDirectory, theVideoFileName, ...
          'generateMissingSubDirs', true);
        
    theVideoFileName = fullfile(exportVisualizationRootDirectory, theVideoFileName);

    ff = PublicationReadyPlotLib.figureComponents('1.5x2 giant figure',...
        'darkScheme', true);

    fff = PublicationReadyPlotLib.figureComponents('1.5x2 giant figure',...
        'darkScheme', true);

    ff.grid = 'off';
    ff.box  = 'on';
    tmp = ff.backgroundColor;
    ff.backgroundColor = ff.legendBackgroundColor;
    ff.legendBackgroundColor = tmp;

    fff.grid = 'on';
    fff.box = 'off';
    fff.backgroundColor = ff.backgroundColor;
    fff.legendBackgroundColor = ff.legendBackgroundColor;

    hFig = figure(10); clf;
    theAxes = PublicationReadyPlotLib.generatePanelAxes(hFig,ff);
    axTraces = theAxes{1,1};
    axTraces2 = theAxes{2,1};

    axRetinalImageAndEyeMovement = theAxes{1,2};
    axConeMosaicExcitation = theAxes{2,2};
    

    % Cone mosaic activation range
    activationRange = prctile(abs(theNeuralResponses(:)), 99)*[-1 1];

    
    % Visualize each frame of the stimulus/response/fixational EM
    nTrials = size(theNeuralResponses,1);
    timeSamplesNum = size(theNeuralResponses,2);



    videoOBJ = VideoWriter(theVideoFileName, 'MPEG-4');
    videoOBJ.FrameRate = 60;
    videoOBJ.Quality = 100;
    videoOBJ.open();

    visualizedEMpathDurationSeconds = 0.1;

    
    RedBlueLUT = zeros(1024,3);
    RedBlueLUT(513,:) = ff.legendBackgroundColor;
    RedBlueLUT(514:1024,1) = ff.legendBackgroundColor(1) + (1-ff.legendBackgroundColor(1))*(1:511)/511;
    RedBlueLUT(514:1024,2) = ff.legendBackgroundColor(2);
    RedBlueLUT(514:1024,3) = ff.legendBackgroundColor(3);

    RedBlueLUT(512:-1:1,1) = ff.legendBackgroundColor(1);
    RedBlueLUT(512:-1:1,2) = ff.legendBackgroundColor(2);
    RedBlueLUT(512:-1:1,3) = ff.legendBackgroundColor(3) + (1-ff.legendBackgroundColor(3))*(1:512)/512;

    activationLUT = RedBlueLUT;
    activationLUT = brewermap(1024, '*greys');



    c = brewermap(6, 'blues');
    color1 = c(6,:);
    c = brewermap(6, 'reds');
    color2 = c(6,:);

 
    theLegends{1} = 'cone modulations + BK filters';
    [theTemporalSupportSeconds1, theResponse1] = retrieveTheSpatioTemporalMRGCmosaicResponses(...
        theMRGCmosaicResponseDictionary, ...
        theLegends{1}, ...
        0, 0, ...
        targetRGCindex);


    theLegends{2} = 'photocurrents + inner retina filter cascade';
    theResponseBias = 0.15;
    theResponseDelay = 12/1000;

    [theTemporalSupportSeconds2, theResponse2] = retrieveTheSpatioTemporalMRGCmosaicResponses(...
        theMRGCmosaicResponseDictionary, ...
        theLegends{2}, ...
        theResponseBias, theResponseDelay, ...
        targetRGCindex);


    theLegends3 = 'photocurrents only';
    [theTemporalSupportSeconds3, theResponse3] = retrieveTheSpatioTemporalMRGCmosaicResponses(...
        theMRGCmosaicResponseDictionary, ...
        theLegends3, ...
        0,0, ...
        targetRGCindex);


    drawTraces = true;
    drawTraces3 = true;

    
    m1 = max(abs(theResponse1(:)));
    m2 = max(abs(theResponse2(:)));
    m3 = max(abs(theResponse3(:)));
    theResponse1 = theResponse1 / m1;
    theResponse2 = theResponse2 / m2;
    theResponse3 = theResponse3 / m3;

    traceViewWindowSeconds = 1500/1000;

    minTimeSeconds = traceViewWindowSeconds;
    maxTimeSeconds = 4500/1000;


    for iTrial = 1:nTrials
    for iTimePoint = 1:timeSamplesNum

        currentTime = temporalSupportSeconds(iTimePoint);
        if (currentTime < minTimeSeconds) || (currentTime > maxTimeSeconds)
            continue;
        end
        
        theMosaicResponse = theNeuralResponses(iTrial, iTimePoint,:);

        % The input cone mosaic activation
        theConeMosaic.visualize('figureHandle', hFig,...
            'axesHandle', axConeMosaicExcitation, ...
            'activation', theMosaicResponse, ...
            'activationRange', activationRange, ...
            'visualizedConeAperture', 'lightcollectingarea5sigma', ...
            'visualizedConeApertureThetaSamples', 32, ...
            'activationColorMap', activationLUT, ...
            'backgroundColor', ff.legendBackgroundColor, ...
            'domainVisualizationLimits', domainVisualizationLimits, ...
            'domainVisualizationTicks', domainVisualizationTicks, ...
            'withFigureFormat', ff, ...
            'plotTitleFontSize', 20, ...
            'plotTitle', sprintf('cone mosaic activation (photocurrents)\ntime: %2.1f msec', (currentTime-minTimeSeconds)*1e3));
        set(axConeMosaicExcitation, 'YaxisLocation', 'right')
         
        % The retinal illuminance and fixational EM path
        %imagesc(axRetinalImageAndEyeMovement, oiSupport, oiSupport, (stimulusIlluminance-illuminanceRange(1))/(illuminanceRange(2) - illuminanceRange(1)), [0 1]);
        image(axRetinalImageAndEyeMovement, oiSupport, oiSupport, retinalImage);


        % Overlay the fixational EMpath
        hold(axRetinalImageAndEyeMovement, 'on');

        % Visualize fEM during the last visualizedEMpathDurationSecond period
        timeIndicesVisualized = find(...
            (theFixationalEMOb.timeAxis <= currentTime) & ...
            (theFixationalEMOb.timeAxis >= currentTime -visualizedEMpathDurationSeconds));

        timeIndicesVisualized = min(size(theFixationalEMOb.emPosArcMin,2),timeIndicesVisualized);

        plot(axRetinalImageAndEyeMovement, ...
            theFixationalEMOb.emPosArcMin(iTrial, timeIndicesVisualized,1)/60, ...
            theFixationalEMOb.emPosArcMin(iTrial, timeIndicesVisualized,2)/60, '-', ...
            'LineWidth', 3.0, 'Color', 'k');

        plot(axRetinalImageAndEyeMovement, ...
            theFixationalEMOb.emPosArcMin(iTrial, timeIndicesVisualized,1)/60, ...
            theFixationalEMOb.emPosArcMin(iTrial, timeIndicesVisualized,2)/60, '-', ...
            'LineWidth', 2.0, 'Color', 'r');

        plot(axRetinalImageAndEyeMovement, ...
            theFixationalEMOb.emPosArcMin(iTrial, timeIndicesVisualized(end),1)/60, ...
            theFixationalEMOb.emPosArcMin(iTrial, timeIndicesVisualized(end),2)/60, 'ro', ...
            'LineWidth', 2.0, 'MarkerSize', 12, 'MarkerFaceColor', [1 0 0], 'MarkerEdgeColor', [1 1 1]);

        hold(axRetinalImageAndEyeMovement, 'off')

        axis(axRetinalImageAndEyeMovement, 'equal');
        axis(axRetinalImageAndEyeMovement, 'image');
        set(axRetinalImageAndEyeMovement, 'FontSize', 20, 'Color', [0 0 0]);

        
        set(axRetinalImageAndEyeMovement, 'XLim', xLims, 'YLim', yLims);
        set(axRetinalImageAndEyeMovement, 'XTick', xTicks, 'YTick', yTicks);
        set(axRetinalImageAndEyeMovement, 'XTickLabel', {}, 'YTickLabel', {});
        colormap(axRetinalImageAndEyeMovement, brewermap(1024, '*greys'));
        title(axRetinalImageAndEyeMovement, sprintf('retinal illuminance and recent fixational EM path'));
       
        PublicationReadyPlotLib.applyFormat(axRetinalImageAndEyeMovement,ff);

   
        
        if (drawTraces)
            drawTraces = false;

            % Plot every 5th point
            skipSize = 5;

            % The traces
            pHandles = [];
            plot(axTraces, (theTemporalSupportSeconds1(1:skipSize:end))*1e3, theResponse1(1:skipSize:end), 'k-', 'Color', color1, 'LineWidth', 3.0);

            pHandles(numel(pHandles)+1) = plot(axTraces, (theTemporalSupportSeconds1(1:skipSize:end))*1e3, theResponse1(1:skipSize:end), 'o-',...
                'Color', color1.^0.5, 'MarkerSize', 10, 'MarkerFaceColor', color1, 'MarkerEdgeColor', color1.^0.5, 'LineWidth', 2.0);
            hold(axTraces, 'on')
    
    
            plot(axTraces, theTemporalSupportSeconds2*1e3, theResponse2, 'k-', 'Color', color2, 'LineWidth', 3.0);
            pHandles(numel(pHandles)+1) = scatter(axTraces, (theTemporalSupportSeconds2(1:skipSize:end))*1e3, theResponse2(1:skipSize:end), 100,...
                'Color', color2.^0.5, 'MarkerFaceAlpha', 0.8, 'MarkerEdgeColor', color2, 'MarkerFaceColor', color2.^0.5, 'LineWidth', 2.0);
  
            legend(axTraces, pHandles, theLegends, 'Location', 'NorthOutside', 'NumColumns', 2);
        end

        timeLimits = currentTime + [-traceViewWindowSeconds 0];
        responseLimits = [-1.0 1.0];
        set(axTraces, 'XLim', timeLimits*1e3, 'YLim', responseLimits, 'XTick', 0:100:6000, 'XTickLabel', sprintf('%2.0f\n', (0:100:6000)-minTimeSeconds*1e3), 'YTick', -1:0.5:1);
        xlabel(axTraces, 'time (msec)');
        ylabel(axTraces, 'mRGC response');

        PublicationReadyPlotLib.applyFormat(axTraces,fff);
        set(axTraces, 'YaxisLocation', 'right')


        if (drawTraces3)
            drawTraces3 = false;

            % The traces
            skipSize = 5;

            plot(axTraces2, theTemporalSupportSeconds3*1e3, theResponse3, 'k-', 'Color', color1, 'LineWidth', 3.0);
            p3 = plot(axTraces2, theTemporalSupportSeconds3(1:skipSize:end)*1e3, theResponse3(1:skipSize:end), 'o-',...
                'Color', color1.^0.5, 'MarkerSize', 10, 'MarkerFaceColor', color1, 'MarkerEdgeColor', color1.^0.5, 'LineWidth', 2.0);
    
            legend(axTraces2, p3, theLegends3, 'Location', 'NorthOutside', 'NumColumns', 2);
        end

        set(axTraces2, 'XLim', timeLimits*1e3, 'YLim', responseLimits, 'XTick', 0:100:6000, 'XTickLabel', {}, 'YTick', -1:0.5:1);
      
        ylabel(axTraces2, 'mRGC response');
        PublicationReadyPlotLib.applyFormat(axTraces2 , fff);
        set(axTraces2, 'YaxisLocation', 'right')

        drawnow;
        videoOBJ.writeVideo(getframe(hFig));

    end % for iTimePoint
    end % for iTrial

    videoOBJ.close();
end


function fixationalEMObj = generateFixationalEyeMovements(trialDurationSeconds, nTrials, theConeMosaic)
    % Initialize
    fixationalEMObj = fixationalEM;              % Instantiate a fixationalEM object

    % Generate microsaccades with a mean interval of  150 milliseconds
    % Much more often than the default, just for video purposes.
    fixationalEMObj.microSaccadeMeanIntervalSeconds = 0.200;

    % fixationalEMObj.microSaccadeType = 'none';   % No microsaccades, just drift
    
    % Compute number of eye movements
    eyeMovementsPerTrial = trialDurationSeconds/theConeMosaic.integrationTime;

    % Generate the em sequence for the passed cone mosaic,
    % which results in a time step equal to the integration time of theConeMosaic
    fixationalEMObj.computeForCmosaic(...
        theConeMosaic, eyeMovementsPerTrial,...
        'nTrials' , nTrials);

    % Set the fixational eye movements into the cone mosaic
    theConeMosaic.emSetFixationalEMObj(fixationalEMObj);
end


function [scene, spatialSupportXdegs, spatialSupportYdegs] = loadMachnesterDataBaseScene(...
    theDatabaseYear, theSceneName)

    scenesDir = fullfile(localDropboxDir, 'HyperspectralSceneTutorial', 'resources', 'manchester_database');
    sceneFileName = sprintf('%s/%d/%s.', scenesDir, theDatabaseYear, theSceneName);
    load(sceneFileName, 'scene');

    % retrieve the spatial support of the scene(in millimeters)
    spatialSupportMilliMeters = sceneGet(scene, 'spatial support', 'mm');

    viewingDistance = sceneGet(scene, 'distance');
    spatialSupportDegs = 2 * atand(spatialSupportMilliMeters/1e3/2/viewingDistance);
    spatialSupportXdegs = squeeze(spatialSupportDegs(1,:,1));
    spatialSupportYdegs = squeeze(spatialSupportDegs(:,1,2));


end


function visualizeHDRscene(scene, spatialSupportXdegs, spatialSupportYdegs, sceneCropParams, figNo, ...
    exportVisualizationPDFrootDirectory, exportVisualizationPDFdirectory, thePDFfileName)


    flipUpsideDown = true;
    if (flipUpsideDown)
        thePhotons = sceneGet(scene, 'photons');
        for iWave = 1:size(thePhotons,3)
            thePhotons(:,:,iWave) = flipud(squeeze(thePhotons(:,:,iWave)));
        end
        scene = sceneSet(scene, 'photons', thePhotons);
    end

    rangeDegs = max(spatialSupportXdegs)-min(spatialSupportXdegs);
    if (rangeDegs<2)
        xTicks = -10:0.5:10;
    else
        xTicks = -10:1:10;
    end

    RGBsettings = sceneGet(scene, 'rgbimage');
    luminanceMap = sceneGet(scene, 'luminance');

    ff = PublicationReadyPlotLib.figureComponents('1x2 giant figure',...
        'darkScheme', true);

    hFig = figure(figNo); clf;
    theAxes = PublicationReadyPlotLib.generatePanelAxes(hFig,ff);
    ax1 = theAxes{1,1};
    ax2 = theAxes{1,2};

    % The RGB scene
    image(ax1, spatialSupportXdegs, spatialSupportYdegs, RGBsettings); 
    hold(ax1, 'on')
    plot(ax1,spatialSupportXdegs, spatialSupportXdegs*0, 'k-');
    plot(ax1,spatialSupportYdegs*0, spatialSupportYdegs, 'k-');
    if (~isempty(sceneCropParams))
        xx = sceneCropParams.positionDegs(1) + 0.5*sceneCropParams.sizeDegs(1)*[-1 -1 1 1 -1];
        yy = sceneCropParams.positionDegs(2) + 0.5*sceneCropParams.sizeDegs(2)*[-1 1 1 -1 -1];
        plot(ax1, xx, yy, 'w-', 'LineWidth', 3);
        plot(ax1, xx, yy, 'k--', 'LineWidth', 1.5);
    end    
    hold(ax1, 'off');
    


    colorbar(ax1)
    axis(ax1, 'xy');
    axis(ax1, 'image');
    xlabel(ax1, 'space, x (degs)');
    ylabel(ax1, 'space, y (degs)');
    set(ax1, 'XTick', xTicks, 'YTick', xTicks);
    PublicationReadyPlotLib.applyFormat(ax1,ff);


    % The luminance map
    imagesc(ax2, spatialSupportXdegs, spatialSupportYdegs, luminanceMap);
    hold(ax2, 'on')
    plot(ax2,spatialSupportXdegs, spatialSupportXdegs*0, 'k-');
    plot(ax2,spatialSupportYdegs*0, spatialSupportYdegs, 'k-');
    if (~isempty(sceneCropParams))
        xx = sceneCropParams.positionDegs(1) + 0.5*sceneCropParams.sizeDegs(1)*[-1 -1 1 1 -1];
        yy = sceneCropParams.positionDegs(2) + 0.5*sceneCropParams.sizeDegs(2)*[-1 1 1 -1 -1];
        plot(ax2, xx, yy, 'k-', 'LineWidth', 3);
        plot(ax2, xx, yy, 'g--', 'LineWidth', 1.5);
        
    end
    hold(ax2, 'off');

    colormap(ax2,hot(1024))
    colorbar(ax2)
    axis(ax2, 'xy');
    axis(ax2, 'image');
    set(ax2, 'XTick', xTicks, 'YTick', xTicks);
    xlabel(ax2, 'space, x (degs)');
    
    PublicationReadyPlotLib.applyFormat(ax2,ff);

    ax3 = axes('Position', [0.57 0.15 0.365 0.10]);
    luminanceRange = [0 200];
    h = histogram(ax3, luminanceMap(:), luminanceRange(1):2:luminanceRange(2));
    h.FaceColor = [0.2 0.8 0.2];
    h.FaceAlpha = 0.8;
    hold(ax3, 'on');
    plot(ax3, [0 200], [0 0], 'w-', 'Color', [0.8 0.8 0.8], 'LineWidth', 1.5);
    lumRange = prctile(luminanceMap(:), [1 50 99]);
    meanLuminance = mean(luminanceMap(:));

    yy = get(ax3, 'YLim');
    yy(2) = yy(2)*1.02;
    set(ax3, 'YLim', yy);
    scatter(ax3, lumRange(1), yy(2), 121, 'v', 'MarkerEdgeColor', [0 1 0], 'MarkerFaceColor', [0.4 0.4 0.4], 'MarkerFaceAlpha', 0.6, 'LineWidth', 1.0);
    scatter(ax3, lumRange(2), yy(2), 121, 'v', 'MarkerEdgeColor', [0 1 0], 'MarkerFaceColor', [0.4 1 0.4], 'MarkerFaceAlpha', 0.6, 'LineWidth', 1.0);
    scatter(ax3, lumRange(3), yy(2), 121, 'v', 'MarkerEdgeColor', [0 1 0], 'MarkerFaceColor', [0.4 0.4 0.4], 'MarkerFaceAlpha', 0.6, 'LineWidth', 1.0);
    scatter(ax3, meanLuminance, yy(2), 121, 'v', 'MarkerEdgeColor', [1 1 0], 'MarkerFaceColor', [0.4 0.4 0.4], 'MarkerFaceAlpha', 0.6, 'LineWidth', 1.0);
    
    hold(ax3, 'off');
    title(ax3, sprintf('luminance prctiles (1, 50, 99): %1.0f/%1.0f/%1.0f; (meanLum:%1.0f) cd/m2', lumRange(1), lumRange(2), lumRange(3), meanLuminance));
    set(ax3, 'XLim', luminanceRange, 'XTick', [], 'XTickLabel', {}, 'YTick', []);
    
    ff.box = 'on';
    PublicationReadyPlotLib.applyFormat(ax3,ff);

    theVisualizationPDFfilename = fullfile(exportVisualizationPDFdirectory, thePDFfileName);
            
    % Generate the path if we need to
    RGCMosaicConstructor.filepathFor.augmentedPathWithSubdirs(...
          exportVisualizationPDFrootDirectory, theVisualizationPDFfilename, ...
          'generateMissingSubDirs', true);
        
    thePDFfileName = fullfile(exportVisualizationPDFrootDirectory, theVisualizationPDFfilename);
    NicePlot.exportFigToPDF(thePDFfileName, hFig, 300, 'beVerbose');
end




function [theScene, spatialSupportXdegs, spatialSupportYdegs] = ...
        cropScene(theScene, spatialSupportXdegs, spatialSupportYdegs, ...
        cropParams)

    % Boost factor for mean luminance
    luminance = sceneCalculateLuminance(theScene);
    meanLuminanceBefore = mean(luminance(:));
    boostFactor = cropParams.meanLuminanceCdM2 / meanLuminanceBefore;

    flipUpsideDown = true;
    if (flipUpsideDown)
        thePhotons = sceneGet(theScene, 'photons');
        for iWave = 1:size(thePhotons,3)
            thePhotons(:,:,iWave) = flipud(squeeze(thePhotons(:,:,iWave)));
        end
        theScene = sceneSet(theScene, 'photons', thePhotons*boostFactor);
    end

    % Crop a patch
    widthDegs = cropParams.sizeDegs(1);
    heightDegs = cropParams.sizeDegs(2);
    xCenterDegs = cropParams.positionDegs(1);
    yCenterDegs = cropParams.positionDegs(2);

    if (widthDegs<=0)
        error('width cannot be negative or 0')
    end
    if (heightDegs<=0)
        error('height cannot be negative or 0')
    end

    % Compute cropping rect
    [~,minCol] = min(abs(xCenterDegs-0.5*widthDegs-spatialSupportXdegs));
    [~,maxCol] = min(abs(xCenterDegs+0.5*widthDegs-spatialSupportXdegs));
    [~,minRow] = min(abs(yCenterDegs-0.5*heightDegs-spatialSupportYdegs));
    [~,maxRow] = min(abs(yCenterDegs+0.5*heightDegs-spatialSupportYdegs));
    theCroppingRect(1:2) = [minCol minRow];
    theCroppingRect(3:4) = [maxCol-minCol maxRow-minRow];

    % Crop the scene
    theScene = sceneCrop(theScene, theCroppingRect);

    % Set the desired FOV of the cropped image
    theScene = sceneSet(theScene, 'wangular', cropParams.imageFOVdegs);

    if (flipUpsideDown)
        % Undo the updown-flip
        thePhotons = sceneGet(theScene, 'photons');
        for iWave = 1:size(thePhotons,3)
            thePhotons(:,:,iWave) = flipud(squeeze(thePhotons(:,:,iWave)));
        end
        theScene = sceneSet(theScene, 'photons', thePhotons);
    end

    % retrieve the spatial support of the scene(in millimeters)
    spatialSupportMilliMeters = sceneGet(theScene, 'spatial support', 'mm');

    viewingDistance = sceneGet(theScene, 'distance');
    spatialSupportDegs = 2 * atand(spatialSupportMilliMeters/1e3/2/viewingDistance);
    
    spatialSupportXdegs = squeeze(spatialSupportDegs(1,:,1));
    spatialSupportYdegs = squeeze(spatialSupportDegs(:,1,2));
end



function fancyMosaicVisualization(theMRGCmosaic, ...
    thePSFatTheMosaicEccentricity, ...
    domainVisualizationLimits, ...
    domainVisualizationTicks, ...
    exportVisualizationPDFrootDirectory, ...
    exportVisualizationPDFdirectory)


    % Generate a PSF visualization data struct (containing the vLambda-weighted PSF) for
    % visualization purposes
    PSFvisualizationOffset = theMRGCmosaic.eccentricityDegs - [mean(domainVisualizationLimits(1:2)) mean(domainVisualizationLimits(3:4))];
    vLambdaWeightedPSF.data = RGCMosaicAnalyzer.compute.vLambdaWeightedPSF(thePSFatTheMosaicEccentricity);
    vLambdaWeightedPSF.supportXdegs = thePSFatTheMosaicEccentricity.supportX/60 - PSFvisualizationOffset(1);
    vLambdaWeightedPSF.supportYdegs = thePSFatTheMosaicEccentricity.supportY/60 - PSFvisualizationOffset(2);


    % Visualize the full mosaic of RF centers using a representation
    % like the representation used in visualizing
    % mosaics of RGCs in typical in-vitro experiments (e.g. by the Chichilnisky lab)
    minCenterConeWeight = mRGCMosaic.sensitivityAtPointOfOverlap;
    

    % Get ready for publication-quality visualization
    ff = PublicationReadyPlotLib.figureComponents('1x1 giant rectangular-double wide mosaic', ...
        'darkScheme', true);
    
    % Plot the mosaic of mRGC RF centers only
    hFig = figure(1); clf;
    theAxes = PublicationReadyPlotLib.generatePanelAxes(hFig,ff);
    ax = theAxes{1,1};
    
    tmp = ff.backgroundColor;
    ff.backgroundColor = ff.legendBackgroundColor;
    ff.legendBackgroundColor = tmp;
    
    theMRGCmosaic.visualize(...
        'figureHandle', hFig, ...
        'axesHandle', ax, ...
        'identifyInputCones', false, ...
        'identifyPooledCones', false, ...
        'minConeWeightVisualized', minCenterConeWeight, ...
        'centerSubregionContourSamples', 32, ...
        'plottedRFoutlineFaceAlpha', 1.0, ...
        'plottedRFoutlineLineWidth', 1.0, ...
        'plottedRFoutlineFaceColor', [1 1 1], ...
        'plottedRFoutlineEdgeColor',  [0 0 0], ...
        'domainVisualizationLimits', domainVisualizationLimits, ...
        'domainVisualizationTicks', domainVisualizationTicks, ...
        'plotTitle', sprintf('min center weight visualized: %2.3f', minCenterConeWeight), ...
        'withFigureFormat', ff, ...
        'backgroundColor', ff.legendBackgroundColor, ...
        'clearAxesBeforeDrawing', false);
    hold(ax, 'on');

    % double rendering
    theMRGCmosaic.visualize(...
        'figureHandle', hFig, ...
        'axesHandle', ax, ...
        'identifyInputCones', false, ...
        'identifyPooledCones', false, ...
        'minConeWeightVisualized', minCenterConeWeight, ...
        'centerSubregionContourSamples', 32, ...
        'plottedRFoutlineFaceAlpha', 0.5, ...
        'plottedRFoutlineLineWidth', 4.0, ...
        'plottedRFoutlineEdgeColor', [0 0 0], ...
        'plottedRFoutlineFaceColor',  [0. 1.0 0.0], ...
        'domainVisualizationLimits', domainVisualizationLimits, ...
        'domainVisualizationTicks', domainVisualizationTicks, ...
        'plotTitle', sprintf('min center weight visualized: %2.3f', minCenterConeWeight), ...
        'withFigureFormat', ff, ...
        'backgroundColor', ff.legendBackgroundColor, ...
        'clearAxesBeforeDrawing', false)
    
    theMRGCmosaic.visualize(...
        'figureHandle', hFig, ...
        'axesHandle', ax, ...
        'identifyInputCones', false, ...
        'identifyPooledCones', false, ...
        'minConeWeightVisualized', minCenterConeWeight, ...
        'centerSubregionContourSamples', 32, ...
        'plottedRFoutlineFaceAlpha', 0.0, ...
        'plottedRFoutlineLineWidth', 2, ...
        'plottedRFoutlineEdgeColor', [0 1 0 ], ...
        'plottedRFoutlineFaceColor',  [0. 1 0.0], ...
        'domainVisualizationLimits', domainVisualizationLimits, ...
        'domainVisualizationTicks', domainVisualizationTicks, ...
        'plotTitle', ' ', ...
        'withFigureFormat', ff, ...
        'backgroundColor', ff.legendBackgroundColor, ...
        'clearAxesBeforeDrawing', false, ...
        'visualizationPDFfileName', 'mRGCmosaic', ...
        'exportVisualizationPDF', true, ...
        'exportVisualizationPNG', true, ...
        'exportVisualizationPDFrootDirectory', exportVisualizationPDFrootDirectory, ...
        'exportVisualizationPDFdirectory', exportVisualizationPDFdirectory);
    
end
