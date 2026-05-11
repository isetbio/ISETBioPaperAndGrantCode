%
% demoEngine.visualize.simulationAnimationsAndStaticRenderings
%
function simulationAnimationsAndStaticRenderings(theDataFileName, ...
    visualizeResponsesOfInputConesToRGCindex, ...
    theResponseNormalizingFactors, ...
    theResponseBiasForPhotocurrentInnerRetinalFilterCascade, ...
    theResponseDelayForPhotocurrentInnerRetinalFilterCascade, ...
    maxTimeToVisualize, traceViewWindowSeconds, ...
    overlaySceneInsetOnTopOfRetinalImageVideo, ...
    figureFormatForStaticResponseTimeSeries, ...
    exportVisualizationRootDirectory, exportVisualizationPDFdirectory, ...
    exportVisualizationVideoDirectory, exportDataDirectory)
    
    % Load the data
    theDataFileName = fullfile(exportVisualizationRootDirectory, exportDataDirectory, theDataFileName);

    % Check to see if we have theMRGCmosaicResponseDictionary
    S = whos('-file', theDataFileName);
    foundIt = false;
    for iVar = 1:length(S)
        if (strcmp(S(iVar).name, 'theMRGCmosaicResponseDictionary'))
            foundIt = true;
        end
    end

    assert(foundIt, ...
        sprintf('No MRGCmosaic responses dictionary found in %s.\nHave you run the simulation with ''recomputeMRGCmosaicSimulation'' set to true?\n', theDataFileName));

    load(theDataFileName, ...
        'theMRGCmosaic', 'sceneCropParams', ...
        'theConeMosaicSpatioTemporalModulationsResponse', ...
        'theConeExcitationsResponseTemporalSupportSeconds', ...
        'theScene', 'theRetinalImage', 'theFixationalEMObj', ...
        'theConeMosaicSpatioTemporalPhotocurrentResponses', ...
        'thePhotocurrentResponseTemporalSupportSeconds', ...
        'theMRGCmosaicResponseDictionary');
    
    
    if (~overlaySceneInsetOnTopOfRetinalImageVideo)
        theScene = [];
    end

    if (~isempty(visualizeResponsesOfInputConesToRGCindex))
        % Compute photocurrents for cone indices that provide input to a single mRGC
        targetMRGCindex = visualizeResponsesOfInputConesToRGCindex(1);

        surroundConnectivityVector = full(squeeze(theMRGCmosaic.rgcRFsurroundConeConnectivityMatrix(:, targetMRGCindex)));
        surroundConeIndices = find(surroundConnectivityVector > theMRGCmosaic.minSurroundWeightForInclusionInComputing);
        coneIndicesToVisualize = surroundConeIndices;
    else
        coneIndicesToVisualize = 1:theMRGCmosaic.inputConeMosaic.conesNum;
    end


    % Cone modulations + BK filter
    c = brewermap(6, 'blues');
    theResponseColors(1,:) = c(6,:);

    % Photocurrents + derived inner retina filter
    c = brewermap(6, 'reds');
    theResponseColors(2,:) = c(6,:);

    % Photocurrents
    c = brewermap(6, 'oranges');
    theResponseColors(3,:) = c(6,:);


    targetString = 'data/';
    idx = strfind(theDataFileName, targetString);
    sourceName = strrep(theDataFileName(idx+numel(targetString):numel(theDataFileName)), '.mat', '');
    thePDFfileName = sprintf('mRGCresponseTraces_%s.pdf', sourceName);
    theMovieFileName = sprintf('photoCurrentsMovie_%s', sourceName);

    theVisualizedResponseDataSetLabels{1} = 'cone modulations + BK filters';
    theResponseBias(1) = 0;
    theResponseDelay(1) = 0;

    theVisualizedResponseDataSetLabels{2} = 'photocurrents + inner retina filter cascade';
    theResponseBias(2) = theResponseBiasForPhotocurrentInnerRetinalFilterCascade;
    theResponseDelay(2) = theResponseDelayForPhotocurrentInnerRetinalFilterCascade;



    % Generate static PDF of the response of the 2 models
    demoEngine.visualize.responseTimeSeriesForSingleMRGC(targetMRGCindex, ...
        theMRGCmosaicResponseDictionary, ...
        theVisualizedResponseDataSetLabels, theResponseColors, ...
        theResponseNormalizingFactors, theResponseBias, theResponseDelay, maxTimeToVisualize, ...
        figureFormatForStaticResponseTimeSeries, ...
        exportVisualizationRootDirectory, exportVisualizationPDFdirectory, ...
        thePDFfileName);

    pause


    % Photocurrents only
    theResponseBias(3) = 0;
    theResponseDelay(3) = 0;
    theVisualizedResponseDataSetLabels{3} = 'photocurrents only';

    % Render video of everything
    demoEngine.visualize.simulationTimeCourse(...
        theMRGCmosaicResponseDictionary, targetMRGCindex, ...
        theMRGCmosaic.inputConeMosaic, ...
        theConeMosaicSpatioTemporalPhotocurrentResponses, ...
        thePhotocurrentResponseTemporalSupportSeconds, ...
        theVisualizedResponseDataSetLabels, theResponseColors, ...
        theResponseNormalizingFactors, theResponseBias, theResponseDelay, ...
        maxTimeToVisualize, traceViewWindowSeconds, ...
        theScene, theRetinalImage, theFixationalEMObj, ...
        exportVisualizationRootDirectory, ...
        exportVisualizationVideoDirectory, ...
        theMovieFileName);

end


