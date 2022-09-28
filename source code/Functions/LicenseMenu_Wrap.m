function app = LicenseMenu_Wrap(app)


            
  LampSwitch(app,'off','License Menu... ')
   selection  = '' ;
    DefaultOpt = 1 ; 
    while ~strcmp(selection,'3:Close')
    
% first try to read the license file (CHECK UUID)
[app.License,Hidxarray,msgboxText_LF] = READ_LICENSE_Aimag2(app.License_Path) ;      
% second  try to read the TimeStampLicense  file ( CHECK TIMESTAMP )
[TimeStampValue,msgboxText_TS] = READ_TimeStamp_Aimag2(app.TimeStamp_Path) ;    
  

    selection = License_File_Menu(app,DefaultOpt) ; 
    
    if strcmp(selection,'1:Key_Gen')
        DefaultOpt = 2  ; 
%        uialert(app.UIFigure, 'Activation KEY generated succesfully. please Restart the application once you have received the License File.','Activation Key','Icon','success')
 
    elseif  strcmp(selection,'2:Activation')
        
          DefaultOpt = 3  ; 
        
    elseif strcmp(selection,'3:Update')
        
         DefaultOpt = 3  ; 
         
     elseif strcmp(selection,'3:Close')
        
         DefaultOpt = 3  ;  
         if strcmp(msgboxText_LF,'License file is valid.')    
         else
             return
         end
    end
    
    
    end
    
    
    % seems to work call it again , to see how it is ?
    [app, msgboxText,status] =LICENSECHECKHICHECK2(app)  ;
    
    % Must call this after each LICENSECHECK2 FUNCTIONS
    switch status
        case -1
            app.UIFigure.Visible    = 'on' ;
            LampSwitch(app,'on','License Error! ')
            sel = uiconfirm(app.UIFigure,{msgboxText},...
                'License Error','Icon','error',...
                'Options',{'Ok','Exit'}...
                ,'DefaultOption',1,'CancelOption',2) ;
            switch sel
                case 'Ok'
                    app = LicenseMenu_Wrap(app) ;
                case 'Exit'
                    closereq
                    return
            end
            
        case 1
            LampSwitch(app,'off','Welcome to Aimag QC. ')
        case 0
             LampSwitch(app,'off','License Menu... ')
            app.UIFigure.Visible    = 'on' ;
            app = LicenseMenu_Wrap(app) ;
    end
    
            
    
    