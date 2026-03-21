function analyzeCSFrun()
% UTTBSkip

    eccDegs = [7 0];
    theTemporalFrequencyHz = 5.0;

    coneMosaicNoise = 'none';
    mRGCmosaicNoise = 'random';
    inputSignalType = 'coneModulations';


    hFig = figure(1); clf;
    ff = MSreadyPlot.figureFormat('1x2 wide');
    theAxes = MSreadyPlot.generateAxes(hFig,ff);

    
    [spatialFreqs, theLuminanceCSFs, theLegends] = loadCSFDataForDifferentOrientations(eccDegs, [0.06 0.06 0.0], ...
        inputSignalType, theTemporalFrequencyHz, coneMosaicNoise, mRGCmosaicNoise);

    MSreadyPlot.renderCSF(theAxes{1,1}, spatialFreqs, theLuminanceCSFs, 'luminance (L+M)', theLegends, ff, ...
        'visualizedSpatialFrequencyRange', [0.1 70], ...
        'visualizedSensitivityRange', [0 800], ...
        'colors', [0.4 0.4 0.1; [0.4 0.4 0.1]*0.5], ...
        'markers', {'o', 'v'});


    [spatialFreqs, theRedGreenCSFs, theLegends] = loadCSFDataForDifferentOrientations(eccDegs, [0.06 -0.06 0.0], ...
        inputSignalType, theTemporalFrequencyHz, coneMosaicNoise, mRGCmosaicNoise);

    MSreadyPlot.renderCSF(theAxes{1,2}, spatialFreqs, theRedGreenCSFs, 'red-green (L-M)', theLegends, ff, ...
        'visualizedSpatialFrequencyRange', [0.1 70], ...
        'visualizedSensitivityRange', [0 800], ...
        'noYLabel', true, ...
        'noYTickLabel', true, ...
        'colors', [1.0 0.2 0.5; [1.0 0.2 0.5]*0.5], ...
        'markers', {'o', 'v'});

    NicePlot.exportFigToPDF('test.pdf', hFig, 300);

end

function analyzeCSFrunOLD()
    eccDegs = [7 0];
    
    coneMosaicNoise = 'random';
    mRGCmosaicNoise = 'random';
    inputSignal = 'coneModulations';

    analyzeLuminanceCSFvsRedGreenCSF(...
        eccDegs, inputSignal, ...
        coneMosaicNoise, mRGCmosaicNoise);

    %vMembraneSigma = 0.015;
    %coneContrasts = [0.06 0.06 0.00];
    %inputSignal = 'coneModulations';
    %analyzeNoiseComponents(eccDegs, orientationDegs, coneContrasts, ...
    %    inputSignal, vMembraneSigma);
end

function analyzeNoiseComponents(eccDegs, orientationDegs, coneContrasts, ...
        inputSignal, vMembraneSigma)
    
    [spatialFreqs, theCSFs] = loadCSFDataForDifferentNoiseComponents(...
        eccDegs,coneContrasts, orientationDegs, ...
        inputSignal, vMembraneSigma);

    hFig = figure(1); clf;
    ff = MSreadyPlot.figureFormat('1x2 tall');
    theAxes = MSreadyPlot.generateAxes(hFig,ff);

    
    theLegends{1} = 'cone noise only';
    theLegends{2} = 'mRGC noise only';
    theLegends{3} = 'cone + mRGC noise only';

    MSreadyPlot.renderCSF(theAxes{1,1}, spatialFreqs, theCSFs, 'luminance (L+M)', theLegends, ff, ...
        'visualizedSpatialFrequencyRange', [0.1 30], ...
        'visualizedSensitivityRange', [0 800]);

     NicePlot.exportFigToPDF('test.pdf', hFig, 300);
end

function analyzeLuminanceCSFvsRedGreenCSF(eccDegs, inputSignal, coneMosaicNoise, mRGCmosaicNoise)
    
    coneContrasts = [0.06 0.06 0.00];
    [spatialFreqs, theLuminanceCSFs] = loadCSFDataForDifferentOrientations(eccDegs, coneContrasts, ...
        inputSignal, coneMosaicNoise, mRGCmosaicNoise);

    hFig = figure(1); clf;
    ff = MSreadyPlot.figureFormat('1x2 wide');
    theAxes = MSreadyPlot.generateAxes(hFig,ff);

    
    theLegends{1} = 'orientation: 0 degs';
    theLegends{2} = 'orientation: 90 degs';

    MSreadyPlot.renderCSF(theAxes{1,1}, spatialFreqs, theLuminanceCSFs, 'luminance (L+M)', theLegends, ff, ...
        'visualizedSpatialFrequencyRange', [0.1 70], ...
        'visualizedSensitivityRange', [0 800], ...
        'colors', [0.4 0.4 0.1; [0.4 0.4 0.1]*0.5], ...
        'markers', {'o', 'v'});


    coneContrasts = [0.06 -0.06 0.00];
    [spatialFreqs, theRedGreenCSFs] = loadCSFDataForDifferentOrientations(eccDegs, coneContrasts, ...
        inputSignal, coneMosaicNoise, mRGCmosaicNoise);

    MSreadyPlot.renderCSF(theAxes{1,2}, spatialFreqs, theRedGreenCSFs, 'red-green (L-M)', theLegends, ff, ...
        'visualizedSpatialFrequencyRange', [0.1 70], ...
        'visualizedSensitivityRange', [0 800], ...
        'noYLabel', true, ...
        'noYTickLabel', true, ...
        'colors', [1.0 0.2 0.5; [1.0 0.2 0.5]*0.5], ...
        'markers', {'o', 'v'});

    NicePlot.exportFigToPDF('test.pdf', hFig, 300);

end

function [spatialFreqs, theCSFs, ...
    contrastsTested, Pcorrect, contrastsTestedFit, PcorrectFit] = loadCSFDataForDifferentNoiseComponents(...
    eccDegs,coneContrasts, orientationDegs, inputSignal, vMembraneSigma)

    % Only cone mosaic noise
    coneMosaicNoise = 'random';
    mRGCmosaicNoise = 'none';

    matFileName = sprintf('mRGCMosaicSpatialCSF_eccDegs_%2.1f_%2.1f_coneContrasts_%2.2f_%2.2f_%2.2f_OrientationDegs_%d_coneMosaicNoise_%s_mRGCMosaicNoise_%s.mat', ...
        eccDegs(1), eccDegs(2), coneContrasts(1), coneContrasts(2), coneContrasts(3), ...
        orientationDegs, coneMosaicNoise, mRGCmosaicNoise);
   

    load(matFileName, 'spatialFreqs', 'threshold', 'chromaDir', ...
        'theStimulusFOVdegs', 'theStimulusSpatialEnvelopeRadiusDegs', 'theStimulusScenes',...
        'theNeuralComputePipelineFunction', 'neuralResponsePipelineParams', ...
        'classifierChoice', 'classifierParams', 'thresholdParams', ...
        'theComputedQuestObjects', 'thePsychometricFunctions', 'theFittedPsychometricParams');

    % Extract psychometric data for this noise condition
    [contrastsTested, Pcorrect, contrastsTestedFit, PcorrectFit] = ...
        extractPsychometricCurves(theFittedPsychometricParams, theComputedQuestObjects);

    % Plot psychometric data for this noise condition
    hFig = figure(20); clf;
    set(hFig, 'Name', sprintf('coneMosaicNoise: %s, mRGCmosaicNoise: %s', coneMosaicNoise, mRGCmosaicNoise));
    for iSF = 1:numel(contrastsTested)
        subplot(4,4,iSF)
        theContrastsTested = 10.^contrastsTested{iSF};
        theContrastsFit = 10.^contrastsTestedFit{iSF};

        contrastRange = [min(theContrastsFit ) max(theContrastsFit )];
        thePerfomance = Pcorrect{iSF};
        [~,idx] = sort(theContrastsTested, 'ascend');
        theContrastsTested = theContrastsTested(idx);
        thePerfomance = thePerfomance(idx);

        plot(theContrastsFit, PcorrectFit{iSF}, 'r-', 'LineWidth', 1.5);
        hold 'on'
        plot(theContrastsTested, thePerfomance, 'ko', ...
            'LineWidth', 1.0, 'MarkerSize', 12, 'MarkerFaceColor', [1 0.8 0.5], 'MarkerEdgeColor', [0.6 0.4 0.0]);
        grid 'on'
        set(gca, 'FontSize', 15, 'XScale', 'log', 'XLim', contrastRange, 'XTick', [0.01 0.03 0.1 0.3 1], 'YLim', [0.5 1], 'YTick', 0.5:0.1:1.0);
        title(sprintf('%2.2f c/deg', spatialFreqs(iSF)));
        drawnow;
    end


    % CSF for this noise condition
    threshold = threshold * norm(chromaDir);
    theCSFs(1,:) = 1./threshold;


    % Only mRGC mosaic noise
    coneMosaicNoise = 'none';
    mRGCmosaicNoise = 'random';

    matFileName = sprintf('mRGCMosaicSpatialCSF_eccDegs_%2.1f_%2.1f_coneContrasts_%2.2f_%2.2f_%2.2f_OrientationDegs_%d_inputSignal_%s_coneMosaicNoise_%s_mRGCMosaicNoise_%s_vMembraneSigma_%1.3f.mat', ...
        eccDegs(1), eccDegs(2), coneContrasts(1), coneContrasts(2), coneContrasts(3), ...
        orientationDegs, inputSignal, coneMosaicNoise, mRGCmosaicNoise, vMembraneSigma);

%     matFileName = sprintf('mRGCMosaicSpatialCSF_eccDegs_%2.1f_%2.1f_coneContrasts_%2.2f_%2.2f_%2.2f_OrientationDegs_%d_coneMosaicNoise_%s_mRGCMosaicNoise_%s.mat', ...
%         eccDegs(1), eccDegs(2), coneContrasts(1), coneContrasts(2), coneContrasts(3), ...
%         orientationDegs, coneMosaicNoise, mRGCmosaicNoise);
   
    load(matFileName, 'spatialFreqs', 'threshold', 'chromaDir', ...
    'theStimulusFOVdegs', 'theStimulusSpatialEnvelopeRadiusDegs', 'theStimulusScenes',...
    'theNeuralComputePipelineFunction', 'neuralResponsePipelineParams', ...
    'classifierChoice', 'classifierParams', 'thresholdParams', ...
    'theComputedQuestObjects', 'thePsychometricFunctions', 'theFittedPsychometricParams');

    
    threshold = threshold * norm(chromaDir);
    theCSFs(2,:) = 1./threshold;

    % Both cone mosaic + mRGC mosaic noise
    coneMosaicNoise = 'random';
    mRGCmosaicNoise = 'random';

    matFileName = sprintf('mRGCMosaicSpatialCSF_eccDegs_%2.1f_%2.1f_coneContrasts_%2.2f_%2.2f_%2.2f_OrientationDegs_%d_inputSignal_%s_coneMosaicNoise_%s_mRGCMosaicNoise_%s_vMembraneSigma_%1.3f.mat', ...
        eccDegs(1), eccDegs(2), coneContrasts(1), coneContrasts(2), coneContrasts(3), ...
        orientationDegs, inputSignal, coneMosaicNoise, mRGCmosaicNoise, vMembraneSigma);

%     matFileName = sprintf('mRGCMosaicSpatialCSF_eccDegs_%2.1f_%2.1f_coneContrasts_%2.2f_%2.2f_%2.2f_OrientationDegs_%d_coneMosaicNoise_%s_mRGCMosaicNoise_%s.mat', ...
%         eccDegs(1), eccDegs(2), coneContrasts(1), coneContrasts(2), coneContrasts(3), ...
%         orientationDegs, coneMosaicNoise, mRGCmosaicNoise);
%    

    load(matFileName, 'spatialFreqs', 'threshold', 'chromaDir', ...
    'theStimulusFOVdegs', 'theStimulusSpatialEnvelopeRadiusDegs', 'theStimulusScenes',...
    'theNeuralComputePipelineFunction', 'neuralResponsePipelineParams', ...
    'classifierChoice', 'classifierParams', 'thresholdParams', ...
    'theComputedQuestObjects', 'thePsychometricFunctions', 'theFittedPsychometricParams');

    
    threshold = threshold * norm(chromaDir);
    theCSFs(3,:) = 1./threshold;

end

function [spatialFreqs, theCSFs, theLegends] = loadCSFDataForDifferentOrientations(eccDegs, coneContrasts, ...
    inputSignalType, temporalFrequencyHz, coneMosaicNoise, mRGCmosaicNoise)

    % Load the 0 deg orientation data
    orientationDegs = 0;
    theLegends{1} = 'orientation: 0 degs';

    matFileName = sprintf('mRGCMosaicSpatialCSF_eccDegs_%2.1f_%2.1f_coneContrasts_%2.2f_%2.2f_%2.2f_OrientationDegs_%d_temporalFrequencyHz_%2.1f_inputSignal_%s_coneMosaicNoise_%s_mRGCMosaicNoise_%s.mat', ...
        eccDegs(1), eccDegs(2), ...
        coneContrasts(1), coneContrasts(2), coneContrasts(3), ...
        orientationDegs, temporalFrequencyHz, inputSignalType, ...
        coneMosaicNoise, mRGCmosaicNoise);


    load(matFileName, 'spatialFreqs', 'threshold', 'chromaDir');


    threshold = threshold * norm(chromaDir);
    theCSFs(1,:) = 1./threshold;

    % Load the 90 deg orientation data
    orientationDegs = 90;
    theLegends{2} = 'orientation: 90 degs';

    matFileName = sprintf('mRGCMosaicSpatialCSF_eccDegs_%2.1f_%2.1f_coneContrasts_%2.2f_%2.2f_%2.2f_OrientationDegs_%d_temporalFrequencyHz_%2.1f_inputSignal_%s_coneMosaicNoise_%s_mRGCMosaicNoise_%s.mat', ...
        eccDegs(1), eccDegs(2), ...
        coneContrasts(1), coneContrasts(2), coneContrasts(3), ...
        orientationDegs, temporalFrequencyHz, inputSignalType, ...
        coneMosaicNoise, mRGCmosaicNoise);


    load(matFileName, 'spatialFreqs', 'threshold', 'chromaDir');

    threshold = threshold * norm(chromaDir);
    theCSFs(2,:) = 1./threshold;
end

function [contrastsTested, Pcorrect, contrastsTestedFit, PcorrectFit] = ...
    extractPsychometricCurves(theFittedPsychometricParams, theComputedQuestObjects)
    
    % Extract the measured psychometric data and the fitted Weibul functions
    nParamValues = numel(theFittedPsychometricParams);

    contrastsTested = cell(1,nParamValues);
    contrastsTestedFit = cell(1,nParamValues);
    Pcorrect = cell(1,nParamValues);
    PcorrectFit = cell(1,nParamValues);

    for iParamValueIndex = 1:nParamValues
        theFittedPsychometricFunctionParams = theFittedPsychometricParams{iParamValueIndex};
        theQuestObj = theComputedQuestObjects{iParamValueIndex};

        [~,~,dataOut] = theQuestObj.thresholdMLE(...
            'showPlot', ~true,  ...
            'newFigure' , ~true, ...
            'para', theFittedPsychometricFunctionParams, ...
            'returnData', true);

        contrastsTested{iParamValueIndex} = dataOut.examinedContrasts;
        Pcorrect{iParamValueIndex} = dataOut.pCorrect;

        contrastsTestedFit{iParamValueIndex} = dataOut.examinedContrastsFit;
        PcorrectFit{iParamValueIndex} = dataOut.pCorrectFit;
    end
end
