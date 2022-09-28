function activation_code = GetMachineID()
% machine ID: 
% code to exectue on the machine that reqquest software activation 

[~,~,~,~,SysID] = getSystemInfo() ;

activation_code = DataHash(SysID,'SHA-256','HEX','array') ; 
% 
% disp('please send the returned activation code to info@aimaginostic.com ')

% 
% On my side store this value ( 43 long character into the license file 
% UUID2 = DataHash(activation_code,'SHA-256','HEX','short')

% then the software will read UUID from the license file and compare it
% with the machine ID 