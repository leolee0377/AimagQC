function [Raw_MASK, Focus_MASK, STATS] = QC_MASKS_2(DAPI_d,Outfold,ImageObj,Im_org)
% main code for the global mask detection!
% Author: Laurent GOLE, AIMAGINOSTIC PTE LTD ®. All Rights Reserved ©, 2020.

 

SlideID = ImageObj.MetaData.SlideID ;
SlideID = SlideID{1} ;



% allow to remove the annoying edge things 2% up to a max of 500 pixel thick  while activity mask saves up the
% correct?
[x, y,~] = size(DAPI_d);
thx = max(200,round(2*x/100));
thy = max(200,round(2*y/100));

tmp = DAPI_d ;
tmp (1:thx,:,:) = 0 ;
tmp(:,1:thy,:) = 0 ;
tmp(:,end-thy:end,:) = 0 ;
tmp(end-thx:end,:,:) = 0 ;

% lowrez PIQE.
[score,smolactmask,~,~] = piqe(imgaussfilt(imresize(tmp-3,0.1,'nearest'),1)) ;
S = regionprops(smolactmask,'Area') ;
MaxArea = max([S.Area]) ;
MaxArea = sort(MaxArea,'ascend') ; 
MaxArea = MaxArea(1) ; 
pct_max_size = 5/100 ;

smolactmask = bwareaopen(smolactmask,round(pct_max_size*MaxArea)) ;
smolactmask = imbinarize(imgaussfilt(double(smolactmask),15)) ;
globsmolmas = imresize(imerode(smolactmask,strel('disk',15)),[x y],'nearest') ;
activityMask = imresize(smolactmask,[x y],'nearest') ; 



% Laplacian filter to remove like marker annotation from mask 
LAP = fspecial('laplacian');
ILAP = imfilter(imresize(tmp-3,0.1,'nearest'), LAP, 'replicate', 'conv');
logmap = imresize(ILAP,[x y],'nearest') ; 


% global mask using imbinarize + activity mask 
%GlobMask = (imbinarize(adaptthresh(tmp,0.5,'Statistic','gaussian','NeighborhoodSize',21))) ;
GlobMask = (imbinarize(adaptthresh(logmap.*(0.5.*tmp),0.5,'Statistic','gaussian','NeighborhoodSize',21))) ;
GlobMask = bwmorph(GlobMask,'close') ;
GlobMask = GlobMask | globsmolmas ;

% smoothing and filling of mask
% dowensize and reupsize after???
GlobMask = imresize(GlobMask,1/4) ; 

tmprm = (imgaussfilt(double(GlobMask),120/4)) ;
tmprm = imresize(tmprm,[x y],'nearest') ;
Raw_MASK = imbinarize(tmprm);
Raw_MASK = imfill(Raw_MASK,'holes');
if sum(activityMask(:))>0
    tmpam = (imgaussfilt(double(activityMask),120)) ;
    Focus_MASK = imbinarize(tmpam);
else
    Focus_MASK = activityMask ;
end

STATS.AREA_TotalImage = size(DAPI_d,1)* size(DAPI_d,2) ; 
STATS.AREA_RawTissue = sum(Raw_MASK(:)) ; 
STATS.AREA_FocusTissue = sum(Focus_MASK(:));
STATS.PCT_Focus = 100* (STATS.AREA_FocusTissue/STATS.AREA_RawTissue);
STATS.PCT_Tissue = 100* (STATS.AREA_RawTissue/STATS.AREA_TotalImage);
STATS.globalPiqeScore = score ; 

% channel histogram of pixels intensity ([0 255])
[countsI,~] = imhist(DAPI_d)       ;
CI          = countsI(2:end)          ;
sumR        = cumsum(100*CI./sum(CI)) ;
% FIND THE 95% cumulative limit
MAXR   = find(sumR>=95,1,'first')./255  ;
MINR   = 0./255                         ;
Emat = [MINR MAXR]                    ;
visDAPI  = zeros([size(DAPI_d),3],'like',DAPI_d);
visDAPI(:,:,2)  = imadjust(DAPI_d,Emat,[]) ;

% size in micron : 
pixtomu = str2double(ImageObj.MetaData.PixelSizeMicrons{1}) ;
Amicronfull = double((single(ImageObj.ImSize(1)) * pixtomu ) *  (single(ImageObj.ImSize(2)) * pixtomu )) ;
Atissue = double(STATS.PCT_Tissue * Amicronfull /100) ;
% Amicronfull*(1.*10^-8) ;
Atissue = Atissue.*(1.*10^-8) ;
Atissue = round(100*Atissue)./100 ;
    %Optional figure display
    h= figure(1) ;
    h.Visible = 'off' ;
    drawnow ;
    
     subplot(1,2,1)
    imagesc(Im_org)
    axis equal
    axis off
    title({['Input Image.'] ; ['Tissue area: ' num2str(Atissue) ' cm^{2}' ]},'Interpreter','Tex')
    
    subplot(1,2,2)
    imagesc(visDAPI)
     hold on ; visboundaries(Focus_MASK,'Color',[0.5 0.5 0.5],'LineWidth',0.5)
    hold on ; visboundaries(Raw_MASK,'Color',[1 0 0],'LineWidth',0.5)
    axis equal
    axis off
    title({['\color{red}- \color{black}Tissue Area: ' num2str(STATS.PCT_Tissue) ' % of Whole Slide.'] ; ['\color{gray}- \color{black}Piqe Area : ' num2str(STATS.PCT_Focus) ' % of Tissue Area.']},'Interpreter','Tex')   
    
    sgtitle([SlideID ', Tissue Boundaries Detection'],'Interpreter','None')
    drawnow
    h.Color = [1 1 1 ] ;
    
    set(h,'PaperUnits','inches','PaperSize',[8.5,11],'PaperPosition',[0 0 1024/150 1024/150])
    
    SAVEimagePath = [Dir_Up(Outfold) filesep SlideID  '_Tissue_MASKS.png'] ;
    saveas(h, SAVEimagePath, 'png'); 
    
   close(h)




