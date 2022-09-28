function status = F_delete(filename)
%% Delete a File: 
% if 1: file is correctly deleted
% if 0:  file doesnt exist.

if strcmp(filename(end),filesep)
    filename = filename(1:end-1);
end

fIDs = fopen('all');
nmax = length(fIDs);
found = false;
m = 0;
for n=1:nmax
    filename_comp = fopen(fIDs(n));
    if strcmp(filename_comp,filename)
        found = true;
        m=m+1;
        index(m) = n;               %#ok<AGROW>
    end
end
if found
    fID = fIDs(index);
else
    fID = -1;
end
if all(fID ~= -1)
    pmax = length(fID);
    for p = 1:pmax
        fclose(fID(p));
    end
end
if exist(filename,'file')
    delete(filename);
    status = 1 ;
else
    status = 0 ;
end
end
