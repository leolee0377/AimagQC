function selection = License_File_Menu(app,DefaultOpt)
% DefaultOpt is 1 , 2 or 3 .
% IMCB all Rights Reserved. 2020. Laurent GOLE. 


selection = uiconfirm(app.UIFigure, {['1: Generate encrypted KEY and email it at info@aimaginostic.com'],...
    ['2: Activate the License File received by email.'],...
    ['Close: close the license file menu']}...
    ,'Software License Menu', 'Options',{'1:Key_Gen','2:Activation','3:Close'}...
    ,'DefaultOption',DefaultOpt,'CancelOption',3,'Icon','question');
%     ['3: Update the License File received by email.'],...

switch selection
    case '1:Key_Gen'
        
        LampSwitch(app,'on','Generate Activation Key.')
        try ID = [GetMachineID()] ;
        catch
        LampSwitch(app,'on','Fatal Err. GMID.')
        end
        [ActivationKey_file,ActivationKey_Path] = uiputfile('AimagQC_Activation_Key.txt','Save the activation Key') ;
        if ActivationKey_Path
            if ActivationKey_file
                writematrix(string(ID),[ActivationKey_Path filesep ActivationKey_file] ) ;
                drawnow
                    LampSwitch(app,'off','Key Gen Success.')
            end
        else
             LampSwitch(app,'off','Key Gen failed.')
        end
       
    case '2:Activation'
   % after ACTIVATION THE SOFTWARE SHOULD BE WORKING. 
        
        LampSwitch(app,'on','Activate License.')
        drawnow
        
        [LicenseKey_File,LicenseKey_Path]=  uigetfile({'.aimagl'} ,'Select License File',[app.Last_Path , '/'] );
        if LicenseKey_Path
            if LicenseKey_File
                [L] = dir([app.Source_Path filesep '*.aimagl']) ;
                for i = 1:numel(L)
                    F_delete([app.Source_Path filesep L.name])
                end
                copyfile( [LicenseKey_Path filesep LicenseKey_File] , [app.Source_Path filesep LicenseKey_File],'f');
                F_delete([LicenseKey_Path filesep LicenseKey_File]) ;
                %  A TIME STAMP IS GENERATED HERE DURING license
                app.License_Path  =  [app.Source_Path filesep LicenseKey_File]  ; 
               try app = Gen_T_Aimag2(app) ;
                    LampSwitch(app,'off','License Validation Success.')
                    drawnow
                    
               catch
                   LampSwitch(app,'off','License Validation failed.')
                  selection = 'Close' ;  
               end
            end
        else
                LampSwitch(app,'off','License Validation failed.')
        end

    case '3:Close'
     LampSwitch(app,'off','')
     return
 

end