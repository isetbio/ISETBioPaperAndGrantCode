function t_visualizeConePoolingForTargetMRGC(options)
% Visualize the cone pooling map of a single cell in an mRGCmosaic
%
% Syntax:
%   t_visualizeConePoolingForTargetMRGC
%
% Description:
%   Visualize the cone pooling map of a single mRGC

% History:
%    05/12/26  NPC  Wrote it.


% Examples:
%{

  % Only use a small patch of the mRGC mosaic
 cropParams = struct( ...
        'sizeDegs', [0.25 0.25], ...
        'eccentricityDegs', [-6 0]);

  t_visualizeConePoolingForTargetMRGC(...
        'rgcMosaicName', 'JCNpaperTemporal7DegsMosaic', ...
        'cropParams', cropParams, ...
        'targetRGCindex', 30, ...
        'superimposeLineWeightingFunctionForRFcenter', true, ...
        'superimposeLineWeightingFunctionForRFsurround', true)
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
    options.opticsForTTFresponses = [];

    % Wavefront spatial samples
    options.opticsWavefrontSpatialSamples = [];

    % Visualizations
    options.superimposeLineWeightingFunctionForRFcenter (1,1) logical = true;
    options.superimposeLineWeightingFunctionForRFsurround (1,1) logical = true;
    options.targetRGCindex (1,:) double = 30;

    % Whether to close previously open figures
    options.closePreviouslyOpenFigures (1,1) logical = true;

    options.exportVisualizationPDF (1,1) logical = false;
    options.exportVisualizationPNG (1,1) logical = false;
end

% Mosaic specifiers for selecting a prebaked mRGC mosaic
rgcMosaicName = options.rgcMosaicName;
coneMosaicSpecies = options.coneMosaicSpecies;
opticsSubjectName = options.opticsSubjectName;
targetVisualSTFdescriptor = options.targetVisualSTFdescriptor;

% Mosaic cropping
cropParams = options.cropParams;

% Optics to employ for the computations
opticsForTTFresponses = options.opticsForTTFresponses;
opticsWavefrontSpatialSamples = options.opticsWavefrontSpatialSamples;

% Visualizations
theTargetRGCindex = options.targetRGCindex;
superimposeLineWeightingFunctionForRFcenter = options.superimposeLineWeightingFunctionForRFcenter;
superimposeLineWeightingFunctionForRFsurround = options.superimposeLineWeightingFunctionForRFsurround;

% Close previously open figures
closePreviouslyOpenFigures = options.closePreviouslyOpenFigures;

if (closePreviouslyOpenFigures)
    % Close any stray figs
    close all;
end

    % Load the mRGCmosaic specified by the passed parameters:
    %   coneMosaicSpecies, opticsSubjectName, rgcMosaicName, targetVisualSTFdescriptor
    % and generate the optics that were used to synthesize the mosaic
    [theMRGCmosaic, theOptics, thePSFatTheMosaicEccentricity, ...
        prebakedMRGCMosaicDir, prebakedMRGCMosaicFilename] = mRGCMosaic.loadPrebakedMosaic(...
        coneMosaicSpecies, opticsSubjectName, rgcMosaicName, targetVisualSTFdescriptor, ...
        'computeTheMosaicOptics', true, ...
        'opticsToEmploy', opticsForTTFresponses, ...
        'wavefrontSpatialSamples', opticsWavefrontSpatialSamples, ...
        'cropParams', cropParams);



    % Get ready for publication-quality visualization
    hFig = figure(1000); clf;
    ff = PublicationReadyPlotLib.figureComponents('1x1 standard wide figure', ...
        'darkScheme', true);

    theAxes = PublicationReadyPlotLib.generatePanelAxes(hFig,ff);
    axRFpooling = theAxes{1,1};


    visualizedHeightDegs = 0.45;
    narrowDomainVisualizationLimits(1:2) = theMRGCmosaic.rgcRFpositionsDegs(theTargetRGCindex, 1) + (2000/1200)*[-0.5 0.5]*visualizedHeightDegs;
    narrowDomainVisualizationLimits(3:4) = theMRGCmosaic.rgcRFpositionsDegs(theTargetRGCindex, 2) + [-0.5 0.5]*visualizedHeightDegs;
    narrowDomainVisualizationTicks = struct(...
        'x', -30:0.2:0, ...
        'y', -10:0.2:10);

    narrowDomainVisualizationTicksNoYticks = narrowDomainVisualizationTicks;
    narrowDomainVisualizationTicksNoYticks.y = [];


     [~, ~, centerLineWeightingFunctions, surroundLineWeightingFunctions] = ...
         theMRGCmosaic.visualizeCenterSurroundConePoolingMap(theTargetRGCindex, ...
         'axesToRenderIn', axRFpooling, ...
         'backgroundColor', ff.legendBackgroundColor,...
         'identifiedConeAperture', 'lightCollectingArea5sigma', ...
         'identifyPooledCones', false, ...
         'identifyInputCones', true, ...
         'doNotLabelScaleBar', true, ...
         'scaleBarDegs', 0, ...
         'plottedRFoutlineLineWidth', 4.0, ...
         'plottedRFoutlineEdgeColor', [1 1 1], ...
         'plottedRFoutlineFaceColor', [0 0 0], ...
         'plottedRFoutlineFaceAlpha', 0.0, ...
         'spatialSupportSamplesNumForLineWeightingFunctions', 2400, ...
         'inputConesAlpha', 0.5, ...
         'noXLabel', true, ...
         'noXLabel', true, ...
         'domainVisualizationLimits', narrowDomainVisualizationLimits, ...
         'domainVisualizationTicks', narrowDomainVisualizationTicksNoYticks);

     hold(axRFpooling,'on');
     set(axRFpooling, 'TickDir', 'both');

     xlabel(axRFpooling, '')
     ylabel(axRFpooling, '')


     centerLineWeightingProfile = centerLineWeightingFunctions.xProfile;
     surroundLineWeightingProfile = surroundLineWeightingFunctions.xProfile;

     
     theCenterProfile = centerLineWeightingProfile.amplitude;
     maxCenterResponse = max(abs(theCenterProfile));

     baselineValue = -0.18;
     theCenterProfile = baselineValue+ 0.35 * theCenterProfile/maxCenterResponse;
     theSurroundProfile = surroundLineWeightingProfile.amplitude;
     theSurroundProfile = baselineValue -0.35 * theSurroundProfile/maxCenterResponse;

    if (superimposeLineWeightingFunctionForRFcenter)
         a1 = area(axRFpooling, ...
             centerLineWeightingProfile.spatialSupportDegs, theCenterProfile, baselineValue);
         a1.FaceColor = [1 .2 .4];
         a1.FaceAlpha = 0.5;
         a1.EdgeColor = [1 1 1];
         a1.LineWidth = 2.0;
    end

    if (superimposeLineWeightingFunctionForRFsurround)
        a2 = area(axRFpooling, ...
                    surroundLineWeightingProfile.spatialSupportDegs, theSurroundProfile, baselineValue);
        a2.FaceColor = [.2 .4 1];
        a2.FaceAlpha = 0.5;
        a2.EdgeColor = [1 1 1];
        a2.LineWidth = 2.0;
    end


    title(axRFpooling, 'input cone mosaic pooling');
    box(axRFpooling, 'on')

    % Finalize figure using the Publication-Ready format
    PublicationReadyPlotLib.applyFormat(axRFpooling,ff);

    % Export figure
    thePDFfileName = sprintf('RF_%d.pdf', theTargetRGCindex);
    exportVisualizationRootDirectory = ISETBioPaperAndGrantCodeFigureDirForScript(mfilename);
    theVisualizationPDFfilename = fullfile(exportVisualizationRootDirectory, thePDFfileName);
            
    % Generate the path if we need to
    RGCMosaicConstructor.filepathFor.augmentedPathWithSubdirs(...
          exportVisualizationRootDirectory, '', ...
          'generateMissingSubDirs', true);
        
    NicePlot.exportFigToPDF(theVisualizationPDFfilename , hFig, 300, 'beVerbose');



end
