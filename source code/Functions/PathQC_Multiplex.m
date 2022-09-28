function [QC_MASK,MASK,T,Decision] = PathQC_Multiplex(ImageObj,DownsizeCoef,app)
% main analysis routine for Fluorescence DAPI images:
% Author: Laurent GOLE, AIMAGINOSTIC PTE LTD ®. All Rights Reserved ©, 2020.

% % read the first DAPI image page:
% MGlobalmaskindex = (ImageObj.Indexes.Magnification == DownsizeCoef) ;
% PageIndex = ImageObj.Indexes.Channels{1}(MGlobalmaskindex) ;


mod = 0 ;
% read the first DAPI image page:
MGlobalmaskindex = (ImageObj.Indexes.Magnification == DownsizeCoef) ;
if ~sum(MGlobalmaskindex)
    DownsizeCoef = DownsizeCoef/2 ;
    MGlobalmaskindex = (ImageObj.Indexes.Magnification == DownsizeCoef) ;
    mod = 1;
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



%Outfold = [app.EditField.Value  filesep SlideID filesep 'Patches'] ;
ImageType = app.ImageTypeButtonGroup.SelectedObject.Tag ;
if ~exist(Outfold,'dir')
    mkdir(Outfold)
end

% READ THE DAPI IMAGE:
DAPI_d = ImageObj.read(PageIndex);


% min max adjustment normalization:
QuantileI = quantile(DAPI_d(:),[0 0.25 0.5 0.75 1]) ;
DAPI_d = imadjust(DAPI_d,[double(QuantileI(1))/255 double(QuantileI(5))/255],[0 1]);


if mod
    DAPI_d = imresize(DAPI_d,1/2) ; 
end

% 
% 
% % EXTRACT DOWNSIZE GLOBAL TISSUE MASK AND AREA STATS
% [Raw_MASK,~, STATS] = QC_MASKS(HE_d,Outfold,ImageObj,HE_d_org);
%  QC_MASKS(DAPI_d,Outfold,ImageObj,Im_org)

% EXTRACT DOWNSIZE GLOBAL TISSUE MASK AND AREA STATS
[Raw_MASK,~, STATS] = QC_MASKS_2(DAPI_d,Outfold,ImageObj,DAPI_d);
MASK = Raw_MASK ;



if mod
    MASK = imresize(MASK,2) ;
end



% temp tif file necessary for block proc in parallell
%tmppath = strrep(ImageObj.Filename,'.qptiff',['_tmp' num2str(DownsizeCoef) '.tif']) ;
ImageObj.createTif(DownsizeCoef) ;

 

if contains(ImageObj.MetaData.AcquisitionSoftware, 'KFBIO')
    % initialise parameters:
    IMAGE_PTR.DataFilePTR = 0 ;
    [~, IMAGE_PTR, ~] = calllib('lib','InitImageFileFunc',IMAGE_PTR,ImageObj.Filename) ;
   ImageIndex =  str2double(ImageObj.MetaData.Magnification{1})/PageIndex ;
    fun = @(block_struct) QC_patchblurDetection_mask_KFBIO(IMAGE_PTR,block_struct,ImageIndex,Outfold,SlideID,MASK,ImageType)  ;
    
blockproc(ImageObj.Tmp_path,[256 256],fun,...
    'PadPartialBlocks',true,'BorderSize',[0 0],...
    'DisplayWaitbar',false,'UseParallel',false...
    ) ;


else
    % TILE ANALYSIS MAIN CODE :
    fun = @(block_struct) QC_patchblurDetection_mask_2(ImageObj.Filename,block_struct,PageIndex,Outfold,SlideID,MASK,ImageType) ;
    
blockproc(ImageObj.Tmp_path,[256 256],fun,...
    'PadPartialBlocks',true,'BorderSize',[0 0],...
    'DisplayWaitbar',false,'UseParallel',true...
    ) ;


end






% % TILE ANALYSIS MAIN CODE :
% fun = @(block_struct) QC_patchblurDetection_mask_2(ImageObj.Filename,block_struct,PageIndex,Outfold,SlideID,MASK,ImageType) ;
% blockproc(ImageObj.Tmp_path,[256 256],fun,...
%     'PadPartialBlocks',true,'BorderSize',[0 0],...
%     'DisplayWaitbar',false,'UseParallel',true...
%     ) ;

imds = imageDatastore(Outfold,'IncludeSubfolders',true);
Tiles = imds.Files ;
FocusMeasurement = zeros([1,numel(Tiles),1]);
BlurMeasurement = zeros([1,numel(Tiles),1]);
SaturationMeasurement = zeros([1,numel(Tiles)]) ;
ContrastMeasurement = zeros([1,numel(Tiles)]) ;
TextureMeasurement = zeros([1,numel(Tiles)]) ;
LOCvalues = zeros([numel(Tiles),2]);
AreaWeight = zeros([1,numel(Tiles)]) ;
for j = 1:numel(Tiles)
    
     FM =  extractBetween(Tiles{j},'FM_','_BM') ;
    BM =  extractBetween(Tiles{j},'BM_','_SM');
    SM =  extractBetween(Tiles{j},'SM_','_CM');
    CM =  extractBetween(Tiles{j},'CM_','_TM');
    TM =  extractBetween(Tiles{j},'TM_','_AW');
    LOC = extractBetween(Tiles{j},'Loc_','_FM');
    
    AW =  extractBetween(Tiles{j},'AW_','.png');
    
    tmpL = str2num(LOC{1}); %#ok<ST2NM>
    LOCvalues(j,1) =  tmpL(1) ;
    LOCvalues(j,2) =  tmpL(2) ;
    FocusMeasurement(j) =  str2double(FM{1});
    % inverse for positive scale:
    BlurMeasurement(j) = 1/str2double(BM{1}) ;
    % scale is 100 is no saturation --> 0 full saturation.
    SaturationMeasurement(j) = str2double(SM{1});
    ContrastMeasurement(j) = str2double(CM{1}) ;
    TextureMeasurement(j) = str2double(TM{1}) ;
     AreaWeight(j) = str2double(AW{1}) ; 
end


% LIST OF THRESHOLDS FOR DAPI + CONFIG INFO :
Thresh = [] ;
Thresh.Image_Type = ImageType ;
Thresh.Image_Magnification = app.MagnificationDropDown.Value ;
% Thresh.Focus = 100 ;
% Thresh.Artefacts = 1/40 ;
% Thresh.Saturation = 90.0 ;
% Thresh.Contrast = 30 ;
% Thresh.Uniformity = 300 ;
% Thresh.OverallQuality = 2;
% 
% 
% % Focus used to set at 1800 revert back to 1000 now : 1000 too low . try
% % again but with 1300?
% Thresh.Focus = 1300 ;
% % artefact s trhesh  use to be 100 but it s too harsh ?
% Thresh.Artefacts = 1/130 ;
% Thresh.Saturation = 90.0 ;
% Thresh.Contrast = 70 ;
% Thresh.Uniformity = 900  ;
% Thresh.OverallQuality = 2;

Thresh.Focus =  app.ConfigFocus ;
% artefact s trhesh  use to be 100 but it s too harsh ?
Thresh.Artefacts =app.ConfigArtefacts ;
Thresh.Saturation = app.ConfigSaturation;
Thresh.Contrast =  app.ConfigContrast ;
Thresh.Uniformity = app.ConfigUniformity ;
Thresh.OverallQuality =app.ConfigOverallQuality ;



% acceptable FOCUS FM>=20
idxLowFM = FocusMeasurement<Thresh.Focus ;
% acceptable Artefacts BM<12  i.e ?
idxBlur = BlurMeasurement<Thresh.Artefacts ;
% find tiles with 1% of pixels saturated ?
idxSaturated = SaturationMeasurement< Thresh.Saturation;
% find tiles with really low contrast:
idxLowcontrast = ContrastMeasurement<Thresh.Contrast;
% idx Low texture energy :
idxLowtexture  = TextureMeasurement<Thresh.Uniformity ;

% acceptableTOTAL TO AUTO INCLUDE FORCEFULLY ARTIFCTED TILES
%idxALL = (idxLowFM | idxBlur | idxSaturated | idxLowcontrast  | idxLowtexture );
%QCallidx = (idxLowFM + idxBlur + idxSaturated + idxLowcontrast  + idxLowtexture ) ;
QCallidx = (2.*idxLowFM + 2.*idxBlur + idxSaturated + idxLowcontrast  + 2.*idxLowtexture ) ;
% only Artefacts and really LowFocus are hard threshold coded to be sure is always counted as
% bad , if only OOF and all the rest is ok then doesnt count as so bad?

% if Tiles has more than 2 criteria rejected consider it trully bad in
% final decision ?
idxBAD = (QCallidx>=Thresh.OverallQuality);




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

% 
% % just store the Tiles count in Structure:
% Stats = [];
% Stats2 = [] ;
% Stats.Total = numel(Tiles) ;
% Stats2.Pct_Total= 100* Stats.Total / Stats.Total;
% Stats.OutofFocus =   sum(idxLowFM(:)) ;
% Stats2.Pct_OutofFocus= 100* Stats.OutofFocus / Stats.Total;
% Stats.Artefacts = sum(idxBlur(:)) ;
% Stats2.Pct_Artifact= 100* Stats.Artefacts / Stats.Total;
% Stats.Saturated =   sum(idxSaturated(:)) ;
% Stats2.Pct_Saturated= 100* Stats.Saturated / Stats.Total;
% Stats.LowContrast = sum(idxLowcontrast(:)) ;
% Stats2.Pct_LowContrast= 100* Stats.LowContrast / Stats.Total;
% Stats.LowTexture = sum(idxLowtexture(:)) ;
% Stats2.Pct_LowTexture= 100* Stats.LowTexture / Stats.Total;
% Stats.QC =  sum(idxBAD(:)) ;
% Stats2.Pct_QC = 100* Stats.QC / Stats.Total;

% FOCUS HEATMAP FIGURE AND CALCULATION:
HFM = double(zeros(size(MASK))) ;
for k = 1:numel(FocusMeasurement)
    HFM([LOCvalues(k,1):LOCvalues(k,1)+256-1],...
        [LOCvalues(k,2):LOCvalues(k,2)+256-1],:) ...
        = FocusMeasurement(k) ; %#ok<*NBRAK>
end
% Artefacts HEATMAP FIGURE AND CALCULATION:
HBM = double(zeros(size(MASK))) ;
for k = 1:numel(BlurMeasurement)
    HBM([LOCvalues(k,1):LOCvalues(k,1)+256-1],...
        [LOCvalues(k,2):LOCvalues(k,2)+256-1],:) ...
        = BlurMeasurement(k) ;
end
% SaturationHEATMAP FIGURE AND CALCULATION:
HSM = double(zeros(size(MASK))) ;
for k = 1:numel(SaturationMeasurement)
    HSM([LOCvalues(k,1):LOCvalues(k,1)+256-1],...
        [LOCvalues(k,2):LOCvalues(k,2)+256-1],:) ...
        = SaturationMeasurement(k) ;
end
% Contrasts HEATMAP FIGURE AND CALCULATION:
HCM = double(zeros(size(MASK))) ;
for k = 1:numel(ContrastMeasurement)
    HCM([LOCvalues(k,1):LOCvalues(k,1)+256-1],...
        [LOCvalues(k,2):LOCvalues(k,2)+256-1],:) ...
        = ContrastMeasurement(k) ;
end
% Texture HEATMAP FIGURE AND CALCULATION:
HTM = double(zeros(size(MASK))) ;
for k = 1:numel(TextureMeasurement)
    HTM([LOCvalues(k,1):LOCvalues(k,1)+256-1],...
        [LOCvalues(k,2):LOCvalues(k,2)+256-1],:) ...
        = TextureMeasurement(k) ;
end

QCALL = double(zeros(size(MASK))) ;
for k = 1:numel(BlurMeasurement)
    QCALL([LOCvalues(k,1):LOCvalues(k,1)+256-1],...
        [LOCvalues(k,2):LOCvalues(k,2)+256-1],:) ...
        = 6- QCallidx(k) ;   
end

% plot Heatmaps figures
HeatMap_QC(MASK,(MASK.*HFM),SlideID,Outfold,'Focus',quantile(FocusMeasurement,0.99),Thresh.Focus)
HeatMap_QC(MASK,(MASK.*HBM),SlideID,Outfold,'Artefacts',1,Thresh.Artefacts)
HeatMap_QC(MASK,(MASK.*HSM),SlideID,Outfold,'100 - Saturation',100,Thresh.Saturation)
HeatMap_QC(MASK,(MASK.*HCM),SlideID,Outfold,'Contrast (1%)',quantile(ContrastMeasurement,0.99),Thresh.Contrast)
HeatMap_QC(MASK,(MASK.*HTM),SlideID,Outfold,'Texture Uniformity',quantile(TextureMeasurement,0.99),Thresh.Uniformity)
HeatMap_QC(MASK,(MASK.*QCALL),SlideID,Outfold,'QC',6,5.1)

QC_MASK = (MASK.*QCALL) ;

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
if  (QCV>=0 && QCV<=20 && STATS.PCT_Focus>=70)
    % All good
    Decision = 'Valid' ;
    Decval = 1;
elseif (QCV>20 && QCV <=40)
    Decision = 'ToCheck' ;
    Decval = 0.5;
elseif QCV>40
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




% 
 try 
     WriteExcelTable_01(T,Ttitle,T2,Ttitle2,TDecision,T3,Ttitle3,Outfold,SlideID)   
 catch
    WriteCsvTable_01(T,Ttitle,T2,Ttitle2,TDecision,T3,Ttitle3,Outfold,SlideID)  
 end



if ((app.SortSaveImageTilesCheckBox.Value) && (app.TrainingDataGenCheckBox.Value))
    Tile_Training_QC(Tiles,LOCvalues,(idxBAD==0),'Good')
    Tile_Training_QC(Tiles,LOCvalues,idxLowtexture,'Low_Texture')
    Tile_Training_QC(Tiles,LOCvalues,idxLowcontrast,'Low_Contrast')
    Tile_Training_QC(Tiles,LOCvalues,idxLowFM,'Out_of_Focus')
    Tile_Training_QC(Tiles,LOCvalues,idxBlur,'Artefacts')
    Tile_Training_QC(Tiles,LOCvalues,idxSaturated,'Over_Saturated')
    Tile_Sorting_QC(Tiles,LOCvalues,(idxBAD==0),'Good',ImageObj,DownsizeCoef)
    Tile_Sorting_QC(Tiles,LOCvalues,idxLowtexture,'Low_Texture',ImageObj,DownsizeCoef)
    Tile_Sorting_QC(Tiles,LOCvalues,idxLowcontrast,'Low_Contrast',ImageObj,DownsizeCoef)
    Tile_Sorting_QC(Tiles,LOCvalues,idxLowFM,'Out_of_Focus',ImageObj,DownsizeCoef)
    Tile_Sorting_QC(Tiles,LOCvalues,idxBlur,'Artefacts',ImageObj,DownsizeCoef)
    Tile_Sorting_QC(Tiles,LOCvalues,idxSaturated,'Over_Saturated',ImageObj,DownsizeCoef)
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
    Tile_Sorting_QC(Tiles,LOCvalues,(idxBAD==0),'Good',ImageObj,DownsizeCoef)
    Tile_Sorting_QC(Tiles,LOCvalues,idxLowtexture,'Low_Texture',ImageObj,DownsizeCoef)
    Tile_Sorting_QC(Tiles,LOCvalues,idxLowcontrast,'Low_Contrast',ImageObj,DownsizeCoef)
    Tile_Sorting_QC(Tiles,LOCvalues,idxLowFM,'Out_of_Focus',ImageObj,DownsizeCoef)
    Tile_Sorting_QC(Tiles,LOCvalues,idxBlur,'Artefacts',ImageObj,DownsizeCoef)
    Tile_Sorting_QC(Tiles,LOCvalues,idxSaturated,'Over_Saturated',ImageObj,DownsizeCoef)
    rmdir(Dir_Up(Tiles{1}), 's')
else
    rmdir(Dir_Up(Tiles{1}), 's')
end


% SAVE LARGE MASK TIF,might cause issues?
if app.SaveHighResolutionMasksCheckBox.Value
    
    HighRez_RawMask =  imresize(MASK,[ImageObj.ImSize(1),ImageObj.ImSize(2)],'nearest') ;
    try imwrite(uint8(255.*(HighRez_RawMask>0)),[Dir_Up(Outfold) filesep SlideID '_RawMASK.tif']);
    catch
        disp('VERYBIGMASK')
        t = Tiff([Dir_Up(Outfold) filesep SlideID '_RawMASK.tif'],'w8');
        tagstruct.ImageLength = ImageObj.ImSize(1);
        tagstruct.ImageWidth = ImageObj.ImSize(2);
        tagstruct.Photometric = Tiff.Photometric.MinIsBlack;
        tagstruct.BitsPerSample = 8;
        tagstruct.SamplesPerPixel = 1;
        tagstruct.PlanarConfiguration = Tiff.PlanarConfiguration.Chunky;
        tagstruct.Software = 'AImaginostic';
        setTag(t,tagstruct)
        write(t,uint8(255.*(HighRez_RawMask>0)));
        close(t);
    end
    HighRez_QCMask =  imresize((QC_MASK>=2),[ImageObj.ImSize(1),ImageObj.ImSize(2)],'nearest') ;
    try  imwrite(uint8(255.*(HighRez_QCMask>0)),[Dir_Up(Outfold) filesep SlideID '_QCMASK.tif']);
    catch
        t = Tiff([Dir_Up(Outfold) filesep SlideID '_QCMASK.tif'],'w8');
        tagstruct.ImageLength = ImageObj.ImSize(1);
        tagstruct.ImageWidth = ImageObj.ImSize(2);
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