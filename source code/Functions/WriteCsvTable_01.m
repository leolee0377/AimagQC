function WriteCsvTable_01(T,Ttitle,T2,Ttitle2,TDecision,T3,Ttitle3,Outfold,SlideID)
   

 T.Properties.VariableNames(3) = {'Artefacts'} ; 
 T2.Properties.VariableNames(1) = {'Total_Area'} ;
 T3.Properties.VariableNames(4) = {'Focus_Threshold'} ; 
 T3.Properties.VariableNames(5) = {'Artefact_Threshold'} ; 
 T3.Properties.VariableNames(6) = {'Saturation_Threshold'} ; 
 T3.Properties.VariableNames(7) = {'Contrast_Threshold'} ; 
 T3.Properties.VariableNames(8) = {'Texture_Threshold'} ; 
 
firstrow = [matlab.lang.makeValidName(Ttitle.Var1),T.Properties.VariableNames,...
    matlab.lang.makeValidName(Ttitle2.Var1),T2.Properties.VariableNames,...
    TDecision.Properties.VariableNames,...
    matlab.lang.makeValidName(Ttitle3.Var1),T3.Properties.VariableNames] ;


FullTable = table (T.Properties.RowNames,T(:,1).Variables,T(:,2).Variables,T(:,3).Variables,T(:,4).Variables,T(:,5).Variables,T(:,6).Variables,T(:,7).Variables,...
    T2.Properties.RowNames,T2(:,1).Variables,T2(:,2).Variables,T2(:,3).Variables,...
    TDecision.Variables,...
    [T3.Properties.RowNames,{''}]',[T3(:,1).Variables,{''}]',[T3(:,2).Variables,{''}]',[T3(:,3).Variables,{''}]',[T3(:,4).Variables,{''}]',[T3(:,5).Variables,{''}]',[T3(:,6).Variables,{''}]',[T3(:,7).Variables,{''}]',[T3(:,8).Variables,{''}]',[T3(:,9).Variables,{''}]',...
    'VariableNames',firstrow) ;

try
  writetable(FullTable, [Dir_Up(Outfold) filesep SlideID '_' 'Table.csv'],'WriteRowNames',true)
catch
    disp('File Already open in excel!')
    c = clock ;
    strrep(num2str(c(6)),'.','_')
    writetable(FullTable, [Dir_Up(Outfold) filesep SlideID '_' strrep(num2str(c(6)),'.','_') 'Table.csv'],'WriteRowNames',true)
  
end