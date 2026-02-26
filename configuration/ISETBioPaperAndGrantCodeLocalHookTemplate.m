% ISETBioPaperAndGrantCode
%
% Template for setting preferences for the ISETBioPaperAndGrantCode
% repository
%
% 9/20/2020  npc    Wrote it.

%% Clear prefs
% 
% We use these, clear before setting below.
if (ispref('ISETbioAdaPEE'))
    rmpref('ISETbioAdaPEE');
end
if (ispref('ISETBioPaperAndGrantCode'))
    rmpref('ISETBioPaperAndGrantCode');
end

% Root dir
setpref('ISETBioPaperAndGrantCode','recipesDir',fullfile(tbLocateToolbox('ISETBioPaperAndGrantCode'),'recipes'));
