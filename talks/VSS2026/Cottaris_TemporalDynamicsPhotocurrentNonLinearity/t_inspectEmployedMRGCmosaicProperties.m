function t_inspectEmployedMRGCmosaicProperties(options)
% History:
%    07/28/25  NPC  Wrote it.

% Examples:
%{
    t_inspectEmployedMRGCmosaicProperties();

%}


arguments

    % ---- Mosaic specifiers for selecting a prebaked mRGC mosaic ---

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


    % ------ Visualization options ----
    % Visualize cone pooling maps for a target RGC
    options.targetRGCindexForVisualizingConePoolingMaps (1,:) double = [];

    % Whether to generate a video of RFpooling maps along the horizontal meridian
    options.generateVideoOfRFpoolingMapsAlongHorizontalMeridian (1,1) logical = false;

    % Whether to close previously open figures
    options.closePreviouslyOpenFigures (1,1) logical = true;
end


% Set flags from key/value pairs

% Mosaic specifiers for selecting a prebaked mRGC mosaic
rgcMosaicName = options.rgcMosaicName;
coneMosaicSpecies = options.coneMosaicSpecies;
opticsSubjectName = options.opticsSubjectName;
targetVisualSTFdescriptor = options.targetVisualSTFdescriptor;

% Load the mRGCmosaic specified by the passed parameters:
%   coneMosaicSpecies, opticsSubjectName, rgcMosaicName, targetVisualSTFdescriptor
% and generate the optics that were used to synthesize the mosaic
[theMRGCmosaic, ~, thePSFatTheMosaicEccentricity] = mRGCMosaic.loadPrebakedMosaic(...
        coneMosaicSpecies, opticsSubjectName, rgcMosaicName, targetVisualSTFdescriptor, ...
        'computeTheMosaicOptics', true);


% Visualize RF centers using the spatial extent of cones whose RF center pooling weights
% are > mRGCMosaic.minSensitivityForInclusionOfDivergentConeConnections
% (basically all cones connected to each RF center). This is useful for
% visualizing the degree of RF center overlap
minCenterConeWeight = mRGCMosaic.minSensitivityForInclusionOfDivergentConeConnections;

% Get ready for publication-quality visualization
ff = PublicationReadyPlotLib.figureComponents('1x1 giant rectangular-wide mosaic');
ff.backgroundColor = [0 0 0];

% Subdirectory for exporting the generated PDFs
exportVisualizationPDFdirectory = 'mosaicVisualizationPDFs';

% mRGC mosaic visualization limits and ticks (excluding the extent of the
% input cone mosaic)
visualizedWidthDegs = theMRGCmosaic.sizeDegs(1);
visualizedHeightDegs = theMRGCmosaic.sizeDegs(2);
domainVisualizationLimits(1:2) = theMRGCmosaic.eccentricityDegs(1) + 0.5 * visualizedWidthDegs * [-1 1];
domainVisualizationLimits(3:4) = theMRGCmosaic.eccentricityDegs(2) + 0.5 * visualizedHeightDegs * [-1 1];
domainVisualizationTicks = struct(...
    'x', theMRGCmosaic.eccentricityDegs(1) + 0.5 * visualizedWidthDegs * [-1 -0.5 0 0.5 1], ...
    'y', theMRGCmosaic.eccentricityDegs(2) + 0.5 * visualizedHeightDegs * [-1 -0.5 0 0.5 1]);


% Generate a PSF visualization data struct (containing the vLambda-weighted PSF) for
% visualization purposes
PSFvisualizationOffset = theMRGCmosaic.eccentricityDegs - [mean(domainVisualizationLimits(1:2)) mean(domainVisualizationLimits(3:4))];
visualizedPSFData.data = RGCMosaicAnalyzer.compute.vLambdaWeightedPSF(thePSFatTheMosaicEccentricity);
visualizedPSFData.supportXdegs = thePSFatTheMosaicEccentricity.supportX/60 - PSFvisualizationOffset(1);
visualizedPSFData.supportYdegs = thePSFatTheMosaicEccentricity.supportY/60 - PSFvisualizationOffset(2);


hFig = figure(1); clf;
theAxes = PublicationReadyPlotLib.generatePanelAxes(hFig,ff);
ax = theAxes{1,1};


theMRGCmosaic.visualize(...
    'figureHandle', hFig, ...
    'axesHandle', ax, ...
    'identifyInputCones', false, ...
    'identifyPooledCones', false, ...
    'plottedRFoutlineFaceColor',  [0 1 0], ...
    'plottedRFoutlineFaceAlpha', 0.5, ...
    'minConeWeightVisualized', minCenterConeWeight, ...
    'plottedRFoutlineFaceAlpha', 0.75, ...
    'plottedRFoutlineLineWidth', 1.0, ...
    'plottedRFoutlineFaceColor',  [0 1 0.4], ...
    'centerSubregionContourSamples', 32, ...
    'withSuperimposedPSF', visualizedPSFData, ...
    'domainVisualizationLimits', domainVisualizationLimits, ...
    'domainVisualizationTicks', domainVisualizationTicks, ...
    'plotTitle', sprintf('min center weight visualized: %2.3f', minCenterConeWeight), ...
    'withFigureFormat', ff, ...
    'visualizationPDFfileName', sprintf('%s_%sf', rgcMosaicName, opticsSubjectName), ...
    'exportVisualizationPDF', true, ...
    'exportVisualizationPNG', true, ...
    'exportVisualizationPDFdirectory', exportVisualizationPDFdirectory);


pause

targetedCenterConeNumerosityRange = [1 1];
targetedSurroundPurityRange = [];
targetedRadialEccentricityRange = [];
targetedCenterPurityRange = [];

[targetRGCindices, theSurroundConePurities, theCenterConeDominances, ...
     theCenterConeNumerosities, theCenterConePurities] = theMRGCmosaic.indicesOfRGCsWithinTargetedPropertyRanges( ...
                            targetedCenterConeNumerosityRange, ...
                            targetedSurroundPurityRange, ...
                            targetedRadialEccentricityRange, ...
                            targetedCenterPurityRange);


[min(theCenterConeNumerosities) max(theCenterConeNumerosities)]
[min(theMRGCmosaic.responseGains(targetRGCindices)) max(theMRGCmosaic.responseGains(targetRGCindices))]


end


