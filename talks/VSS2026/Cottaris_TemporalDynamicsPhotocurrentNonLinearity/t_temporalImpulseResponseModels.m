function t_temporalImpulseResponseModels
% Demonstrate the temporal filters models of Benardete&Kaplan (1997a) and
% Purpura et al (1990)
%
% Syntax:
%   t_temporalImpulseResponseModels()

	% Temporal frequency support
    temporalFrequencySupportHz = 0.5:0.5:200;

    params = RGCmodels.BenardeteKaplan1997.figure6CenterSurroundFilterParams('ON');
    theMacaqueAnnulusImpulseResponseData = RGCmodels.BenardeteKaplan1997.digitizedData.ONcenterAnnulusImpulseResponseFromFigure6();
    theMacaqueDiskImpulseResponseData = RGCmodels.BenardeteKaplan1997.digitizedData.ONcenterDiskImpulseResponseFromFigure6()

    params = RGCmodels.BenardeteKaplan1997.figure6CenterSurroundFilterParams('OFF');
    theMacaqueAnnulusImpulseResponseData = RGCmodels.BenardeteKaplan1997.digitizedData.OFFcenterAnnulusImpulseResponseFromFigure6();
    theMacaqueDiskImpulseResponseData = RGCmodels.BenardeteKaplan1997.digitizedData.OFFcenterDiskImpulseResponseFromFigure6();

    %params = RGCmodels.BenardeteKaplan1997.figure7CenterSurroundFilterParams();
    %theMacaqueSurroundImpulseResponseData = [];

    % TTF models as 1-stage high-pass, N-stage low-pass filter cascade
	theCenterDiskTTF = RGCmodels.BenardeteKaplan1997.oneStageHighPassNstageLowPassFilterCascadeTTF(...
        params.centerIR.pVector, temporalFrequencySupportHz);
    
    theSurroundAnnulusTTF = RGCmodels.BenardeteKaplan1997.oneStageHighPassNstageLowPassFilterCascadeTTF(...
        params.surroundIR.pVector, temporalFrequencySupportHz);

    performFFTshift = false;
    zeroPaddingLength = 512;
    theCenterDiskImpulseResponseData = RGCMosaicConstructor.temporalFilterEngine.impulseResponseFunctionFromTTF(...
        theCenterDiskTTF, temporalFrequencySupportHz, performFFTshift, zeroPaddingLength);

    theSurroundAnnulusImpulseResponseData = RGCMosaicConstructor.temporalFilterEngine.impulseResponseFunctionFromTTF(...
        theSurroundAnnulusTTF, temporalFrequencySupportHz, performFFTshift, zeroPaddingLength);

    

    plotFilters(1, temporalFrequencySupportHz, ...
        theCenterDiskTTF, theSurroundAnnulusTTF, ...
        theCenterDiskImpulseResponseData, ...
        theSurroundAnnulusImpulseResponseData, ...
        'withMacaqueDiskImpulseResponseData', theMacaqueDiskImpulseResponseData, ...
        'withMacaqueAnnulusImpulseResponseData', theMacaqueAnnulusImpulseResponseData);

    pause;

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
    theSurroundImpulseResponseData, varargin)

    p = inputParser;
    p.addParameter('withMacaqueDiskImpulseResponseData', [], @(x)(isempty(x) || (isstruct(x))));
    p.addParameter('withMacaqueAnnulusImpulseResponseData', [], @(x)(isempty(x) || (isstruct(x))));
    p.parse(varargin{:});
    theMacaqueAnnulusImpulseResponseData = p.Results.withMacaqueAnnulusImpulseResponseData;
    theMacaqueDiskImpulseResponseData = p.Results.withMacaqueDiskImpulseResponseData;

    % Plot temporal transfer functions
    hFig = figure(figNo*10+1); clf;
    set(hFig, 'Position', [300 10 1200 800]);
    subplot(1,2,1)
    plot(temporalFrequencySupportHz, abs(theCenterTTF), 'r-');
    hold('on')
    if (~isempty(theSurroundTTF))
        plot(temporalFrequencySupportHz, abs(theSurroundTTF), 'b-');
    end
    set(gca, 'XScale', 'log', 'XLim', [0.1 100], 'XTick', [0.25 0.5 1 2 4 8 16 32 64 128]);
    grid on
    set(gca, 'FontSize', 16)
    
    subplot(1,2,2)
    plot(temporalFrequencySupportHz, unwrap(angle(theCenterTTF))/pi*180, 'r-');
    hold on;
    if (~isempty(theSurroundTTF))
        plot(temporalFrequencySupportHz, unwrap(angle(theSurroundTTF))/pi*180, 'b-');
    end
    set(gca, 'XScale', 'log', 'XLim', [0.25 32], 'XTick', [0.25 0.5 1 2 4 8 16 32], 'YLim', [-360 360], 'YTick', -360:30:360);
    set(gca, 'FontSize', 16)
    ylabel('phase (degs)');
    grid on

    % Plot impulse response functions
    hFig = figure(figNo*10+2); clf;
    set(hFig, 'Position', [900 10 1050 700]);
    pHandles(1) = plot(theCenterImpulseResponseData.temporalSupportSeconds*1e3, theCenterImpulseResponseData.amplitude, 'r-', 'LineWidth', 1.5);
    legends{1} = 'center IR (fitted model)';
    hold on
    if (~isempty(theMacaqueDiskImpulseResponseData))
            pHandles(numel(pHandles)+1)= plot(theMacaqueDiskImpulseResponseData.temporalSupportSeconds*1e3, theMacaqueDiskImpulseResponseData.amplitude, ...
                'rv', 'LineWidth', 1.5, 'MarkerFaceColor', [1 0.5 0.5]);
            legends{numel(legends)+1} = 'disk IR (macaque data)';
    end

    if (~isempty(theSurroundImpulseResponseData))
        pHandles(numel(pHandles)+1) = plot(theSurroundImpulseResponseData.temporalSupportSeconds*1e3, theSurroundImpulseResponseData.amplitude, 'b-', 'LineWidth', 1.5);
        legends{numel(legends)+1} = 'surround IR (fitted model)';
        if (~isempty(theMacaqueAnnulusImpulseResponseData))
            pHandles(numel(pHandles)+1)= plot(theMacaqueAnnulusImpulseResponseData.temporalSupportSeconds*1e3, theMacaqueAnnulusImpulseResponseData.amplitude, ...
                'bv', 'LineWidth', 1.5, 'MarkerFaceColor', 'c');
            legends{numel(legends)+1} = 'annulus IR (macaque data)';
        end
    end
    legend(pHandles, legends);
    xlabel('time (msec)');
    ylabel('response');
    set(gca, 'XLim', [0 200], 'XTick', 0:10:1000, 'FontSize', 16);
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
