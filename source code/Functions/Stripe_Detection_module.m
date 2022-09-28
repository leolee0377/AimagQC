function [Peaks_Coords,PCT_Strip] = Stripe_Detection_module(Image,Orientation)

switch Orientation
    case 'Vertical'
        Projection_Image =  smoothdata(mean(Image,1),'sgolay','SmoothingFactor',0.3,'Degree',4) ;
%         Projection_MASK = mean(Image>0,1) ;
        [~, ProjectionSize, ~] = size(Image) ;
    case 'Horizontal'
        Projection_Image =  smoothdata(mean(Image,2),'sgolay','SmoothingFactor',0.32,'Degree',4) ;
%         Projection_MASK = mean(~imdilate(Image<=0,strel('disk',150)),2) ;
        [ProjectionSize, ~, ~] = size(Image) ;
end
% 
% % remove points outside MASKS AREA
% Projection_Image(Projection_MASK==0)=[] ;
% % 
% 
% idx = 0 ; 
% for i = 1:numel(Sample_Points)
%     idx = idx+1 ; 
%     SP(Sample_Points(i)) = idx ;
%     
%     
% end


% Projection_Image.*(Image>0)

%
% TF1 = [] ; TF2 = [] ; TF = [] ;
xp = 1:numel(Projection_Image);
% TF1 = isoutlier(Ver_HE,'quartiles','ThresholdFactor',1.1)
[TF1] = islocalmax(Projection_Image,'MinProminence', 10,'MinSeparation',256,'ProminenceWindow',[128 128]);
[TF2] = islocalmin(Projection_Image,'MinProminence', 10,'MinSeparation',256,'ProminenceWindow',[128 128]);
TF = TF1 | TF2 ;
NumPeaks = max(sum(TF2),sum(TF1)) ;
peakdist = mean([diff(xp(TF1)) ,diff(xp(TF2))]) ;

if NumPeaks>=4
    Peaks_Coords = xp(islocalmax(TF,'FlatSelection','first','MinSeparation',256)) ;
    PCT_Strip = 100*floor((peakdist*NumPeaks)/ProjectionSize) ;
else
    Peaks_Coords =[] ;
    PCT_Strip = NaN ;
end


%
%
%
%
% % let s go detect Vertical/Horizontal Line!:
% Hor_HE = smoothdata(mean(HE_d,2),'sgolay','SmoothingFactor',0.3,'Degree',4) ;
% Projection_Image =  smoothdata(mean(HE_d,1),'sgolay','SmoothingFactor',0.3,'Degree',4) ;
%
% TF1 = [] ; TF2 = [] ; TF = [] ;
% xp = 1:numel(Projection_Image);
% % TF1 = isoutlier(Ver_HE,'quartiles','ThresholdFactor',1.1)
% [TF1] = islocalmax(Projection_Image,'MinProminence', 10,'MinSeparation',256,'ProminenceWindow',[128 128]);
% [TF2] = islocalmin(Projection_Image,'MinProminence', 10,'MinSeparation',256,'ProminenceWindow',[128 128]);
% TF = TF1 | TF2 ;
% NumPeaks = max(sum(TF2),sum(TF1)) ;
% peakdist = mean([diff(xp(TF1)) ,diff(xp(TF2))]) ;
% vertPeaks_Coords = xp(islocalmax(TF,'FlatSelection','first','MinSeparation',256)) ;
% PCT_Ver_strip = 100*(peakdist*NumPeaks)/y ;
%
% figure ; plot(xp,Projection_Image,xp(TF),Projection_Image(TF),'r*')
%
% % %
% % % vertPeaks_Coords = xp(islocalmax(TF,'FlatSelection','center')) ;
% % tmp = diff(xp(TF)) ;
% % peakwidth = (mean(tmp(tmp<0.5*peakdist))) ;
% % vertPeaks_Width = 2*round(peakwidth) ;
% % ;
% % rangepeaks = 0 ;
% % for l = 1:numel(vertPeaks_Coords)
% %     rangepeaks =vertcat(rangepeaks, [vertPeaks_Coords(l)-vertPeaks_Width : vertPeaks_Coords(l)+vertPeaks_Width]') ;
% % end
% % rangepeaks = rangepeaks(2:end-1) ;
%
% %PR = Pr1 + Pr2 ;
% % TF = isoutlier(Ver_HE,'mean','ThresholdFactor',3);
% % figure ; plot(xp,Ver_HE,xp(TF),Ver_HE(TF),'r*')
%
% % figure ; imagesc(HE_d)
%
%
% TF1 = [] ; TF2 = [] ; TF = [] ;
% xp = 1:numel(Hor_HE);
% [TF1,P1] = islocalmax(Hor_HE,'MinProminence', 10,'MinSeparation',256,'ProminenceWindow',256);
% [TF2,P2] = islocalmin(Hor_HE,'MinProminence',10,'MinSeparation',256,'ProminenceWindow',256);
% TF = TF1| TF2 ;
%
% NumPeaks = max(sum(TF2),sum(TF1)) ;
% peakdist = mean([diff(xp(TF1)) ,diff(xp(TF2))]) ;
% PCT_Hor_strip = 100*(peakdist*NumPeaks)/x ;
%
% horiPeaks_Coords = xp(islocalmax(TF,'FlatSelection','first','MinSeparation',256)) ;
% % horiPeaks_Coords = xp(TF) ;
% % tmp = diff(xp(TF)) ;
% % peakwidth = mean(tmp(tmp<0.5*peakdist),'omitnan') ;
% % Perc_Hor_strip = 100*(peakdist*NumPeaks)/x ;
%
% figure ; plot(xp,Hor_HE,xp(TF),Hor_HE(TF),'r*')
%
