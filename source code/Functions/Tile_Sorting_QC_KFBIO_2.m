function Tile_Sorting_QC_KFBIO_2(Tiles,LOCvalues,Idx,Foldname,ImageObj,DownsizeCoef,PageIndex)
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
% HIGHREZDAPI = 1 ;


% initialize Tpath variable for better parfor performance:
IDXT = zeros(size(TileGX)) ;
for k = 1:numel(TileGX)
  IDXT(k) = find(contains(Tiles,['_' num2str(TileG(k,:)) '_'])) ;
end
Tpath = cell((size(Tiles))) ;
for k = 1:numel(TileGX)
    Tpath{k} =   Tiles{IDXT(k)} ;
end



bSize = 256 ;
% 
% ImageObj.unloadLib()
% ImageObj.loadCoreLib()
% ImageObj.loadParalellLib()

% testparallell . didnt work TO BE FIXED ASAP as it works now . see Patch_Mask_3 Code
parfor k=1:numel(TileGX)
    try   Imidx = Tpath{k} ;
        

        IMAGE_PTR.DataFilePTR = 0 ;
        [~, IMAGE_PTR, ~] = calllib('lib','InitImageFileFunc',IMAGE_PTR,FNAME) ;

        
        Coord1 = round((TileGX(k)-1)*DownsizeCoef) ;
        Coord2 = round((TileGY(k)-1)*DownsizeCoef) ;
        Coord3 = round((TileGX(k)-1)*DownsizeCoef) + bSize ;
        Coord4 = round((TileGY(k)-1)*DownsizeCoef) ;
        Coord5 = round((TileGX(k)-1)*DownsizeCoef) ;
        Coord6 = round((TileGY(k)-1)*DownsizeCoef) + bSize ;
        Coord7 = round((TileGX(k)-1)*DownsizeCoef) + bSize ;
        Coord8 = round((TileGY(k)-1)*DownsizeCoef) + bSize ;
        block1 = READ_KFBIO_Block(Coord1,Coord2,IMAGE_PTR,PageIndex) ;
        block2 = READ_KFBIO_Block(Coord3,Coord4,IMAGE_PTR,PageIndex) ;
        block3 = READ_KFBIO_Block(Coord5,Coord6,IMAGE_PTR,PageIndex) ;
        block4 = READ_KFBIO_Block(Coord7,Coord8,IMAGE_PTR,PageIndex) ;
        HR_block1 = [block1, block3; block2, block4];
        
        Coord1 = round((TileGX(k)-1)*DownsizeCoef) + 2*bSize ;
        Coord2 = round((TileGY(k)-1)*DownsizeCoef) ;
        Coord3 = Coord1 + bSize ;
        Coord4 = Coord2 ;
        Coord5 = Coord1 ;
        Coord6 = Coord2 + bSize ;
        Coord7 = Coord1 + bSize ;
        Coord8 = Coord2 + bSize ;
        block1 = READ_KFBIO_Block(Coord1,Coord2,IMAGE_PTR,PageIndex) ;
        block2 = READ_KFBIO_Block(Coord3,Coord4,IMAGE_PTR,PageIndex) ;
        block3 = READ_KFBIO_Block(Coord5,Coord6,IMAGE_PTR,PageIndex) ;
        block4 = READ_KFBIO_Block(Coord7,Coord8,IMAGE_PTR,PageIndex) ;
        HR_block2 = [block1, block3; block2, block4];
        
        Coord1 = round((TileGX(k)-1)*DownsizeCoef) ;
        Coord2 = round((TileGY(k)-1)*DownsizeCoef) + 2*bSize ;
        Coord3 = Coord1 + bSize ;
        Coord4 = Coord2 ;
        Coord5 = Coord1 ;
        Coord6 = Coord2 + bSize ;
        Coord7 = Coord1 + bSize ;
        Coord8 = Coord2 + bSize ;
        block1 = READ_KFBIO_Block(Coord1,Coord2,IMAGE_PTR,PageIndex) ;
        block2 = READ_KFBIO_Block(Coord3,Coord4,IMAGE_PTR,PageIndex) ;
        block3 = READ_KFBIO_Block(Coord5,Coord6,IMAGE_PTR,PageIndex) ;
        block4 = READ_KFBIO_Block(Coord7,Coord8,IMAGE_PTR,PageIndex) ;
        HR_block3 = [block1, block3; block2, block4];
        
        Coord1 = round((TileGX(k)-1)*DownsizeCoef) + 2*bSize ;
        Coord2 = round((TileGY(k)-1)*DownsizeCoef) + 2*bSize ;
        Coord3 = Coord1 + bSize ;
        Coord4 = Coord2 ;
        Coord5 = Coord1 ;
        Coord6 = Coord2 + bSize ;
        Coord7 = Coord1 + bSize ;
        Coord8 = Coord2 + bSize ;
        block1 = READ_KFBIO_Block(Coord1,Coord2,IMAGE_PTR,PageIndex) ;
        block2 = READ_KFBIO_Block(Coord3,Coord4,IMAGE_PTR,PageIndex) ;
        block3 = READ_KFBIO_Block(Coord5,Coord6,IMAGE_PTR,PageIndex) ;
        block4 = READ_KFBIO_Block(Coord7,Coord8,IMAGE_PTR,PageIndex) ;
        HR_block4 = [block1, block3; block2, block4];
        
         % Unload the pointer from memory! : 
        [bool] = calllib('lib','UnInitImageFileFunc',IMAGE_PTR) ;
    
        
        
        
        HR_block   = [HR_block1, HR_block3; HR_block2, HR_block4];
        imwrite(HR_block,[PTG filesep Dir_Extract(Imidx,Dir_Num(Imidx))])
        
    catch
        disp('Error in Tile_Sorting_QC_KFBIO_2')
    end
    
end