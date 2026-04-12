% ISETBioPaperAndGrantCode/papers/TreeshrewModel
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
%      Compute and contrast cone-excitations vs. photocurrent-based mRGC responses 
%      to a single drifting grating with the addition of an output static nonlinearity
%
% - t_inspectEmployedMRGCmosaicProperties
%       Visualize the mosaic of RF centers of an mRGC mosaic along with the corresponding PSF
