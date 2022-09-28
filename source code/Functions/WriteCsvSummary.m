function WriteCsvSummary(Outfold,FOLDNAME)
%
% Outfold = 'D:\DATA\KFBIO_DATA\TCT_DATA\QualityControl_FINALPARALELLVERSION\T2017-32680'

Files = []; R = [];
warning('off','MATLAB:table:ModifiedVarnames')
warning('off','MATLAB:table:ModifiedAndSavedVarnames')

if exist([Outfold filesep FOLDNAME '_QC_Summary.csv'],'file')
    delete([Outfold filesep FOLDNAME '_QC_Summary.csv'])
end
csvds = datastore(Outfold,'Type','tabulartext', 'FileExtensions' , {'.csv'} , 'IncludeSubfolders',true) ;
Files = csvds.Files ;

if sum(contains(Files,'Summary.csv'))>=1
    Files(contains(Files,'Summary.csv'))=[] ;
end

if ~isempty(Files)
    ik = 0;
    for k = 1:numel(Files)
        k;
        ik = ik+1;
        Fname = strsplit(Files{k},filesep) ;
        Fname = Fname{end-1} ;
        T = readtable(Files{k});
        % in case for some eason the excel file is a wrong one:
        try T.QC(2) ;
        catch
            ik = ik-1 ;
            continue
        end
        
        % TO_DO ADD IMAGE TYPE AND MAGNIFICATION TO TABLE
        % SUMMARY
        R(ik).Image_Name = Fname ;
        try  R(ik).Image_Root = T.RootFolder{1} ;
        catch
            R(ik).Image_Root =T.RootFolder(1) ;
        end
        R(ik).Image_Type =  T.Image_Type{1} ;
        R(ik).Image_Magnification = T.Image_Magnification{1};
        R(ik).Low_Focus_Pct = (T.OutofFocus(2)) ;
        R(ik).Artifacts_Pct = (T.Artefacts(2)) ;
        R(ik).Low_Contrast_Pct = (T.LowContrast(2)) ;
        R(ik).Saturation_Pct = (T.Saturated(2)) ;
        R(ik).High_Uniformity_Pct = (T.LowTexture(2)) ;
        R(ik).Global_Low_Quality_Pct = (T.QC(2)) ;
        R(ik).Focus_Area_Pct =  (T.Focused(2)) ;
        R(ik).Tissue_Area_Pct =  (T.Tissue(2)) ;
        R(ik).Number_of_Tiles = (T.Total(1)) ;
        R(ik).Status = T.Quality_Check(1) ;
        R(ik).Cumulative_Pct_Approved =  round(100*100*(sum([R.Status] == categorical({'Valid'})))/(numel(Files)-1))/100 ;    
    end
    
    GTable = struct2table(R);
    
    try
        writetable(GTable,[Outfold filesep FOLDNAME '_QC_Summary.csv'])
    catch
        writetable(GTable,[Outfold filesep FOLDNAME '_' matlab.lang.makeValidName(char(datetime)) '_QC_Summary.csv'])
    end
    
    
end