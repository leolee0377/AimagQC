function [Serialnumber,CDriveID,MacAddress,SID,UNIQUEID] = getSystemInfo()

[~,cmdout] = system('wmic bios get serialnumber') ;
cmdout = erase(cmdout,newline) ;
cmdout = erase(cmdout,char(13)) ;
cmdout = strsplit(cmdout,' ') ;
Serialnumber =  string(cmdout{2}) ;

[~,cmdout] = system('vol c:') ;
cmdout = erase(cmdout,newline) ;
cmdout = erase(cmdout,char(13)) ;
cmdout = strsplit(cmdout,' ') ;
CDriveID = string(cmdout{end}) ;

[~,cmdout] = system('getmac') ;
cmdout = erase(cmdout,newline) ;
cmdout = erase(cmdout,char(13)) ;
cmdout = erase(cmdout,'=') ;
cmdout = strsplit(cmdout,' ') ;
MacAddress = string(cmdout{5}) ;

[~,cmdout] = system('wmic useraccount where name=''%username%'' get sid');
cmdout = erase(cmdout,newline) ;
cmdout = erase(cmdout,char(13)) ;
cmdout = strsplit(cmdout,' ') ;
SID = string(cmdout{2}) ; 

UNIQUEID = strcat(SID,Serialnumber,CDriveID,MacAddress) ; 