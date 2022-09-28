function app = CN_2_EN(app)



TLfile = [app.Source_Path filesep 'Functions' filesep 'Aimag_QC_Translation.csv' ] ;
T=readtable(TLfile,'encoding','UTF-8');

% now find all fields in UI:
allObj = findall(app.UIFigure) ;

allTitle = findobj(allObj,'-property','Title') ;
for i = 1:numel(allTitle)
    i ;
    if (~isempty(allTitle(i).Title) && (strcmp(allTitle((i)).Type,'axes'))==0)
        IDX = find(strcmp(allTitle(i).Title,T.T2)) ;
        if ~isempty(IDX)
            allTitle(i).Title = T.T1{IDX} ;
        end
    end
end



allText = findobj(allObj,'-property','Text') ;
for i = 1:numel(allText)
    if ~isempty(allText(i).Text)
        IDX = find(strcmp(allText(i).Text,T.T2)) ;
        if ~isempty(IDX)
            allText(i).Text = T.T1{IDX} ;
        end
    end
end



allString = findobj(allObj,'-property','String') ;
for i = 1:numel(allString)
    if ~isempty(allString(i).String)
        IDX = find(strcmp(allString(i).String,T.T2)) ;
        if ~isempty(IDX)
            allString(i).String = T.T1{IDX} ;
        end
    end
end



