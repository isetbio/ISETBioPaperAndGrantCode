%
% demoEngine.compute.inputConeMosaicActivation
%
function inputConeMosaicActivation(coneMosaicSpecies, opticsSubjectName, rgcMosaicName, targetVisualSTFdescriptor, ...
        opticsForTTFresponses, opticsWavefrontSpatialSamples, cropParams, sceneCropParams, ...
        photocurrentParams, eyeMovementParams, HDRdatabaseYear, HDRimageName, ......
        visualizeMRGCmosaic, ...
        exportVisualizationRootDirectory, exportVisualizationPDFdirectory, exportVisualizationVideoDirectory, ...
        exportDataDirectory, theDataFileName)


    % Load the mRGCmosaic specified by the passed parameters:
    %   coneMosaicSpecies, opticsSubjectName, rgcMosaicName, targetVisualSTFdescriptor
    % and generate the optics that were used to synthesize the mosaic
    [theMRGCmosaic, theOptics, thePSFatTheMosaicEccentricity] = mRGCMosaic.loadPrebakedMosaic(...
            coneMosaicSpecies, opticsSubjectName, rgcMosaicName, targetVisualSTFdescriptor, ...
            'computeTheMosaicOptics', true, ...
            'opticsToEmploy', opticsForTTFresponses, ...
            'wavefrontSpatialSamples', opticsWavefrontSpatialSamples, ...
            'cropParams', cropParams);

    % Plot a smaller region of the mRGC mosaic with the PSF superimposed
    narrowDomainVisualizationLimits(1:2) = theMRGCmosaic.eccentricityDegs(1) + [-0.5 0.5]*theMRGCmosaic.sizeDegs(1);
    narrowDomainVisualizationLimits(3:4) = theMRGCmosaic.eccentricityDegs(2) + [-0.5 0.5]*theMRGCmosaic.sizeDegs(2);
    narrowDomainVisualizationTicks = struct(...
        'x', -30:0.2:0, ...
        'y', -10:0.2:10);
    
    
    if (visualizeMRGCmosaic)
        demoEngine.visualize.fancyMosaic(theMRGCmosaic, thePSFatTheMosaicEccentricity, ...
            narrowDomainVisualizationLimits, ...
            narrowDomainVisualizationTicks, ...
            exportVisualizationRootDirectory, ...
            exportVisualizationPDFdirectory);
    end



    gratingParams = [];
    if (isstruct(HDRimageName))

        % Get the grating params
        gratingParams = HDRimageName;

        visualizeStimulusSequence = true;
        [theStimulusSceneSequence, theNullStimulusScene, theSceneStimulusSequenceTemporalSupportSeconds] = ...
            demoEngine.scene.classicCRTstimulus(...
                gratingParams, theMRGCmosaic, theOptics, visualizeStimulusSequence);


        % Compute the retinal image for each stimulus frame
        theRetinalImage = cell(1, numel(theSceneStimulusSequenceTemporalSupportSeconds));
        parfor iFrame = 1:numel(theSceneStimulusSequenceTemporalSupportSeconds)
            fprintf('Computing retinal images for stimulus frame %d of %d\n', iFrame, numel(theSceneStimulusSequenceTemporalSupportSeconds));
            theRetinalImage{iFrame} = oiCompute(theOptics, theStimulusSceneSequence{iFrame},'pad value','mean');
        end

        % Set the integration time of the cone mosaic to the frame duration
        % temporal resolution
        theMRGCmosaic.inputConeMosaic.integrationTime = ...
            theSceneStimulusSequenceTemporalSupportSeconds(2)-theSceneStimulusSequenceTemporalSupportSeconds(1);


    else

        % Load an HDR scene
        [theScene, spatialSupportXdegs, spatialSupportYdegs] = demoEngine.scene.loadMachnesterDataBaseScene(...
            HDRdatabaseYear, sprintf('%s.mat', HDRimageName));
    
        % Visualize scene and its luminance map
        figNo = 1;
        thePDFfileName = sprintf('%s_%d_%s_original.pdf', 'Manchester', HDRdatabaseYear, HDRimageName);
        demoEngine.scene.visualizeHDR(theScene, spatialSupportXdegs, spatialSupportYdegs, sceneCropParams, figNo,...
            exportVisualizationRootDirectory, ...
            exportVisualizationPDFdirectory, ...
            thePDFfileName);
    
        % Crop the scene
        if (~isempty(sceneCropParams))
            [theScene, spatialSupportXdegs, spatialSupportYdegs] = ...
                demoEngine.scene.crop(theScene, spatialSupportXdegs, spatialSupportYdegs, ...
                sceneCropParams);
        end

        % Visualize cropped scene and its luminance map
        figNo = 2;
        demoEngine.scene.visualizeHDR(theScene, spatialSupportXdegs, spatialSupportYdegs, [], figNo, ...
            exportVisualizationRootDirectory, ...
            exportVisualizationPDFdirectory, ...
            sprintf('%s_%d_%s_cropped.pdf', 'Manchester', HDRdatabaseYear, HDRimageName));

        % Compute the retinal image
        theRetinalImage = oiCompute(theOptics,theScene,'pad value','mean');

        % Set the integration time of the cone mosaic to the eye movement
        % temporal resolution
        theMRGCmosaic.inputConeMosaic.integrationTime = eyeMovementParams.temporalResolutionSeconds;

    end

    
    if (isstruct(HDRimageName))

        % CRT modulated stimulus witout fixational eye movements
        % Compute the cone mosaic excitation responses

        % Compute the response to the first frame
        theConeMosaicExcitationFrameResponse = theMRGCmosaic.inputConeMosaic.compute(theRetinalImage{1});

        % Allocate memory for the responses to all the frames
        theConeMosaicSpatioTemporalExcitationResponse = zeros(1, numel(theRetinalImage), size(theConeMosaicExcitationFrameResponse,3));
        theConeMosaicSpatioTemporalExcitationResponse(1, 1, :) = theConeMosaicExcitationFrameResponse;

        theConeExcitationsResponseTemporalSupportSeconds = theSceneStimulusSequenceTemporalSupportSeconds;

        parfor iFrame = 2:numel(theRetinalImage)
            fprintf('Computing cone mosaic excitations response for frame %d of %d\n', iFrame, numel(theRetinalImage))
            theConeMosaicSpatioTemporalExcitationResponse(1, iFrame, :) = ...
                theMRGCmosaic.inputConeMosaic.compute(theRetinalImage{iFrame});
        end

    else
        % HDR with fixational eye movements
        % Instantiate a fixational eye movement object for generating
        % fixational eye movements that include drift and microsaccades.
        fixEMobj = fixationalEM();
    
        % Generate microsaccades with a mean interval of  150 milliseconds
        % Much more often than the default, just for video purposes.
        fixEMobj.microSaccadeMeanIntervalSeconds = eyeMovementParams.microSaccadeMeanIntervalSeconds;
        
        % Compute nTrials of emPaths for this mosaic
        % Here we are fixing the random seed so as to reproduce identical eye
        % movements whenever this script is run.
        theFixationalEMObj = demoEngine.compute.fixationalEyeMovementPaths(...
            eyeMovementParams.trialDurationSeconds, eyeMovementParams.nTrials, ...
            theMRGCmosaic.inputConeMosaic, ...
            eyeMovementParams.randomNumberGeneratorSeed);
    
    
        % Compute the cone mosaic excitation responses
        [theConeMosaicSpatioTemporalExcitationResponse, ~, ~, ~, theConeExcitationsResponseTemporalSupportSeconds] = ...
                theMRGCmosaic.inputConeMosaic.compute(theRetinalImage, ...
                'withFixationalEyeMovements', true);
    end



    % Compute mean cone excitation rates.
    % Must be < 30,000 R*/sec to avoid significant bleaching
    meanConeExcitationRates = mean(theConeMosaicSpatioTemporalExcitationResponse,2)/ theMRGCmosaic.inputConeMosaic.integrationTime;
    maxConeExcitationRates = max(theConeMosaicSpatioTemporalExcitationResponse,2)/ theMRGCmosaic.inputConeMosaic.integrationTime;
    
    fprintf('Range of mean cone excitation rates: %f - %f * 10000 (R*/sec)\n', min(meanConeExcitationRates(:))/1e3, max(meanConeExcitationRates(:))/1e3);
    fprintf('Range of max cone excitation rates: %f - %f * 10000 (R*/sec)\n', min(maxConeExcitationRates(:))/1e3, max(maxConeExcitationRates(:))/1e3);
    
    
    if (max(meanConeExcitationRates) > 30*1000)
        error('some mean cone excitation rates were > 30000')
    end

    [theConeMosaicSpatioTemporalPhotocurrentResponses, ...
     thePhotocurrentResponseTemporalSupportSeconds] = computePhotocurrentActivation(theMRGCmosaic, ...
        theConeMosaicSpatioTemporalExcitationResponse, ...
        photocurrentParams);

    % Append photocurrents to theDataFileName
    theDataFileName = fullfile(exportVisualizationRootDirectory, exportDataDirectory, theDataFileName);
    save(theDataFileName, ...
        'theMRGCmosaic', ...
        'sceneCropParams', ...
        'gratingParams', ...
        'theConeMosaicSpatioTemporalExcitationResponse', ...
        'theConeExcitationsResponseTemporalSupportSeconds', ...
        'theScene', 'theRetinalImage', 'theFixationalEMObj', ...
        'theConeMosaicSpatioTemporalPhotocurrentResponses', ...
        'thePhotocurrentResponseTemporalSupportSeconds', ...
        '-v7.3');

    fprintf('Saved everything to %s', theDataFileName);

end

function [theConeMosaicSpatioTemporalPhotocurrentResponses, ...
          thePhotocurrentResponseTemporalSupportSeconds] = computePhotocurrentActivation(theMRGCmosaic, ...
    theConeMosaicSpatioTemporalExcitationResponse, ...
    photocurrentParams)

    fprintf('Computing photocurrent responses');

    % Allocate memory for each cone mosaic OS biophys model
    nTrials = size(theConeMosaicSpatioTemporalExcitationResponse,1);
    nCones = size(theConeMosaicSpatioTemporalExcitationResponse,3);
    theConeOSbiophysModels = cell(1,nCones);
    
    eccentricityDegsOfOSbiophysicalModel = sqrt(sum(theMRGCmosaic.inputConeMosaic.eccentricityDegs(:).^2));

    skipAssertions = false;
    iCone = 1; iTrial = 1;
    % Retrieve this cone's excitations count response 
    theSingleConeExcitationCountsResponse = squeeze(theConeMosaicSpatioTemporalExcitationResponse(iTrial,:,iCone));
    
    % Convert it to a cone excitation rate response
    theSingleConeExcitationRateResponse = theSingleConeExcitationCountsResponse(:) / theMRGCmosaic.inputConeMosaic.integrationTime;
    
    % Compute the cone's mean excitation rate over the entire course of stimulation
    theSingleConeBackgroundConeExcitationRate = mean(theSingleConeExcitationRateResponse);
    
    % Compute the first cone's photocurrent response just to get the number of time
    % bins and also conduct the assertions
    [~, thePhotocurrentResponseTemporalSupportSeconds] = cMosaic.photocurrentFromConeExcitationRateUsingBiophysicalOSmodel(...
        eccentricityDegsOfOSbiophysicalModel, ...
        theSingleConeExcitationRateResponse, ...
        theSingleConeBackgroundConeExcitationRate, ...
        theMRGCmosaic.inputConeMosaic.integrationTime, ...  % the timebase of the cone excitation rate signal
        photocurrentParams.temporalResolutionSeconds,  ...  % the timebase of the returned photocurrent signal
        'osTimeStepSeconds', photocurrentParams.osBiophysicalModelTemporalResolutionSeconds, ...  % the time base for running the osBiophysical model
        'skipAssertions', skipAssertions, ...
        'theConeOSbiophysModel', theConeOSbiophysModels{iCone});


    % Allocate memory for the cone mosaic photocurrent response
    theConeMosaicSpatioTemporalPhotocurrentResponses = zeros(nTrials, numel(thePhotocurrentResponseTemporalSupportSeconds), nCones);
    
    skipAssertions = true;
    for iTrial = 1:nTrials
        parfor iCone = 1:nCones
        
            if (mod(iCone-1,100)==0)
                fprintf('Computing photocurrent for cone %d of %d (trial: %d of %d)\n', iCone, nCones, iTrial, eyeMovementParams.nTrials);
            end

            % Retrieve this cone's excitations count response 
            theSingleConeExcitationCountsResponse = squeeze(theConeMosaicSpatioTemporalExcitationResponse(iTrial,:,iCone));
        
            % Convert it to a cone excitation rate response
            theSingleConeExcitationRateResponse = theSingleConeExcitationCountsResponse(:) / theMRGCmosaic.inputConeMosaic.integrationTime;
        
            % Compute the cone's mean excitation rate over the entire course of stimulation
            theSingleConeBackgroundConeExcitationRate = mean(theSingleConeExcitationRateResponse);
        
            % Compute the cone's photocurrent response
            [theSingleConePhotocurrentDifferentialResponse, ~, ...
             theSingleConePhotocurrentBackgroundTransientResponse, ...
             theConeOSbiophysModels{iCone}] = cMosaic.photocurrentFromConeExcitationRateUsingBiophysicalOSmodel(...
                    eccentricityDegsOfOSbiophysicalModel, ...
                    theSingleConeExcitationRateResponse, ...
                    theSingleConeBackgroundConeExcitationRate, ...
                    theMRGCmosaic.inputConeMosaic.integrationTime, ...  % the timebase of the cone excitation rate signal
                    photocurrentParams.temporalResolutionSeconds,  ...  % the timebase of the returned photocurrent signal
                    'osTimeStepSeconds', photocurrentParams.osBiophysicalModelTemporalResolutionSeconds, ...  % the time base for running the osBiophysical model
                    'skipAssertions', skipAssertions, ...
                    'theConeOSbiophysModel', theConeOSbiophysModels{iCone});
            
            theConeMosaicSpatioTemporalPhotocurrentResponses(iTrial,:,iCone) = theSingleConePhotocurrentDifferentialResponse;
        end % parfor
    end % iTrial
    
end



