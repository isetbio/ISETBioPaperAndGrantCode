function plotTrewShrewOptics(options)
% Plots typical treeshrew and human optics
%
% Description:
%   Plots typical treeshrew and human optics (Polans data set)

% History:
%    03/01/26  NPC  Wrote it.

arguments

    % The tree shrew subject number. Between 1 and 11
    options.theTreeShrewSubjectIndex (1,1) double = 1;

    % The human subject rank order. Between 1 and 10
    options.theHumanSubjectRankOrder (1,1) double = 4;

    % The pupil size in mm
    options.pupilSizeMM (1,1) double = 4;

    % The wavelength for which to visualize the PSF
    options.visualizedWavelength = 550;

    % The spatial support for the visualized PSF
    options.visualizedPSFrangeMicrons = 80;

end % arguments


    % Generate optics for this subject
    theOI = oiTreeShrewCreate( ...
            'opticsType', 'wvf', ...
            'pupilDiameterMM', options.pupilSizeMM, ...
            'whichShrew', options.theTreeShrewSubjectIndex, ...
            'name', 'wvf-based optics');

    % Retrieve the PSF and the MTF slices for a target wavelength
    [thePSFdataStruct, theMTFdataStruct] = retrievePSFandMTF(theOI, options.visualizedWavelength);

    % Plot the PSF
    pdfFileName = sprintf('PSF_TreeShrewSubject%d_%dnm.pdf', options.theTreeShrewSubjectIndex, options.visualizedWavelength);
    plotTitle = sprintf('PSF @ %dnm (tree shrew subject %d)', options.visualizedWavelength,  options.theTreeShrewSubjectIndex);
    generatePSFfigure(thePSFdataStruct, options.visualizedPSFrangeMicrons, pdfFileName, plotTitle);


    % Plot the MTF
    pdfFileName = sprintf('MTF_TreeShrewSubject%d_%dnm.pdf', options.theTreeShrewSubjectIndex, options.visualizedWavelength);
    plotTitle = sprintf('MTF @ %dnm (tree shrew subject %d)', options.visualizedWavelength,  options.theTreeShrewSubjectIndex);
    generateMTFfigure(theMTFdataStruct, pdfFileName, plotTitle);



    % Select a human subject
    opticsZernikeCoefficientsDataBase = 'Polans2015';
    rankedSubjectIDs = PolansOptics.constants.subjectRanking;
    testSubjectID = rankedSubjectIDs(options.theHumanSubjectRankOrder);
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
        'pupilDiameterMM', options.pupilSizeMM, ...
        'subtractCentralRefraction', subtractCentralRefraction);
    theOI = oiEnsemble{1};


    % Retrieve the PSF and the MTF slices for a target wavelength
    [thePSFdataStruct, theMTFdataStruct] = retrievePSFandMTF(theOI, options.visualizedWavelength);

    % Plot the PSF
    pdfFileName = sprintf('PSF_HumanSubject%s_%dnm.pdf', sprintf('%s_subj%d',opticsZernikeCoefficientsDataBase, testSubjectID), options.visualizedWavelength);
    plotTitle = sprintf('PSF @ %dnm (human subject %s-%d)', options.visualizedWavelength, opticsZernikeCoefficientsDataBase, testSubjectID);
    generatePSFfigure(thePSFdataStruct, options.visualizedPSFrangeMicrons, pdfFileName, plotTitle);


    % Plot the MTF
    pdfFileName = sprintf('MTF_HumanSubject%s_%dnm.pdf', sprintf('%s_subj%d',opticsZernikeCoefficientsDataBase, testSubjectID), options.visualizedWavelength);
    plotTitle = sprintf('MTF @ %dnm (human subject %s-%d)', options.visualizedWavelength, opticsZernikeCoefficientsDataBase, testSubjectID);
    generateMTFfigure(theMTFdataStruct, pdfFileName, plotTitle);

    
end

function generateMTFfigure(theMTFdataStruct, pdfFileName, plotTitle)

    ff = PublicationReadyPlotLib.figureComponents('1x1 standard figure');
	hFig = figure(1); clf;
    theAxes = PublicationReadyPlotLib.generatePanelAxes(hFig,ff);
    ax = theAxes{1,1};

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
    NicePlot.exportFigToPNG(strrep(thePDFfileName, 'pdf', 'png'),hFig,  300);
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
    %title(ax, plotTitle);
    set(ax, 'XLim', [0 visualizedSFcyclesPerDegree], 'YLim', [0 1]);
    set(ax, 'XTick', 0:10:200, 'yTick', 0:0.2:1);
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
    NicePlot.exportFigToPNG(strrep(thePDFfileName, 'pdf', 'png'),hFig,  300);

end


function visualizePSF(ax, thePSFdataStruct, visualizedPSFrangeMicrons, plotTitle)

    imagesc(ax, thePSFdataStruct.supportMicrons, thePSFdataStruct.supportMicrons, thePSFdataStruct.data);
    axis(ax, 'image'); axis(ax, 'xy')
    set(ax, 'XLim', visualizedPSFrangeMicrons*0.5*[-1 1], 'YLim', visualizedPSFrangeMicrons*0.5*[-1 1]);
    set(ax, 'XTick', -100:10:100, 'yTick', -100:10:100, 'FontSize', 12);
    xlabel(ax, 'space, x (microns)');
    ylabel(ax, 'space, y (microns)');
    
    grid(ax, 'on');
    %title(ax, plotTitle);
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

