function [app, msgboxText,status] =LICENSECHECKHICHECK2(app)
% check if license file exist and isnt corrupted.
% Author: Laurent GOLE, AIMAGINOSTIC PTE LTD ®. All Rights Reserved ©, 2020.
msgboxText = '' ;
status = -1 ;
%__________________________________________________________________________
% 1. DETECT LICENSE FILE INSIDE FOLDER:
Lfile = dir([app.Source_Path filesep '*.aimagl']) ;
if size(Lfile,1)==0
    disp('No License Files found on path')
    app.License_Path = '' ;
elseif size(Lfile,1)>1
    disp([ num2str(size(Lfile,1)) ' Licenses file conflicts.'])
    % in that case must ask user to select a specific license file ?
    [Lfile, ~] = uigetfile([app.Source_Path filesep '*.aimagl'],'Select specific Aimag_QC License File') ;
    app.License_Path =  [ app.Source_Path filesep Lfile] ;
elseif size(Lfile,1)==1
    app.License_Path =  [ app.Source_Path filesep Lfile.name] ;
end
% first try to read the license file (CHECK UUID)
[app.License,Hidxarray,msgboxText_LF] = READ_LICENSE_Aimag2(app.License_Path) ;
%
% 2. DETECT TIME STAMP  FILE INSIDE FOLDER:
TFile = dir([app.Source_Path filesep 'License' filesep '*.aimagl']) ;
if size(TFile,1)==0
    % NO TIME STAMP:
    app.TimeStamp_Path = '' ;
elseif size(TFile,1)>1
    % THIS CASE SHOULD NEVER HAPPEN:
    % in that case must ask user to select a specific timestamp file ?
    [TFile, ~] = uigetfile([app.Source_Path filesep 'License' filesep '*.aimagl'],'Select specific Aimag_QC TimeStamp File') ;
    app.TimeStamp_Path =  [ app.Source_Path filesep 'License' filesep TFile] ;
elseif size(TFile,1)==1
    app.TimeStamp_Path =  [ app.Source_Path filesep 'License' filesep TFile.name] ;
end
% second  try to read the TimeStampLicense  file ( CHECK TIMESTAMP )
[TimeStampValue,msgboxText_TS] = READ_TimeStamp_Aimag2(app.TimeStamp_Path) ;
%
% now check for errors and conditions:::
if contains(msgboxText_LF,'RLA2_6')
    % License file doesnt not exist.
    %$ prompt and ask for them to do KEYGEN.
    msgboxText = ' Create a License File '  ;
    % exit and go ask to create a License ? or aask to  activate it ??
    status =  0 ;
    app.UIFigure.Visible = 'on' ; 
    return
    
elseif contains(msgboxText_LF,'RLA2_25')
    %     UUID is not valid.
    % error of machine IDD meaning it s either trying other user or license on
    % other computer, fishy but possible alsao PC hardware change, must check
    % with them
    % must block the software and ask them to email us with error RLA2_25.
    msgboxText  = msgboxText_LF ;
    status =  -1 ;
    return
    
elseif contains(msgboxText_LF,'RLA2_46')
    %     CHECK SD KEY: that would be a fishy issue like trying to modify the
    %     string inside the license file i think...:
    % must block the software and ask them to email us with error RLA2_46.
    msgboxText  = msgboxText_LF ;
    status =  -1 ;
    return
    
elseif strcmp(msgboxText_LF,'License file is valid.')
    LicenseText = app.License(44:end);
    LDate = hex2num(( [ LicenseText(Hidxarray(1:8)),  '00000000'] )) ;
    Ltime = hex2num(( [ LicenseText(Hidxarray(1+8:8+8)),  '00000000'] )) ;
    DATEofINSTALLATION      =  LDate                                                            ;
    LicenseValidationTime   =  round(Ltime)                                                     ;
    DATEofEXPIRY            = datestr(DATEofINSTALLATION + LicenseValidationTime,'dd/mm/yyyy')  ;
    NUMOFEXPIRY             = datenum(DATEofEXPIRY,'dd/mm/yyyy')                                ;
     NowT = datenum(datetime('now')) ;
% TO SIMULAATE A FAKE EAARLY DATE : 
%      NowT = datenum(datetime('01/01/2019','Format','dd/MM/uuuu'))
    % Finally IF all SEEMS OK , COMPAARE LICENSE TIME LLEFT:
    CURRENTTIME     = datestr(NowT,'dd/mm/yyyy')            ;
    CURRENTNUM      = datenum(CURRENTTIME,'dd/mm/yyyy')         ;
end

if contains(msgboxText_TS,'RTSA2_6')
    % TimeStamp file doesnt not exist.
    % this should happen only the first time but not after ?
    % if this  haappen it  s WEIRDAF :
    msgboxText  = msgboxText_TS ;
    status = -1 ;
    return
    
elseif contains(msgboxText_TS,'RTSA2_25')
    %     atomField dsoesnt exist?
    msgboxText  = msgboxText_TS ;
    status =  -1 ;
    return
    
elseif contains(msgboxText_TS,'RTSA2_38') || contains(msgboxText_TS,'RTSA2_42') || contains(msgboxText_TS,'RTSA2_46')
    %   issue with DM,DA or DC , i.e timestamp was copiedd and or modified ?
    %   suspicious cases:
    msgboxText  = msgboxText_TS ;
    status =  -1 ;
    return
    
elseif strcmp(msgboxText_TS,'TimeStamp is valid.')
    % from now on all Files are Valid, Laast check to do is to check if
    % License is Expired or not
    % must compare time in stamp Vs time in licenseFile and also VS Curent Now Time on PC?
    TSV = (hex2num(TimeStampValue(1:16)));
    if TSV  < DATEofINSTALLATION
        % means the PC time is set to before LicenseFile Gen!
        %DELTA_VALUE = string(between(datetime(datestr(LGentime)),datetime(datestr(TSV))))
        msgboxText = ('Error LC2_112:: Please contact Aimaginostic Pte. Ltd. at info@aimaginostic.com.') ;
        status =  -1 ;
        return
    elseif NowT < TSV
        % means the current PC date time is WRONG!
        % DELTA_VALUE = string(between(datetime(datestr(TSV)),datetime(datestr(NowT))))
        msgboxText = ('Error LC2_118:: Please contact Aimaginostic Pte. Ltd. at info@aimaginostic.com.') ;
        status =  -1 ;
        return
    end
end

LICENSETIMELEFT = NUMOFEXPIRY - CURRENTNUM                  ;
% if License Time is up deny access to software.
if LICENSETIMELEFT <= 0
    msgboxText =  ['Error LC2_127:: License is expired. Please contact Aimaginostic Pte. Ltd. at info@aimaginostic.com' ];
    status =  -1 ;
    return
else
    msgboxText = ['License is valid for ' num2str(LICENSETIMELEFT) ' days.'];
    status = 1 ;
end