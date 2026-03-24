function plotConeQuantalEfficienties(options)
% Plot the cone quantal efficiencies of the treeshrew and of the human retina
%
% Description:
%   Plot the cone quantal efficiencies of the treeshrew and of the human retina 

% History:
%    03/01/26  NPC  Wrote it.

arguments

    % Whether to plot the quantal efficiencies at the cornea or at the retina
    options.efficienciesAtCornea (1,1) logical = ~true;

end % arguments

    % Flag indicating whether to plot cone quantal efficiencies at the
    % cornea or at the retina
    efficienciesAtCornea = options.efficienciesAtCornea;

    % Generate a treeshrew cone mosaic object to retrieve the macular pigment
    theTreeShrewConeMosaic = cMosaicTreeShrewCreate(...
        'sizeDegs', [1 1]);

    % Generate a treeshrew lens object
    theTreeShrewLens = lensTreeShrewCreate(...
        'wave', theTreeShrewConeMosaic.wave);

    if (efficienciesAtCornea)
        % Add the spectral filtering due to the lens wavelength-dependent
        % transmittance. The macular pigment is already included  intheConeMosaic.qe
        for iConeType = cMosaic.LCONE_ID : cMosaic.SCONE_ID
            quantalEfficiencies(:,iConeType) = theTreeShrewConeMosaic.qe(:,iConeType) .* theTreeShrewLens.transmittance;
        end
        pdfFileName = 'TreeShrewQuantalEfficienciesAtCornea.pdf';
        plotTitle = 'tree shrew (cornea-referred)';
    else
        % Efficiencies of cone pigments (including the effect of the macular pigment)
        quantalEfficiencies = theTreeShrewConeMosaic.qe;
        pdfFileName = 'TreeShrewQuantalEfficiencies.pdf';
         plotTitle = 'tree shrew (retina-referred)';
    end

    % Plot the quantal efficiencies and save the plot in a pdf file
    generateFigure(theTreeShrewConeMosaic.wave, quantalEfficiencies,  pdfFileName, plotTitle);


    % Generate a human cone mosaic object to retrieve the macular pigment
    theHumanConeMosaic = cMosaic(...
        'sizeDegs', [1 1]);

    if (efficienciesAtCornea)
        % Add the spectral filtering due to the lens wavelength-dependent
        % transmittance. The macular pigment is already included  intheConeMosaic.qe
        for iConeType = cMosaic.LCONE_ID : cMosaic.SCONE_ID
            quantalEfficiencies(:,iConeType) = theHumanConeMosaic.qe(:,iConeType) .* theHumanLens.transmittance;
        end
        pdfFileName = 'HumanQuantalEfficienciesAtCornea.pdf';
        plotTitle = 'human (cornea-referred)';
    else
        % Efficiencies of cone pigments (including the effect of the macular pigment)
        quantalEfficiencies = theHumanConeMosaic.qe;
        pdfFileName = 'HumanQuantalEfficiencies.pdf';
        plotTitle = 'human (retina-referred)';
    end

    % Plot the quantal efficiencies and save the plot in a pdf file
    generateFigure(theHumanConeMosaic.wave, quantalEfficiencies,  pdfFileName, plotTitle);
end


function generateFigure(wavelengthSupport, quantalEfficiencies,  pdfFileName, plotTitle)

    ff = PublicationReadyPlotLib.figureComponents('1x1 standard tall figure');
	hFig = figure(1); clf;
    
    theAxes = PublicationReadyPlotLib.generatePanelAxes(hFig,ff);
    ax = theAxes{1,1};

   
    plot(ax, wavelengthSupport, quantalEfficiencies(:,cMosaic.LCONE_ID), 'k-', 'LineWidth', 4);
    hold(ax, 'on');
    p1 = plot(ax, wavelengthSupport, quantalEfficiencies(:,cMosaic.LCONE_ID), 'r-', 'LineWidth', 2);

    plot(ax, wavelengthSupport, quantalEfficiencies(:,cMosaic.MCONE_ID), 'k-', 'LineWidth', 4);
    p2 = plot(ax, wavelengthSupport, quantalEfficiencies(:,cMosaic.MCONE_ID), 'g-', 'LineWidth', 2);

    plot(ax, wavelengthSupport, quantalEfficiencies(:,cMosaic.SCONE_ID), 'k-', 'LineWidth', 4);
    p3 = plot(ax, wavelengthSupport, quantalEfficiencies(:,cMosaic.SCONE_ID), 'c-', 'LineWidth', 2);

    % Legend
    legend(ax, [p1 p2 p3], {'L-cone', 'M-cone', 'S-cone'}, 'Location', 'NorthEast');

    % Legend customization
    ff.legendBox = 'on';
    ff.legendBackgroundAlpha = 0.5;
    ff.legendBackgroundColor = [0.6 0.6 0.6];
    ff.legendEdgeColor = [0.2 0.2 0.2];
    ff.legendLineWidth = 1.0;

    axis (ax, 'square');

    xLims = [wavelengthSupport(1) wavelengthSupport(end)];
    yLims = [0.001 0.5];
    xTicks = 400:50:850;
    yTicks = [0.001 0.003 0.01 0.03 0.1 0.3 1];

    set(ax, 'XLim', xLims, 'XTick', xTicks, 'XTickLabel', {'400', '', '500', '', '600', '', '700', '', '800'});
    set(ax, 'YLim', yLims, 'YTick', yTicks, 'YScale', 'log', 'YTickLabel', {'1e-3', '3e-3', '1e-2', '3e-2', '1e-1', '3e-1', '1.0'});
    xlabel(ax, 'wavelength (nm)');
    ylabel(ax, 'quantal efficiency');

    title(ax, plotTitle);

    PublicationReadyPlotLib.applyFormat(ax,ff);
    %PublicationReadyPlotLib.offsetAxes(ax, ff, xLims, yLims);

    % Generate figure dir if it does not exist
    theFiguresDir = ISETBioPaperAndGrantCodeFigureDirForScript(mfilename);
    
    thePDFfileName = fullfile(theFiguresDir, pdfFileName);
    NicePlot.exportFigToPDF(thePDFfileName,hFig,  300);

end
