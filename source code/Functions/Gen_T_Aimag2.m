function app = Gen_T_Aimag2(app)

[ app.License,~,~] = READ_LICENSE_Aimag2(app.License_Path)  ;
atomTime = [num2hex(datenum(datetime('now'))) ,  app.License(1:43) ]   ;

% 2. Create TimeStamp:
Poutreal = [app.Source_Path filesep 'License'] ;
Foutreal = ['AimagQC_Tstamp' '.aimagl'] ;
Pouttemp = [tempdir  'Aimag_tmpfiles'] ;
if ~exist(Pouttemp,'dir')
    mkdir(Pouttemp)
end
Fouttemp = strrep( Foutreal  , '.aimagl','.mat');
% write tempfile first:
save([Pouttemp filesep Fouttemp] ,'atomTime');
% convert into ainote format:
copyfile([Pouttemp filesep Fouttemp], [Poutreal filesep Foutreal],'f')
F_delete([Pouttemp filesep Fouttemp]);
app.TimeStamp_Path = [Poutreal filesep Foutreal] ; 