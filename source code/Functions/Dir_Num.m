function ndir = Dir_Num(dirstring)
% Give me the number of directory within path.
updir = strsplit(dirstring,filesep) ;
ndir = numel(updir);