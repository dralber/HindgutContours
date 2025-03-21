function structToVars(s, suppressPrompt)
% Author: Daniel Alber
% Date: 6/16/2024
% Description: Give a structure as an input and it assign the value of each field
% in the structure to a variable in the base workspace with the same name.

    if nargin < 2
        suppressPrompt = false;
    end

    % Get field names from the structure
    fieldNames = fieldnames(s);

    % Loop over each field
    for i = 1:numel(fieldNames)
        if suppressPrompt
            assignin('base', fieldNames{i}, s.(fieldNames{i}));
        % Check if variable already exists in the base workspace
        elseif evalin('base', ['exist(''' fieldNames{i} ''', ''var'')'])
            % Prompt the user to confirm overwriting the variable
            prompt = ['Variable ' fieldNames{i} ' already exists. Do you want to overwrite it? Y/N [N]: '];
            str = input(prompt,'s');
            if isempty(str)
                str = 'N';
            end
            if strcmpi(str, 'Y')
                % Assign the field to a variable in the base workspace
                assignin('base', fieldNames{i}, s.(fieldNames{i}));
            end
        else
            % Assign the field to a variable in the base workspace
            assignin('base', fieldNames{i}, s.(fieldNames{i}));
        end
    end

end
