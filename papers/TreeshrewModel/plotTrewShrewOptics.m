function plotTrewShrewOptics()

    % Select a tree-shrew subject
    theTreeShrewSubjectIndex = 1;

    % Generate optics for this subject
    theOI = oiTreeShrewCreate( ...
            'opticsType', 'wvf', ...
            'pupilDiameterMM', 4.0, ...
            'whichShrew', theTreeShrewSubjectIndex, ...
            'name', 'wvf-based optics');

    % Retrieve the PSF and the MTF slices for a target wavelength
    theTargetWavelength = 650;
    visualizedPSFrangeMicrons = 80;

    [thePSFdataStruct, theMTFdataStruct] = retrievePSFandMTF(theOI, theTargetWavelength);

    % Plot the PSF
    pdfFileName = sprintf('PSF_TreeShrewSubject%d_%dnm.pdf', theTreeShrewSubjectIndex, theTargetWavelength);
    plotTitle = sprintf('PSF @ %dnm (tree shrew subject %d)', theTargetWavelength,  theTreeShrewSubjectIndex);
    generatePSFfigure(thePSFdataStruct, visualizedPSFrangeMicrons, pdfFileName, plotTitle);


    % Plot the MTF
    pdfFileName = sprintf('MTF_TreeShrewSubject%d_%dnm.pdf', theTreeShrewSubjectIndex, theTargetWavelength);
    plotTitle = sprintf('MTF @ %dnm (tree shrew subject %d)', theTargetWavelength,  theTreeShrewSubjectIndex);
    generateMTFfigure(theMTFdataStruct, pdfFileName, plotTitle);



    % Select a human subject
    opticsZernikeCoefficientsDataBase = 'Polans2015';
    subjectRankOrder = 1;
    rankedSubjectIDs = PolansOptics.constants.subjectRanking;
    testSubjectID = rankedSubjectIDs(subjectRankOrder);
    subtractCentralRefraction = PolansOptics.constants.subjectRequiresCentralRefractionCorrection(testSubjectID);

     
    % Generate human cone mosaic
    cm = cMosaic(...
        'whichEye', 'right eye', ...         
        'sizeDegs', [0.2 0.2], ...    
        'positionDegs', [0 0]);

    % Generate optics appropriate for the mosaic's eccentricity  
    oiEnsemble = cm.oiEnsembleGenerate(cm.eccentricityDegs, ...
        'zernikeDataBase', opticsZernikeCoefficientsDataBase, ...
        'subjectID', testSubjectID, ...
        'pupilDiameterMM', 4.0, ...
        'subtractCentralRefraction', subtractCentralRefraction, ...
        'wavefrontSpatialSamples', 501, ...
        'refractiveErrorDiopters', 0.0);
    theOI = oiEnsemble{1};


    % Retrieve the PSF and the MTF slices for a target wavelength
    [thePSFdataStruct, theMTFdataStruct] = retrievePSFandMTF(theOI, theTargetWavelength);

    % Plot the PSF
    pdfFileName = sprintf('PSF_HumanSubject%s_%dnm.pdf', sprintf('%s_subj%d',opticsZernikeCoefficientsDataBase, testSubjectID), theTargetWavelength);
    plotTitle = sprintf('PSF @ %dnm (human subject %s-%d)', theTargetWavelength, opticsZernikeCoefficientsDataBase, theTreeShrewSubjectIndex);
    generatePSFfigure(thePSFdataStruct, visualizedPSFrangeMicrons, pdfFileName, plotTitle);


    % Plot the MTF
    pdfFileName = sprintf('MTF_HumanSubject%s_%dnm.pdf', sprintf('%s_subj%d',opticsZernikeCoefficientsDataBase, testSubjectID), theTargetWavelength);
    plotTitle = sprintf('MTF @ %dnm (human subject %s-%d)', theTargetWavelength, opticsZernikeCoefficientsDataBase, theTreeShrewSubjectIndex);
    generateMTFfigure(theMTFdataStruct, pdfFileName, plotTitle);

    
end

function generateMTFfigure(theMTFdataStruct, pdfFileName, plotTitle)

    ff = PublicationReadyPlotLib.figureComponents('1x1 standard tall figure');
	hFig = figure(1); clf;
    theAxes = PublicationReadyPlotLib.generatePanelAxes(hFig,ff);
    ax = theAxes{1,1};

    PublicationReadyPlotLib.applyFormat(ax,ff);
    % PublicationReadyPlotLib.offsetAxes(ax, ff, xLims, yLims);

    visualizedSFcyclesPerDegree = 100;
    visualizeMTFslice(ax, theMTFdataStruct, visualizedSFcyclesPerDegree, plotTitle);

    PublicationReadyPlotLib.applyFormat(ax,ff);
    % PublicationReadyPlotLib.offsetAxes(ax, ff, xLims, yLims); 

    theFiguresDir = fullfile(ISETBioPaperAndGrantCodeRootDirectory, 'local', mfilename);
    if (~exist(theFiguresDir,'dir'))
        mkdir(theFiguresDir);
    end

    thePDFfileName = fullfile(theFiguresDir, pdfFileName);
    NicePlot.exportFigToPDF(thePDFfileName,hFig,  300);
end


function visualizeMTFslice(ax, theMTFdataStruct, visualizedSFcyclesPerDegree, plotTitle)

    % Get the slice through the center
    [~,idx] = max(theMTFdataStruct.data(:));
    [peakRow, peakCol] = ind2sub(size(theMTFdataStruct.data), idx);
    theVisualizeMTFslice = squeeze(theMTFdataStruct.data(peakRow,:));
 

    plot(ax, theMTFdataStruct.supportCyclesPerDeg, theVisualizeMTFslice, 'k-', 'LineWidth', 4);
    hold (ax, 'on');
    plot(ax, theMTFdataStruct.supportCyclesPerDeg, theVisualizeMTFslice, 'y-', 'LineWidth', 2);

    xlabel(ax, 'spatial frequency (c/deg)');
    ylabel(ax, 'MTF');
    title(ax, plotTitle);
    set(ax, 'XLim', [0 visualizedSFcyclesPerDegree], 'YLim', [0 1]);
    set(ax, 'XTick', 0:10:100, 'yTick', 0:0.2:1);
    grid(ax, 'on')

end


function generatePSFfigure(thePSFdataStruct,  visualizedPSFrangeMicrons, pdfFileName, plotTitle)

    ff = PublicationReadyPlotLib.figureComponents('1x1 standard tall figure');
	hFig = figure(1); clf;
    theAxes = PublicationReadyPlotLib.generatePanelAxes(hFig,ff);
    ax = theAxes{1,1};

    visualizePSF(ax, thePSFdataStruct, visualizedPSFrangeMicrons, plotTitle);

    PublicationReadyPlotLib.applyFormat(ax,ff);
    % PublicationReadyPlotLib.offsetAxes(ax, ff, xLims, yLims);

    theFiguresDir = fullfile(ISETBioPaperAndGrantCodeRootDirectory, 'local', mfilename);
    if (~exist(theFiguresDir,'dir'))
        mkdir(theFiguresDir);
    end

    thePDFfileName = fullfile(theFiguresDir, pdfFileName);
    NicePlot.exportFigToPDF(thePDFfileName,hFig,  300);

end


function visualizePSF(ax, thePSFdataStruct, visualizedPSFrangeMicrons, plotTitle)

    imagesc(ax, thePSFdataStruct.supportMicrons, thePSFdataStruct.supportMicrons, thePSFdataStruct.data);
    axis(ax, 'image'); axis(ax, 'xy')
    set(ax, 'XLim', visualizedPSFrangeMicrons*0.5*[-1 1], 'YLim', visualizedPSFrangeMicrons*0.5*[-1 1]);
    set(ax, 'XTick', -100:10:100, 'yTick', -100:10:100, 'FontSize', 12);
    xlabel(ax, 'space, x (microns)');
    ylabel(ax, 'space, y (microns)');
    
    grid(ax, 'on');
    title(ax, plotTitle);
    colormap(ax, 1-gray(1024));
    drawnow;
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
        'supportMicrons', squeeze(psf.xy(1,:,1)), ...
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

