function demoPeripheralOpticsRetinalImage()

    % Generate the local export root directory for this script name
    exportRootDirectory = ISETBioPaperAndGrantCodeFigureDirForScript(mfilename);

    % Generate the figures dir, if it does not exist
    theFiguresDir = fullfile(exportRootDirectory, 'staticPDFs');
    if (~exist(theFiguresDir,'dir'))
        mkdir(theFiguresDir);
    end

    % Generate the data dir, if it does not exist
    theDataDir = fullfile(exportRootDirectory, 'data');
    if (~exist(theDataDir,'dir'))
        mkdir(theDataDir);
    end


    theImageIndex = 1;
    % Load the sample fMRI stimulus images provided by Gari (Garikoitz Lerma-Usabiaga)
    [spatialSupportXDegs, spatialSupportYDegs, theSelectedImage] = loadSampleImages(theImageIndex);


    % Generate a cone mosaic that extends over the entire stimulus
    % area (and beyond)
    mosaicEccDegs = [5.5 0];
    theConeMosaic = cMosaic(...
            'sizeDegs', [4 18], ...
            'eccentricityDegs',  mosaicEccDegs);
  

    % Whether to subtract the central refraction if needed
    subtractCentralRefractionAsNeeded = ~true;

    % Set the first 3 Zernike coeffs to 0 (no spatial offset in the PSF)
    withZeroedPistonAndTiltZernikeCoefficients = true;

    % Since we are dealing with a large stimulus, we will need optics 
    % sampled at a number of positions
    % Specify an oiSamplingGridStruct for the optics 
    % This will generate a regular hexagonal grid with specified 
    % spacing, height, width at the specified eccentricity 

    oiSamplingGridData = struct(...
        'eccentricityDegs', mosaicEccDegs, ...
        'widthDegs', 3, ...
        'heightDegs', 16, ...
        'spacingDegs', 2, ...                % sampling grid spacing
        'weightingType', 'raised cosine' ... % choose between {'Gaussian', 'raised cosine'};
        );

    % Or if we just wanted to use the optics at one position only (center
    % of cone mosaic)
    %oiSamplingGridData = theConeMosaic.eccentricityDegs;

    % Generate an ISETBio scene for the selected image
    [theScene, theBackgroundScene] = ISETBioSceneFromImage(theConeMosaic.wave, ...
            spatialSupportXDegs, spatialSupportYDegs, theSelectedImage);
    

    for PolansSubjectRankOrder = 1:1
        runTheSimulation(theConeMosaic, oiSamplingGridData, PolansSubjectRankOrder, ...
            subtractCentralRefractionAsNeeded, withZeroedPistonAndTiltZernikeCoefficients, theScene, theBackgroundScene, theFiguresDir, theDataDir);
    end

end

function runTheSimulation(theConeMosaic, oiSamplingGridData, PolansSubjectRankOrder, ...
    subtractCentralRefractionAsNeeded, withZeroedPistonAndTiltZernikeCoefficients, theScene, theBackgroundScene, theFiguresDir, theDataDir)

    % Form the data filename
    theDataFileName = fullfile(theDataDir, sprintf('simulationData_PolansSubjectRank%d.mat', PolansSubjectRankOrder));

    % Optics subject
    rankedSujectIDs = PolansOptics.constants.subjectRanking;
    testSubjectID = rankedSujectIDs(PolansSubjectRankOrder);

    if (subtractCentralRefractionAsNeeded)
        % correct for central refraction
        subtractCentralRefraction = ...
            PolansOptics.constants.subjectRequiresCentralRefractionCorrection(testSubjectID);
    else
        % Or, alternatively do not correct for central refraction
        subtractCentralRefraction = false;
    end

    % Generate the optics at the desired sampling grid
    [oiEnsemble, psfEnsemble, ~, oiSamplingGridDegs, theMergingWeights] = theConeMosaic.oiEnsembleGenerate(...
        oiSamplingGridData, ...
        'zernikeDataBase', 'Polans2015', ...
        'subjectID', testSubjectID, ...
        'subtractCentralRefraction', subtractCentralRefraction, ...
        'zeroCenterPSF', false, ...
        'withZeroedPistonAndTiltZernikeCoefficients', withZeroedPistonAndTiltZernikeCoefficients, ...
        'wavefrontSpatialSamples', 601, ...
        'pupilDiameterMM', 3.0, ...
        'refractiveErrorDiopters', 0.0, ...
        'visualizedSamplingGrid', ~true);
  
    % Visualize the cone mosaic
    hFig = figure(10); clf;
    set(hFig, 'Position', [10 10 700 1300], 'Color', [1 1 1]);
    ax = subplot('Position', [0.05 0.05 0.94 0.94]);
    theConeMosaic.visualize(...
        'figureHandle', hFig, ...
        'axesHandle', ax, ...
        'plotTitle', ' ');
    hold(ax, 'on');
    plot(ax, oiSamplingGridDegs(:,1), oiSamplingGridDegs(:,2), 'wx', 'MarkerSize', 12, 'LineWidth', 1.5);
    NicePlot.exportFigToPDF(fullfile(theFiguresDir, 'coneMosaicAndOIsampling.pdf'), hFig, 300);

    hFig = visualizeThePSFs(theConeMosaic, psfEnsemble, oiSamplingGridDegs);
    NicePlot.exportFigToPDF(fullfile(theFiguresDir, sprintf('thePSFs_PolansOpticsSubjectRank_%d.pdf', PolansSubjectRankOrder)), hFig, 300);


    if (isstruct(oiSamplingGridData))

        visualizeTheMergingWeightDistributions = false;
        if (visualizeTheMergingWeightDistributions)
            % Visualize the merging weights
            for oiPosIndex = 1:size(theMergingWeights,1)
                hFig = visualizeTheMergingWeights(theConeMosaic, theMergingWeights(oiPosIndex,:), oiSamplingGridDegs);
                NicePlot.exportFigToPDF(fullfile(theFiguresDir, sprintf('theMerginWeights_Position_%d.pdf', oiPosIndex)), hFig, 300);
            end
        end


        % Multiple position optics
        % Compute cone mosaic activations to the retinal images of the scene computed for 
        % each OI in the oiEnsemble, and merge the comuted activations using theMergingWeights
        multiOImergedConeMosaicActivation = theConeMosaic.computeForOIensemble(...
            oiEnsemble, theMergingWeights, theScene);
    
        % Compute cone mosaic activations to the retinal images of the background scene computed for 
        % each OI in the oiEnsemble, and merge the comuted activations using theMergingWeights
        multiOImergedConeMosaicBackgroundActivation = theConeMosaic.computeForOIensemble(...
            oiEnsemble, theMergingWeights, theBackgroundScene);
    
        % Compute cone modulations
        coneMosaicModulations = (multiOImergedConeMosaicActivation - multiOImergedConeMosaicBackgroundActivation)./multiOImergedConeMosaicBackgroundActivation;
    else
        % Single position optics
        theOI = oiEnsemble{1};

        % Compute the retinal image of the scene under this OI
        theRetinalImage = oiCompute(theOI, theScene, 'pad value','mean');

        % Compute the cone mosaic activation for the current OI
        theConeMosaicActivation = theConeMosaic.compute(...
            theRetinalImage, ...
            'opticalImagePositionDegs', [0 0]);

        % Compute the retinal image of the background scene under this OI
        theRetinalImage = oiCompute(theOI, theBackgroundScene, 'pad value','mean');

        % Compute the cone mosaic activation for the current OI
        theConeMosaicBackgroundActivation = theConeMosaic.compute(...
            theRetinalImage, ...
            'opticalImagePositionDegs', [0 0]);

        % Compute cone modulations
        coneMosaicModulations = (theConeMosaicActivation - theConeMosaicBackgroundActivation)./theConeMosaicBackgroundActivation;
    end

    % Visualized the loaded weightedConeMosaicModulations
    thePDFfileName = sprintf('coneMosaicActivation_PolansOpticsSubjectRank_%d.pdf', PolansSubjectRankOrder);
    visualizeConeMosaicActivation(theConeMosaic, coneMosaicModulations, theFiguresDir, thePDFfileName);

    % Save the  data
    save(theDataFileName, ...
         'theConeMosaic', ...
         'oiSamplingGridDegs', ...
         'theMergingWeights', ...
         'oiEnsemble', 'psfEnsemble', ...
         'coneMosaicModulations', ...
         '-v7.3');
end


function hFig = visualizeTheMergingWeights(theConeMosaic, theMergingWeights, oiSamplingGridDegs)
    hFig = figure(10); clf;
    set(hFig, 'Position', [10 10 700 1300], 'Color', [1 1 1]);
    ax = subplot('Position', [0.05 0.05 0.94 0.94]);
    theConeMosaic.visualize(...
        'figureHandle', hFig, ...
        'axesHandle', ax, ...
        'activation', reshape(theMergingWeights, [1 1 numel(theMergingWeights)]), ...
        'activationRange', [0 1], ...
        'plotTitle', ' ');
    hold(ax, 'on');
    plot(ax, oiSamplingGridDegs(:,1), oiSamplingGridDegs(:,2), 'wx', 'MarkerSize', 12, 'LineWidth', 1.5);
end

function  hFig = visualizeThePSFs(theConeMosaic, psfEnsemble, oiSamplingGridDegs)

    opticsSamplingPositionsNum = size(oiSamplingGridDegs, 1);

    hFig = figure(3002); clf;
    if (theConeMosaic.sizeDegs(1)>theConeMosaic.sizeDegs(2))
        % wide mosaic
        figureWidthPixels = 1200;
        aspectRatio = theConeMosaic.sizeDegs(1)/theConeMosaic.sizeDegs(2);
        figureHeightPixels = round(figureWidthPixels/aspectRatio);
    else
        figureHeightPixels = 1200;
        aspectRatio = theConeMosaic.sizeDegs(2)/theConeMosaic.sizeDegs(1);
        figureWidthPixels = round(figureHeightPixels/aspectRatio);
    end

    set(hFig, 'Position', [10 10 figureWidthPixels figureHeightPixels], 'Color', [1 1 1]);

    for oiPos = 1:opticsSamplingPositionsNum
        
        width = 0.2;
        axPosition(1) = 0.5*(1+(oiSamplingGridDegs(oiPos,1) - theConeMosaic.eccentricityDegs(1))/(0.52*theConeMosaic.sizeDegs(1)))-0.5*width;
        axPosition(2) = 0.5*(1+(oiSamplingGridDegs(oiPos,2) - theConeMosaic.eccentricityDegs(2))/(0.52*theConeMosaic.sizeDegs(2))) - 0.5*width;
        axPosition(3:4) = width;

        ax = axes('Position', axPosition);
        set(ax, 'Color', [0 0 0]);
        thePSF = psfEnsemble{oiPos};
        [~, wIdx] = min(abs(thePSF.supportWavelength-550));
        wavePSF = squeeze(thePSF.data(:,:,wIdx));
        zLevels = 0.1:0.1:0.9;
        % half a degree
        xyRangeArcMin = 15*[-1 1];
        PolansOptics.renderPSF(ax, ...
            thePSF.supportX, thePSF.supportY, wavePSF/max(wavePSF(:)), ...
            xyRangeArcMin, zLevels,  gray(1024), [0 0 0], ...
            'plotTitle',  sprintf('%2.1f,%2.1f', oiSamplingGridDegs(oiPos,1), oiSamplingGridDegs(oiPos,2)));
        box(ax, 'on')
        set(ax, 'XColor', 0.2*[1 1 1], 'YColor', 0.2*[1 1 1]);
        set(ax, 'XTickLabel', {}, 'YTickLabel', {});
        xlabel(ax, '');
        ylabel(ax, '');
        colormap(ax, gray(1024));
        drawnow;
    end
    pause(0.5)
end

function visualizeConeMosaicActivation(theConeMosaic, theConeMosaicActivation, theFiguresDir, thePDFfileName)

    hFig = figure(4000); clf;
    set(hFig, 'Position', [10 10 430 1300]);
    set(hFig, 'Color', [1 1 1]);
    ax = subplot('Position', [0.06 0.07 0.93 0.93]);
    theConeMosaic.visualize(...
            'figureHandle', hFig, ...
            'axesHandle', ax, ...
            'visualizedConeAperture', 'lightCollectingArea5sigma', ...
            'visualizedConeApertureThetaSamples', 12, ...
            'fontSize', 24, ...
            'activation', reshape(theConeMosaicActivation, [1 1 numel(theConeMosaicActivation)]), ...
            'plotTitle', ' ');

    NicePlot.exportFigToPDF(fullfile(theFiguresDir, thePDFfileName), hFig, 300);

    hFig = figure(4001); clf;
    set(hFig, 'Position', [10 10 1000 1000]);
    set(hFig, 'Color', [1 1 1]);
    ax = subplot('Position', [0.07 0.07 0.92 0.92]);
    theConeMosaic.visualize(...
            'figureHandle', hFig, ...
            'axesHandle', ax, ...
            'visualizedConeAperture', 'lightCollectingArea5sigma', ...
            'visualizedConeApertureThetaSamples', 24, ...
            'domainVisualizationLimits', [3.5 7.5 4.5 8.5], ...
            'domainVisualizationTicks', struct('x', 0:0.5:10, 'y', -10:0.5:10), ...
            'activation', reshape(theConeMosaicActivation, [1 1 numel(theConeMosaicActivation)]), ...
            'fontSize', 24, ...
            'plotTitle', ' ');

    NicePlot.exportFigToPDF(fullfile(theFiguresDir, strrep(thePDFfileName, '.pdf', '_zoomedIn.pdf')), hFig, 300);
end




function [theScene, theBackgroundScene] = ISETBioSceneFromImage(wavelengthSupport, spatialSupportXDegs, spatialSupportYDegs, theSampleImage)

    % Generate presentation display
    stimulusResolutionDegs = 1/100;
    viewingDistanceMeters = 1.0;
    thePresentationDisplay = visualStimulusGenerator.presentationDisplay(...
            wavelengthSupport, ...
            stimulusResolutionDegs, ...
            viewingDistanceMeters, ...
            'displayType', 'CRT-Sony-HorwitzLab', ...
            'bitDepth', 20, ...
            'meanLuminanceCdPerM2', 100, ...
            'luminanceHeadroom', 0.5);

    grayScaleImage = double(theSampleImage);
    grayScaleImage = grayScaleImage / max(grayScaleImage(:));
    RGBimage = repmat(grayScaleImage, [1 1 3]);

    % Generate a gamma corrected RGB image (RGBsettings) that we can pop in the
    % isetbio scene straightforward
    RGBsettings = (ieLUTLinear(RGBimage, displayGet( thePresentationDisplay, 'inverse gamma'))) / displayGet(thePresentationDisplay, 'nLevels');

    % Generate scene corresponding to the test stimulus on the presentation display
    format = 'rgb';
    meanLuminance = []; % EMPTY, so that mean luminance is determined from the rgb settings values we pass
    theScene = sceneFromFile(flipud(RGBsettings), format, meanLuminance, thePresentationDisplay);

    % Set the desired FOV 
    theScene = sceneSet(theScene, 'h fov', max(spatialSupportXDegs)-min(spatialSupportXDegs));
    
    % Background scene (only used to compute cone modulations from cone excitations)
    RGBimage = RGBimage*0+0.5;
    RGBsettings = (ieLUTLinear(RGBimage, displayGet(thePresentationDisplay, 'inverse gamma'))) / displayGet(thePresentationDisplay, 'nLevels');
    theBackgroundScene = sceneFromFile(flipud(RGBsettings), format, meanLuminance, thePresentationDisplay);
    theBackgroundScene = sceneSet(theBackgroundScene, 'h fov', max(spatialSupportXDegs)-min(spatialSupportXDegs));
end


function [spatialSupportXDegs, spatialSupportYDegs, theSelectedImage, imageHeightDegs] = loadSampleImages(theImageIndex)
    load('fMRIsampleImages.mat')
    
    imageHeightDegs = 18;

    rowsNum = size(sample_images,1);
    colsNum = size(sample_images,2);

    
    pixelSizeDegs = imageHeightDegs/rowsNum;
    spatialSupportYpixels = 1:rowsNum;
    spatialSupportXpixels = 1:colsNum;
    
    spatialSupportXpixels = spatialSupportXpixels-mean(spatialSupportYpixels);
    spatialSupportYpixels = spatialSupportYpixels-mean(spatialSupportYpixels);
    spatialSupportXDegs = spatialSupportXpixels * pixelSizeDegs;
    spatialSupportYDegs = spatialSupportYpixels * pixelSizeDegs;

    theSelectedImage = sample_images(:,:, theImageIndex);

end
