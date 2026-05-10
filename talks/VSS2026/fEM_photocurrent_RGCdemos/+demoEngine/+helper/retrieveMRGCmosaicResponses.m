%
% demoEngine.helper.retrieveMRGCmosaicResponses
%
function [theTemporalSupportSeconds, theResponse, normalizingFactor] = retrieveMRGCmosaicResponses(...
    theMRGCmosaicResponseDictionary, theDataSetLabel, ...
    theResponseBias, theResponseDelay, maxTimeToVisualize, targetRGCindex)
    
    minTimeToStabilizeSeconds = 600/1000;

    d = theMRGCmosaicResponseDictionary(theDataSetLabel);
    if (isempty(targetRGCindex))
        theResponse = squeeze(d.theMRGCmosaicResponse(1,:,:));
    else
        theResponse = squeeze(d.theMRGCmosaicResponse(1,:,targetRGCindex));
    end

    theTemporalSupportSeconds = d.theTemporalSupportSeconds;

    idx = find(theTemporalSupportSeconds>=minTimeToStabilizeSeconds);  
    theResponse = theResponse(idx);
    theTemporalSupportSeconds = theTemporalSupportSeconds(idx);
    theTemporalSupportSeconds = theTemporalSupportSeconds - theTemporalSupportSeconds(1);


    if (~isempty(maxTimeToVisualize))
        idx = find(theTemporalSupportSeconds<=maxTimeToVisualize);    
        theResponse = theResponse(idx);
        theTemporalSupportSeconds = theTemporalSupportSeconds(idx);
    end
    

    theTemporalSupportSeconds = theTemporalSupportSeconds + theResponseDelay;
    theResponse = theResponse + theResponseBias;

    % Find the max of the response from the central 1 second of the data
    observationWindowSeconds = 1.0;
    midPoint = mean(theTemporalSupportSeconds);
    indicesMidResponseWindow = find(abs(theTemporalSupportSeconds-midPoint)<0.5*observationWindowSeconds);

    indicesMidResponseWindow = [];

    if (isempty(indicesMidResponseWindow))
        normalizingFactor = 1.05*max(abs(theResponse));
    else
        normalizingFactor = 1.05*max(abs(theResponse(indicesMidResponseWindow)));
    end
end