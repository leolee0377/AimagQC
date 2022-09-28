function updir = Dir_Up(dirstring)
% so damn useful all the time...
updir = strsplit(dirstring,filesep) ; 
updir = strjoin(updir(1:end-1),filesep);