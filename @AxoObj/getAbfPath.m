function obj = getAbfPath(obj,pathIN)
% Extracts file name, extension, and folder path on object construction
if isa(pathIN,'char')
    
    abfPath = [pathIN];
    
    [pathstr,name,ext] = fileparts(abfPath);
    
    % Save filename (no extension) and folder path
    obj.File = name;
    obj.Folder = [ pathstr '\' ];
    obj.AbfFile = [name ext];
    
else
    
    error('Please input path to tiff file as a string, or leave empty')
    
end






end