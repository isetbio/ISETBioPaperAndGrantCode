function analyzeChromaticThresholdRuns()

    eccDegs = [7 0];

    theStimulusSpatialFrequencyCPD = 1.0;
    theStimulusOrientationDegs = 0;
    theInputSignalType = 'cone_modulations';
    if (strcmp(theInputSignalType, 'cone_excitations'))
        vMembraneGaussianNoiseSigma = 1e3 * 0.1;
    else
        vMembraneGaussianNoiseSigma = 0.015;
    end

    [theTresholdConeContrasts, theLegends] = loadChromaticThresholdDataForDifferentNoiseComponents(...
        eccDegs, theStimulusOrientationDegs, theStimulusSpatialFrequencyCPD, ...
        theInputSignalType, vMembraneGaussianNoiseSigma);


   
    hFig = figure(1); clf;
    set(hFig, 'Name', sprintf('input signal type: %s', theInputSignalType));
    thresholdConeContrasts = 100*theTresholdConeContrasts{1};
    p1 = plot(thresholdConeContrasts(1,:), thresholdConeContrasts(2,:), ...
        'ro-', 'MarkerFaceColor',[1 0.5 0.5], 'MarkerSize',12, 'LineWidth', 1.5);
    hold on

    thresholdConeContrasts = 100*theTresholdConeContrasts{2};
    p2 = plot(thresholdConeContrasts(1,:), thresholdConeContrasts(2,:), ...
        'bo-', 'MarkerFaceColor',[0.5 0.8 1.0], 'MarkerSize',12, 'LineWidth', 1.5);

    maxConeContast = 0.01*100;
    plot(maxConeContast*[-1 1], [0 0], 'k-');
    plot([0 0], maxConeContast*[-1 1],'k-');

    legend([p1 p2], theLegends);
    
    axis 'square'
    box on;
    grid on;
    set(gca, 'XLim', maxConeContast*[-1 1], 'YLim', maxConeContast*[-1 1]);
    set(gca, 'XTick', 100*(-1:0.005:1), 'YTick', 100*(-1:0.005:1), 'FontSize', 15);
    xlabel('l-cone contrast')
    ylabel('m-cone contrast')

end

function [theTresholdConeContrasts, theLegends] = loadChromaticThresholdDataForDifferentNoiseComponents(...
    eccDegs, theStimulusOrientationDegs, theStimulusSpatialFrequencyCPD, ...
    theInputSignalType, vMembraneGaussianNoiseSigma)

    % First noise condition
    coneMosaicNoise = 'random';
    mRGCmosaicNoise = 'none';

    matFileName = sprintf('mRGCMosaicIsothresholdContour_eccDegs_%2.1f_%2.1f_SpatialFrequencyCPD_%2.1f_OrientationDegs_%d_inputSignal_%s_coneMosaicNoise_%s_mRGCMosaicNoise_%s_vMembraneSigma_%2.3f.mat', ...
        eccDegs(1), eccDegs(2), ...
        theStimulusSpatialFrequencyCPD, ...
        theStimulusOrientationDegs, ...
        regexprep(theInputSignalType, '_+(\w)', '${upper($1)}'), ...
        coneMosaicNoise, ...
        mRGCmosaicNoise, ...
        vMembraneGaussianNoiseSigma);


    % Load data
    load(matFileName, 'theChromaticDirections', 'threshold', ...
        'theStimulusSpatialFrequencyCPD', 'theStimulusSpatialPhaseDegs', 'theStimulusOrientationDegs', ...
        'theStimulusFOVdegs', 'theStimulusSpatialEnvelopeRadiusDegs', 'theStimulusScenes',...
        'theNeuralComputePipelineFunction', 'neuralResponsePipelineParams', ...
        'classifierChoice', 'classifierParams', 'thresholdParams', ...
        'theComputedQuestObjects', 'thePsychometricFunctions', 'theFittedPsychometricParams');

    % Extract psychometric data for this noise condition
    [contrastsTested, Pcorrect, contrastsTestedFit, PcorrectFit] = ...
        extractPsychometricCurves(theFittedPsychometricParams, theComputedQuestObjects);

    chromaticDirectionsNum = size(theChromaticDirections,2);
    
    % Plot psychometric data for this noise condition
    hFig = figure(20); clf;
    set(hFig, 'Name', sprintf('coneMosaicNoise: %s, mRGCmosaicNoise: %s', coneMosaicNoise, mRGCmosaicNoise));
    for iChromaDir = 1:chromaticDirectionsNum
        subplot(4,4,iChromaDir)
        theContrastsTested = 10.^contrastsTested{iChromaDir};
        theContrastsFit = 10.^contrastsTestedFit{iChromaDir};

        contrastRange = [min(theContrastsFit ) max(theContrastsFit )];
        thePerfomance = Pcorrect{iChromaDir};
        [~,idx] = sort(theContrastsTested, 'ascend');
        theContrastsTested = theContrastsTested(idx);
        thePerfomance = thePerfomance(idx);

        plot(theContrastsFit, PcorrectFit{iChromaDir}, 'r-', 'LineWidth', 1.5);
        hold 'on'
        plot(theContrastsTested, thePerfomance, 'ko', ...
            'LineWidth', 1.0, 'MarkerSize', 12, 'MarkerFaceColor', [1 0.8 0.5], 'MarkerEdgeColor', [0.6 0.4 0.0]);
        grid 'on'
        set(gca, 'FontSize', 15, 'XScale', 'log', 'XLim', contrastRange, 'XTick', [0.01 0.03 0.1 0.3 1], 'YLim', [0.5 1], 'YTick', 0.5:0.1:1.0);
        title(sprintf('c_LMS = <%2.2f, %2.2f %2.2f>', theChromaticDirections(:,iChromaDir)));
        drawnow;
    end

    % Threshold cone contrasts
    thresholdsConeContrasts = [...
        threshold.*theChromaticDirections(1,:); ...
        threshold.*theChromaticDirections(2,:); ...
        threshold.*theChromaticDirections(3,:)];

    % Repeat first point
    thresholdsConeContrasts(:,end+1) = thresholdsConeContrasts(:,1);

    theTresholdConeContrasts{1} = thresholdsConeContrasts;
    theLegends{1} = 'cone mosaic noise only';


    % Second noise condition
    coneMosaicNoise = 'none';
    mRGCmosaicNoise = 'random';

    matFileName = sprintf('mRGCMosaicIsothresholdContour_eccDegs_%2.1f_%2.1f_SpatialFrequencyCPD_%2.1f_OrientationDegs_%d_inputSignal_%s_coneMosaicNoise_%s_mRGCMosaicNoise_%s_vMembraneSigma_%2.3f.mat', ...
        eccDegs(1), eccDegs(2), ...
        theStimulusSpatialFrequencyCPD, ...
        theStimulusOrientationDegs, ...
        regexprep(theInputSignalType, '_+(\w)', '${upper($1)}'), ...
        coneMosaicNoise, ...
        mRGCmosaicNoise, ...
        vMembraneGaussianNoiseSigma);

%     matFileName = sprintf('mRGCMosaicIsothresholdContour_eccDegs_%2.1f_%2.1f_SpatialFrequencyCPD_%2.1f_OrientationDegs_%d_coneMosaicNoise_%s_mRGCMosaicNoise_%s.mat', ...
%         eccDegs(1), eccDegs(2), ...
%         theStimulusSpatialFrequencyCPD, ...
%         theStimulusOrientationDegs, ...
%         coneMosaicNoise, ...
%         mRGCmosaicNoise);

    % Load data
    load(matFileName, 'theChromaticDirections', 'threshold', ...
        'theStimulusSpatialFrequencyCPD', 'theStimulusSpatialPhaseDegs', 'theStimulusOrientationDegs', ...
        'theStimulusFOVdegs', 'theStimulusSpatialEnvelopeRadiusDegs', 'theStimulusScenes',...
        'theNeuralComputePipelineFunction', 'neuralResponsePipelineParams', ...
        'classifierChoice', 'classifierParams', 'thresholdParams', ...
        'theComputedQuestObjects', 'thePsychometricFunctions', 'theFittedPsychometricParams');

    % Extract psychometric data for this noise condition
    [contrastsTested, Pcorrect, contrastsTestedFit, PcorrectFit] = ...
        extractPsychometricCurves(theFittedPsychometricParams, theComputedQuestObjects);


    % Plot psychometric data for this noise condition
    hFig = figure(21); clf;
    set(hFig, 'Name', sprintf('coneMosaicNoise: %s, mRGCmosaicNoise: %s', coneMosaicNoise, mRGCmosaicNoise));
    for iChromaDir = 1:chromaticDirectionsNum
        subplot(4,4,iChromaDir)
        theContrastsTested = 10.^contrastsTested{iChromaDir};
        theContrastsFit = 10.^contrastsTestedFit{iChromaDir};

        contrastRange = [min(theContrastsFit ) max(theContrastsFit )];
        thePerfomance = Pcorrect{iChromaDir};
        [~,idx] = sort(theContrastsTested, 'ascend');
        theContrastsTested = theContrastsTested(idx);
        thePerfomance = thePerfomance(idx);

        plot(theContrastsFit, PcorrectFit{iChromaDir}, 'r-', 'LineWidth', 1.5);
        hold 'on'
        plot(theContrastsTested, thePerfomance, 'ko', ...
            'LineWidth', 1.0, 'MarkerSize', 12, 'MarkerFaceColor', [1 0.8 0.5], 'MarkerEdgeColor', [0.6 0.4 0.0]);
        grid 'on'
        set(gca, 'FontSize', 15, 'XScale', 'log', 'XLim', contrastRange, 'XTick', [0.01 0.03 0.1 0.3 1], 'YLim', [0.5 1], 'YTick', 0.5:0.1:1.0);
        title(sprintf('c_LMS = <%2.2f, %2.2f %2.2f>', theChromaticDirections(:,iChromaDir)));
        drawnow;
    end


    % Threshold cone contrasts
    thresholdsConeContrasts = [...
        threshold.*theChromaticDirections(1,:); ...
        threshold.*theChromaticDirections(2,:); ...
        threshold.*theChromaticDirections(3,:)];

    % Repeat first point
    thresholdsConeContrasts(:,end+1) = thresholdsConeContrasts(:,1);

    theTresholdConeContrasts{numel(theTresholdConeContrasts)+1} = thresholdsConeContrasts;
    theLegends{numel(theLegends)+1} = 'mRGCmosaic noise only';


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

