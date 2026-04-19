% ISETBioPaperAndGrantCode/talks/VSS2026
%
% Scripts used to generate material for the VSS2026 talk 
%
% NOTE: To run any RGC-related ISETBio code, such as this tutorial, users must follow
% the directions discribed in:
%    https://github.com/isetbio/isetbio/wiki/Retinal-ganglion-cell-(RGC)-mosaics
% under section "Configuring ISETBio to access RGC resources and run RGC simulations"
%
%
% - t_contrastConeExcitationVsPhotocurrentSTFs 
%       Compute and contrast mRGC STFs that are based on cone excitations vs photocurrents    
%       as a function of 3 important phototransduction variables:
%       (i) background luminance
%       (ii) temporal frequency
%       (iii) contrast
%
% - t_mRGCMosaicNonLinearities
%      Ispect the effect of different properties of the modified Naka-Rusthon output nonlinearity
%      by visualizing the cone modulation- and photocurrent-based mRGC response to a single drifting grating
%
% - t_inspectEmployedMRGCmosaicProperties
%       Visualize the mosaic of RF centers of an mRGC mosaic along with the corresponding PSF
%
% - t_mRGCMosaicSynthesizeTemporalFilters
%       Generate center and surround temporal filters for cells in an mRGC mosaic
%       mosaic. This is done by computing TTFs based on cone photocurrent
%       inputs to a synthetic mRGC using a disk stimulus (to drive mainly the center) and an annulus
%       stimulus which drives the surround. 
%       These TTFs are computed by calling :
%           RGCMosaicAnalyzer.compute.mosaicTTFsForStimulusChromaticityAndOptics)
%       In the second step, we derive intrinsic center and surround temporal filters of the mRGC so that the cascade
%       of the photocurrentBasedTTF * intrinscicTTF  = BenardeteKaplan1992TTF (separately for the center and the surround)
%       This is done by calling:
%           RGCMosaicAnalyzer.compute.MRGCtemporalFiltersFromPhotocurrentsBasedTTF
%
%
% - t_temporalImpulseResponseModels
%       Demonstrate the temporal filters models of Benardete&Kaplan (1992a) and of Purpura et al (1990)