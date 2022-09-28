function [imds,app]= CleanFolders_QC(imds,rootFolders,app)
% remove file with incorrect format from list of folder
% Author: Laurent GOLE, AIMAGINOSTIC PTE LTD ®. All Rights Reserved ©, 2020.


% check if some images are in the same folder:
for j = 1:numel(imds.Files)
    tmp =    imds.Files{j} ;
    tmp =   strsplit(tmp,filesep) ;
    rootpatheach{j} = strjoin(tmp(1:end-1),filesep) ; %#ok<*AGROW>
end
similarfolder = [] ;
for k=1:numel(imds.Files)-1
    for m = k+1:numel(imds.Files)
        similarfolder(k,m) =   strcmp(rootpatheach{k},rootpatheach{m}) ;
    end
end

[K,M] = ind2sub([numel(imds.Files)-1,numel(imds.Files)],find(similarfolder==1)) ;
idxtochange = unique([K,M]) ;

if ~isempty(similarfolder)
    %            do nothing
end


for n = 1:numel(idxtochange)
    orgfile = imds.Files{idxtochange(n)} ;
    tmp =     imds.Files{idxtochange(n)} ;
    tmp =   strsplit(tmp,filesep) ;
    newfile = strjoin([strjoin(tmp(1:end-1),filesep) filesep strrep(tmp(end),app.FileFormat,'') '_' num2str(idxtochange(n)) filesep  tmp{end}],'') ;
    mkdir([rootpatheach{idxtochange(n)} filesep strrep(tmp{end},app.FileFormat,'') '_' num2str(idxtochange(n))]);
    movefile(orgfile,newfile)
end
% find all  images within specified folder path and subfolders:
try imds = imageDatastore(rootFolders,'FileExtensions',app.FileFormat,'IncludeSubfolders',true) ;
    
    % do a quick check of all images and remove wrong images:
    formatCheck = CheckFileFormat(imds.Files,app.FileFormat);
    idx = 0;IDXdelete=[];
    for k = 1:numel(formatCheck)
        if formatCheck(k)==0
            idx = idx+1 ;
            IDXdelete(idx) = k ;
        end
    end
    imds.Files(IDXdelete) = [] ;
    
catch
    logtext = (['Error! no ' app.FileFormatDropDown.Value ' images detected in "' rootFolders '"']);
    app.TextArea.Value = [join(app.TextArea.Value,newline) logtext] ;
    figure(app.UIFigure)
    return
end