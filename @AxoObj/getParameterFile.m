function getParameterFile(obj)
daqName = obj.AbfFile;
[~,~,ext] = fileparts(daqName);
pName = strrep(daqName,'MASTER','PARAMETERS');
pName = strrep(pName,ext,'.mat');
pFolder = obj.Folder;
pPath = fullfile(pFolder,pName);


%Check the new file exists before storing it
if exist(pPath, 'file') ~= 2
    disp(['Copy parameter file not found: <a href="matlab:winopen(''' pFolder ''')">dump folder</a> '])
else
    params = load(pPath,'parameterSet');
    obj.pSet = params.parameterSet;
end
