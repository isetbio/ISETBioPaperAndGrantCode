function plotConeMosaicsWithPSFs(options)
% Combo plotting of cone mosaics & PSF of the treeshrew and of the human retina 
%
% Description:
%   Plots combo plots of cone mosaics and PSFs of the treeshrew and of the
%   human retina.

% History:
%    03/01/26  NPC  Wrote it.

arguments

    % The tree shrew subject number. Between 1 and 11
    options.theTreeShrewSubjectIndex (1,1) double = 1;

    % The human subject rank order. Between 1 and 10
    options.theHumanSubjectRankOrder (1,1) double = 4;

    % Whether to plot the quantal efficiencies at the cornea or at the retina
    options.mosaicSizeDegs (1,1) double = 0.4;

    % The pupil size in mm
    options.pupilSizeMM (1,1) double = 4;

    % The wavelength for which to visualize the PSF
    options.visualizedWavelength = 550;

end % arguments

    % Generate a treeshrew cone mosaic
    theTreeShrewConeMosaic = cMosaicTreeShrewCreate(...
        'sizeDegs', options.mosaicSizeDegs * [1 1], ...
        'relativeSconeDensity', 0.14);

    % Generate optics for this subject
    theOI = oiTreeShrewCreate( ...
            'opticsType', 'wvf', ...
            'pupilDiameterMM', options.pupilSizeMM, ...
            'whichShrew', options.theTreeShrewSubjectIndex , ...
            'name', 'wvf-based optics');

    % Retrieve the PSF and the MTF slices for a target wavelength
    theTreeShrewPSFdataStruct = retrievePSFandMTF(theOI, options.visualizedWavelength);
    plotConeMosaicWithPSF(theTreeShrewConeMosaic,theTreeShrewPSFdataStruct, sprintf('tree shrew mosaic'), 'treeShrewConeMosaicAndPSF.pdf');

    % Generate human cone mosaic
    theHumanConeMosaic = cMosaic(...
        'whichEye', 'right eye', ...         
        'sizeDegs', options.mosaicSizeDegs * [1 1]);

    opticsZernikeCoefficientsDataBase = 'Polans2015';
    rankedSubjectIDs = PolansOptics.constants.subjectRanking;
    testSubjectID = rankedSubjectIDs( options.theHumanSubjectRankOrder);
    subtractCentralRefraction = PolansOptics.constants.subjectRequiresCentralRefractionCorrection(testSubjectID);


    % Generate optics appropriate for the mosaic's eccentricity  
    oiEnsemble = theHumanConeMosaic.oiEnsembleGenerate(theHumanConeMosaic.eccentricityDegs, ...
        'zernikeDataBase', opticsZernikeCoefficientsDataBase, ...
        'subjectID', testSubjectID, ...
        'pupilDiameterMM', options.pupilSizeMM, ...
        'subtractCentralRefraction', subtractCentralRefraction);

    theHumanPSFdataStruct = retrievePSFandMTF(oiEnsemble{1}, options.visualizedWavelength);
    plotConeMosaicWithPSF(theHumanConeMosaic, theHumanPSFdataStruct, sprintf('human cone mosaic'), 'humanConeMosaicAndPSF.pdf');


end


function plotConeMosaicWithPSF(theConeMosaic, thePSFdataStruct, plotTitle, pdfFileName)

    ff = PublicationReadyPlotLib.figureComponents('1x1 standard figure');

	hFig = figure(1); clf;
    theAxes = PublicationReadyPlotLib.generatePanelAxes(hFig,ff);
    ax = theAxes{1,1};

    domainUnits = 'microns';
    domainVisualizationTicks = struct(...
            'x',  10*(-3:3), ...
            'y',  10*(-3:3));
    domainVisualizationLimits = [-0.15 0.15 -0.15 0.15] * theConeMosaic.distanceDegreesToDistanceMicronsForCmosaic(1.0);

    domainUnits = 'degrees';
    domainVisualizationTicks = struct(...
            'x',  -1:0.1:1, ...
            'y',  -1:0.1:1);
    domainVisualizationLimits = [-0.15 0.15 -0.15 0.15];

    activation = zeros(1,1,theConeMosaic.conesNum);
    activation(1,1,theConeMosaic.lConeIndices) = activation(1,1,theConeMosaic.lConeIndices) + 0.7;
    activation(1,1,theConeMosaic.mConeIndices) = activation(1,1,theConeMosaic.mConeIndices) + 0.4;
    activation(1,1,theConeMosaic.sConeIndices) = activation(1,1,theConeMosaic.sConeIndices) + 0.2;
    
    theConeMosaic.visualize('figureHandle', hFig, ...
            'axesHandle', ax, ...
            'domain', domainUnits, ...
            'domainVisualizationLimits', domainVisualizationLimits, ...
            'domainVisualizationTicks', domainVisualizationTicks, ...
            'visualizedConeAperture', 'lightcollectingarea4sigma', ... %'activation', activation, %'activationRange', [0 1], ...
            'withSuperimposedPsf', thePSFdataStruct, ...
            'visualizedConeApertureThetaSamples', 32, ...
            'withSuperimposedPSFcontourLineColor', [1 1 1], ...
            'withSuperimposedPSFcolorMap', brewermap(1024, '*greys'), ...
            'activationColorMap', brewermap(256, '*greys'), ...
            'conesAlpha', 0.8, ...
            'conesEdgeAlpha', 0.9, ...
            'backgroundColor', [0.2 0.2 0.2], ...
            'clearAxesBeforeDrawing', true, ...
            'plotTitleColor', [0.5 0.5 0.5], ...
            'fontSize', 16, ...
            'verbose', false, ...
            'plotTitle', plotTitle, ...
            'plotTitleFontSize', 16 ...
            );

    ff.backgroundColor = [0.2 0.2 0.2];
    
    PublicationReadyPlotLib.applyFormat(ax,ff);
    % PublicationReadyPlotLib.offsetAxes(ax, ff, xLims, yLims); 

    % Generate figure dir if it does not exist
    theFiguresDir = ISETBioPaperAndGrantCodeFigureDirForScript(mfilename);


    thePDFfileName = fullfile(theFiguresDir, pdfFileName);
    NicePlot.exportFigToPDF(thePDFfileName,hFig,  300);
    NicePlot.exportFigToPNG(strrep(thePDFfileName, 'pdf', 'png'),hFig,  300);
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

