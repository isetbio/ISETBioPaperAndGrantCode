function t_temporalImpulseResponseModels
% Demonstrate the temporal filters models of Benardete&Kaplan (1992a) and
% Purpura et al (1990)
%
% Syntax:
%   t_temporalImpulseResponseModels()

	% Temporal frequency support
    temporalFrequencySupportHz = 0.5:0.5:200;

    params = RGCmodels.BenardeteKaplan1992.figure6CenterSurroundFilterParams('ON');
    params = RGCmodels.BenardeteKaplan1992.figure6CenterSurroundFilterParams('OFF');
    params = RGCmodels.BenardeteKaplan1992.figure7CenterSurroundFilterParams();

    % TTF models as 1-stage high-pass, N-stage low-pass filter cascade
	theCenterDiskTTF = RGCmodels.BenardeteKaplan1992.oneStageHighPassNstageLowPassFilterCascadeTTF(...
        params.centerIR.pVector, temporalFrequencySupportHz);
    
    theSurroundAnnulusTTF = RGCmodels.BenardeteKaplan1992.oneStageHighPassNstageLowPassFilterCascadeTTF(...
        params.surroundIR.pVector, temporalFrequencySupportHz);

    performFFTshift = false;
    zeroPaddingLength = 512;
    theCenterDiskImpulseResponseData = RGCMosaicConstructor.temporalFilterEngine.impulseResponseFunctionFromTTF(...
        theCenterDiskTTF, temporalFrequencySupportHz, performFFTshift, zeroPaddingLength);

    theSurroundAnnulusImpulseResponseData = RGCMosaicConstructor.temporalFilterEngine.impulseResponseFunctionFromTTF(...
        theSurroundAnnulusTTF, temporalFrequencySupportHz, performFFTshift, zeroPaddingLength);

    plotFilters(1, temporalFrequencySupportHz, ...
        theCenterDiskTTF, theSurroundAnnulusTTF, ...
        theCenterDiskImpulseResponseData, theSurroundAnnulusImpulseResponseData)

    pause
    params = RGCmodels.PurpuraTranchinaKaplanShapley1990.table1FilterParams('P26/10_@120Trolands');
    theDriftingGratingTTF = RGCmodels.PurpuraTranchinaKaplanShapley1990.twoStageLeadLagNstageLowPassFilterCascadeTTF(params, temporalFrequencySupportHz);
    theDriftingGratingImpulseResponseData = RGCMosaicConstructor.temporalFilterEngine.impulseResponseFunctionFromTTF(...
        theDriftingGratingTTF, temporalFrequencySupportHz, performFFTshift, zeroPaddingLength)
   

    plotFilters(2, temporalFrequencySupportHz, ...
        theDriftingGratingTTF, [], ...
        theDriftingGratingImpulseResponseData, []);

    params = RGCmodels.PurpuraTranchinaKaplanShapley1990.table1FilterParams('P8/25_@46Trolands');
    theDriftingGratingTTF = RGCmodels.PurpuraTranchinaKaplanShapley1990.twoStageLeadLagNstageLowPassFilterCascadeTTF(params, temporalFrequencySupportHz);
    theDriftingGratingImpulseResponseData = RGCMosaicConstructor.temporalFilterEngine.impulseResponseFunctionFromTTF(...
        theDriftingGratingTTF, temporalFrequencySupportHz, performFFTshift, zeroPaddingLength);
   

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
