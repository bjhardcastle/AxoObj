function abfData = getAbfData(obj)
%GETABFDATA Read an object's .abf file and temporarily store the data within
% getAbfData(obj)
%
% This function makes the following available in the object (but not stored):
%   obj.Abf     - all analog input channel data saved within obj.AbfFile
%                 This property is transient and is not stored with object
%                 when saved to disk. If an object is loaded, this
%                 function must be re-run.
%
% See also ...
import 'AxoObjfuncs.*'

% First, check abf file has been found automatically on object creation.
if isempty(obj.AbfFile) && obj.Unattended
    
    % If not, and this function was called in Unattended mode, show message:
    disp(['ABF file not found. ' obj.File ' skipped'])
    return
    
elseif isempty(obj.AbfFile) && ~( obj.Unattended )
    % Otherwise, a file selection tool is launched:
    
    try
        getAbfFile(obj);
    catch
        % - in case GUI is cancelled
    end
    if isempty(obj.AbfFile)
        disp('No ABF file exists - try running ''getAbfFile(obj)''')
        return
    end
    
end

% Read and push ABF data to object:
disp('Reading ABF file')
% s = warning('off','all');           % Disable warnings temporarily
try
    [data] = daqread([obj.Folder obj.AbfFile]);
    abfData = data;  % abf analog data (multiple channels)
    %obj.AbfRate = 1e6/si; % si is sample interval, in microseconds
    %obj.AbfInfo = h;
catch
    disp('abfload failed. No data loaded')
end
% warning(s); % Restore previous warning state
