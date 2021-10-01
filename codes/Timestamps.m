classdef Timestamps < handle
    
    properties
        
        file_id
        file_path
        variable_names = {'trial_no','trigger','time'}
        triggers cell
        
    end
    
    properties (Dependent)
        
        nrow
        ncol
        current
        variable_types
        
    end
    
    properties (Access = private)
        
        precision = 15
        delimiter = ','
        
    end
    
    properties (Dependent, Access = private)
        
        format_spec
        
    end
    
    methods
        
        function trg = Timestamps(sub,var_names)
            
            if sub.isNew
                
                trg.file_path = sub.file.timestamps;
                trg.file_id = fopen(trg.file_path,'w');
                if nargin > 1; trg.variable_names = var_names; end
                var_names = join(trg.variable_names,trg.delimiter);
                fprintf(trg.file_id,sprintf('%s\n',var_names{:}));
                
            else
                
                trg.file_id = fopen(sub.file.timestamps,'a+');
                
            end
            
        end
        
        function trg = write(trg,varargin)
            
            trg.triggers(end+1,:) = varargin;
            
        end
        
        function trg = write_if(trg,isWrite,varargin)
            
            if isWrite
                
                trg.write(varargin{:});
                
            end
            
        end
        
        
        function trg = flush(trg)
            
            trg.triggers = {};
            
        end
        
        function trg = print(trg)
            
            for whRow = 1:trg.nrow()
                
                fprintf(trg.file_id,trg.format_spec,trg.triggers{whRow,:});

            end
            trg.flush();
            
        end
        
        function trg = set_precision(trg,val)
            
            trg.precision = val;
            
        end
        
        function trg = set_delimiter(trg,val)
            
            trg.delimiter = val;
            
        end
        
        function n = get.nrow(trg)
            
            n = size(trg.triggers,1);
            
        end
        
        function n = get.ncol(trg)
            
            n = size(trg.triggers,2);
            
        end
        
        function row = get.current(trg)
            
            row = trg.triggers(end,:);
            
        end
        
        function types = get.variable_types(trg)
            
            types = cellfun(@(x) class(x),trg.current,'UniformOutput',false);
            
        end
        
        function fmt = get.format_spec(trg)
            
            if isempty(trg.triggers); return; end
            fmt = join(cellfun(@(x) trg.class2formatspec(x), trg.triggers(1,:),'UniformOutput',false),trg.delimiter);
            fmt = [fmt{:},'\n'];
            
        end
        
        function spec = class2formatspec(trg,var)
            
            if isinteger(var)
                
                spec = '%i';
                
            elseif isfloat(var)
                
                spec = sprintf('%%.%df',trg.precision);
                
            elseif isstring(var) || ischar(var)
                
                spec = '%s';
                
            elseif isdatetime(var)
                
                spec = '%s';
                warning('Not yet developed for datetime class');
                
            else
                
                error('The variable is not of a compatible class.')
                
            end
        end
        
    end
    
    
end

