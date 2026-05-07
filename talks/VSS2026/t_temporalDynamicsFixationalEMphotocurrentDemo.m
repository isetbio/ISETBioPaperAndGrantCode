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
        'sizeDegs', [0.75 0.5], ...
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
        'imageFOVdegs', 3.0, ...        % scale it to a 3x3 patch
        'meanLuminanceCdM2', 15 ...     % and asdjust its mean luminance
    );
    % -====================================================================


   

    % Distant forest, luminance range: 17-230 (mean: 10)
    HDRdatabaseYear = 2004
    HDRimageName = 'scene1';

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

    t_temporalDynamicsFixationalEMphotocurrentDemo(...
        'cropParams', cropParams, ...
        'sceneCropParams', sceneCropParams, ...
        'HDRdatabaseYear', HDRdatabaseYear, ...
        'HDRimageName', HDRimageName, ...
        'photocurrentParams', photocurrentParams, ...
        'rgcMosaicName', 'JCNpaperTemporal7DegsMosaic', ...
        'opticsSubjectName', 'JCNpaperDefaultSubject', ...
        'visualizeMRGCmosaic',~true);
        

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

    
    % Nonlinearities
    options.mRGCNonLinearityParamsStruct = [];
    options.mRGCsOperateOnBackgroundAdaptedPhotocurrents (1,1) logical = true;


    % Source HDR image
    options.HDRdatabaseYear (1,:) double =  2004;
    options.HDRimageName (1,:) char = 'scene1';

    % Visualizations
    options.visualizeMRGCmosaic (1,1) logical = false;

    % ---- Choices of actions to perform ----
    % Whether to compute the input cone mosaic TTF responses
    options.computeInputConeMosaicResponses (1,1) logical = false;
    options.computeInputConeMosaicResponsesBasedOnConeExcitations (1,1) logical = true;
    options.computeInputConeMosaicResponsesBasedOnPhotocurrents (1,1) logical = true;
    options.computePhotocurrentResponsesOnlyForInputsToSingleRGCwithIndex (1,:) double = [];

    options.computeMRGCMosaicResponses (1,1) logical = false;


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

mRGCsOperateOnBackgroundAdaptedPhotocurrents = options.mRGCsOperateOnBackgroundAdaptedPhotocurrents;

% Nonlinearities
mRGCNonLinearityParamsStruct = options.mRGCNonLinearityParamsStruct;


% Source HDR image
HDRdatabaseYear = options.HDRdatabaseYear;
HDRimageName = options.HDRimageName;


% Visualizations
visualizeMRGCmosaic = options.visualizeMRGCmosaic;
exportVisualizationPDF = options.exportVisualizationPDF;
exportVisualizationPNG = options.exportVisualizationPNG;

% Close previously open figures
closePreviouslyOpenFigures = options.closePreviouslyOpenFigures;

if (closePreviouslyOpenFigures)
    % Close any stray figs
    close all;
end

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

% Generate figure dir if it does not exist
exportVisualizationRootDirectory = ISETBioPaperAndGrantCodeFigureDirForScript(mfilename);
exportVisualizationPDFdirectory = 'staticPDFs';
exportVisualizationVideoDirectory = 'videos';


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


    % Visualize cropped scene and its luminance map
    figNo = 2;
    visualizeHDRscene(theScene, spatialSupportXdegs, spatialSupportYdegs, [], figNo, ...
        exportVisualizationRootDirectory, ...
        exportVisualizationPDFdirectory, ...
        sprintf('%s_%d_%s_cropped.pdf', 'Manchester', HDRdatabaseYear, HDRimageName));
end


% Compute the retinal image
theRetinalImage = oiCompute(theOptics,theScene,'pad value','mean');


theMRGCmosaic.inputConeMosaic.integrationTime = 5/1000;

% Instantiate a fixational eye movement object for generating
% fixational eye movements that include drift and microsaccades.
fixEMobj = fixationalEM();

% Generate microsaccades with a mean interval of  150 milliseconds
% Much more often than the default, just for video purposes.
fixEMobj.microSaccadeMeanIntervalSeconds = 0.150;

% Compute nTrials of emPaths for this mosaic
% Here we are fixing the random seed so as to reproduce identical eye
% movements whenever this script is run.
nTrials = 1;
trialDurationSeconds = 5.0;

theFixationalEMObj = generateFixationalEyeMovements(...
    trialDurationSeconds, nTrials, theMRGCmosaic.inputConeMosaic);


% Compute the cone mosaic excitation responses
[theConeMosaicSpatioTemporalExcitationResponse, ~, ~, ~, theConeExcitationsResponseTemporalSupportSeconds] = ...
        theMRGCmosaic.inputConeMosaic.compute(theRetinalImage, ...
        'withFixationalEyeMovements', true);


% Compute mean cone excitation rates.
% Must be < 30,000 R*/sec to avoid significant bleaching
meanConeExcitationRates = mean(theConeMosaicSpatioTemporalExcitationResponse,2)/ theMRGCmosaic.inputConeMosaic.integrationTime;

maxConeExcitationRates = max(theConeMosaicSpatioTemporalExcitationResponse,2)/ theMRGCmosaic.inputConeMosaic.integrationTime;

fprintf('Range of mean cone excitation rates: %f - %f (R*/sec) * 10000 \n', min(meanConeExcitationRates(:))/1e3, max(meanConeExcitationRates(:))/1e3);
fprintf('Range of max cone excitation rates: %f - %f (R*/sec) * 10000 \n', min(maxConeExcitationRates(:))/1e3, max(maxConeExcitationRates(:))/1e3);


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
theConeMosaicSpatioTemporalPhotocurrentResponses = zeros(nTrials, numel(thePhotocurrentResponseTemporalSupportSeconds), nCones);

skipAssertions = true;

for iTrial = 1:nTrials
    parfor iCone = 1:nCones
    
        fprintf('Computing photocurrent for cone %d of %d (trial: %d of %d)\n', iCone, nCones, iTrial, nTrials);
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

save('alldata.mat', ...
    'theMRGCmosaic', ...
    'theConeMosaicSpatioTemporalExcitationResponse', ...
    'theConeExcitationsResponseTemporalSupportSeconds', ...
    'theScene', 'theRetinalImage', 'theFixationalEMObj', ...
    'theConeMosaicSpatioTemporalPhotocurrentResponses', ...
    'thePhotocurrentResponseTemporalSupportSeconds', ...
    '-v7.3');

fprintf('Saved everything to alldata.mat');

radii = sqrt(sum((bsxfun(@minus, theMRGCmosaic.inputConeMosaic.coneRFpositionsDegs, theMRGCmosaic.inputConeMosaic.eccentricityDegs)).^2,2));
coneIndicesToVisualize = find(radii < 0.2);

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

    pause

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



%
% HELPER FUNCTIONS
%

function visualizeConeExcitationsStimulusModulationAndFixationalEMs(...
    theConeMosaic, theNeuralResponses, temporalSupportSeconds, ...
    theRetinalImage, theFixationalEMOb, ...
    exportVisualizationRootDirectory, ...
    exportVisualizationVideoDirectory, ...
    theVideoFileName)


    domainVisualizationLimits(1:2) = theConeMosaic.eccentricityDegs(1) + 0.51 * theConeMosaic.sizeDegs(1) * [-1 1];
    domainVisualizationLimits(3:4) = theConeMosaic.eccentricityDegs(2) + 0.51 * theConeMosaic.sizeDegs(2) * [-1 1];
    domainVisualizationTicks = struct(...
        'x', theConeMosaic.eccentricityDegs(1) + 0.5 * theConeMosaic.sizeDegs(1) * [-1  0 1], ...
        'y', theConeMosaic.eccentricityDegs(2) + 0.5 * theConeMosaic.sizeDegs(2) * [-1  0  1]);

    stimulusIlluminance = oiGet(theRetinalImage, 'illuminance');
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

    ff = PublicationReadyPlotLib.figureComponents('1x2 giant figure',...
        'darkScheme', true);

    ff.grid = 'off';
    tmp = ff.backgroundColor;
    ff.backgroundColor = ff.legendBackgroundColor;
    ff.legendBackgroundColor = tmp;

    hFig = figure(10); clf;
    theAxes = PublicationReadyPlotLib.generatePanelAxes(hFig,ff);
    axConeMosaicExcitation = theAxes{1,1};
    axRetinalImageAndEyeMovement = theAxes{1,2};


    % Cone mosaic activation range
    activationRange = [min(theNeuralResponses(:)) max(theNeuralResponses(:))];

    % Visualize each frame of the stimulus/response/fixational EM
    nTrials = size(theNeuralResponses,1);
    timeSamplesNum = size(theNeuralResponses,2);



    videoOBJ = VideoWriter(theVideoFileName, 'MPEG-4');
    videoOBJ.FrameRate = 30;
    videoOBJ.Quality = 100;
    videoOBJ.open();

    visualizedEMpathDurationSeconds = 0.5;

    for iTrial = 1:nTrials
    for iTimePoint = 1:timeSamplesNum

        currentTime = temporalSupportSeconds(iTimePoint);
        theMosaicResponse = theNeuralResponses(iTrial, iTimePoint,:);

        % The input cone mosaic activation
        theConeMosaic.visualize('figureHandle', hFig,...
            'axesHandle', axConeMosaicExcitation, ...
            'activation', theMosaicResponse, ...
            'activationRange', activationRange, ...
            'visualizedConeAperture', 'lightcollectingarea5sigma', ...
            'visualizedConeApertureThetaSamples', 32, ...
            'backgroundColor', ff.legendBackgroundColor, ...
            'domainVisualizationLimits', domainVisualizationLimits, ...
            'domainVisualizationTicks', domainVisualizationTicks, ...
            'withFigureFormat', ff, ...
            'plotTitleFontSize', 20, ...
            'plotTitle', sprintf('cone mosaic activation (excitations)\ntime: %2.1f msec', currentTime*1e3));
    
            
        % The retinal illuminance and fixational EM path
        imagesc(axRetinalImageAndEyeMovement, oiSupport, oiSupport, (stimulusIlluminance-illuminanceRange(1))/(illuminanceRange(2) - illuminanceRange(1)), [0 1]);

        % Overlay the fixational EMpath
        hold(axRetinalImageAndEyeMovement, 'on');

        % Visualize fEM during the last visualizedEMpathDurationSecond speriod
        timeIndicesVisualized = find(...
            (temporalSupportSeconds <= currentTime) & ...
            (temporalSupportSeconds >= currentTime -visualizedEMpathDurationSeconds));

        plot(axRetinalImageAndEyeMovement, ...
            theFixationalEMOb.emPosArcMin(iTrial, timeIndicesVisualized,1)/60, ...
            theFixationalEMOb.emPosArcMin(iTrial, timeIndicesVisualized,2)/60, '-', ...
            'LineWidth', 2.0, 'Color', 'k');


        plot(axRetinalImageAndEyeMovement, ...
            theFixationalEMOb.emPosArcMin(iTrial, timeIndicesVisualized,1)/60, ...
            theFixationalEMOb.emPosArcMin(iTrial, timeIndicesVisualized,2)/60, '-', ...
            'LineWidth', 1.5, 'Color', 'g');

        hold(axRetinalImageAndEyeMovement, 'off')

        axis(axRetinalImageAndEyeMovement, 'equal');
        axis(axRetinalImageAndEyeMovement, 'image');
        set(axRetinalImageAndEyeMovement, 'FontSize', 20, 'Color', [0 0 0]);

        xLims = domainVisualizationLimits(1:2)-mean(domainVisualizationLimits(1:2));
        xTicks = domainVisualizationTicks.x - mean(domainVisualizationLimits(1:2));
        yLims = domainVisualizationLimits(3:4)-mean(domainVisualizationLimits(3:4));
        yTicks = domainVisualizationTicks.y - mean(domainVisualizationLimits(3:4));

        set(axRetinalImageAndEyeMovement, 'XLim', xLims, 'YLim', yLims);
        set(axRetinalImageAndEyeMovement, 'XTick', xTicks, 'YTick', yTicks);
        set(axRetinalImageAndEyeMovement, 'XTickLabel', sprintf('%1.1f\n', xTicks), 'YTickLabel', sprintf('%1.1f\n', yTicks));
        colormap(axRetinalImageAndEyeMovement, hot(1024));
        title(axRetinalImageAndEyeMovement, sprintf('retinal illuminance and\nrecent fixational EM path'));
       

        PublicationReadyPlotLib.applyFormat(axRetinalImageAndEyeMovement,ff);
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
