%
% demoEngine.scene.visualizeHDR
%

function visualizeHDR(scene, spatialSupportXdegs, spatialSupportYdegs, sceneCropParams, figNo, ...
    exportVisualizationPDFrootDirectory, exportVisualizationPDFdirectory, thePDFfileName)


    flipUpsideDown = true;
    if (flipUpsideDown)
        thePhotons = sceneGet(scene, 'photons');
        for iWave = 1:size(thePhotons,3)
            thePhotons(:,:,iWave) = flipud(squeeze(thePhotons(:,:,iWave)));
        end
        scene = sceneSet(scene, 'photons', thePhotons);
    end

    rangeDegs = max(spatialSupportXdegs)-min(spatialSupportXdegs);
    if (rangeDegs<2)
        xTicks = -10:0.5:10;
    else
        xTicks = -10:1:10;
    end

    RGBsettings = sceneGet(scene, 'rgbimage');
    luminanceMap = sceneGet(scene, 'luminance');

    ff = PublicationReadyPlotLib.figureComponents('1x2 giant figure',...
        'darkScheme', true);

    hFig = figure(figNo); clf;
    theAxes = PublicationReadyPlotLib.generatePanelAxes(hFig,ff);
    ax1 = theAxes{1,1};
    ax2 = theAxes{1,2};

    % The RGB scene
    image(ax1, spatialSupportXdegs, spatialSupportYdegs, RGBsettings); 
    hold(ax1, 'on')
    plot(ax1,spatialSupportXdegs, spatialSupportXdegs*0, 'k-');
    plot(ax1,spatialSupportYdegs*0, spatialSupportYdegs, 'k-');
    if (~isempty(sceneCropParams))
        xx = sceneCropParams.positionDegs(1) + 0.5*sceneCropParams.sizeDegs(1)*[-1 -1 1 1 -1];
        yy = sceneCropParams.positionDegs(2) + 0.5*sceneCropParams.sizeDegs(2)*[-1 1 1 -1 -1];
        plot(ax1, xx, yy, 'w-', 'LineWidth', 3);
        plot(ax1, xx, yy, 'k--', 'LineWidth', 1.5);
    end    
    hold(ax1, 'off');
    


    colorbar(ax1)
    axis(ax1, 'xy');
    axis(ax1, 'image');
    xlabel(ax1, 'space, x (degs)');
    ylabel(ax1, 'space, y (degs)');
    set(ax1, 'XTick', xTicks, 'YTick', xTicks);
    PublicationReadyPlotLib.applyFormat(ax1,ff);


    % The luminance map
    imagesc(ax2, spatialSupportXdegs, spatialSupportYdegs, luminanceMap);
    hold(ax2, 'on')
    plot(ax2,spatialSupportXdegs, spatialSupportXdegs*0, 'k-');
    plot(ax2,spatialSupportYdegs*0, spatialSupportYdegs, 'k-');
    if (~isempty(sceneCropParams))
        xx = sceneCropParams.positionDegs(1) + 0.5*sceneCropParams.sizeDegs(1)*[-1 -1 1 1 -1];
        yy = sceneCropParams.positionDegs(2) + 0.5*sceneCropParams.sizeDegs(2)*[-1 1 1 -1 -1];
        plot(ax2, xx, yy, 'k-', 'LineWidth', 3);
        plot(ax2, xx, yy, 'g--', 'LineWidth', 1.5);
        
    end
    hold(ax2, 'off');

    colormap(ax2,hot(1024))
    colorbar(ax2)
    axis(ax2, 'xy');
    axis(ax2, 'image');
    set(ax2, 'XTick', xTicks, 'YTick', xTicks);
    xlabel(ax2, 'space, x (degs)');
    
    PublicationReadyPlotLib.applyFormat(ax2,ff);

    ax3 = axes('Position', [0.57 0.15 0.365 0.10]);
    luminanceRange = [0 200];
    h = histogram(ax3, luminanceMap(:), luminanceRange(1):2:luminanceRange(2));
    h.FaceColor = [0.2 0.8 0.2];
    h.FaceAlpha = 0.8;
    hold(ax3, 'on');
    plot(ax3, [0 200], [0 0], 'w-', 'Color', [0.8 0.8 0.8], 'LineWidth', 1.5);
    lumRange = prctile(luminanceMap(:), [1 50 99]);
    meanLuminance = mean(luminanceMap(:));

    yy = get(ax3, 'YLim');
    yy(2) = yy(2)*1.02;
    set(ax3, 'YLim', yy);
    scatter(ax3, lumRange(1), yy(2), 121, 'v', 'MarkerEdgeColor', [0 1 0], 'MarkerFaceColor', [0.4 0.4 0.4], 'MarkerFaceAlpha', 0.6, 'LineWidth', 1.0);
    scatter(ax3, lumRange(2), yy(2), 121, 'v', 'MarkerEdgeColor', [0 1 0], 'MarkerFaceColor', [0.4 1 0.4], 'MarkerFaceAlpha', 0.6, 'LineWidth', 1.0);
    scatter(ax3, lumRange(3), yy(2), 121, 'v', 'MarkerEdgeColor', [0 1 0], 'MarkerFaceColor', [0.4 0.4 0.4], 'MarkerFaceAlpha', 0.6, 'LineWidth', 1.0);
    scatter(ax3, meanLuminance, yy(2), 121, 'v', 'MarkerEdgeColor', [1 1 0], 'MarkerFaceColor', [0.4 0.4 0.4], 'MarkerFaceAlpha', 0.6, 'LineWidth', 1.0);
    
    hold(ax3, 'off');
    title(ax3, sprintf('luminance prctiles (1, 50, 99): %1.0f/%1.0f/%1.0f; (meanLum:%1.0f) cd/m2', lumRange(1), lumRange(2), lumRange(3), meanLuminance));
    set(ax3, 'XLim', luminanceRange, 'XTick', [], 'XTickLabel', {}, 'YTick', []);
    
    ff.box = 'on';
    PublicationReadyPlotLib.applyFormat(ax3,ff);

    theVisualizationPDFfilename = fullfile(exportVisualizationPDFdirectory, thePDFfileName);
            
    % Generate the path if we need to
    RGCMosaicConstructor.filepathFor.augmentedPathWithSubdirs(...
          exportVisualizationPDFrootDirectory, theVisualizationPDFfilename, ...
          'generateMissingSubDirs', true);
        
    thePDFfileName = fullfile(exportVisualizationPDFrootDirectory, theVisualizationPDFfilename);
    NicePlot.exportFigToPDF(thePDFfileName, hFig, 300, 'beVerbose');
end


