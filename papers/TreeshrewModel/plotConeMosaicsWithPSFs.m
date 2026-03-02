function plotConeMosaicsWithPSFs()

    % Generate a treeshrew cone mosaic
    treeShrewMosaicSizeDegs = [0.95 0.95];
    theTreeShrewConeMosaic = cMosaicTreeShrewCreate(...
        'sizeDegs', treeShrewMosaicSizeDegs);


    % Select a tree-shrew subject
    theTreeShrewSubjectIndex = 1;

    % Generate optics for this subject
    theOI = oiTreeShrewCreate( ...
            'opticsType', 'wvf', ...
            'pupilDiameterMM', 4.0, ...
            'whichShrew', theTreeShrewSubjectIndex, ...
            'name', 'wvf-based optics');

    % Retrieve the PSF and the MTF slices for a target wavelength
    theTargetWavelength = 550;
    visualizedPSFrangeMicrons = 80;

    theTreeShrewPSFdataStruct = retrievePSFandMTF(theOI, theTargetWavelength);
    plotConeMosaicWithPSF(theTreeShrewConeMosaic,theTreeShrewPSFdataStruct, sprintf('tree shrew mosaic'), 'treeShrewConeMosaicAndPSF.pdf');

    % Generate human cone mosaic
    humanConeMosaicSizeDegs = [0.25 0.25];
    theHumanConeMosaic = cMosaic(...
        'whichEye', 'right eye', ...         
        'sizeDegs', humanConeMosaicSizeDegs);

    opticsZernikeCoefficientsDataBase = 'Polans2015';
    subjectRankOrder = 1;
    rankedSubjectIDs = PolansOptics.constants.subjectRanking;
    testSubjectID = rankedSubjectIDs(subjectRankOrder);
    subtractCentralRefraction = PolansOptics.constants.subjectRequiresCentralRefractionCorrection(testSubjectID);


    % Generate optics appropriate for the mosaic's eccentricity  
    oiEnsemble = theHumanConeMosaic.oiEnsembleGenerate(theHumanConeMosaic.eccentricityDegs, ...
        'zernikeDataBase', opticsZernikeCoefficientsDataBase, ...
        'subjectID', testSubjectID, ...
        'pupilDiameterMM', 4.0, ...
        'subtractCentralRefraction', subtractCentralRefraction, ...
        'wavefrontSpatialSamples', 501, ...
        'refractiveErrorDiopters', 0.0);

    theHumanPSFdataStruct = retrievePSFandMTF(oiEnsemble{1}, theTargetWavelength);
    plotConeMosaicWithPSF(theHumanConeMosaic, theHumanPSFdataStruct, sprintf('human cone mosaic'), 'humanConeMosaicAndPSF.pdf');

end


function plotConeMosaicWithPSF(theConeMosaic, thePSFdataStruct, plotTitle, pdfFileName)

    ff = PublicationReadyPlotLib.figureComponents('1x1 giant square mosaic');
	hFig = figure(1); clf;
    theAxes = PublicationReadyPlotLib.generatePanelAxes(hFig,ff);
    ax = theAxes{1,1};

    domainUnits = 'microns';
    domainVisualizationTicks = struct(...
            'x',  30*(-2:2), ...
            'y',  30*(-2:2));


    domainUnits = 'degrees';
    domainVisualizationTicks = struct(...
            'x',  -1:0.1:1, ...
            'y',  -1:0.1:1);


    activation = zeros(1,1,theConeMosaic.conesNum);
    activation(1,1,theConeMosaic.lConeIndices) = activation(1,1,theConeMosaic.lConeIndices) + 0.7;
    activation(1,1,theConeMosaic.mConeIndices) = activation(1,1,theConeMosaic.mConeIndices) + 0.4;
    activation(1,1,theConeMosaic.sConeIndices) = activation(1,1,theConeMosaic.sConeIndices) + 0.2;
    
    theConeMosaic.visualize('figureHandle', hFig, ...
            'axesHandle', ax, ...
            'domain', domainUnits, ...
            'domainVisualizationTicks', domainVisualizationTicks, ...
            'visualizedConeAperture', 'lightcollectingarea4sigma', ... %'activation', activation, %'activationRange', [0 1], ...
            'withSuperimposedPsf', thePSFdataStruct, ...
            'withSuperimposedPSFcontourLineColor', [1 0 0], ...
            'visualizedConeApertureThetaSamples', 32, ...
            'activation', activation, ...
            'activationRange', [0 1], ...
            'activationcolormap', brewermap(256, '*greys'), ...
            'conesAlpha', 0.8, ...
            'conesEdgeAlpha', 0.9, ...
            'backgroundColor', [1 1 1], ...
            'clearAxesBeforeDrawing', false, ...
            'plotTitleColor', [0.5 0.5 0.5], ...
            'fontSize', 16, ...
            'verbose', false, ...
            'plotTitle', plotTitle, ...
            'plotTitleFontSize', 16 ...
            );

    PublicationReadyPlotLib.applyFormat(ax,ff);
    % PublicationReadyPlotLib.offsetAxes(ax, ff, xLims, yLims); 

    theFiguresDir = fullfile(ISETBioPaperAndGrantCodeRootDirectory, 'local', mfilename);
    if (~exist(theFiguresDir,'dir'))
        mkdir(theFiguresDir);
    end

    thePDFfileName = fullfile(theFiguresDir, pdfFileName);
    NicePlot.exportFigToPDF(thePDFfileName,hFig,  300);

end


function [thePSFdataStruct, theMTFdataStruct] = retrievePSFandMTF(theOI, theTargetWavelength)
    
    % Get the optics data
    optics = oiGet(theOI, 'optics');

    % Get the focal length
    focalLengthMeters = opticsGet(optics, 'focal length');
    micronsPerDegree = focalLengthMeters*tand(1)*1e6;

    % Get the wavelength support
    wavelengthSupport = opticsGet(optics, 'otf wave');
    [~,theVisualizedWavelengthIndex] = min(abs(wavelengthSupport-theTargetWavelength));

    % Get the full psf volume
    psf = opticsGet(optics, 'psf data');

    % Form thePSFdataStruct with the visualized PSF slice
    thePSFdataStruct = struct(...
        'supportXdegs', squeeze(psf.xy(1,:,1))/micronsPerDegree, ...
        'supportYdegs', squeeze(psf.xy(1,:,1))/micronsPerDegree, ...
        'data', squeeze(psf.psf(:,:,theVisualizedWavelengthIndex)) ...
        );

     % Get the OTF volume
    theOTF = opticsGet(optics,'otf');

    % Get the slice at the visualized wavelength
    theVisualizedOTF = squeeze(theOTF(:,:,theVisualizedWavelengthIndex));
    theVisualizedMTF = fftshift(abs(theVisualizedOTF));

    % Compute the circularly symmetric MTF
    theVisualizedMTF = psfCircularlyAverage(theVisualizedMTF);

    % Form theMTFdataStruct with the visualized MTF slice
    theMTFdataStruct = struct(...
        'supportCyclesPerDeg', opticsGet(optics,'otf fx', 'mm') * 1e-3 * micronsPerDegree, ...
        'data', theVisualizedMTF ...
     );

end

