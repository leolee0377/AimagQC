function [FM,BM,SM,CM,TM] = QC_imageMeasurements_BF_2(BLOCKMASK,block)


% Image ROI EXTRACTION_____________________________________________________
% starts with I :
I = BLOCKMASK.*double(block) ;
% save original Image input:
Iorg = double(block) ;
% entropy filtering large to detect texture ?
J = entropyfilt(block,true(21)) ;
% mask of the entropy active areas
entroMASK =  J>mean2(J) ;
% add up areas that are flat ( texture wise) but still higher intensity
Me = imbinarize(I.*~entroMASK,quantile(I(:),0.5)) ;
% cropp the mask:
BLOCKMASK = BLOCKMASK &(entroMASK | Me );
% BLOCKMASK = imdilate(BLOCKMASK,strel('disk',5)) ; 


% Cropped Image:
I = BLOCKMASK.*double(I) ;

%1) FOCUS MEASUREMENT________________________________________________________
LAP = fspecial('laplacian');
ILAP = imfilter(Iorg, LAP, 'replicate', 'conv');
ILAP = ILAP.*(BLOCKMASK) ;


% MEDFILTERING TO TEST FOR FAKEFOCUS ISSUE: % super large filter to remove
% all cells or dust in focus ? and keep only really really bakg ?
MF = medfilt2(Iorg,[35,35]) ;
MLAP = imfilter(double(MF), LAP, 'replicate', 'conv');
MLAP = MLAP.*(BLOCKMASK) ;

% measure for non zero elements , shld give a good tissue focus measurments.


FMI = std(ILAP(I>(255*graythresh(I))))^2 ;
FMM = std(MLAP(MF>0.7*(255*graythresh(MF))))^2 ;

FM = FMI ;
FakeFocus_Trheshold = 1; 
if (FMM<FakeFocus_Trheshold && FMM>0)
  %  disp(['FakeFocus: ' num2str(FMM)])
    FM = 10*FMM ; 
end  
% 
% % measure for non zero elements , shld give a good tissue focus measurments.
% FM = std(ILAP(ILAP~=0))^2 ;
%
if isnan(FM)
   disp('FM is NaN? DEBUG HERE in QC_imageMeasurements_BF_2.m')
   FM = 0 ;
    
end


%2) Artefacts DETECTION by Openning_________________________________________
Minthresh_25 = quantile(I(I>0),0.25) ;
Idirt = I.*(I>Minthresh_25) .* ( entroMASK | Me) ;
Imdirt = imopen(Idirt,strel('disk',12));
BM1 = quantile(Imdirt(:),0.99);
COEFBM =  10* mean2(J.*(bwmorph(Imdirt>=BM1,'Thin',1)));
COEFILAPabs =100* mean2(abs(ILAP).*(bwmorph(Imdirt>=BM1,'Thin',1)));
BM = BM1*COEFBM ;

% perctange area of artefact
Art_area_pct= (100*sum(sum(Imdirt>BM))) /   (size(Imdirt,1) * size(Imdirt,2) ) ;

ARTEFACTCOEF = BM1 ;

if BM1<100
    % not an artefact:
    ARTEFACTCOEF = BM1  ;
end

if BM1>=150 && BM>=80
    % real folded tissue
    ARTEFACTCOEF = BM1  ;
end

if BM1>=150 && BM<80 && Art_area_pct<=10
    % blood clot? fake artefact not always... :
    ARTEFACTCOEF = BM  ;
end

if BM1>=150 && BM<80 && Art_area_pct>10
    %  consider as an artefact if it really takes a big space of the tile
    %  moe than 10%
    ARTEFACTCOEF = BM1  ;
end

if BM1>=100 && BM1<150 && BM>100 && COEFILAPabs <20
    % medium range real artefact
    ARTEFACTCOEF = max(BM1,BM)  ;    
end

if BM1>=100 && BM1<150 && BM>100 && COEFILAPabs >=20
    % medium range fake artefact , sometimes it s slightly blurred can
    % include if necessary? but prefer consider not artefacts at the moment
    % as it doenst affect the image quality that much.
    ARTEFACTCOEF = min(99,COEFILAPabs)  ;    
end

if BM1>=100 && BM1<150 && BM<100 && COEFILAPabs <20
    %can be blur too!
    ARTEFACTCOEF = BM1 ;
    
end

if BM1>=100 && BM1<150 && BM<100 && COEFILAPabs >=20
    % medium range fake artefact but can be blur too!
    ARTEFACTCOEF = BM ;
    
end

BM = ARTEFACTCOEF ;


%3) CONTRAST MEASUREMENT ( Top1% +ve pixels - Bottom1% +ve pixels)___________
Qcontrast  = quantile(I(I>0),[0.01 0.99]) ;
CM = Qcontrast(2) - Qcontrast(1) ;



%4) SATURATIONN MEASUREMENT: ________________________________________________
[countsR,~] = imhist(I./255)       ;
CR          = countsR(2:end)          ;
sumR        = cumsum(100*CR./sum(CR)) ;
SM = sumR(end-1) ;


%5) TEXTURE MEASUREMENT:_____________________________________________________
% measure edge variation absolute to highlight texture of tile ?:

if (FMM<FakeFocus_Trheshold && FMM>0)
    TM =100* mean2(abs(MLAP)) ;
else
TM =500* mean2(abs(ILAP)) ;
end



% DEBUG FIGURE :
% figure(101)
%
% subplot(2,3,1)
% imagesc(Iorg) ; title('original image')
% axis equal
% axis tight
% axis off
% subplot(2,3,2)
% imagesc(BLOCKMASK) ; title ('MASK')
% axis equal
% axis tight
% axis off
%
% subplot(2,3,3)
% imagesc(ILAP) ; title(['ILAP FM: ' num2str(FM)])
% axis equal
% axis tight
% axis off
%
%
% subplot(2,3,4)
% imagesc(Imdirt) ; title(['artefact: ' num2str(BM)])
% axis equal
% axis tight
% axis off
%
% subplot(2,3,5)
% imagesc(I) ; title('I')
% axis equal
% axis tight
% axis off
% drawnow
