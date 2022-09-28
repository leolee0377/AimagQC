function [TimeStampValue,msgboxText] = READ_TimeStamp_Aimag2(TimeStampPath)
% CONFIDENTIAL AIMAGINOSTIC PTE. LTD. LAURENT GOLE,  ALL RIGHTS RESERVED 2020.

%1. Check if file exist:
if ~exist(TimeStampPath,'file')
    msgboxText= ('Error RTSA2_6:: Time Stamp file doesnt not exist.') ;
    TimeStampValue ='' ;
    return
end
%
% 2. Read TimeStamp:
Poutreal = Dir_Up(TimeStampPath) ;
Foutreal = Dir_Extract(TimeStampPath,Dir_Num(TimeStampPath)) ;
Pouttemp = [tempdir  'Aimag_tmpfiles'] ;
if ~exist(Pouttemp,'dir')
    mkdir(Pouttemp)
end
Fouttemp = strrep( Foutreal  , '.aimagl','.mat');
copyfile([Poutreal filesep Foutreal],[Pouttemp filesep Fouttemp],'f') ;
L = load([Pouttemp filesep Fouttemp]);
F_delete([Pouttemp filesep Fouttemp]);
if isfield(L,'atomTime')
    msgboxText = ('TimeStamp is valid.') ;
    TimeStampValue = L.atomTime ;
else
    msgboxText= ('Error RTSA2_25:: Time Stamp file corrupted.') ;
    TimeStampValue ='' ;
    return
end

%
% 3. check for tampering on: 




DM = dir(TimeStampPath) ;
try 
DM = datenum(datetime(DM.date,'Locale','en_US')) ;
catch
DM = datenum(datetime(DM.date,'Locale','zh_cn')) ;
end
% DA = datenum(  getdateaccessed(TimeStampPath));
% DM = datenum( getdatemodified(TimeStampPath));
% DC = datenum( getdatecreated(TimeStampPath)) ;
CurrentD = (hex2num(TimeStampValue(1:16))) ;
disp(num2str((CurrentD - DM)))
if (CurrentD - DM)< 0
    % Those Error MEANS SOME TAMPERING ( Copying etc  may have happened on
    % those Temporary files?) 
     msgboxText = ('Error RTSA2_38:: Please contact Aimaginostic Pte. Ltd. at info@aimaginostic.com.');
    TimeStampValue = '' ;
    return
% elseif (CurrentD - DA) < -0.0050
%     msgboxText = ('Error RTSA2_42:: Please contact Aimaginostic Pte. Ltd. at info@aimaginostic.com.');
%     TimeStampValue = '' ;
%     return
% elseif (CurrentD - DC)< -0.0050 % -0.01
%        msgboxText = ('Error RTSA2_46:: Please contact Aimaginostic Pte. Ltd. at info@aimaginostic.com.');
%     TimeStampValue = '' ;
%     return 
end


