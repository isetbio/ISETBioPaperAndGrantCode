%
% demoEngine.visualize.responseTimeSeriesForSingleMRGC
%
function responseTimeSeriesForSingleMRGC(targetRGCindex, ...
    theMRGCmosaicResponseDictionary, theResponseLabels, theResponseColors, ...
    theResponseBias, theResponseDelay, maxTimeToVisualize, ...
    exportVisualizationRootDirectory, exportVisualizationPDFdirectory, thePDFfileName)


    ff = PublicationReadyPlotLib.figureComponents('1x1 giant rectangular-double wide mosaic', ...
        'darkScheme', true);

    RedBlueLUT = zeros(1024,3);
    RedBlueLUT(513,:) = ff.legendBackgroundColor;
    RedBlueLUT(514:1024,1) = ff.legendBackgroundColor(1) + (1-ff.legendBackgroundColor(1))*(1:511)/511;
    RedBlueLUT(514:1024,2) = ff.legendBackgroundColor(2);
    RedBlueLUT(514:1024,3) = ff.legendBackgroundColor(3);

    RedBlueLUT(512:-1:1,1) = ff.legendBackgroundColor(1);
    RedBlueLUT(512:-1:1,2) = ff.legendBackgroundColor(2);
    RedBlueLUT(512:-1:1,3) = ff.legendBackgroundColor(3) + (1-ff.legendBackgroundColor(3))*(1:512)/512;


    % Get ready for publication-quality visualization
    hFig = figure(6000); clf;
    ff = PublicationReadyPlotLib.figureComponents('1x1 giant rectangular-double wide mosaic', ...
        'darkScheme', true);
    theAxes = PublicationReadyPlotLib.generatePanelAxes(hFig,ff);
    ax = theAxes{1,1};
    hold(ax,'on');

   
    skippedSamples = 2;
    for iResponse = 1:numel(theResponseLabels)
    
        [theTemporalSupportSeconds, theResponse, normalizingFactor] = demoEngine.helper.retrieveMRGCmosaicResponses(...
            theMRGCmosaicResponseDictionary, ...
            theResponseLabels{iResponse}, ...
            theResponseBias(iResponse), theResponseDelay(iResponse), maxTimeToVisualize, ...
            targetRGCindex);

        theResponse = theResponse / normalizingFactor;

        if (iResponse == 1)
            % baseline
            plot(ax, theTemporalSupportSeconds*1e3, theResponse*0, 'w-', 'LineWidth', 1.5);
        end

        plot(ax, theTemporalSupportSeconds*1e3, theResponse, '-', 'Color', theResponseColors(iResponse,:), 'LineWidth', 3.0);
        pHandles(iResponse) = plot(ax, ...
            theTemporalSupportSeconds(1:skippedSamples:end)*1e3, ...
            theResponse(1:skippedSamples:end), 'o-',...
            'Color', theResponseColors(iResponse,:).^0.5, 'MarkerSize', 10, 'LineWidth', 2.0,...
            'MarkerFaceColor', theResponseColors(iResponse,:), 'MarkerEdgeColor', theResponseColors(iResponse,:).^0.5);

    end % iResponse


    legend(ax, pHandles, theResponseLabels, 'Location', 'NorthOutside', 'NumColumns', 2);

    timeLimits = [0 theTemporalSupportSeconds(end)]*1e3;
    responseLimits = [-1.0 1.0];
    set(ax, 'XLim', timeLimits, 'YLim', responseLimits, 'XTick', 0:250:5000, 'YTick', -1:0.5:1);
    xlabel(ax, 'time (msec)');
    ylabel(ax, 'mRGC response');

    PublicationReadyPlotLib.offsetAxes(ax,ff, timeLimits, responseLimits);
    PublicationReadyPlotLib.applyFormat(ax,ff);


    % Export figure
    theVisualizationPDFfilename = fullfile(exportVisualizationPDFdirectory, thePDFfileName);
            
    % Generate the path if we need to
    RGCMosaicConstructor.filepathFor.augmentedPathWithSubdirs(...
          exportVisualizationRootDirectory, theVisualizationPDFfilename, ...
          'generateMissingSubDirs', true);
        
    thePDFfileName = fullfile(exportVisualizationRootDirectory, theVisualizationPDFfilename);
    NicePlot.exportFigToPDF(thePDFfileName, hFig, 300, 'beVerbose');

end


