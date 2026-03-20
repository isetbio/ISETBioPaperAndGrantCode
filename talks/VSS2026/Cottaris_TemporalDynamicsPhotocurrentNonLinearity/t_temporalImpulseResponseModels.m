function t_temporalImpulseResponseModels

	% Compute TTF
    temporalFrequencySupportHz = 0.5:0.5:200;


    % Center TTF params (ON-center cell data from Figure 6)
    centerParams(1) = 1.0
    ;        % gain (A)
    centerParams(2) = 100;            % high-pass stages num
    centerParams(3) = 30;          % high-pass time constant (msec) (Ts)
    centerParams(4) = 50.0;          % delay (msec) (D)

    % Compute temporal transfer functions
	theCenterTTF = highPassNstageLowPassMstageTTF(centerParams, temporalFrequencySupportHz);

    theCenterImpulseResponseData = ...
        temporalTransferFunctionToImpulseResponseFunction(theCenterTTF, temporalFrequencySupportHz);

    % Plot temporal transfer functions
    hFig = figure(1); clf;
    set(hFig, 'Position', [300 10 560 420]);
    subplot(1,2,1)
    plot(temporalFrequencySupportHz, abs(theCenterTTF), 'ro-');
    set(gca, 'XScale', 'log', 'XLim', [0.1 100], 'XTick', [0.25 0.5 1 2 4 8 16 32 64 128]);
    grid on

    subplot(1,2,2)
    plot(temporalFrequencySupportHz, unwrap(angle(theCenterTTF))/pi*180, 'ro-');

    set(gca, 'XScale', 'log', 'XLim', [0.25 32], 'XTick', [0.25 0.5 1 2 4 8 16 32], 'YLim', [-360 360], 'YTick', -360:30:360);
    ylabel('center-surround phase difference (degs)');
    grid on

    % Plot impulse response functions
    hFig = figure(2); clf;
    set(hFig, 'Position', [900 10 560 420]);
    p1 = plot(theCenterImpulseResponseData.temporalSupportSeconds*1e3, theCenterImpulseResponseData.weights, 'ro-');
    xlabel('time (msec)')
    set(gca, 'XLim', [0 200], 'XTick', 0:10:1000);
    grid on

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




function theImpulseResponseFunctionData = ...
        temporalTransferFunctionToImpulseResponseFunction(theTTF, temporalFrequencySupportHz)

    % Zero padding
    extraSamplesNum = 0;
    nSamples = numel(theTTF) + extraSamplesNum;
    temporalFrequencySupportHz
    theTTF = cat(2, theTTF, zeros(1,nSamples-numel(theTTF)));
    temporalFrequencySupportHz = temporalFrequencySupportHz(1) + (0:(nSamples-1))*(temporalFrequencySupportHz(2)-temporalFrequencySupportHz(1));

    % Convert single-sided spectrum to double sided
    theDoubleSidedTTF = [theTTF(1) theTTF(2:end)/2 fliplr(conj(theTTF(2:end)))/2];

    theImpulseResponse = ifft(theDoubleSidedTTF, 'symmetric');

    fMax = max(temporalFrequencySupportHz);
    dtSeconds = 1/(2*fMax)
    theTemporalSupportSeconds = (1:numel(theImpulseResponse)) * dtSeconds;

    theImpulseResponseFunctionData.weights = theImpulseResponse;
    theImpulseResponseFunctionData.temporalSupportSeconds = theTemporalSupportSeconds;
end


function theTTF = highPassNstageLowPassMstageTTF(params, temporalFrequencySupportHz)

	% Get params
    gain = params(1);
    highPassStagesNum = round(params(2));
    highPassTimeConstantSeconds = params(3)*1e-3;
    delaySeconds = params(4)*1e-3;
    omega = temporalFrequencySupportHz * (2 * pi);

    % The TwoStageTTF model in the frequency domain
    j_omega_tau = 1i * omega * highPassTimeConstantSeconds;
    theTTF = ...
    	gain * exp(-1i * omega * delaySeconds) .* ((j_omega_tau .^ highPassStagesNum) ./ ((1 + j_omega_tau) .^ highPassStagesNum));

end


function theResidual = highPassNstageLowPassTTFresidual(theCurrentParams, theTTFtoFit, temporalFrequencySupportHz, ax, modelVariables)

    theResidual = norm(highPassNstageLowPassTTF(theCurrentParams, temporalFrequencySupportHz) - theTTFtoFit);

    modelVariables.finalValues = theCurrentParams;
    RGCMosaicConstructor.visualize.fittedModelParams(ax, modelVariables, 'TTF fit');

end
