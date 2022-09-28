function [random_string,Hidxarray,msgboxText] = READ_LICENSE_Aimag2(LicensePath)
% CONFIDENTIAL AIMAGINOSTIC PTE. LTD. LAURENT GOLE,  ALL RIGHTS RESERVED 2020.
Hidxarray = 0 ;
%1. Check if file exist:
if ~exist(LicensePath,'file')
    msgboxText= ('Error RLA2_6:: License file does not exist.') ;
    random_string ='' ;
    return
end
Poutreal = Dir_Up(LicensePath) ;
Foutreal = Dir_Extract(LicensePath,Dir_Num(LicensePath)) ;
Pouttemp = [tempdir  'Aimag_tmpfiles'] ;
if ~exist(Pouttemp,'dir')
    mkdir(Pouttemp)
end
Fouttemp = strrep( Foutreal  , '.aimagl','.mat');
copyfile([Poutreal filesep Foutreal],[Pouttemp filesep Fouttemp],'f') ;
L = load([Pouttemp filesep Fouttemp]);
%
F_delete([Pouttemp filesep Fouttemp]) ;
%2. CHECK  Unique User ID:
UUID = L.random_string(1:43);
% COMPARE THIS UUID TO THE current MACHINE AND USER!
if ~strcmp(UUID,DataHash(GetMachineID(),'SHA-256','HEX','short'))
    msgboxText  = ('Error RLA2_25:: License file UUID is not valid.');
    random_string = '' ;
    return
end
%3. CHECK SD KEY:
random_string = L.random_string(44:end);
ttt = char("'0000000040f8392000000000hng121220000012412amg0101070000004112lg310186800000004127ca4000000000412b000'") ;
tt2 = char("'0000000410bdf2800000000412368180000000041066d20000000004125612c00000000411be8a800000000412ca8b0000000'");
idxarray = hex2num(random_string(end-15:end)) ;
Hidxarray = random_string(idxarray:idxarray+511);
Keyidx = [19 25 24 30 26 12 32 1 5 23 8 14 9 16 13 31];
Hidxarray = rot90(reshape(Hidxarray,16,32),-1) ;
Hidxarray = Hidxarray(Keyidx,:);
try Hidxarray = hex2num(Hidxarray)' ;
catch
    Hidxarray = 0 ;
end
CHECK1 = strcmp(random_string(1:99),ttt(2:end-2)) ;
CHECK2 = contains(random_string,tt2(2:end-2)) ;
CHECK3 = (sum(Hidxarray)==8190795) ; %#ok<UDIM>
if (CHECK1 + CHECK2 + CHECK3 )~=3
    msgboxText = ('Error RLA2_46:: License file UUID is not valid.');
    random_string = '' ;
    return
else
    msgboxText = ('License file is valid.') ;
end
% return license if all 3 steps succeed .
random_string = [UUID, random_string] ;