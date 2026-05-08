%
% demoEngine.scene.classicCRTstimulus
%

function [theStimulusFrameSceneSequence, theNullStimulusScene, theStimulusFrameSceneSequenceTemporalSupportSeconds] = ...
    classicCRTstimulus(gratingParams, theMRGCmosaic, theOptics, visualizeStimulusSequence)


    fprintf('Generating stimulus scene sequence\n');

    if (gratingParams.coneFundamentalsOptimizedForStimPosition)
        % Compute custom cone fundamentals
        maxConesNumForAveraging = 3;
        customConeFundamentals = visualStimulusGenerator.coneFundamentalsForPositionWithinConeMosaic(...
            theMRGCmosaic.inputConeMosaic, theOptics, theMRGCmosaic.eccentricityDegs, gratingParams.sizeDegs, maxConesNumForAveraging);
    else
        customConeFundamentals = [];

    end


    % Determine the stimulus pixel resolution to be a fraction of the minimum cone aperture or cone spacing in the mosaic
    % here, half of the cone spacing
    theMetric = 'cone aperture';  % choose from {'cone aperture' or cone spacing'}
    opticsIsDiffractionLimited = false;
    if (opticsIsDiffractionLimited)
        theFraction = 0.1;
    else
        theFraction = 0.25;
    end
    targetRGCindices =  1:theMRGCmosaic.rgcsNum;
    stimulusResolutionDegs = RGCMosaicConstructor.helper.simulateExperiment.stimulusResolutionFromConeApertureOrConeSpacing(...
                theMRGCmosaic, targetRGCindices, theFraction, theMetric);


    % Generate presentation display
    viewingDistanceMeters = 4;
    
    stimParams = gratingParams;
    stimParams.resolutionDegs = stimulusResolutionDegs;

    % Generate presentation display
    [thePresentationDisplay, ...
     stimParams.backgroundChromaticity, ...
     stimParams.backgroundLuminanceCdM2] = visualStimulusGenerator.presentationDisplay(...
            theMRGCmosaic.inputConeMosaic.wave, ...
            stimulusResolutionDegs, ...
            viewingDistanceMeters, ...
            'displayType', 'CRT-Sony-HorwitzLab', ...
            'bitDepth', 20, ...
            'meanLuminanceCdPerM2', gratingParams.backgroundLuminanceCdM2, ...
            'luminanceHeadroom', 0.5, ...
            'adjustBackgroundChromaticityToEqualizeLandMconeExcitations', true, ...
            'backgroundChromaticity', gratingParams.backgroundChromaticity, ...
            'backgroundLuminanceCdM2', gratingParams.backgroundLuminanceCdM2, ...
            'coneFundamentalsToEmploy',customConeFundamentals);

     % Generate the spatial modulation patterns for all spatial phases of the drifting grating
     [theDriftingGratingSpatialModulationPatterns, ...
      spatialSupportDegs, spatialPhasesDegs, ...
      theStimulusFrameSceneSequenceTemporalSupportSeconds, temporalRamp] = visualStimulusGenerator.driftingGratingModulationPatterns(stimParams);


     % Generate scenes for the different frames of the drifting grating and for the null stimulus
     [theStimulusFrameSceneSequence, theNullStimulusScene] = visualStimulusGenerator.stimulusFramesScenes(...
        thePresentationDisplay, stimParams, theDriftingGratingSpatialModulationPatterns, ...
        'frameIndexToCompute', [], ... % [] field indicates that all stimulus frame scenes must be computed
        'validateScenes', ~true);

     if (visualizeStimulusSequence)
        hFig = figure(211); clf;
  		set(hFig,'Position', [10 10 1800 900], 'Color', [1 1 1]);
        domainVisualizationLimits = [];
        domainVisualizationTicks = [];
        ax = subplot(1,1,1);
        for iFrame = 1:numel(theStimulusFrameSceneSequence)
            theFrameScene = theStimulusFrameSceneSequence{iFrame};
            RGCMosaicConstructor.visualize.sceneOrOpticalImage(theFrameScene, ...
	    			thePresentationDisplay, ax, ...
	    			domainVisualizationLimits, ...
	    			domainVisualizationTicks, ...
	    			'plotTitle', sprintf('frame (%d/%d), time: %2.0f mseconds', iFrame, numel(theStimulusFrameSceneSequence), theStimulusFrameSceneSequenceTemporalSupportSeconds(iFrame)*1e3));
            drawnow
        end
     end

end
