%
% demoEngine.visualize.simulationTimeCourse
%

function simulationTimeCourse(...
    theMRGCmosaicResponseDictionary, targetRGCindex, ...
    theConeMosaic, theInputConeMosaicPhotocurrentActivation, ...
    theInputConeMosaicPhotocurrentTemporalSupportSeconds, ...
    theResponseLabels, theResponseColors, ...
    theResponseNormalizingFactors, theResponseBias, theResponseDelay, ...
    maxTimeToVisualize, traceViewWindowSeconds, ...
    theScene, theRetinalImage, theFixationalEMOb, ...
    exportVisualizationRootDirectory, ...
    exportVisualizationVideoDirectory, ...
    theVideoFileName)


    domainVisualizationLimits(1:2) = theConeMosaic.eccentricityDegs(1) + 0.41 * theConeMosaic.sizeDegs(1) * [-1 1];
    domainVisualizationLimits(3:4) = theConeMosaic.eccentricityDegs(2) + 0.31 * theConeMosaic.sizeDegs(2) * [-1 1];
    domainVisualizationTicks = struct(...
        'x', theConeMosaic.eccentricityDegs(1) + 0.4 * theConeMosaic.sizeDegs(1) * [-1  0 1], ...
        'y', theConeMosaic.eccentricityDegs(2) + 0.3 * theConeMosaic.sizeDegs(2) * [-1  0  1]);

    xLims = domainVisualizationLimits(1:2)-mean(domainVisualizationLimits(1:2));
    xTicks = domainVisualizationTicks.x - mean(domainVisualizationLimits(1:2));
    yLims = domainVisualizationLimits(3:4)-mean(domainVisualizationLimits(3:4));
    yTicks = domainVisualizationTicks.y - mean(domainVisualizationLimits(3:4));


    if (~isempty(theScene))
        if (iscell(theScene))
            error('A cell of scenes. NO code to visualize dynamic stimuli yet')
        end
        theSceneImage = sceneGet(theScene, 'rgbimage');
    end

    stimulusIlluminance = oiGet(theRetinalImage, 'illuminance');
    retinalImage = oiGet(theRetinalImage, 'rgbimage');
    illuminanceRange = [min(stimulusIlluminance(:)) max(stimulusIlluminance(:))];

    oiPixelWidthDegs = oiGet(theRetinalImage, 'wangular resolution');
    oiWidthPixels = oiGet(theRetinalImage, 'cols');
    oiSupport = (1:oiWidthPixels)*oiPixelWidthDegs;
    oiSupport = oiSupport - mean(oiSupport);

    
    theVideoFileName = fullfile(exportVisualizationVideoDirectory, theVideoFileName);
            
    % Generate the path if we need to
    RGCMosaicConstructor.filepathFor.augmentedPathWithSubdirs(...
          exportVisualizationRootDirectory, theVideoFileName, ...
          'generateMissingSubDirs', true);
        
    theVideoFileName = fullfile(exportVisualizationRootDirectory, theVideoFileName);

    ff = PublicationReadyPlotLib.figureComponents('1.5x2 giant figure',...
        'darkScheme', true);

    fff = ff;

    ff.grid = 'off';
    ff.box  = 'on';
    tmp = ff.backgroundColor;
    ff.backgroundColor = ff.legendBackgroundColor;
    ff.legendBackgroundColor = tmp;

    fff.grid = 'on';
    fff.box = 'off';
    fff.backgroundColor = ff.backgroundColor;
    fff.legendBackgroundColor = ff.legendBackgroundColor;

    hFig = figure(10); clf;
    theAxes = PublicationReadyPlotLib.generatePanelAxes(hFig,ff);
    axTraces = theAxes{1,1};
    axTraces2 = theAxes{2,1};

    axRetinalImageAndEyeMovement = theAxes{1,2};
    axConeMosaicExcitation = theAxes{2,2};
    

    % Cone mosaic activation range
    activationRange = prctile(abs(theInputConeMosaicPhotocurrentActivation(:)), 99)*[-1 1];

    
    % Visualize each frame of the stimulus/response/fixational EM
    nTrials = size(theInputConeMosaicPhotocurrentActivation,1);
    timeSamplesNum = size(theInputConeMosaicPhotocurrentActivation,2);



    videoOBJ = VideoWriter(theVideoFileName, 'MPEG-4');
    videoOBJ.FrameRate = 60;
    videoOBJ.Quality = 100;
    videoOBJ.open();

    visualizedEMpathDurationSeconds = 0.1;

    
    RedBlueLUT = zeros(1024,3);
    RedBlueLUT(513,:) = ff.legendBackgroundColor;
    RedBlueLUT(514:1024,1) = ff.legendBackgroundColor(1) + (1-ff.legendBackgroundColor(1))*(1:511)/511;
    RedBlueLUT(514:1024,2) = ff.legendBackgroundColor(2);
    RedBlueLUT(514:1024,3) = ff.legendBackgroundColor(3);

    RedBlueLUT(512:-1:1,1) = ff.legendBackgroundColor(1);
    RedBlueLUT(512:-1:1,2) = ff.legendBackgroundColor(2);
    RedBlueLUT(512:-1:1,3) = ff.legendBackgroundColor(3) + (1-ff.legendBackgroundColor(3))*(1:512)/512;

    activationLUT = RedBlueLUT;
    activationLUT = brewermap(1024, '*greys');
 

    % Retrieve the data
    [theTemporalSupportSeconds1, theResponse1, normalizingFactor1] = demoEngine.helper.retrieveMRGCmosaicResponses(...
        theMRGCmosaicResponseDictionary, ...
        theResponseLabels{1}, ...
        theResponseBias(1), theResponseDelay(1), maxTimeToVisualize, ...
        targetRGCindex);


    % Retrieve the data
    [theTemporalSupportSeconds2, theResponse2, normalizingFactor2] = demoEngine.helper.retrieveMRGCmosaicResponses(...
        theMRGCmosaicResponseDictionary, ...
        theResponseLabels{2}, ...
        theResponseBias(2), theResponseDelay(2), maxTimeToVisualize, ...
        targetRGCindex);

    % Retrieve the data
    [theTemporalSupportSeconds3, theResponse3, normalizingFactor3] = demoEngine.helper.retrieveMRGCmosaicResponses(...
        theMRGCmosaicResponseDictionary, ...
        theResponseLabels{3}, ...
        theResponseBias(3), theResponseDelay(3), maxTimeToVisualize, ...
        targetRGCindex);


    
    
    % Response normalization
    if (isempty(theResponseNormalizingFactors))
            theResponse1 = theResponse1 / normalizingFactor1;
            theResponse2 = theResponse2 / normalizingFactor2;
            theResponse3 = theResponse3 / normalizingFactor3;
    else 
        if (~isnan(theResponseNormalizingFactors(1)))
            theResponse1 = theResponse1 / theResponseNormalizingFactors(1);
        end
        if (~isnan(theResponseNormalizingFactors(2)))
            theResponse2 = theResponse2 / theResponseNormalizingFactors(2);
        end
        if (~isnan(theResponseNormalizingFactors(3)))
            theResponse3 = theResponse3 / theResponseNormalizingFactors(3);
        end
    end

    

    % The time of visualization
    minTimeSeconds = traceViewWindowSeconds;
    maxTimeSeconds = max(theInputConeMosaicPhotocurrentTemporalSupportSeconds)-traceViewWindowSeconds;


    drawTraces = true;
    for iTrial = 1:nTrials
    for iTimePoint = 1:timeSamplesNum

        currentTime = theInputConeMosaicPhotocurrentTemporalSupportSeconds(iTimePoint);
        theCurrentInputConeMosaicActivation = theInputConeMosaicPhotocurrentActivation(iTrial, iTimePoint,:);

        if (currentTime < minTimeSeconds) || (currentTime > maxTimeSeconds)
            continue;
        end
        
        
        % The input cone mosaic activation
        theConeMosaic.visualize('figureHandle', hFig,...
            'axesHandle', axConeMosaicExcitation, ...
            'activation', theCurrentInputConeMosaicActivation, ...
            'activationRange', activationRange, ...
            'visualizedConeAperture', 'lightcollectingarea5sigma', ...
            'visualizedConeApertureThetaSamples', 32, ...
            'activationColorMap', activationLUT, ...
            'backgroundColor', ff.legendBackgroundColor, ...
            'domainVisualizationLimits', domainVisualizationLimits, ...
            'domainVisualizationTicks', domainVisualizationTicks, ...
            'withFigureFormat', ff, ...
            'plotTitleFontSize', 20, ...
            'plotTitle', sprintf('cone mosaic activation (photocurrents)\ntime: %2.1f msec', (currentTime-minTimeSeconds)*1e3));
        set(axConeMosaicExcitation, 'YaxisLocation', 'right')
         
        % The retinal illuminance and fixational EM path
        %imagesc(axRetinalImageAndEyeMovement, oiSupport, oiSupport, (stimulusIlluminance-illuminanceRange(1))/(illuminanceRange(2) - illuminanceRange(1)), [0 1]);
        image(axRetinalImageAndEyeMovement, oiSupport, oiSupport, retinalImage);


        % Overlay the fixational EMpath
        hold(axRetinalImageAndEyeMovement, 'on');

        % Visualize fEM during the last visualizedEMpathDurationSecond period
        timeIndicesVisualized = find(...
            (theFixationalEMOb.timeAxis <= currentTime) & ...
            (theFixationalEMOb.timeAxis >= currentTime -visualizedEMpathDurationSeconds));

        timeIndicesVisualized = min(size(theFixationalEMOb.emPosArcMin,2),timeIndicesVisualized);

        plot(axRetinalImageAndEyeMovement, ...
            theFixationalEMOb.emPosArcMin(iTrial, timeIndicesVisualized,1)/60, ...
            theFixationalEMOb.emPosArcMin(iTrial, timeIndicesVisualized,2)/60, '-', ...
            'LineWidth', 3.0, 'Color', 'k');

        plot(axRetinalImageAndEyeMovement, ...
            theFixationalEMOb.emPosArcMin(iTrial, timeIndicesVisualized,1)/60, ...
            theFixationalEMOb.emPosArcMin(iTrial, timeIndicesVisualized,2)/60, '-', ...
            'LineWidth', 2.0, 'Color', 'r');

        plot(axRetinalImageAndEyeMovement, ...
            theFixationalEMOb.emPosArcMin(iTrial, timeIndicesVisualized(end),1)/60, ...
            theFixationalEMOb.emPosArcMin(iTrial, timeIndicesVisualized(end),2)/60, 'ro', ...
            'LineWidth', 2.0, 'MarkerSize', 12, 'MarkerFaceColor', [1 0 0], 'MarkerEdgeColor', [1 1 1]);

        hold(axRetinalImageAndEyeMovement, 'off')

        axis(axRetinalImageAndEyeMovement, 'equal');
        axis(axRetinalImageAndEyeMovement, 'image');
        set(axRetinalImageAndEyeMovement, 'FontSize', 20, 'Color', [0 0 0]);

        
        set(axRetinalImageAndEyeMovement, 'XLim', xLims, 'YLim', yLims);
        set(axRetinalImageAndEyeMovement, 'XTick', xTicks, 'YTick', yTicks);
        set(axRetinalImageAndEyeMovement, 'XTickLabel', {}, 'YTickLabel', {});
        colormap(axRetinalImageAndEyeMovement, brewermap(1024, '*greys'));
        title(axRetinalImageAndEyeMovement, sprintf('retinal illuminance and recent fixational EM path'));
       
        PublicationReadyPlotLib.applyFormat(axRetinalImageAndEyeMovement,ff);

   
        if (~isempty(theScene))
            % thumbnail of scene
            axSceneInset = axes('Position', [0.84 0.55 0.13 0.13]);
            image(axSceneInset, theSceneImage(1:5:end, 1:5:end,:));
            axis(axSceneInset, 'image');
            set(axSceneInset, 'XTick', [], 'YTick', []);
        end

        
        if (drawTraces)
            drawTraces = false;

            % Plot every 5th point
            skipSize = 5;

            % The traces
            pHandles = [];
            plot(axTraces, (theTemporalSupportSeconds1(1:skipSize:end))*1e3, theResponse1(1:skipSize:end), ...
                'k-', 'Color', theResponseColors(1,:), 'LineWidth', 3.0);

            pHandles(numel(pHandles)+1) = plot(axTraces, (theTemporalSupportSeconds1(1:skipSize:end))*1e3, theResponse1(1:skipSize:end), 'o-',...
                'MarkerSize', 10, 'LineWidth', 2.0, 'Color', theResponseColors(1,:).^0.5,  ...
                'MarkerFaceColor', theResponseColors(1,:), 'MarkerEdgeColor', theResponseColors(1,:).^0.5);
            hold(axTraces, 'on')
    
    
            plot(axTraces, theTemporalSupportSeconds2*1e3, theResponse2, ...
                'k-', 'Color', theResponseColors(2,:), 'LineWidth', 3.0);

            pHandles(numel(pHandles)+1) = scatter(axTraces, (theTemporalSupportSeconds2(1:skipSize:end))*1e3, theResponse2(1:skipSize:end), ...
                100, 'LineWidth', 2.0, 'Color', theResponseColors(2,:).^0.5, 'MarkerFaceAlpha', 0.8, ...
                'MarkerEdgeColor', theResponseColors(2,:), 'MarkerFaceColor', theResponseColors(2,:).^0.5);
  
            legend(axTraces, pHandles, theResponseLabels{1:2}, 'Location', 'NorthOutside', 'NumColumns', 2);


            plot(axTraces2, theTemporalSupportSeconds3*1e3, theResponse3, ...
                'k-', 'Color', theResponseColors(3,:), 'LineWidth', 3.0);

            p3 = plot(axTraces2, theTemporalSupportSeconds3(1:skipSize:end)*1e3, theResponse3(1:skipSize:end), 'o-',...
                'Color', theResponseColors(3,:).^0.5, 'MarkerSize', 10, 'LineWidth', 2.0, ...
                'MarkerFaceColor', theResponseColors(3,:), 'MarkerEdgeColor', theResponseColors(3,:).^0.5);
    
            legend(axTraces2, p3, theResponseLabels{3}, 'Location', 'NorthOutside', 'NumColumns', 2);
        end


        timeLimits = currentTime + [-traceViewWindowSeconds 0];
        responseLimits = [-1.0 1.0];
        set(axTraces, 'XLim', timeLimits*1e3, 'YLim', responseLimits, ...
            'XTick', 0:100:6000, 'XTickLabel', sprintf('%2.0f\n', (0:100:6000)-minTimeSeconds*1e3), 'YTick', -1:0.5:1);
        xlabel(axTraces, 'time (msec)');
        ylabel(axTraces, 'mRGC response');

        PublicationReadyPlotLib.applyFormat(axTraces,fff);
        set(axTraces, 'YaxisLocation', 'right')



        set(axTraces2, 'XLim', timeLimits*1e3, 'YLim', responseLimits, 'XTick', 0:100:6000, 'XTickLabel', {}, 'YTick', -1:0.5:1);
        ylabel(axTraces2, 'mRGC response');
        PublicationReadyPlotLib.applyFormat(axTraces2 , fff);
        set(axTraces2, 'YaxisLocation', 'right')

        drawnow;
        videoOBJ.writeVideo(getframe(hFig));

    end % for iTimePoint
    end % for iTrial

    videoOBJ.close();
end


