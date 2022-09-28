function HeatMap_QC(MASK,HM,SlideID,Outfold,Heattype,Valmax,Valmin)
% generate Heatmap figures for each Features of Quality Control
% Author: Laurent GOLE, AIMAGINOSTIC PTE LTD ®. All Rights Reserved ©, 2020.

hm = figure(401) ;
hm.MenuBar = 'None';
hm.ToolBar = 'None';
hm.Visible = 'off' ;

HM(HM>Valmax) = Valmax ;
if max(HM(:))<Valmax && ~isempty(HM(HM>Valmax))
    HM(HM==max(HM(:))) = Valmax ;
end

% 
% % THAT S WEIRD!:
% if max(HM(:))<Valmax
%     HM(HM==max(HM(:))) = Valmax ;
% end
imagesc(HM) ; title(['slide: ' SlideID ' ' Heattype ' Heatmap.'],'Interpreter','None')
AXESIDX = findobj(hm.Children,'Type','Axes') ;
hm.Color = [1 1 1 ] ; c =colorbar(AXESIDX) ;
c.Label.String = [Heattype ' Measurement (A.U)'];
c.Limits = [0 Valmax] ;

NCins = 5000 ;
ccmap = zeros(NCins,3) ;
PORTION1 = Valmin ./ Valmax ;
PORTION2 = 1 - PORTION1;
c2 = linspace(0,0.647,round(NCins*(PORTION1))) ;
for ci = 1:round(NCins*(PORTION1))
    ccmap(ci,:) = [1  c2(ci) 0 ] ;
end
c1 = linspace(1,0,round(NCins*(PORTION2))) ;
for ci = 1:round(NCins*(PORTION2))
    ccmap(ci+round(NCins*(PORTION1)),:) = [c1(ci) 1 0] ;
end
ccmap(1,:) = [0 0 0] ;
hm.Colormap = ccmap ;
hold on ; visboundaries(MASK,'color','w','EnhanceVisibility',false)
axis tight
axis equal
axis off

SAVEimagePath = [Dir_Up(Outfold) filesep SlideID '_' Heattype '_Heatmap.png'] ;
saveas(hm, SAVEimagePath, 'png');
close(hm) ;