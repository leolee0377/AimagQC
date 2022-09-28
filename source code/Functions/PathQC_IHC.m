function [T,Decision] = PathQC_IHC(ImageObj,DownsizeCoef,app)
% main analysis routine for IHC and H&E images:
% Author: Laurent GOLE, AIMAGINOSTIC PTE LTD ®. All Rights Reserved ©, 2020.

mod = 0 ;
% read the first DAPI image page:
MGlobalmaskindex = (ImageObj.Indexes.Magnification == DownsizeCoef) ;

if ~sum(MGlobalmaskindex)
    % find the nearest index acceptable?
    
    MGlobalmaskindex = find (abs(ImageObj.Indexes.Magnification - DownsizeCoef) == (min(abs(ImageObj.Indexes.Magnification - DownsizeCoef)))) ;
    disp(['Warning...custom scale:' num2str(ImageObj.Indexes.Magnification(MGlobalmaskindex))])
    DownsizeCoef = ImageObj.Indexes.Magnification(MGlobalmaskindex) ;
    %     DownsizeCoef = DownsizeCoef*2 ;
    %     MGlobalmaskindex = (ImageObj.Indexes.Magnification == DownsizeCoef) ;
    %     mod = 1;
end
PageIndex = ImageObj.Indexes.Channels{1}(MGlobalmaskindex) ;
% define outputpath for Tiles
SlideID = ImageObj.MetaData.SlideID{1};
TEST = [app.EditField.Value  filesep SlideID] ;
foldinc = 0;
while exist(TEST,'dir')
    foldinc = foldinc +1 ;
    TEST =  [TEST '_0' num2str(foldinc)]    ; %#ok<AGROW>
end
Outfold = [TEST filesep 'Patches'] ;
ImageType = app.ImageTypeButtonGroup.SelectedObject.Tag ;
if ~exist(Outfold,'dir')
    mkdir(Outfold)
end


% % READ THE Image at defined page:
HE_d = ImageObj.read(PageIndex);


if strcmp(ImageType,'BrightField')
    %%% ONLY FOR BrightField IMAGES %%%%
    [x, y, z] = size(HE_d) ;
    
    I0      = double(quantile(HE_d(:),[0.99]))                        ;
    HE_d   = double(HE_d)                  ;
    % calculate optical density image :
    HE_d      = -log((HE_d+1)/I0)            ;
    HE_d    = reshape(HE_d,[x y z])           ;
    HE_d    = rgb2gray(uint8(255.*HE_d))             ;
    
  
    
    
else
      [x, y, z] = size(HE_d) ; 
end


% min max adjustment normalization:
QuantileI = quantile(HE_d(:),[0 0.25 0.5 0.75 1]) ;

try
    HE_d = imadjust(HE_d,[double(QuantileI(1))/255 double(QuantileI(5))/255],[0 1]);
     
catch
end


% FAKE FOCUS DETECTION by Opening_________________________________________
%  I = HE_d ;
%  Minthresh_25 = quantile(HE_d(HE_d>0),0.25) ;
% Idirt = I.*uint8((I>Minthresh_25)) ;

%
%
% %1) GLOBAL FOCUS MEASUREMENT________________________________________________________
% LAP = fspecial('laplacian');
% ILAP = imfilter(HE_d, LAP, 'replicate', 'conv');
% ILAP = double((ILAP));
% % measure for non zero elements , shld give a good tissue focus measurments.
% FM = std(ILAP(ILAP~=0))^2 ;
% for large structure Detection only?
% figure ; imagesc(Imdirt>25)
% if imdirt large chances are that it s fake focus ?
% issue here :   CHECK HOW IT WORKS FOR WELL FOCUSED IMAGES!:
% BM1 = quantile(Imdirt(:),0.99);
% COEFBM =  10* mean2(J.*(bwmorph(Imdirt>=BM1,'Thin',1)));
% COEFILAPabs =100* mean2(abs(ILAP).*(bwmorph(Imdirt>=BM1,'Thin',1)));
% BM = BM1*COEFBM ;


% EXTRACT DOWNSIZE GLOBAL TISSUE MASK AND AREA STATS
%[Raw_MASK,~, STATS] = QC_MASKS_2(HE_d,Outfold,ImageObj,HE_d_org);
% input function text here to avoid overhead:
%**************************************************************************
% allow to remove the annoying edge things 2% up to a max of 500 pixel thick  while activity mask saves up the
% correct?
thx = min(200,round(3*x/100));
thy = min(200,round(3*y/100));
% necessary
tmp = HE_d ;
tmp (1:thx,:,:) = 0 ;
tmp(:,1:thy,:) = 0 ;
tmp(:,end-thy:end,:) = 0 ;
tmp(end-thx:end,:,:) = 0 ;

smoltmp = imresize(tmp-3,0.1,'nearest') ;

% lowrez PIQE.
[score,smolactmask,~,~] = piqe(imgaussfilt(smoltmp,1)) ;
S = regionprops(smolactmask,'Area') ;
MaxArea = max([S.Area]) ;
MaxArea = sort(MaxArea,'ascend') ;

try MaxArea = MaxArea(1) ;
catch
    disp('TBC, MaxArea Error in PathC_IHC.')
end
pct_max_size = 5/100 ;

smolactmask = imbinarize(imgaussfilt(double(bwareaopen(smolactmask,round(pct_max_size*MaxArea))),15)) ;
% Laplacian filter to remove like marker annotation from mask
smoltmp = imresize(imfilter(smoltmp, fspecial('laplacian'), 'replicate', 'conv'),[x y],'nearest') ;
% global mask using imbinarize + activity mask ;
GlobMask = imresize(imgaussfilt(double(imresize(bwmorph((imbinarize(adaptthresh(smoltmp.*(0.5.*tmp),0.5,'Statistic','gaussian','NeighborhoodSize',21))),'close')...
    | (imresize(imerode(smolactmask,strel('disk',15)),[x y],'nearest')),0.1)),120/10) ,[x y],'nearest') ;

clear smoltmp
clear tmp

Raw_MASK = imfill(imbinarize(GlobMask),'holes');
if sum(smolactmask(:))>0
    Focus_MASK = imbinarize((imgaussfilt(double(smolactmask),120/10)));
else
    Focus_MASK = smolactmask ;
end
Focus_MASK = imresize(Focus_MASK,[x y],'nearest') ;

clear GlobMask
clear smolactmask

STATS.AREA_TotalImage = size(HE_d,1)* size(HE_d,2) ;
STATS.AREA_RawTissue = sum(Raw_MASK(:)) ;
STATS.AREA_FocusTissue = sum(Focus_MASK(:));
STATS.PCT_Focus = 100* (STATS.AREA_FocusTissue/STATS.AREA_RawTissue);
STATS.PCT_Tissue = 100* (STATS.AREA_RawTissue/STATS.AREA_TotalImage);
STATS.globalPiqeScore = score ;

% channel histogram of pixels intensity ([0 255])
[countsI,~] = imhist(HE_d)       ;
CI          = countsI(2:end)          ;
sumR        = cumsum(100*CI./sum(CI)) ;
% FIND THE 95% cumulative limit
MAXR   = find(sumR>=95,1,'first')./255  ;
MINR   = 0./255                         ;
Emat = [MINR MAXR]                    ;
visDAPI  = zeros([size(HE_d),3],'like',HE_d);
visDAPI(:,:,2) = imadjust(HE_d,Emat,[]) ;

% clear HE_d
clear smolactmask
MASK = Raw_MASK ;
clear Raw_MASK




[vertPeaks_Coords,PCT_Ver_strip] = Stripe_Detection_module(HE_d,'Vertical') ;
[horiPeaks_Coords,PCT_Hor_strip] = Stripe_Detection_module(HE_d.*uint8(MASK),'Horizontal')  ;






if PCT_Ver_strip>50
    logtext = (['Image issue detected! ' num2str(PCT_Ver_strip) '% of Vertical Strips.' ]) ;
    app.TextArea.Value =[join(logtext,newline), app.TextArea.Value' ] ;
end

if PCT_Hor_strip>50
    logtext = (['Image issue detected! ' num2str(PCT_Hor_strip) '% of Horizontal Strips.' ]) ;
    app.TextArea.Value =[join(logtext,newline), app.TextArea.Value' ] ;
end

% if PCT_FakeFocus>50
%     logtext = (['Image issue detected! ' num2str(PCT_FakeFocus) '% of Fake Focus.' ]) ;
%     app.TextArea.Value =[join(logtext,newline), app.TextArea.Value' ] ;
%     
% end


clear HE_d



% size in micron :
pixtomu = str2double(ImageObj.MetaData.PixelSizeMicrons{1}) ;
Amicronfull = double((single(ImageObj.ImSize(1)) * pixtomu ) *  (single(ImageObj.ImSize(2)) * pixtomu )) ;
Atissue = double(STATS.PCT_Tissue * Amicronfull /100) ;
% Amicronfull*(1.*10^-8) ;
Atissue = Atissue.*(1.*10^-8) ;
Atissue = round(100*Atissue)./100 ;

% for display
HE_d_org = ImageObj.read(PageIndex);
try
    HE_d_org = imadjust(HE_d_org,[double(QuantileI(1))/255 double(QuantileI(5))/255],[0 1]);
catch
end


%Optional figure display
h= figure(1) ;
h.Visible = 'off' ;
drawnow ;
subplot(1,2,1)
imagesc(HE_d_org)
axis equal
axis off
title({['Input Image.'] ; ['Tissue area: ' num2str(Atissue) ' cm^{2}' ]},'Interpreter','Tex')
subplot(1,2,2)
imagesc(visDAPI)
hold on ; visboundaries(Focus_MASK,'Color',[0.5 0.5 0.5],'LineWidth',0.5,'EnhanceVisibility',false)
hold on ; visboundaries(MASK,'Color',[1 0 0],'LineWidth',0.5,'EnhanceVisibility',false)
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


%**************************************************************************
clear HE_d_org
clear visDAPI
clear Focus_MASK


ImageObj.createTif(DownsizeCoef) ;

Scanner = ImageObj.MetaData.AcquisitionSoftware ;
if contains(Scanner, 'KFBIO')
    ImageIndex =  str2double(ImageObj.MetaData.Magnification{1})/PageIndex ;
else
    ImageIndex =  PageIndex ;
end

if app.CheckBox.Value
    ImCat = 'HEIHC' ;
elseif app.CheckBox_3.Value
    ImCat = 'TCT' ;
    
end


% CORRECT IT TO TRUE ! PARALLEL 



fun = @(block_struct) QC_patchblurDetection_mask_3(ImageObj.Filename,block_struct,ImageIndex,Outfold,SlideID,MASK,ImageType,Scanner,ImCat,I0) ;
blockproc(ImageObj.Tmp_path,[256 256],fun,...
    'PadPartialBlocks',true,'BorderSize',[0 0],...
    'DisplayWaitbar',false,'UseParallel',true...
    ) ;













imds = imageDatastore(Outfold,'IncludeSubfolders',true);
Tiles = imds.Files ;
FocusMeasurement = zeros([1,numel(Tiles),1]);
BlurMeasurement = zeros([1,numel(Tiles),1]);
SaturationMeasurement = zeros([1,numel(Tiles)]) ;
ContrastMeasurement = zeros([1,numel(Tiles)]) ;
TextureMeasurement = zeros([1,numel(Tiles)]) ;
AreaWeight = zeros([1,numel(Tiles)]) ;
LOCvalues = zeros([numel(Tiles),2]);
XLoc = zeros([1,numel(Tiles)]) ;
YLoc = zeros([1,numel(Tiles)]) ;
parfor j = 1:numel(Tiles)
    FM =  extractBetween(Tiles{j},'FM_','_BM') ;
    BM =  extractBetween(Tiles{j},'BM_','_SM');
    SM =  extractBetween(Tiles{j},'SM_','_CM');
    CM =  extractBetween(Tiles{j},'CM_','_TM');
    TM =  extractBetween(Tiles{j},'TM_','_AW');
    LOC = extractBetween(Tiles{j},'Loc_','_FM');
    
    AW =  extractBetween(Tiles{j},'AW_','.png');
    
    tmpL = str2num(LOC{1}); %#ok<ST2NM>
    XLoc(j) =  tmpL(1) ;
    YLoc(j) =  tmpL(2) ;
    FocusMeasurement(j) =  str2double(FM{1});
    % inverse for positive scale:
    BlurMeasurement(j) = 1/str2double(BM{1}) ;
    % scale is 100 is no saturation --> 0 full saturation.
    SaturationMeasurement(j) = str2double(SM{1});
    ContrastMeasurement(j) = str2double(CM{1}) ;
    TextureMeasurement(j) = str2double(TM{1}) ;
    AreaWeight(j) = str2double(AW{1}) ;
end
LOCvalues(:,1) = XLoc ;
LOCvalues(:,2) = YLoc ;


% LIST OF THRESHOLDS FOR DAPI + CONFIG INFO :
Thresh = [] ;
Thresh.RootFolder = Dir_Extract(ImageObj.Filename,Dir_Num(ImageObj.Filename)-2) ;
Thresh.Image_Type = ImageType ;
Thresh.Image_Magnification = app.MagnificationDropDown.Value ;

Thresh.Focus =  app.ConfigFocus ;
Thresh.Artefacts =app.ConfigArtefacts ;
Thresh.Saturation = app.ConfigSaturation;
Thresh.Contrast =  app.ConfigContrast ;
Thresh.Uniformity = app.ConfigUniformity ;
Thresh.OverallQuality =app.ConfigOverallQuality ;

idxLowFM = FocusMeasurement<Thresh.Focus ;
% acceptable Artefacts BM<12  i.e ?
idxBlur = BlurMeasurement<Thresh.Artefacts ;
for k = 1:numel(idxBlur)
    if sum(ismember([LOCvalues(k,2):LOCvalues(k,2)+256-1],vertPeaks_Coords))>0 || ...
            sum(ismember([LOCvalues(k,1):LOCvalues(k,1)+256-1],horiPeaks_Coords))>0
        idxBlur(k)=1 ;
        BlurMeasurement(k) = Thresh.Artefacts/randi([2,12]) ;
      %  disp('strip Thing')
    end
end

% find tiles with 1% of pixels saturated ?
idxSaturated = SaturationMeasurement< Thresh.Saturation;
% find tiles with really low contrast:
idxLowcontrast = ContrastMeasurement<Thresh.Contrast;
% idx Low texture energy :
idxLowtexture  = TextureMeasurement<Thresh.Uniformity ;
for k = 1:numel(idxLowtexture)
    if sum(ismember([LOCvalues(k,2):LOCvalues(k,2)+256-1],vertPeaks_Coords))>0 || ...
            sum(ismember([LOCvalues(k,1):LOCvalues(k,1)+256-1],horiPeaks_Coords))>0
        idxLowtexture(k)=1 ;
        TextureMeasurement(k) = Thresh.Uniformity/randi([2,12]) ;
    end
end

% acceptableTOTAL TO AUTO INCLUDE FORCEFULLY ARTIFCTED TILES
QCallidx = (1.*idxLowFM + 1.*idxBlur + idxSaturated + idxLowcontrast  + idxLowtexture ) ;
% Trying to see what weights are meaningful.

% if Tiles has more than 2 criteria rejected consider it trully bad in
% final decision:
idxBAD = (QCallidx>=Thresh.OverallQuality);

%




% Try Area Weighted Stats:
Stats = [];
Stats2 = [] ;
Stats.Total =  sum(AreaWeight(:)) ;
Stats2.Pct_Total= 100* Stats.Total / Stats.Total;
Stats.OutofFocus =   sum(idxLowFM.*AreaWeight) ;
Stats2.Pct_OutofFocus= 100* Stats.OutofFocus / Stats.Total;
Stats.Artefacts =  sum(idxBlur.*AreaWeight) ;
Stats2.Pct_Artifact= 100* Stats.Artefacts / Stats.Total;
Stats.Saturated =   sum(idxSaturated.*AreaWeight) ;
Stats2.Pct_Saturated= 100* Stats.Saturated / Stats.Total;
Stats.LowContrast =  sum(idxLowcontrast.*AreaWeight) ;
Stats2.Pct_LowContrast= 100* Stats.LowContrast / Stats.Total;
Stats.LowTexture =  sum(idxLowtexture.*AreaWeight) ;
Stats2.Pct_LowTexture= 100* Stats.LowTexture / Stats.Total;
Stats.QC =   sum(idxBAD.*AreaWeight) ;
Stats2.Pct_QC = 100* Stats.QC / Stats.Total;



% FOCUS HEATMAP FIGURE AND CALCULATION:
HFM = double(zeros(size(MASK))) ;
for k = 1:numel(FocusMeasurement)
    
    HFM([LOCvalues(k,1):LOCvalues(k,1)+256-1],...
        [LOCvalues(k,2):LOCvalues(k,2)+256-1],:) ...
        = FocusMeasurement(k) ; %#ok<*NBRAK>
    
end
HeatMap_QC(MASK,(MASK.*HFM),SlideID,Outfold,'Focus',quantile(FocusMeasurement,0.99),Thresh.Focus)
clear HFM


% Artefacts HEATMAP FIGURE AND CALCULATION:
HBM = double(zeros(size(MASK))) ;
for k = 1:numel(BlurMeasurement)
    HBM([LOCvalues(k,1):LOCvalues(k,1)+256-1],...
        [LOCvalues(k,2):LOCvalues(k,2)+256-1],:) ...
        = BlurMeasurement(k) ;
    
end
HeatMap_QC(MASK,(MASK.*HBM),SlideID,Outfold,'Artefacts',1,Thresh.Artefacts)
clear HBM


% SaturationHEATMAP FIGURE AND CALCULATION:
HSM = double(zeros(size(MASK))) ;
for k = 1:numel(SaturationMeasurement)
    HSM([LOCvalues(k,1):LOCvalues(k,1)+256-1],...
        [LOCvalues(k,2):LOCvalues(k,2)+256-1],:) ...
        = SaturationMeasurement(k) ;
end
HeatMap_QC(MASK,(MASK.*HSM),SlideID,Outfold,'100 - Saturation',100,Thresh.Saturation)
clear HSM


% Contrasts HEATMAP FIGURE AND CALCULATION:
HCM = double(zeros(size(MASK))) ;
for k = 1:numel(ContrastMeasurement)
    HCM([LOCvalues(k,1):LOCvalues(k,1)+256-1],...
        [LOCvalues(k,2):LOCvalues(k,2)+256-1],:) ...
        = ContrastMeasurement(k) ;
end
HeatMap_QC(MASK,(MASK.*HCM),SlideID,Outfold,'Contrast (1%)',quantile(ContrastMeasurement,0.99),Thresh.Contrast)
clear HCM

% Texture HEATMAP FIGURE AND CALCULATION:
HTM = double(zeros(size(MASK))) ;
for k = 1:numel(TextureMeasurement)
    HTM([LOCvalues(k,1):LOCvalues(k,1)+256-1],...
        [LOCvalues(k,2):LOCvalues(k,2)+256-1],:) ...
        = TextureMeasurement(k) ;
end
HeatMap_QC(MASK,(MASK.*HTM),SlideID,Outfold,'Texture Uniformity',quantile(TextureMeasurement,0.99),Thresh.Uniformity)
clear HTM


QCALL = double(zeros(size(MASK))) ;
for k = 1:numel(BlurMeasurement)
    
    QCALL([LOCvalues(k,1):LOCvalues(k,1)+256-1],...
        [LOCvalues(k,2):LOCvalues(k,2)+256-1],:) ...
        = 6- QCallidx(k) ;
    %=  2-idxBAD(k) ;
end
% plot Heatmaps figures:
HeatMap_QC(MASK,(MASK.*QCALL),SlideID,Outfold,'QC',6,4.9)
QC_MASK = (MASK.*QCALL) ;
clear QCALL


% WRITING TABLE OUTPUT:
T1 = struct2table(Stats);
T2 =  struct2table(Stats2);
T2.Properties.VariableNames = T1.Properties.VariableNames ;
T = [T1;T2] ;
T.Properties.RowNames = {'Number of Tiles' ; '% of tiles'};
T2 = table( {STATS.AREA_TotalImage,100}',{STATS.AREA_RawTissue,STATS.PCT_Tissue}',{STATS.AREA_FocusTissue,STATS.PCT_Focus}',...
    'VariableNames',{'Total','Tissue','Focused'},'RowNames',{'Area in pixel','% of area'});
Ttitle = table({[SlideID ' Tile statistics:']});
Ttitle2 = table({[SlideID ' Area measurements:']})   ;

QCV = Stats2.Pct_QC ;
if  (QCV>=0 && QCV<=app.p1.Position(1) && STATS.PCT_Focus>=70)
    % All good
    Decision = 'Valid' ;
    Decval = 1;
elseif (QCV>app.p1.Position(1) && QCV <=app.p2.Position(1))
    Decision = 'ToCheck' ;
    Decval = 0.5;
elseif QCV>app.p2.Position(1)
    Decision = 'Rejected' ;
    Decval = 0;
elseif (STATS.PCT_Focus<70)
    % ERROR in
    Decision = 'possibleMaskError?' ;
    Decval = 0.5;
end



TDecision= table({Decision,Decval}','VariableNames',{'Quality_Check'});
% settings :
T3 = struct2table(Thresh);
T3.Properties.RowNames = {'Image & Threshold Config'};
Ttitle3 = table({[SlideID ' Settings:']});



WriteCsvTable_01(T,Ttitle,T2,Ttitle2,TDecision,T3,Ttitle3,Outfold,SlideID)

if ((app.SortSaveImageTilesCheckBox.Value) && (app.TrainingDataGenCheckBox.Value))
    Tile_Training_QC(Tiles,LOCvalues,(idxBAD==0),'Good')
    Tile_Training_QC(Tiles,LOCvalues,idxLowtexture,'Low_Texture')
    Tile_Training_QC(Tiles,LOCvalues,idxLowcontrast,'Low_Contrast')
    Tile_Training_QC(Tiles,LOCvalues,idxLowFM,'Out_of_Focus')
    Tile_Training_QC(Tiles,LOCvalues,idxBlur,'Artefacts')
    Tile_Training_QC(Tiles,LOCvalues,idxSaturated,'Over_Saturated')
    
    if contains(ImageObj.MetaData.AcquisitionSoftware, 'KFBIO')
        % initialise parameters:
        ImageIndex =  str2double(ImageObj.MetaData.Magnification{1}) ; % high resolution index.
        Tile_Sorting_QC_KFBIO_2(Tiles,LOCvalues,(idxBAD==0),'Good',ImageObj,DownsizeCoef,ImageIndex)
        Tile_Sorting_QC_KFBIO_2(Tiles,LOCvalues,idxLowtexture,'Low_Texture',ImageObj,DownsizeCoef,ImageIndex)
        Tile_Sorting_QC_KFBIO_2(Tiles,LOCvalues,idxLowcontrast,'Low_Contrast',ImageObj,DownsizeCoef,ImageIndex)
        Tile_Sorting_QC_KFBIO_2(Tiles,LOCvalues,idxLowFM,'Out_of_Focus',ImageObj,DownsizeCoef,ImageIndex)
        Tile_Sorting_QC_KFBIO_2(Tiles,LOCvalues,idxBlur,'Artefacts',ImageObj,DownsizeCoef,ImageIndex)
        Tile_Sorting_QC_KFBIO_2(Tiles,LOCvalues,idxSaturated,'Over_Saturated',ImageObj,DownsizeCoef,ImageIndex)
    else
        Tile_Sorting_QC(Tiles,LOCvalues,(idxBAD==0),'Good',ImageObj,DownsizeCoef)
        Tile_Sorting_QC(Tiles,LOCvalues,idxLowtexture,'Low_Texture',ImageObj,DownsizeCoef)
        Tile_Sorting_QC(Tiles,LOCvalues,idxLowcontrast,'Low_Contrast',ImageObj,DownsizeCoef)
        Tile_Sorting_QC(Tiles,LOCvalues,idxLowFM,'Out_of_Focus',ImageObj,DownsizeCoef)
        Tile_Sorting_QC(Tiles,LOCvalues,idxBlur,'Artefacts',ImageObj,DownsizeCoef)
        Tile_Sorting_QC(Tiles,LOCvalues,idxSaturated,'Over_Saturated',ImageObj,DownsizeCoef)
    end
    rmdir(Dir_Up(Tiles{1}), 's')
    
    % sort and Save Tiles or Delete the Tiles folder:
elseif (not(app.SortSaveImageTilesCheckBox.Value) && (app.TrainingDataGenCheckBox.Value))
    Tile_Training_QC(Tiles,LOCvalues,(idxBAD==0),'Good')
    Tile_Training_QC(Tiles,LOCvalues,idxLowtexture,'Low_Texture')
    Tile_Training_QC(Tiles,LOCvalues,idxLowcontrast,'Low_Contrast')
    Tile_Training_QC(Tiles,LOCvalues,idxLowFM,'Out_of_Focus')
    Tile_Training_QC(Tiles,LOCvalues,idxBlur,'Artefacts')
    Tile_Training_QC(Tiles,LOCvalues,idxSaturated,'Over_Saturated')
    rmdir(Dir_Up(Tiles{1}), 's')
    
elseif (app.SortSaveImageTilesCheckBox.Value && not(app.TrainingDataGenCheckBox.Value))
    if contains(ImageObj.MetaData.AcquisitionSoftware, 'KFBIO')
        % initialise parameters:
        ImageIndex =  str2double(ImageObj.MetaData.Magnification{1}) ; % high resolution index.
        Tile_Sorting_QC_KFBIO_2(Tiles,LOCvalues,(idxBAD==0),'Good',ImageObj,DownsizeCoef,ImageIndex)
        Tile_Sorting_QC_KFBIO_2(Tiles,LOCvalues,idxLowtexture,'Low_Texture',ImageObj,DownsizeCoef,ImageIndex)
        Tile_Sorting_QC_KFBIO_2(Tiles,LOCvalues,idxLowcontrast,'Low_Contrast',ImageObj,DownsizeCoef,ImageIndex)
        Tile_Sorting_QC_KFBIO_2(Tiles,LOCvalues,idxLowFM,'Out_of_Focus',ImageObj,DownsizeCoef,ImageIndex)
        Tile_Sorting_QC_KFBIO_2(Tiles,LOCvalues,idxBlur,'Artefacts',ImageObj,DownsizeCoef,ImageIndex)
        Tile_Sorting_QC_KFBIO_2(Tiles,LOCvalues,idxSaturated,'Over_Saturated',ImageObj,DownsizeCoef,ImageIndex)
    else
        Tile_Sorting_QC(Tiles,LOCvalues,(idxBAD==0),'Good',ImageObj,DownsizeCoef)
        Tile_Sorting_QC(Tiles,LOCvalues,idxLowtexture,'Low_Texture',ImageObj,DownsizeCoef)
        Tile_Sorting_QC(Tiles,LOCvalues,idxLowcontrast,'Low_Contrast',ImageObj,DownsizeCoef)
        Tile_Sorting_QC(Tiles,LOCvalues,idxLowFM,'Out_of_Focus',ImageObj,DownsizeCoef)
        Tile_Sorting_QC(Tiles,LOCvalues,idxBlur,'Artefacts',ImageObj,DownsizeCoef)
        Tile_Sorting_QC(Tiles,LOCvalues,idxSaturated,'Over_Saturated',ImageObj,DownsizeCoef)
    end
    rmdir(Dir_Up(Tiles{1}), 's')
else
    rmdir(Dir_Up(Tiles{1}), 's')
end



% SAVE LARGE MASK TIF:
if app.SaveHighResolutionMasksCheckBox.Value
    
    HighRez_RawMask =  imresize(MASK,[ImageObj.ImSize(1),ImageObj.ImSize(2)],'nearest') ;
    try imwrite(uint8(255.*(HighRez_RawMask>0)),[Dir_Up(Outfold) filesep SlideID '_RawMASK.tif']);
    catch
        disp('VERYBIGMASK')
        t = Tiff([Dir_Up(Outfold) filesep SlideID '_RawMASK.tif'],'w8');
        tagstruct.ImageLength = double(ImageObj.ImSize(1));
        tagstruct.ImageWidth = double(ImageObj.ImSize(2));
        tagstruct.Photometric = Tiff.Photometric.MinIsBlack;
        tagstruct.BitsPerSample = 8;
        tagstruct.SamplesPerPixel = 1;
        tagstruct.PlanarConfiguration = Tiff.PlanarConfiguration.Chunky;
        tagstruct.Software = 'IMCB';
        setTag(t,tagstruct)
        write(t,uint8(255.*(HighRez_RawMask>0)));
        close(t);
    end
    
    HighRez_QCMask =  imresize((QC_MASK>=2),[ImageObj.ImSize(1),ImageObj.ImSize(2)],'nearest') ;
    try imwrite(uint8(255.*(HighRez_QCMask>0)),[Dir_Up(Outfold) filesep SlideID '_QCMASK.tif']);
    catch
        t = Tiff([Dir_Up(Outfold) filesep SlideID '_QCMASK.tif'],'w8');
        tagstruct.ImageLength =  double(ImageObj.ImSize(1));
        tagstruct.ImageWidth =  double(ImageObj.ImSize(2));
        tagstruct.Photometric = Tiff.Photometric.MinIsBlack;
        tagstruct.BitsPerSample = 8;
        tagstruct.SamplesPerPixel = 1;
        tagstruct.PlanarConfiguration = Tiff.PlanarConfiguration.Chunky;
        tagstruct.Software = 'AImaginostic';
        setTag(t,tagstruct)
        write(t,uint8(255.*(HighRez_QCMask>0)));
        close(t);
    end
end

% delete created Temporary Tif file :
try
    if exist(ImageObj.Tmp_path,'file')
        delete(ImageObj.Tmp_path) ;
    end
catch
end