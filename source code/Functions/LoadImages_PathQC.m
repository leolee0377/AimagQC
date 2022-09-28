function LoadImages_PathQC(app)
% load the list of image for Aimag QC
% Author: Laurent GOLE, AIMAGINOSTIC PTE LTD ®. All Rights Reserved ©, 2020.

  %logtext = (['Error! no ' FileTYPE ' images detected in "' rootFolders '"']);
    app.TextArea.Value =['_________________________________________________________________________'] ;
  




app.FileFormat = app.FileFormatDropDown.Value;
FileTYPE = app.FileFormatDropDown.Items{contains(app.FileFormatDropDown.ItemsData,app.FileFormatDropDown.Value)} ;
rootFolders =  uigetdir(app.Last_Path,['get root folder to search for all ' FileTYPE ' files']) ;
if rootFolders==0
    logtext = ('no folder selected');
    app.TextArea.Value =[join(logtext,newline), app.TextArea.Value' ] ;
    figure(app.UIFigure)
    Lamp_index(app,'off') ;
    return
end

if strcmp(app.FileFormat,'.ome.tif')
    orgappformat = app.FileFormat ;
    app.FileFormat = '.tif' ;
else
       orgappformat = app.FileFormat ;
end
% find all  images with folder and subfolders
try imds = imageDatastore(rootFolders,'FileExtensions',app.FileFormat,'IncludeSubfolders',true) ;
    % do a quick check of all images and remove wrong images:
     app.FileFormat =   orgappformat;
    formatCheck = CheckFileFormat(imds.Files,app.FileFormat);
    idx = 0;IDXdelete=[];
    for k = 1:numel(formatCheck)
        if formatCheck(k)==0
            idx = idx+1 ;
            IDXdelete(idx) = k ; %#ok<AGROW>
        end
    end
    imds.Files(IDXdelete) = [] ;
    
catch
    logtext = (['Error! no ' FileTYPE ' images detected in "' rootFolders '"']);
    app.TextArea.Value =[join(logtext,newline), app.TextArea.Value' ] ;
    
    
    figure(app.UIFigure)
    LampSwitch(app,'off','')
    
    return
end


% move file to separate unique folders if folder contains
% multiple file:
[imds,app]= CleanFolders_QC(imds,rootFolders,app) ;


app.ListBox.Items = imds.Files;
app.Input_Path = rootFolders ;

% add default export path as rootfolder:
app.EditField.Value = [rootFolders filesep 'QualityControl'] ;


N = numel(app.ListBox.Items) ;
app.NimagesLabel.Text = [num2str(N) ' images'] ;

figure(app.UIFigure)

logtext = ([num2str(N) ' ' FileTYPE ' images detected in "' rootFolders '"']);
app.TextArea.Value =[join(logtext,newline), app.TextArea.Value' ] ;