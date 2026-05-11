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
        nFrames = numel(theSceneStimulusSequenceTemporalSupportSeconds);


        % Set the integration time of the cone mosaic to the frame duration
        % temporal resolution
        theMRGCmosaic.inputConeMosaic.integrationTime = ...
            theSceneStimulusSequenceTemporalSupportSeconds(2)-theSceneStimulusSequenceTemporalSupportSeconds(1);


        % Set the temporal support of the cone mosaic excitation response
        % to theSceneStimulusSequenceTemporalSupportSeconds;
        theConeExcitationsResponseTemporalSupportSeconds = theSceneStimulusSequenceTemporalSupportSeconds;

        % No fixational eye movements
        theFixationalEMObj = [];

        % Compute the retinal image of the null scene
        theNullSceneRetinalImage = oiCompute(theOptics, theNullStimulusScene,'pad value','mean');
    
        % Compute the cone mosaic response to the null scene (background)
        theConeMosaicNullSceneExcitationResponse = theMRGCmosaic.inputConeMosaic.compute(theNullSceneRetinalImage);

        % Compute mean cone excitation rates.
        meanConeExcitationRates = mean(theConeMosaicNullSceneExcitationResponse,2)/ theMRGCmosaic.inputConeMosaic.integrationTime;
        fprintf('\nRange of mean cone excitation rates for grating stimulus: %f - %f * 10000 (R*/sec)\n', min(meanConeExcitationRates(:))/1e3, max(meanConeExcitationRates(:))/1e3);
    
        % Assert we are below 30,000 R*/sec, where photopigment leaching is < 2%
        if (max(meanConeExcitationRates) > 30*1000)
            error(sprintf('Mean cone excitation rates are > 30k R*/sec.\nAt adaptation levels up to 30k R*/sec,\nphotopigment bleaching is less than 2%%,\nand can therefore be ignored (See Cottaris et al., JoV, 2020'))
        end

        % Allocate memory for the responses to all the frames
        mCones = size(theConeMosaicNullSceneExcitationResponse,3);
        theConeMosaicSpatioTemporalExcitationResponse = zeros(1, nFrames, mCones);

        % Compute the responses to the remaining frames
        parfor iFrame = 1:nFrames

            fprintf('Computing cone mosaic excitations response for frame %d of %d\n', iFrame, nFrames);
            theFrameRetinalImage = oiCompute(theOptics, theStimulusSceneSequence{iFrame},'pad value','mean');
    
            theConeMosaicSpatioTemporalExcitationResponse(1, iFrame, :) = ...
                theMRGCmosaic.inputConeMosaic.compute(theFrameRetinalImage);
        end

        % Save the full scene sequence and the retinal image for one frame
        theScene = theStimulusSceneSequence;
        theRetinalImage = oiCompute(theOptics, theStimulusSceneSequence{1},'pad value','mean');

        maxConeExcitationRates = max(theConeMosaicSpatioTemporalExcitationResponse(:))/ theMRGCmosaic.inputConeMosaic.integrationTime;
       
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

         mCones = size(theConeMosaicSpatioTemporalExcitationResponse,3);

        % Compute mean cone excitation rates by averaging over the eye movement path
        % Must be < 30,000 R*/sec to avoid significant bleaching
        meanConeExcitationRates = mean(theConeMosaicSpatioTemporalExcitationResponse,2)/ theMRGCmosaic.inputConeMosaic.integrationTime;
        maxConeExcitationRates = max(theConeMosaicSpatioTemporalExcitationResponse,2)/ theMRGCmosaic.inputConeMosaic.integrationTime;
        fprintf('Range of mean cone excitation rates for HDR scene scan: %f - %f * 10000 (R*/sec)\n', min(meanConeExcitationRates(:))/1e3, max(meanConeExcitationRates(:))/1e3);
        
        % Assert we are below 30,000 R*/sec, where photopigment leaching is < 2%
        if (max(meanConeExcitationRates) > 30*1000)
            error(sprintf('Mean cone excitation rates are > 30k R*/sec.\nAt adaptation levels up to 30k R*/sec,\nphotopigment bleaching is less than 2%%,\nand can therefore be ignored (See Cottaris et al., JoV, 2020'))
        end
    end  % HDR image under fixational EMs

    fprintf('\nRange of max cone excitation rates: %f - %f * 10000 (R*/sec)\n', min(maxConeExcitationRates(:))/1e3, max(maxConeExcitationRates(:))/1e3);
    

    % Now compute the mosaic photocurrents
    [theConeMosaicSpatioTemporalPhotocurrentResponses, ...
     thePhotocurrentResponseTemporalSupportSeconds] = computePhotocurrentActivation(theMRGCmosaic, ...
        theConeMosaicSpatioTemporalExcitationResponse, ...
        photocurrentParams);


    % Compute cone modulations
    if (isstruct(HDRimageName))
        % Grating: typical transformation
        % Transform to cone modulations
        meanResponse = theConeMosaicNullSceneExcitationResponse;
    else
        % HDR image with fixational eye movement. For each cone compute its
        % mean excitation over the time course of the eye movement path
        % (dimension 2) and all trials (dimension 1)
        % Compute mean response over all trials and over all time bins
        meanResponse = mean(mean(theConeMosaicSpatioTemporalExcitationResponse,2),1);
        assert(size(meanResponse,3) == mCones, 'size(3) should be # of cones (%d) not (%d)', mCones, size(size(meanResponse,3)));
    end


    normalizationResponse = 1./meanResponse;
    normalizationResponse(meanResponse==0) = 0;
    
    % Transform to cone modulations
    theConeMosaicSpatioTemporalModulationsResponse = bsxfun(@times, ...
            bsxfun(@minus,theConeMosaicSpatioTemporalExcitationResponse, meanResponse), ...
            normalizationResponse);

    fprintf('mean cone excitations: %f\n', mean(meanResponse(:)));
    fprintf('mean cone modulations with respect to the mean cone excitations: %f\n', ...
        mean(abs(theConeMosaicSpatioTemporalModulationsResponse(:))));


    % Append photocurrents and cone modulations to theDataFileName
    theDataFileName = fullfile(exportVisualizationRootDirectory, exportDataDirectory, theDataFileName);
    save(theDataFileName, ...
        'theMRGCmosaic', ...
        'sceneCropParams', ...
        'gratingParams', ...
        'theConeMosaicSpatioTemporalModulationsResponse', ...
        'theConeExcitationsResponseTemporalSupportSeconds', ...
        'theScene', 'theRetinalImage', 'theFixationalEMObj', ...
        'theConeMosaicSpatioTemporalPhotocurrentResponses', ...
        'thePhotocurrentResponseTemporalSupportSeconds', ...
        '-v7.3');

    fprintf('Saved everything to %s', theDataFileName);

end

function [theConeMosaicSpatioTemporalPhotocurrentResponses, ...
          thePhotocurrentResponseTemporalSupportSeconds] = computePhotocurrentActivation(...
            theMRGCmosaic, ...
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
                fprintf('Computing photocurrent for cone %d of %d (trial: %d of %d)\n', iCone, nCones, iTrial, nTrials);
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



