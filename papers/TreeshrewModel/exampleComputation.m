function exampleComputation()
% Compute the response of a tree shrew cone mosaic to a grating
%
% Description:
%   Compute the response of a tree shrew cone mosaic to a grating

% History:
%    03/01/26  NPC  Wrote it.

    theOI = oiTreeShrewCreate( ...
            'opticsType', 'wvf', ...
            'pupilDiameterMM', 4.0, ...
            'whichShrew', 1, ...
            'name', 'wvf-based optics');

    theTreeShrewConeMosaic = cMosaicTreeShrewCreate(...
        'sizeDegs', [2 2]);

    stimParams = struct(...
        'spatialFrequencyCyclesPerDeg', 1.0, ... % 3.0 cycles/deg
        'orientationDegs', 0, ...               % 0 degrees
        'phaseDegs', 0, ...                     % spatial phase degrees, 0 = cos, 90 = sin
        'sizeDegs', 3, ...                     % 14 x 14 size
        'sigmaDegs', 1*3, ...                   % sigma of Gaussian envelope
        'contrast', 1,...                     % 0.9 Michelson contrast
        'meanLuminanceCdPerM2', 40, ...         % 40 cd/m2 mean luminance
        'pixelsAlongWidthDim', [], ...          % pixels- width dimension
        'pixelsAlongHeightDim', [] ...          % pixel- height dimension
        );

    
    presentationDisplay = displayCreate('LCD-Apple', 'viewing distance', 30/100);
    realizedStimulusScene = generateGaborScene(...
        'stimParams', stimParams,...
        'presentationDisplay', presentationDisplay, ...
        'minimumPixelsPerHalfPeriod', 5);

    theOI = oiCompute(theOI, realizedStimulusScene);

    nTrialsNum = 10;
    % Compute mosaic excitation responses
    [coneExcitations, noisyConeExcitations] = ...
        theTreeShrewConeMosaic.compute(theOI, ...
        'nTrials', nTrialsNum);

    % Visualize the noise-free activation
    theTreeShrewConeMosaic.visualize('activation', coneExcitations);

    % Visualize the noisy activation instances
    hFig = figure(10); clf;
    ax = subplot(1,1,1);
    for iNoisyInstance = 1:nTrialsNum
        theTreeShrewConeMosaic.visualize(...
            'figureHandle', hFig, ...
            'axesHandle', ax, ...
            'activation', noisyConeExcitations(iNoisyInstance,:,:), ...
            'activationRange', [min(noisyConeExcitations(:)) max(noisyConeExcitations(:))]);
        drawnow;
    end
end
