function reSave(saveDir,prevName,newName)

files = dir(fullfile(saveDir,[prevName,'*']));

for iFile = 1:length(files)
    
    str     = files(iFile).name;
    exp     = prevName;
    replace = newName;
    
    newFileName = regexprep(str,exp,replace);
    
    savedir = files(iFile).folder;
    
    movefile(fullfile(savedir,files(iFile).name),fullfile(savedir,newFileName));

end
