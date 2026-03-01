function plotPreretinalPigmentTransmittances()

    theConeMosaic = cMosaicTreeShrewCreate(...
        'sizeDegs', [1 1]);
    
    theLens = lensTreeShrewCreate(...
        'wave', theConeMosaic.wave);
    
    pdfFileName = 'TreeShrewLensTransmittance.pdf';
    generateFigure(theConeMosaic, theLens, pdfFileName, 'tree shrew');


    theHumanConeMosaic = cMosaic(...
        'sizeDegs', [1 1]);
    
    theHumanLens = Lens(...
        'wave', theConeMosaic.wave);
    
    pdfFileName = 'HumanLensTransmittance.pdf';
    generateFigure(theHumanConeMosaic, theHumanLens, pdfFileName, 'human');



end

function generateFigure(theConeMosaic, theLens, pdfFileName, plotTitle)

    ff = PublicationReadyPlotLib.figureComponents('1x1 standard figure');
	hFig = figure(1); clf;
    
    theAxes = PublicationReadyPlotLib.generatePanelAxes(hFig,ff);
    ax = theAxes{1,1};

    plot(ax,theConeMosaic.wave, theConeMosaic.macular.transmittance, 'k-', 'LineWidth', 3);
    hold(ax, 'on');
    p1 = plot(ax,theConeMosaic.wave, theConeMosaic.macular.transmittance, 'm-', 'LineWidth', 2);
    hold(ax, 'on');
    plot(ax, theConeMosaic.wave,  theLens.transmittance, 'k-', 'LineWidth', 3.0);
    p2 = plot(ax, theConeMosaic.wave,  theLens.transmittance, 'y-', 'LineWidth', 2);

    p3 = plot(ax, theConeMosaic.wave,  theLens.transmittance .* theConeMosaic.macular.transmittance, 'k--', 'LineWidth', 2);

    legend(ax, [p1 p2 p3], {'macular pigment', 'lens', 'combined'}, 'Location', 'SouthEast');
    axis (ax, 'square');
    
    xLims = [theConeMosaic.wave(1) theConeMosaic.wave(end)];
    yLims = [0 1.01];
    xTicks = 400:50:850;
    yTicks = 0:0.2:1;

    set(ax, 'XLim', xLims, 'XTick', xTicks, 'XTickLabel', {'400', '', '500', '', '600', '', '700', '', '800'});
    set(ax, 'YLim', yLims, 'YTick', yTicks);
    xlabel(ax, 'wavelength (nm)');
    ylabel(ax, 'transmittance');
    title(ax, plotTitle);

    PublicationReadyPlotLib.applyFormat(ax,ff);
    PublicationReadyPlotLib.offsetAxes(ax, ff, xLims, yLims);

    

    theFiguresDir = fullfile(ISETBioPaperAndGrantCodeRootDirectory, 'local', mfilename);
    if (~exist(theFiguresDir,'dir'))
        mkdir(theFiguresDir);
    end

    
    thePDFfileName = fullfile(theFiguresDir, pdfFileName);
    NicePlot.exportFigToPDF(thePDFfileName,hFig,  300);

end
