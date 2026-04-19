function t_temporalImpulseResponseModels

	% Temporal frequency support
    temporalFrequencySupportHz = 0.0:0.5:200;


    params = BenardeteAndKaplan1997Figure6CenterSurroundFilterParams('ON');
    params = BenardeteAndKaplan1997Figure6CenterSurroundFilterParams('OFF');

    % TTF models as 1-stage high-pass, N-stage low-pass filter cascade
	theCenterDiskTTF = oneStageHighPassNstageLowPassFilterCascadeTTF(params.centerIR.pVector, temporalFrequencySupportHz);
    theSurroundAnnulusTTF = oneStageHighPassNstageLowPassFilterCascadeTTF(params.surroundIR.pVector, temporalFrequencySupportHz);

    theCenterDiskImpulseResponseData = impulseResponseFunctionFromTTF(theCenterDiskTTF, temporalFrequencySupportHz);
    theSurroundAnnulusImpulseResponseData = impulseResponseFunctionFromTTF(theSurroundAnnulusTTF, temporalFrequencySupportHz);

    plotFilters(1, temporalFrequencySupportHz, ...
        theCenterDiskTTF, theSurroundAnnulusTTF, ...
        theCenterDiskImpulseResponseData, theSurroundAnnulusImpulseResponseData)


    params = PurpuraTranchinaKaplanShapleyParams('P8/25_@4600Trolands');
    theDriftingGratingTTF = twoStageLeadLagNstageLowPassFilterCascadeTTF(params, temporalFrequencySupportHz);
    theDriftingGratingImpulseResponseData = impulseResponseFunctionFromTTF(theDriftingGratingTTF, temporalFrequencySupportHz);
   

    plotFilters(2, temporalFrequencySupportHz, ...
        theDriftingGratingTTF, [], ...
        theDriftingGratingImpulseResponseData, []);



    params = PurpuraTranchinaKaplanShapleyParams('P8/25_@46Trolands');
    theDriftingGratingTTF = twoStageLeadLagNstageLowPassFilterCascadeTTF(params, temporalFrequencySupportHz);
    theDriftingGratingImpulseResponseData = impulseResponseFunctionFromTTF(theDriftingGratingTTF, temporalFrequencySupportHz);
   

    plotFilters(3, temporalFrequencySupportHz, ...
        theDriftingGratingTTF, [], ...
        theDriftingGratingImpulseResponseData, []);


end

function plotFilters(figNo, temporalFrequencySupportHz, ...
    theCenterTTF, theSurroundTTF, ...
    theCenterImpulseResponseData, ...
    theSurroundImpulseResponseData)

    % Plot temporal transfer functions
    hFig = figure(figNo*10+1); clf;
    set(hFig, 'Position', [300 10 560 420]);
    subplot(1,2,1)
    plot(temporalFrequencySupportHz, abs(theCenterTTF), 'ro-');
    hold('on')
    if (~isempty(theSurroundTTF))
        plot(temporalFrequencySupportHz, abs(theSurroundTTF), 'bo-');
    end
    set(gca, 'XScale', 'log', 'XLim', [0.1 100], 'XTick', [0.25 0.5 1 2 4 8 16 32 64 128]);
    grid on

    subplot(1,2,2)
    plot(temporalFrequencySupportHz, unwrap(angle(theCenterTTF))/pi*180, 'ro-');
    hold on;
    if (~isempty(theSurroundTTF))
        plot(temporalFrequencySupportHz, unwrap(angle(theSurroundTTF))/pi*180, 'bo-');
    end
    set(gca, 'XScale', 'log', 'XLim', [0.25 32], 'XTick', [0.25 0.5 1 2 4 8 16 32], 'YLim', [-360 360], 'YTick', -360:30:360);
    ylabel('hase (degs)');
    grid on

    % Plot impulse response functions
    hFig = figure(figNo*10+2); clf;
    set(hFig, 'Position', [900 10 560 420]);
    plot(theCenterImpulseResponseData.temporalSupportSeconds*1e3, theCenterImpulseResponseData.amplitude, 'ro-');
    hold on
    if (~isempty(theSurroundImpulseResponseData))
        plot(theSurroundImpulseResponseData.temporalSupportSeconds*1e3, -theSurroundImpulseResponseData.amplitude, 'bo-');
    end
    xlabel('time (msec)')
    set(gca, 'XLim', [0 500], 'XTick', 0:10:1000);
    grid on

end





function theImpulseResponseFunctionStruct = impulseResponseFunctionFromTTF(theTTF, temporalFrequencySupportHz)

    % Zero padding
    extraSamplesNum = 0;
    nSamples = numel(theTTF) + extraSamplesNum;
    theTTF = cat(2, theTTF, zeros(1,nSamples-numel(theTTF)));
    temporalFrequencySupportHz = temporalFrequencySupportHz(1) + (0:(nSamples-1))*(temporalFrequencySupportHz(2)-temporalFrequencySupportHz(1));

    % Convert single-sided spectrum to double sided
    theDoubleSidedTTF = [theTTF(1) theTTF(2:end)/2 fliplr(conj(theTTF(2:end)))/2];

    % Inverse FFT
    theImpulseResponse = ifft(theDoubleSidedTTF, 'symmetric');

    % Nyquist frequency
    fMax = max(temporalFrequencySupportHz);
    dtSeconds = 1/(2*fMax);
    theTemporalSupportSeconds = (0:(numel(theImpulseResponse)-1)) * dtSeconds;

    theImpulseResponseFunctionStruct.amplitude = theImpulseResponse;
    theImpulseResponseFunctionStruct.temporalSupportSeconds = theTemporalSupportSeconds;
end


function theTTF = oneStageHighPassNstageLowPassFilterCascadeTTF(params, temporalFrequencySupportHz)
    % This is the Berardete & Kaplan 1992A model
	% Get params
    gain = params(1);                         % Responsitivity at 0 Hz
    conductionDelaySeconds = params(2);       % D
    highPassGain = params(3);                 % Hs
    highPassTimeConstantSeconds = params(4);  % Tau_s (Benardete and Kaplan (1992a) varied this for different contrast levels)
    lowPassTimeConstantSeconds = params(5);   % Tau_l
    nLowPassStagesNum = params(6);            % Nl
    nHighPassStagesNum = params(7);           % always 1 in Benardete & Kaplan (1992a)

    % Circular frequency in radians
    omega = 2 * pi * temporalFrequencySupportHz;

    % Delay filter
    theDelayFilterTTF = exp(-1i * omega * conductionDelaySeconds);

    % 1-stage high-pass filter
    theHighPassFilterTTF = 1 - highPassGain * (1 + 1i * omega * highPassTimeConstantSeconds) .^ (-nHighPassStagesNum);

    % N-stge low-pass filter
    theLowPassFilterTTF = (1 + 1i * omega * lowPassTimeConstantSeconds) .^ (-nLowPassStagesNum);

    theTTF = gain * theDelayFilterTTF .* theHighPassFilterTTF .* theLowPassFilterTTF;
end


function theTTF = twoStageLeadLagNstageLowPassFilterCascadeTTF(params, temporalFrequencySupportHz)
    % This is the Purpura, Tranchina, Kaplan & Shapley 1990 model
	% Get params
    gain = params(1);                         % Responsitivity at 0 Hz
    conductionDelaySeconds = params(2);       % 

    timeConstant1Seconds = params(3);         % tau 1
    timeConstant2Seconds = params(4);         % tau 2

    lowPassTimeConstant1Seconds = params(5);  % tau 3
    lowPassTimeConstant2Seconds = params(6);  % tau 4

    n1LowPassStagesNum = params(7);           % n1
    n2LowPassStagesNum = params(8);           % n2

    % Circular frequency in radians
    omega = 2 * pi * temporalFrequencySupportHz;

    % Delay filter
    theDelayFilterTTF = exp(-1i * omega * conductionDelaySeconds);

    % 2-stage lead-lag filter
    % Only when timeConstant1Seconds > timeConstant2Seconds
    % is the lead-lag filter a high-pass filter
    % (i.e., gain and phase increase with TF)
    theLeadLagFilterTTF = ((1 + 1i * omega * timeConstant1Seconds) ./ (1 + 1i * omega * timeConstant2Seconds) ) .^ (2);

    % N1-stage low-pass filter with lowPassTimeConstant1Seconds time constant 
    theLowPassFilter1TTF = (1 + 1i * omega * lowPassTimeConstant1Seconds) .^ (-n1LowPassStagesNum);

    % N2-stage low-pass filter with lowPassTimeConstant2Seconds time constant 
    theLowPassFilter2TTF = (1 + 1i * omega * lowPassTimeConstant2Seconds) .^ (-n2LowPassStagesNum);


    theTTF = gain * theDelayFilterTTF .* theLeadLagFilterTTF .* theLowPassFilter1TTF .* theLowPassFilter2TTF;
end


function params = PurpuraTranchinaKaplanShapleyParams(whichCellAndIllumination)

    switch (whichCellAndIllumination)
        case 'P8/25_@4600Trolands'
            params = [21  4   0.44   38.0/1000   3.0/1000   1.3/1000   10.0/1000   38/1000];

        case 'P8/25_@460Trolands'
            params = [21  4   0.40   52.0/1000   2.9/1000   1.3/1000   16.0/1000   43/1000];

        case 'P8/25_@150Trolands'
            params = [21  4   0.38   70.0/1000   3.7/1000   1.5/1000   26.0/1000   56/1000];

        case 'P8/25_@46Trolands'
            params = [21  4   0.40   42.0/1000   3.5/1000   3.6/1000   20.0/1000   58/1000];

        case 'P8/25_@15Trolands'
            params = [15  4   0.30   67.0/1000   2.8/1000   2.5/1000   38.0/1000   71/1000];


        otherwise
            error('No data for PurpuraTranchinaKaplanShapley (1990)''%s'' cell', whichCellAndIllumination);
    end

    idx = [3 8 4 5 6 7 1 2];
    params = params(idx);

end


function params = BenardeteAndKaplan1997Figure6CenterSurroundFilterParams(whichCell)
    switch (whichCell)
        case 'ON'
            params.centerIR.pVector(1) = 184.20;
            params.surroundIR.pVector(1)  = 125.33;

            params.centerIR.pVector(2) = 4.0/1000;
            params.surroundIR.pVector(2) = 4.0/1000;

            params.centerIR.pVector(3) = 0.69;
            params.surroundIR.pVector(3) = 0.56;

            params.centerIR.pVector(4) = 18.61/1000;
            params.surroundIR.pVector(4) = 33.28/1000;

            params.centerIR.pVector(5) = 1.23/1000;
            params.surroundIR.pVector(5) = 0.42/1000;

            params.centerIR.pVector(6) = 38;
            params.surroundIR.pVector(6) = 124;

            params.centerIR.pVector(7) = 1;
            params.surroundIR.pVector(7) = 1;

      case 'OFF'
            params.centerIR.pVector(1) = 114.12;
            params.surroundIR.pVector(1) = 74.57;

            params.centerIR.pVector(2) = 3.5/1000;
            params.surroundIR.pVector(2) = 3.5/1000;

            params.centerIR.pVector(3) = 0.82;
            params.surroundIR.pVector(3) = 0.72;

            params.centerIR.pVector(4) = 24.9/1000;
            params.surroundIR.pVector(4) = 49.81/1000;

            params.centerIR.pVector(5)= 2.12/1000;
            params.surroundIR.pVector(5) = 0.76/1000;

            params.centerIR.pVector(6)= 25;
            params.surroundIR.pVector(6) = 83;

            params.centerIR.pVector(7) = 1;
            params.surroundIR.pVector(7) = 1;

        otherwise
            error('No data for Banardete&Kaplan (1992a)''%s'' cell', whichCell);
    end

end






% Fit the highPassNstageLowPassTTF to an arbitrary TTF
function  [TTFparams, theFittedTTF] = highPassNstageLowPassTTFtoArbitraryTTF(theArbitraryComplexTTF, temporalFrequencySupportHz, TTFparams, ax)

    objective = @(x)highPassNstageLowPassTTFresidual(x, theArbitraryComplexTTF, temporalFrequencySupportHz, ax, TTFparams);

    % Multi-start
    problem = createOptimProblem('fmincon',...
          'objective', objective, ...
          'x0', TTFparams.initialValues, ...
          'lb', TTFparams.lowerBounds, ...
          'ub', TTFparams.upperBounds, ...
          'options', optimoptions(...
            'fmincon',...
            'Display', 'none', ...
            'Algorithm', 'interior-point',... % 'sqp', ... % 'interior-point',...
            'GradObj', 'off', ...
            'DerivativeCheck', 'off', ...
            'MaxFunEvals', 10^5, ...
            'MaxIter', 10^4) ...
          );

    ms = MultiStart(...
          'Display', 'iter', ...
          'StartPointsToRun','bounds-ineqs', ...  % run only initial points that are feasible with respect to bounds and inequality constraints.
          'UseParallel', true);

    multiStartsNum = 32;

    % Run the multi-start
    TTFparams.finalValues = run(ms, problem, multiStartsNum);


    theFittedTTF = highPassNstageLowPassTTF(TTFparams.finalValues, temporalFrequencySupportHz);

end





function theResidual = highPassNstageLowPassTTFresidual(theCurrentParams, theTTFtoFit, temporalFrequencySupportHz, ax, modelVariables)

    theResidual = norm(highPassNstageLowPassTTF(theCurrentParams, temporalFrequencySupportHz) - theTTFtoFit);

    modelVariables.finalValues = theCurrentParams;
    RGCMosaicConstructor.visualize.fittedModelParams(ax, modelVariables, 'TTF fit');

end
