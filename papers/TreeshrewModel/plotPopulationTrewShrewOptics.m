function plotPopulationTrewShrewOptics()

    % Retrieve the PSF and the MTF slices for a target wavelength
    theTargetWavelength = 550;

    % Select a tree-shrew subject
    for iTreeShrewSubject = 1:11

        fprintf('Generating tree shrew optics for subject: %d\n', iTreeShrewSubject);
        % Generate optics for this subject
        theOI = oiTreeShrewCreate( ...
            'opticsType', 'wvf', ...
            'pupilDiameterMM', 4.0, ...
            'whichShrew', iTreeShrewSubject, ...
            'name', 'wvf-based optics');

        [~, theMTFdataStruct] = ...
            retrievePSFandMTF(theOI, theTargetWavelength);

        % Get the slice through the center
        [~,idx] = max(theMTFdataStruct.data(:));
        [peakRow, peakCol] = ind2sub(size(theMTFdataStruct.data), idx);
        theSubjectMTFs(iTreeShrewSubject,:) = squeeze(theMTFdataStruct.data(peakRow,:));

    end % iTreeShrewSubject

    % Plot the MTFs
    generateMTFfigure(theMTFdataStruct.supportCyclesPerDeg, theSubjectMTFs, 'populationMTFs.pdf', '');

end

function generateMTFfigure(sfSupportCPF, theSubjectMTFs, pdfFileName, plotTitle)

    visualizedSFcyclesPerDegree = 40;

    ff = PublicationReadyPlotLib.figureComponents('1x1 double width figure');
	hFig = figure(1); clf;
    theAxes = PublicationReadyPlotLib.generatePanelAxes(hFig,ff);
    ax = theAxes{1,1};

    yyaxis(ax, 'left');

    % Plot the individual treeshre MTFs
    for iSubject = 1:size(theSubjectMTFs,1)
        p1 = plot(ax, sfSupportCPF, theSubjectMTFs(iSubject,:), 'k-', ...
            'Color', 0.5*[0.7 0.7 0.5], 'LineWidth', 2);
        hold(ax, 'on')
    end

    % Plot the mean across all treeshrew subjects, MTFs
    meanMTF = mean(theSubjectMTFs,1);
    plot(ax, sfSupportCPF, meanMTF, 'k-', 'LineWidth', 4);
    p2 = plot(ax, sfSupportCPF, meanMTF, 'y-', 'LineWidth', 2);
    
    
    
    % Legend customization
    ff.legendBox = 'on';
    ff.legendBackgroundAlpha = 0.5;
    ff.legendBackgroundColor = [0.6 0.6 0.6];
    ff.legendEdgeColor = [0.2 0.2 0.2];
    ff.legendLineWidth = 1.0;

    xlabel(ax, 'spatial frequency (c/deg)');
    ylabel(ax, 'treeshrew MTFs (ISETBio)');
    set(ax, 'XLim', [0 visualizedSFcyclesPerDegree], 'YLim', [0 1]);
    set(ax, 'XTick', 0:5:100, 'yTick', 0:0.2:1, 'Color', [0 0 0]);
    grid(ax, 'on')

    % Load the CSFdata of Saidak
    csfData = mtfTreeShrewFromPaper('SaidakEtAl_2019');
    csfData = csfData{1};

    % Now lets add on the right the CSF data of Saidak et al.
    yyaxis(ax, 'right');
    p3 = plot(csfData.sf, csfData.csf, 'bs--', ...
        'LineWidth', 1.5, ...
        'MarkerFaceColor', 'c', 'MarkerEdgeColor', 'b', 'MarkerSize', 14);
   
    legend(ax, [p1 p2 p3], {'individual MTFs', 'population MTF', 'CSF'});

    ylabel(ax, sprintf('treeshrew CSF\n(measured by SaidakEtAl)'));
    
    title(ax, plotTitle);
    set(ax, 'XLim', [0 visualizedSFcyclesPerDegree], 'YLim', [0 120]);
    set(ax, 'XTick', 0:5:100, 'yTick', 0:20:200, 'Color', [0.5 0.8 1]);
    grid(ax, 'on')


    PublicationReadyPlotLib.applyFormat(ax,ff);
    % PublicationReadyPlotLib.offsetAxes(ax, ff, xLims, yLims); 

    theFiguresDir = fullfile(ISETBioPaperAndGrantCodeRootDirectory, 'local', mfilename);
    if (~exist(theFiguresDir,'dir'))
        mkdir(theFiguresDir);
    end

    thePDFfileName = fullfile(theFiguresDir, pdfFileName);
    NicePlot.exportFigToPDF(thePDFfileName,hFig,  300);
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

