%
% demoEngine.visualize.responseTimeSeriesForSingleMRGC
%
function responseTimeSeriesForSingleMRGC(theMRGCmosaicResponseDictionary, targetRGCindex, ...
    theResponseBias, theResponseDelay, ...
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


    if (1==2)
        hFig = figure(5000); clf;
        theAxes = PublicationReadyPlotLib.generatePanelAxes(hFig,ff);
        ax = theAxes{1,1};
    
        [theTemporalSupportSeconds, theMRGCmosaicSpatioTemporalResponse] = demoEngine.helper.retrieveMRGCmosaicResponses(...
            theMRGCmosaicResponseDictionary, ...
            'cone modulations + BK filters', ...
             0,0, []);
        
    
        mRGCsNum = size(theMRGCmosaicSpatioTemporalResponse,2);
        imagesc(theTemporalSupportSeconds*1e3, 1:mRGCsNum, theMRGCmosaicSpatioTemporalResponse')
    
        timeLimits = [0 5.0*1e3];
        yLims = [1 mRGCsNum];
        set(ax, 'XLim', timeLimits, 'YLim', yLims, 'CLim', max(theMRGCmosaicSpatioTemporalResponse(:))*[-1 1]);
        xlabel(ax, 'time (msec)');
        ylabel(ax, 'mRGC index');
        colormap(ax, RedBlueLUT)
        colorbar(ax, 'east');
    
        PublicationReadyPlotLib.offsetAxes(ax,ff, timeLimits, yLims);
        PublicationReadyPlotLib.applyFormat(ax,ff);
    
        % Export figure
        theVisualizationPDFfilename = fullfile(exportVisualizationPDFdirectory, 'ConeModulations_BKfilters_XTresponse.pdf');
                
        % Generate the path if we need to
        RGCMosaicConstructor.filepathFor.augmentedPathWithSubdirs(...
              exportVisualizationRootDirectory, theVisualizationPDFfilename, ...
              'generateMissingSubDirs', true);
            
        thePDFfileName = fullfile(exportVisualizationRootDirectory, theVisualizationPDFfilename);
        NicePlot.exportFigToPDF(thePDFfileName, hFig, 300, 'beVerbose');



    
    
        hFig = figure(5001); clf;
        theAxes = PublicationReadyPlotLib.generatePanelAxes(hFig,ff);
        ax = theAxes{1,1};
    
    
        % Retrieve the data
        [theTemporalSupportSeconds, theMRGCmosaicSpatioTemporalResponse] = demoEngine.helper.retrieveMRGCmosaicResponses(...
            theMRGCmosaicResponseDictionary, ...
            'photocurrents + inner retina filter cascade', ...
            0,0, []);
    
        mRGCsNum = size(theMRGCmosaicSpatioTemporalResponse,2);
        imagesc(theTemporalSupportSeconds*1e3, 1:mRGCsNum, theMRGCmosaicSpatioTemporalResponse')
    
        timeLimits = [0 4000];
        yLims = [1 mRGCsNum];
        set(ax, 'XLim', timeLimits, 'YLim', yLims, 'CLim', max(theMRGCmosaicSpatioTemporalResponse(:))*[-1 1]);
        xlabel(ax, 'time (msec)');
        ylabel(ax, 'mRGC index');
        colormap(ax, RedBlueLUT)
        colorbar(ax, 'east');
        PublicationReadyPlotLib.offsetAxes(ax,ff, timeLimits, yLims);
        PublicationReadyPlotLib.applyFormat(ax,ff);
    
        % Export figure
        theVisualizationPDFfilename = fullfile(exportVisualizationPDFdirectory, 'Photocurrents_InnerRetinaFilterCascade_XTresponse.pdf');
                
        % Generate the path if we need to
        RGCMosaicConstructor.filepathFor.augmentedPathWithSubdirs(...
              exportVisualizationRootDirectory, theVisualizationPDFfilename, ...
              'generateMissingSubDirs', true);
            
        thePDFfileName = fullfile(exportVisualizationRootDirectory, theVisualizationPDFfilename);
        NicePlot.exportFigToPDF(thePDFfileName, hFig, 300, 'beVerbose');
    
    
    
        hFig = figure(5002); clf;
        theAxes = PublicationReadyPlotLib.generatePanelAxes(hFig,ff);
        ax = theAxes{1,1};
    
        % Retrieve the data
        [theTemporalSupportSeconds, theMRGCmosaicSpatioTemporalResponse] = demoEngine.helper.retrieveMRGCmosaicResponses(...
            theMRGCmosaicResponseDictionary, ...
            'photocurrents only', ...
            0,0, []);
    
    
        mRGCsNum = size(theMRGCmosaicSpatioTemporalResponse,2);
        imagesc(theTemporalSupportSeconds*1e3, 1:mRGCsNum, theMRGCmosaicSpatioTemporalResponse');
    
        timeLimits = [0 4000];
        yLims = [1 mRGCsNum];
        set(ax, 'XLim', timeLimits, 'YLim', yLims, 'CLim', max(theMRGCmosaicSpatioTemporalResponse(:))*[-1 1]);
        xlabel(ax, 'time (msec)');
        ylabel(ax, 'mRGC index');
        colormap(ax, RedBlueLUT);
        colorbar(ax, 'east');
    
        PublicationReadyPlotLib.offsetAxes(ax,ff, timeLimits, yLims);
        PublicationReadyPlotLib.applyFormat(ax,ff);
    
        % Export figure
        theVisualizationPDFfilename = fullfile(exportVisualizationPDFdirectory, 'Photocurrents_Only_XTresponse.pdf');
                
        % Generate the path if we need to
        RGCMosaicConstructor.filepathFor.augmentedPathWithSubdirs(...
              exportVisualizationRootDirectory, theVisualizationPDFfilename, ...
              'generateMissingSubDirs', true);
            
        thePDFfileName = fullfile(exportVisualizationRootDirectory, theVisualizationPDFfilename);
        NicePlot.exportFigToPDF(thePDFfileName, hFig, 300, 'beVerbose');


    end



    % Get ready for publication-quality visualization
    hFig = figure(6000); clf;
    ff = PublicationReadyPlotLib.figureComponents('1x1 giant rectangular-double wide mosaic', ...
        'darkScheme', true);
    theAxes = PublicationReadyPlotLib.generatePanelAxes(hFig,ff);
    ax = theAxes{1,1};
    hold(ax,'on')

    c = brewermap(6, 'blues');
    color1 = c(6,:);
    c = brewermap(6, 'reds');
    color2 = c(6,:);


    % The cone modulations + the Benardete & Kaplan original filter
    theLegends{1} = 'cone modulations + BK filters';

    [theTemporalSupportSeconds, theResponse] = demoEngine.helper.retrieveMRGCmosaicResponses(...
        theMRGCmosaicResponseDictionary, ...
        theLegends{1}, ...
        0,0, ...
        targetRGCindex);

    plot(ax, theTemporalSupportSeconds*1e3, theResponse/max(abs(theResponse)), 'k-', 'Color', color1, 'LineWidth', 3.0);
    pHandles(1) = plot(ax, theTemporalSupportSeconds(1:2:end)*1e3, theResponse(1:2:end)/max(abs(theResponse)), 'o-',...
        'Color', color1.^0.5, 'MarkerSize', 10, 'MarkerFaceColor', color1, 'MarkerEdgeColor', color1.^0.5, 'LineWidth', 2.0);


    % The photocurrent + derived inner retina filter cascade
    theLegends{2} = 'photocurrents + inner retina filter cascade';


    [theTemporalSupportSeconds, theResponse] = demoEngine.helper.retrieveMRGCmosaicResponses(...
        theMRGCmosaicResponseDictionary, ...
        theLegends{2}, ...
        theResponseBias, theResponseDelay, ...
        targetRGCindex);

    plot(ax, theTemporalSupportSeconds*1e3, theResponse/max(abs(theResponse)), 'k-', 'Color', color2, 'LineWidth', 3.0);
    pHandles(numel(pHandles)+1) = scatter(ax, theTemporalSupportSeconds(1:2:end)*1e3, theResponse(1:2:end)/max(abs(theResponse)), 100,...
        'Color', color2.^0.5, 'MarkerFaceAlpha', 0.8, 'MarkerFaceColor', color2, 'MarkerEdgeColor', color2.^0.5, 'LineWidth', 2.0);


    legend(ax, pHandles, theLegends, 'Location', 'NorthOutside', 'NumColumns', 2);

    timeLimits = [0 4000];
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


