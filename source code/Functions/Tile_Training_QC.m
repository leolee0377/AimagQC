function Tile_Training_QC(Tiles,LOCvalues,Idx,Foldname)
% WRITE downsize RESOLUTION TILES for each specified subregions for
% training?
% Author: Laurent GOLE, AIMAGINOSTIC PTE LTD ®. All Rights Reserved ©, 2020.

% sort Tiles:
TileG = LOCvalues(Idx,:) ;
TileGX = TileG(:,1) ;
%TileGY = TileG(:,2) ;


PTG = [Dir_Up(Dir_Up(Tiles{1})) filesep 'Training_Patches' filesep Foldname] ;
if ~exist(PTG,'dir')
    mkdir(PTG)
end



% initialize Tpath variable for better parfor performance:
IDXT = zeros(size(TileGX)) ;
for k = 1:numel(TileGX)
    IDXT(k) = find(contains(Tiles,['_' num2str(TileG(k,:)) '_'])) ;
end
Tpath = cell((size(Tiles))) ;
for k = 1:numel(TileGX)
    Tpath{k} =   Tiles{IDXT(k)} ;
end

try
parfor k=1:numel(TileGX)
    try   Imidx = Tpath{k} ;
%         Training_block = imread(Imidx) ;
%         
%         imwrite(Training_block,[PTG filesep Dir_Extract(Imidx,Dir_Num(Imidx))])
        movefile(Imidx,[PTG filesep Dir_Extract(Imidx,Dir_Num(Imidx))],'f')
        
    catch
    end
end
catch
    disp('error happens when folder empty maybe???')
end