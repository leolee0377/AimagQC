function Spedir = Dir_Extract(dirstring,Nidx)
% so damn useful all the time...
Spedir = strsplit(dirstring,filesep) ; 
Spedir =Spedir{Nidx} ;