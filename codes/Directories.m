classdef Directories
    
    properties
        
        parent
        conditions_file = 'conditions.csv';
        instructions_file = 'instructions.txt';
        block_file = 'block.txt';
        reaction_file = 'reaction.txt';
        break_file = 'break.txt';
        
    end
    
    properties (Dependent)
        
        trial_order
        timestamps
        session_log
        data
        codes
        
    end
    
    methods
        
        function dr = Directories(parent)
            
            dr.parent = parent;
            
            cd(dr.parent);
            addpath(genpath(dr.parent));
            
        end
        
        function trial_order = get.trial_order(dr)
            
            trial_order = fullfile(dr.parent,'trial_order');
                       
        end
        
        function timestamps = get.timestamps(dr)
            
            timestamps = fullfile(dr.parent,'timestamps');
                       
        end
        
        function session_log = get.session_log(dr)
            
            session_log = fullfile(dr.parent,'session_log');
                       
        end
        
        function data = get.data(dr)
            
            data = fullfile(dr.parent,'data');
                       
        end
        
        function codes = get.codes(dr)
            
            codes = fullfile(dr.parent,'codes');
                       
        end
        
        function conditions = get_conditions(dr)
            
            conditions = readtable(fullfile(dr.parent,dr.conditions_file));
            
        end
        
        function txt = get_text(dr,txt_nm)
            
            f_path = retrieve_property_value(dr,txt_nm);
            id = fopen(f_path);
            txt = Directories.lines_to_string_array(id);
            fclose(id);
            
            
        end
        
        function val = retrieve_property_value(dr,keyword)
            % Returns cell array
            props = properties(dr);
            prop = props(contains(props,keyword));
            val = dr.(prop{:});
            
        end
        
    end
    
    methods (Static)
        
        function isFile = isFileIn(folder_path,specification)
            
            isFile = ~isempty(dir(fullfile(folder_path,specification)));
            
        end
        
        function filename = get_filename(folder_path,specification)
            
            f = dir(fullfile(folder_path,specification));
            filename = f.name;
            
        end
        
        function str = lines_to_string_array(id)
            
            str = string(fgetl(id));
            while ~isequal(str(end),'-1')
                
                str(end+1) = string(fgetl(id));

            end
            str = str(1:end-1);
            
        end
        
    end
end