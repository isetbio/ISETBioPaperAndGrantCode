function plotLongitudinalChromaticAberrationDefocus()

    % Generate a treeshrew cone mosaic object to retrieve the wavelengthsupport
    theTreeShrewConeMosaic = cMosaicTreeShrewCreate(...
        'sizeDegs', [1 1]);

    measuredWavelength = 550;
    examinedWavelengths = theTreeShrewConeMosaic.wave;
    for ii = 1:length(examinedWavelengths)
        theHumanLCAdefocusDiopters(ii) = wvfLCAFromWavelengthDifference(measuredWavelength, examinedWavelengths(ii), 'thibosPaper');
        theTreeShrewLCAdefocusDiopters(ii) = treeShrewLCA(measuredWavelength, examinedWavelengths(ii));
    end

    pdfFileName = 'TreeShrewVsHumanLCA.pdf';
    generateFigure(examinedWavelengths, theTreeShrewLCAdefocusDiopters, theHumanLCAdefocusDiopters, pdfFileName, '');

end

function generateFigure(examinedWavelengths, theTreeShrewLCAdefocusDiopters, theHumanLCAdefocusDiopters, pdfFileName, plotTitle)

    ff = PublicationReadyPlotLib.figureComponents('1x1 standard tall figure');
	hFig = figure(1); clf;
    
    theAxes = PublicationReadyPlotLib.generatePanelAxes(hFig,ff);
    ax = theAxes{1,1};

    plot(ax,examinedWavelengths, theHumanLCAdefocusDiopters, 'k-', 'LineWidth', 4);
    hold(ax, 'on');
    p1 = plot(ax,examinedWavelengths, theHumanLCAdefocusDiopters, 'y-', 'LineWidth', 2);
    hold(ax, 'on');
    plot(ax, examinedWavelengths,  theTreeShrewLCAdefocusDiopters, 'k-', 'LineWidth', 4.0);
    p2 = plot(ax, examinedWavelengths,  theTreeShrewLCAdefocusDiopters, 'y--', 'LineWidth', 2);

     % Legend
    legend(ax, [p1 p2], {'human', 'tree shrew'}, ...
        'Location', 'SouthEast');

    % Legend customization
    ff.legendBox = 'on';
    ff.legendBackgroundAlpha = 0.5;
    ff.legendBackgroundColor = [0.6 0.6 0.6];
    ff.legendEdgeColor = [0.2 0.2 0.2];
    ff.legendLineWidth = 1.0;

    axis (ax, 'square');
    
    xLims = [examinedWavelengths(1) examinedWavelengths(end)];
    yLims = [-7 3];
    xTicks = 400:50:850;
    yTicks = -10:1:10;

    set(ax, 'XLim', xLims, 'XTick', xTicks, 'XTickLabel', {'400', '', '500', '', '600', '', '700', '', '800'});
    set(ax, 'YLim', yLims, 'YTick', yTicks);
    xlabel(ax, 'wavelength (nm)');
    ylabel(ax, 'defocus (diopters)');
    title(ax, plotTitle);

    PublicationReadyPlotLib.applyFormat(ax,ff);
    % PublicationReadyPlotLib.offsetAxes(ax, ff, xLims, yLims);

     theFiguresDir = fullfile(ISETBioPaperAndGrantCodeRootDirectory, 'local', mfilename);
    if (~exist(theFiguresDir,'dir'))
        mkdir(theFiguresDir);
    end

    thePDFfileName = fullfile(theFiguresDir, pdfFileName);
    NicePlot.exportFigToPDF(thePDFfileName,hFig,  300);

end
