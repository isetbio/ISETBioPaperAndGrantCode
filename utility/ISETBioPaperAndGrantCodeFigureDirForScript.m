%
% 
%
function theFiguresDir = ISETBioPaperAndGrantCodeFigureDirForScript(theScriptFileName)

    theFiguresDir = fullfile(ISETBioPaperAndGrantCodeRootDirectory, 'local', theScriptFileName);
    if (~exist(theFiguresDir,'dir'))
        mkdir(theFiguresDir);
    end
end
