%
% demoEngine.scene.crop
%
function [theScene, spatialSupportXdegs, spatialSupportYdegs] = ...
        crop(theScene, spatialSupportXdegs, spatialSupportYdegs, ...
        cropParams)

    % Boost factor for mean luminance
    luminance = sceneCalculateLuminance(theScene);
    meanLuminanceBefore = mean(luminance(:));
    boostFactor = cropParams.meanLuminanceCdM2 / meanLuminanceBefore;

    flipUpsideDown = true;
    if (flipUpsideDown)
        thePhotons = sceneGet(theScene, 'photons');
        for iWave = 1:size(thePhotons,3)
            thePhotons(:,:,iWave) = flipud(squeeze(thePhotons(:,:,iWave)));
        end
        theScene = sceneSet(theScene, 'photons', thePhotons*boostFactor);
    end

    % Crop a patch
    widthDegs = cropParams.sizeDegs(1);
    heightDegs = cropParams.sizeDegs(2);
    xCenterDegs = cropParams.positionDegs(1);
    yCenterDegs = cropParams.positionDegs(2);

    if (widthDegs<=0)
        error('width cannot be negative or 0')
    end
    if (heightDegs<=0)
        error('height cannot be negative or 0')
    end

    % Compute cropping rect
    [~,minCol] = min(abs(xCenterDegs-0.5*widthDegs-spatialSupportXdegs));
    [~,maxCol] = min(abs(xCenterDegs+0.5*widthDegs-spatialSupportXdegs));
    [~,minRow] = min(abs(yCenterDegs-0.5*heightDegs-spatialSupportYdegs));
    [~,maxRow] = min(abs(yCenterDegs+0.5*heightDegs-spatialSupportYdegs));
    theCroppingRect(1:2) = [minCol minRow];
    theCroppingRect(3:4) = [maxCol-minCol maxRow-minRow];

    % Crop the scene
    theScene = sceneCrop(theScene, theCroppingRect);

    % Set the desired FOV of the cropped image
    theScene = sceneSet(theScene, 'wangular', cropParams.imageFOVdegs);

    if (flipUpsideDown)
        % Undo the updown-flip
        thePhotons = sceneGet(theScene, 'photons');
        for iWave = 1:size(thePhotons,3)
            thePhotons(:,:,iWave) = flipud(squeeze(thePhotons(:,:,iWave)));
        end
        theScene = sceneSet(theScene, 'photons', thePhotons);
    end

    % retrieve the spatial support of the scene(in millimeters)
    spatialSupportMilliMeters = sceneGet(theScene, 'spatial support', 'mm');

    viewingDistance = sceneGet(theScene, 'distance');
    spatialSupportDegs = 2 * atand(spatialSupportMilliMeters/1e3/2/viewingDistance);
    
    spatialSupportXdegs = squeeze(spatialSupportDegs(1,:,1));
    spatialSupportYdegs = squeeze(spatialSupportDegs(:,1,2));
end

