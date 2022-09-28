function Optconfirm = outputfolderconfirm(app)
% check if output folder exist already and overwrite
% Author: Laurent GOLE, AIMAGINOSTIC PTE LTD ®. All Rights Reserved ©, 2020.

Optconfirm = 0 ;

if isempty(app.EditField.Value)
    LampSwitch(app,'off','Error! Output folder is empty, please redefine path.')
    return
end
if exist(app.EditField.Value,'dir')==7
    msg = 'Output folder already exist.';
    title = 'Confirm OutputFolder';
    selection = uiconfirm(app.UIFigure,msg,title,...
        'Options',{'Overwrite','Create New folder','Cancel'},...
        'DefaultOption',2,'CancelOption',3);
    
    switch selection
        case 'Overwrite'
            try rmdir(app.EditField.Value, 's')
            catch
                message = sprintf('Issue clearing output folder detected! \n please clear output folder before continuing...');
                uialert(app.UIFigure,message,'Warning',...
                    'Icon','warning');
                logtext = ('Issue clearing output folder detected.');
                
                app.TextArea.Value =[join(logtext,newline), app.TextArea.Value' ] ;
                
                LampSwitch(app,'off','') ;
                return
            end
            pause(0.5)
            mkdir(app.EditField.Value)
            logtext = (['Overwriting existing OutputFolder: ' app.EditField.Value]);
            
            app.TextArea.Value =[join(logtext,newline), app.TextArea.Value' ] ;
        case 'Create New folder'
            tmp = strsplit(app.EditField.Value,filesep) ;
            tmp = strjoin(tmp(1:end-1),filesep) ;
            app.EditField.Value = [tmp filesep 'QualityControl_' matlab.lang.makeValidName(char(datetime))] ;
            mkdir(app.EditField.Value);
            logtext = (['Creating New OutputFolder: ' app.EditField.Value]);
            
            app.TextArea.Value =[join(logtext,newline), app.TextArea.Value' ] ;
        case 'Cancel'
            LampSwitch(app,'off','') ;
            logtext = (['please change outputfolder: ' app.EditField.Value]);
            app.TextArea.Value =[join(logtext,newline), app.TextArea.Value' ] ;
            return
    end
else
    mkdir(app.EditField.Value);
end

Tmp = table(1) ;
try writetable(Tmp,[app.Input_Path filesep 'QualityControl.xlsx'])
    pause(1)
    delete([app.Input_Path filesep 'QualityControl.xlsx'])
catch
    message = sprintf('Issue writing excel file detected! \n please close any Excel File before continuing...');
    uialert(app.UIFigure,message,'Warning',...
        'Icon','warning');
    logtext = ('Error writing excel file. Please close Excel software while running the image Quality Control Application.');
    app.TextArea.Value =[join(logtext,newline), app.TextArea.Value' ] ;
    LampSwitch(app,'off','') ;
    return
end

% if it reaches here means "return" never got triggered:
Optconfirm = 1; 