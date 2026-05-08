%
% demoEngine.helper.retrieveMRGCmosaicResponses
%
function [theTemporalSupportSeconds, theResponse] = retrieveMRGCmosaicResponses(...
    theMRGCmosaicResponseDictionary, theDataSetLabel, ...
    theResponseBias, theResponseDelay, targetRGCindex)
    
    minTimeToStabilizeSeconds = 300/1000;
    maxTimeToVisualize = 4500/1000;

    d = theMRGCmosaicResponseDictionary(theDataSetLabel);
    if (isempty(targetRGCindex))
        theResponse = squeeze(d.theMRGCmosaicResponse(1,:,:));
    else
        theResponse = squeeze(d.theMRGCmosaicResponse(1,:,targetRGCindex));
    end

    theTemporalSupportSeconds = d.theTemporalSupportSeconds;

    idx = find((theTemporalSupportSeconds>=minTimeToStabilizeSeconds) & (theTemporalSupportSeconds<=maxTimeToVisualize));    
    theTemporalSupportSeconds = theTemporalSupportSeconds(idx);
    theTemporalSupportSeconds = theTemporalSupportSeconds - theTemporalSupportSeconds(1);

    theTemporalSupportSeconds = theTemporalSupportSeconds + theResponseDelay;
    theResponse = theResponse(idx) + theResponseBias;
end