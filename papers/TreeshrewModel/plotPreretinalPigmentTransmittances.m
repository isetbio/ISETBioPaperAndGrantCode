function plotPreretinalPigmentTransmittances()
% Plots the pre-retinal pigment transmittances of the treeshrew and of the
% human retina. 
%
% Description:
%   Plots the pre-retinal pigment transmittances of the treeshrew and of the
%   human retina. The lens absorbance spectra is digitized from Figure 5 of 
%   Petry and Harosi (1990) - Visual Pigments of the Tree Shrew, Vision Res., 30 (6).

% History:
%    03/01/26  NPC  Wrote it.

    % Generate a treeshrew cone mosaic object to retrieve the macular pigment
    theTreeShrewConeMosaic = cMosaicTreeShrewCreate(...
        'sizeDegs', [1 1]);
    
    % Generate a treeshrew lens object
    theTreeShrewLens = lensTreeShrewCreate(...
        'wave', theTreeShrewConeMosaic.wave);
    
    % Plot the lens and macular pigment transmittances and save the plot in
    % a pdf file
    pdfFileName = 'TreeShrewLensTransmittance.pdf';
    generateFigure(theTreeShrewConeMosaic, theTreeShrewLens, pdfFileName, 'tree shrew');

    % Generate a human cone mosaic object to retrieve the macular pigment
    theHumanConeMosaic = cMosaic(...
        'sizeDegs', [1 1]);
    
    % Generate a human lens object
    theHumanLens = Lens(...
        'wave', theHumanConeMosaic.wave);
    
    % Plot the lens and macular pigment transmittances and save the plot in
    % a pdf file
    pdfFileName = 'HumanLensTransmittance.pdf';
    generateFigure(theHumanConeMosaic, theHumanLens, pdfFileName, 'human');

end

function generateFigure(theConeMosaic, theLens, pdfFileName, plotTitle)

    ff = PublicationReadyPlotLib.figureComponents('1x1 standard tall figure');
	hFig = figure(1); clf;
    
    theAxes = PublicationReadyPlotLib.generatePanelAxes(hFig,ff);
    ax = theAxes{1,1};

    plot(ax,theConeMosaic.wave, theConeMosaic.macular.transmittance, 'k-', 'LineWidth', 4);
    hold(ax, 'on');
    p1 = plot(ax,theConeMosaic.wave, theConeMosaic.macular.transmittance, 'm-', 'LineWidth', 2);
    hold(ax, 'on');
    plot(ax, theConeMosaic.wave,  theLens.transmittance, 'k-', 'LineWidth', 4.0);
    p2 = plot(ax, theConeMosaic.wave,  theLens.transmittance, 'y-', 'LineWidth', 2);

    p3 = plot(ax, theConeMosaic.wave,  theLens.transmittance .* theConeMosaic.macular.transmittance, 'k--', 'LineWidth', 2);

    % Legend
    legend(ax, [p1 p2 p3], {'macular pigment', 'lens', 'combined'}, ...
        'Location', 'SouthEast');

    % Legend customization
    ff.legendBox = 'on';
    ff.legendBackgroundAlpha = 0.5;
    ff.legendBackgroundColor = [0.6 0.6 0.6];
    ff.legendEdgeColor = [0.2 0.2 0.2];
    ff.legendLineWidth = 1.0;


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
    % PublicationReadyPlotLib.offsetAxes(ax, ff, xLims, yLims);

    theFiguresDir = fullfile(ISETBioPaperAndGrantCodeRootDirectory, 'local', mfilename);
    if (~exist(theFiguresDir,'dir'))
        mkdir(theFiguresDir);
    end

    thePDFfileName = fullfile(theFiguresDir, pdfFileName);
    NicePlot.exportFigToPDF(thePDFfileName,hFig,  300);

end
