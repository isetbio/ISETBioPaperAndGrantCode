%
% demoEngine.compute.fixationalEyeMovementPaths
%
function fixationalEMObj = fixationalEyeMovementPaths(trialDurationSeconds, nTrials, theConeMosaic, randomNumberGeneratorSeed)
    % Initialize
    fixationalEMObj = fixationalEM;              % Instantiate a fixationalEM object

    % Generate microsaccades with a mean interval of  150 milliseconds
    % Much more often than the default, just for video purposes.
    fixationalEMObj.microSaccadeMeanIntervalSeconds = 0.200;

    % fixationalEMObj.microSaccadeType = 'none';   % No microsaccades, just drift
    
    % Compute number of eye movements
    eyeMovementsPerTrial = trialDurationSeconds/theConeMosaic.integrationTime;

    % Generate the em sequence for the passed cone mosaic,
    % which results in a time step equal to the integration time of theConeMosaic
    fixationalEMObj.computeForCmosaic(...
        theConeMosaic, eyeMovementsPerTrial,...
        'nTrials' , nTrials, ...
        'rSeed', randomNumberGeneratorSeed)

    % Set the fixational eye movements into the cone mosaic
    theConeMosaic.emSetFixationalEMObj(fixationalEMObj);
end


