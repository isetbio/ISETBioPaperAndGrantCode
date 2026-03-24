function plotConeMosaics(options)
% Plot cone mosaics of the treeshrew and of the human retina
%
% Description:
%   Plot cone mosaics of the treeshrew and of the human retina of the same
%   size in microns

% History:
%    03/01/26  NPC  Wrote it.

arguments

    % Whether to plot the quantal efficiencies at the cornea or at the retina
    options.mosaicSizeMicrons (1,1) double = 150;

end % arguments

    mosaicSizeMicrons = options.mosaicSizeMicrons;

    % Retrieve the tree-shrew retinal magnification factor to compute
    % the mosaic size in visual degrees
    theOI = oiTreeShrewCreate();
    treeShrewMosaicSizeDegs = mosaicSizeMicrons / theOI.optics.micronsPerDegree * [1 1];

    % Compute the human mosaic size in degrees
    humanMosaicSizeDegs = WatsonRGCModel.rhoMMsToDegs(1) * mosaicSizeMicrons/1e3 * [1 1];

    % Generate a treeshrew cone mosaic
    theTreeShrewConeMosaic = cMosaicTreeShrewCreate(...
        'sizeDegs', treeShrewMosaicSizeDegs);
    plotConeMosaic(theTreeShrewConeMosaic, mosaicSizeMicrons/5, sprintf('tree shrew mosaic (%2.1f x %2.1f degs)', treeShrewMosaicSizeDegs(1), treeShrewMosaicSizeDegs(2)), 'treeShrewConeMosaic.pdf');

    % Generate human cone mosaic
    theHumanConeMosaic = cMosaic(...
        'whichEye', 'right eye', ...         
        'sizeDegs', humanMosaicSizeDegs);

    % Plot them
    plotConeMosaic(theHumanConeMosaic, mosaicSizeMicrons/5, sprintf('human cone mosaic (%2.1f x %2.1f degs)', humanMosaicSizeDegs(1), humanMosaicSizeDegs(2)), 'humanConeMosaic.pdf');

end


function plotConeMosaic(theConeMosaic, tickSizeMicrons, plotTitle, pdfFileName)


    ff = PublicationReadyPlotLib.figureComponents('1x1 giant square mosaic');
	hFig = figure(1); clf;
    theAxes = PublicationReadyPlotLib.generatePanelAxes(hFig,ff);
    ax = theAxes{1,1};

    domainUnits = 'microns';
    domainVisualizationTicks = struct(...
            'x',  sign(theConeMosaic.eccentricityMicrons(1)) * round(abs(theConeMosaic.eccentricityMicrons(1))) + round(tickSizeMicrons)*(-2:2), ...
            'y',  sign(theConeMosaic.eccentricityMicrons(2)) * round(abs(theConeMosaic.eccentricityMicrons(2))) + round(tickSizeMicrons)*(-2:2));

    theConeMosaic.sizeMicrons

    domainVisualizationLims(1:2) = theConeMosaic.eccentricityMicrons(1) + [-0.5 0.5] * max(theConeMosaic.sizeMicrons);
    domainVisualizationLims(3:4) = theConeMosaic.eccentricityMicrons(2) + [-0.5 0.5] * max(theConeMosaic.sizeMicrons);

    activation = zeros(1,1,theConeMosaic.conesNum);
    activation(1,1,theConeMosaic.lConeIndices) = activation(1,1,theConeMosaic.lConeIndices) + 0.7;
    activation(1,1,theConeMosaic.mConeIndices) = activation(1,1,theConeMosaic.mConeIndices) + 0.5;
    activation(1,1,theConeMosaic.sConeIndices) = activation(1,1,theConeMosaic.sConeIndices) + 0.2;
    theConeMosaic.visualize('figureHandle', hFig, ...
            'axesHandle', ax, ...
            'domain', domainUnits, ...
            'domainVisualizationTicks', domainVisualizationTicks, ...
            'domainVisualizationLimits', domainVisualizationLims, ...
            'visualizedConeAperture', 'lightcollectingarea4sigma', ... %'activation', activation, %'activationRange', [0 1], ...
            'activationcolormap', brewermap(256, '*greys'), ...
            'visualizedConeApertureThetaSamples', 32, ...
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

    % Generate figure dir if it does not exist
    theFiguresDir = ISETBioPaperAndGrantCodeFigureDirForScript(mfilename);

    thePDFfileName = fullfile(theFiguresDir, pdfFileName);
    NicePlot.exportFigToPDF(thePDFfileName,hFig,  300);

end