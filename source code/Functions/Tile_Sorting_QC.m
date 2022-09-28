function Tile_Sorting_QC(Tiles,LOCvalues,Idx,Foldname,ImageObj,DownsizeCoef)
% WRITE HIGH RESOLUTION TILES for each specified subregions
% Author: Laurent GOLE, AIMAGINOSTIC PTE LTD ®. All Rights Reserved ©, 2020.

% sort Tiles:
TileG = LOCvalues(Idx,:) ;
TileGX = TileG(:,1) ;
TileGY = TileG(:,2) ;


PTG = [Dir_Up(Dir_Up(Tiles{1})) filesep 'HighRez_Patches' filesep Foldname] ;
if ~exist(PTG,'dir')
    mkdir(PTG)
end

FNAME = ImageObj.Filename ;
HIGHREZDAPI = 1 ;


% initialize Tpath variable for better parfor performance:
IDXT = zeros(size(TileGX)) ;
for k = 1:numel(TileGX)
    IDXT(k) = find(contains(Tiles,['_' num2str(TileG(k,:)) '_'])) ;   
end
Tpath = cell((size(Tiles))) ;
for k = 1:numel(TileGX)
    Tpath{k} =   Tiles{IDXT(k)} ;
end


parfor k=1:numel(TileGX)
    try   Imidx = Tpath{k} ;
        % think about editing this one for KFBIO images ?? but how ?
        HR_block = imread(FNAME,'Index',HIGHREZDAPI,'PixelRegion',...
            {[round(TileGX(k)*DownsizeCoef) round(TileGX(k)*DownsizeCoef+256.*DownsizeCoef-1)],...
            [round(TileGY(k)*DownsizeCoef) round(TileGY(k)*DownsizeCoef+256*DownsizeCoef-1)]}) ;
        
        imwrite(HR_block,[PTG filesep Dir_Extract(Imidx,Dir_Num(Imidx))])
    catch
    end
end