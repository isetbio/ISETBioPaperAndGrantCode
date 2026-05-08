%
% demoEngine.scene.loadMachnesterDataBaseScene
%
function [scene, spatialSupportXdegs, spatialSupportYdegs] = loadMachnesterDataBaseScene(...
    theDatabaseYear, theSceneName)

    scenesDir = fullfile(localDropboxDir, 'HyperspectralSceneTutorial', 'resources', 'manchester_database');
    sceneFileName = sprintf('%s/%d/%s.', scenesDir, theDatabaseYear, theSceneName);
    load(sceneFileName, 'scene');

    % retrieve the spatial support of the scene(in millimeters)
    spatialSupportMilliMeters = sceneGet(scene, 'spatial support', 'mm');

    viewingDistance = sceneGet(scene, 'distance');
    spatialSupportDegs = 2 * atand(spatialSupportMilliMeters/1e3/2/viewingDistance);
    spatialSupportXdegs = squeeze(spatialSupportDegs(1,:,1));
    spatialSupportYdegs = squeeze(spatialSupportDegs(:,1,2));


end