function [FM,BM,SM,CM,TM] = QC_imageMeasurements_MF_2(BLOCKMASK,block)


% starts with I :
I = BLOCKMASK.*double(block) ;
Iorg = I ;
% entropy filtering large to detect texture ?
J = entropyfilt(block,true(21)) ;
% mask of the entropy active areas
entroMASK =  J>mean2(J) ;
% add up areas that are flat ( texture wise) but still higher intensity
Me = imbinarize(I.*~entroMASK,quantile(I(:),0.5)) ;
% cropp the masks
BLOCKMASK = BLOCKMASK &(entroMASK | Me );
I = BLOCKMASK.*double(I) ;



% FOCUS MEASUREMENT: ______________________________________________________
LAP = fspecial('laplacian');
ILAP = imfilter(Iorg, LAP, 'replicate', 'conv');
ILAP = ILAP.*(BLOCKMASK) ;
% measure for non zero elements , shld give a good tissue focus measurments.
FM = std(ILAP(ILAP~=0))^2 ;
%


% ARTEFACTS DETECTIONN_____________________________________________________
% take the bottom 10% of intensities
Minthresh_25 = quantile(I(I>0),0.25) ;
%
Idirt = I.*(I>Minthresh_25) .* ( entroMASK | Me) ;
%Idirt = I.*Me ;
% what sort of image to feed into opening ?
Imdirt = imopen(Idirt,strel('disk',12));
BM1 = quantile(Imdirt(:),0.99);
COEFBM =  10* mean2(J.*(bwmorph(Imdirt>=BM1,'Thin',1)));
% COEFILAPabs =100* mean2(abs(ILAP).*(bwmorph(Imdirt>=BM1,'Thin',1)));
BM = BM1*COEFBM ;
% perctange area of artefact
Art_area_pct= (100*sum(sum(Imdirt>BM))) /   (size(Imdirt,1) * size(Imdirt,2) ) ;

ARTEFACTCOEF = BM1 ;
if BM1<40
    % not an artefact:
    ARTEFACTCOEF = BM1  ;
end
if BM1>=40 && BM>=30
    % real Artefact tissue
    ARTEFACTCOEF = BM1  ;
end
if BM1>=40 && BM<30 && Art_area_pct<=10
    % blood clot? fake artefact not always... :
    ARTEFACTCOEF = BM  ;
end
if BM1>=40 && BM<30 && Art_area_pct>10
    %  consider as an artefact if it really takes a big space of the tile
    %  moe than 10%
    ARTEFACTCOEF = BM1  ;
end
BM = ARTEFACTCOEF ;


% CONTRAST MEASUREMENT ( Top1% +ve pixels - Bottom1% +ve pixels):__________
Qcontrast  = quantile(I(I>0),[0.01 0.99]) ;
CM = Qcontrast(2) - Qcontrast(1) ;


% SATURATION MEASUTREMENT:_________________________________________________
[countsR,~] = imhist(I./255)       ;
CR          = countsR(2:end)          ;
sumR        = cumsum(100*CR./sum(CR)) ;
SM = sumR(end-1) ;


% TEXTURE MEASUREMENT:_____________________________________________________
% measure edge variation absolute to highlight texture of tile ?:
TM =100* mean2(abs(ILAP)) ;











