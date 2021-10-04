classdef DataFile < handle
    
    properties
        
        file_id
        file_path
        variable_names cell = {}
        data cell
        
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
        
        function df = DataFile(varargin)
            % DataFile(isNew, file_path, variable_names)
            % DataFile(sub, fieldname, variable_names)
            n_arg = length(varargin);
            switch class(varargin{1})
                case 'Participant'
                    
                    isNew = varargin{1}.isNew;
                    df.file_path = varargin{1}.file.(varargin{2});                    
                
                case {'logical','double'}
                    
                    isNew = varargin{1};
                    df.file_path = varargin{2}; 
                    
                otherwise
                    
                    error('Wrong input class.')
                
            end
            
            if n_arg > 2; df.variable_names = varargin{3}; end
            
            if isNew               
                
                df.file_id = fopen(df.file_path,'w');
                var_names = join(df.variable_names,df.delimiter);
                fprintf(df.file_id,sprintf('%s\n',var_names{:}));                
                
            else
                
                df.file_id = fopen(df.file_path,'a+');
                
            end
            
        end
        
        function df = write(df,varargin)
            
            df.data(end+1,:) = varargin;
            
        end
        
        function df = write_if(df,isWrite,varargin)
            
            if isWrite
                
                df.write(varargin{:});
                
            end
            
        end
        
        
        function df = flush(df)
            
            df.data = {};
            
        end
        
        function df = print(df)
            
            for whRow = 1:df.nrow()
                
                fprintf(df.file_id,df.format_spec,df.data{whRow,:});

            end
            df.flush();
            
        end
        
        function df = set_precision(df,val)
            
            df.precision = val;
            
        end
        
        function df = set_delimiter(df,val)
            
            df.delimiter = val;
            
        end
        
        function n = get.nrow(df)
            
            n = size(df.data,1);
            
        end
        
        function n = get.ncol(df)
            
            n = size(df.data,2);
            
        end
        
        function row = get.current(df)
            
            row = df.data(end,:);
            
        end
        
        function types = get.variable_types(df)
            
            types = cellfun(@(x) class(x),df.current,'UniformOutput',false);
            
        end
        
        function fmt = get.format_spec(df)
            
            if isempty(df.data); return; end
            fmt = join(cellfun(@(x) df.class2formatspec(x), df.data(1,:),'UniformOutput',false),df.delimiter);
            fmt = [fmt{:},'\n'];
            
        end
        
        function spec = class2formatspec(df,var)
            
            if isinteger(var)
                
                spec = '%i';
                
            elseif isfloat(var)
                
                spec = sprintf('%%.%df',df.precision);
                
            elseif isstring(var) || ischar(var)
                
                spec = '%s';
                
            elseif isdatetime(var)
                
                spec = '%s';
                warning('Not yet developed for datetime class');
                
            else
                
                error('The variable is not of a compatible class.')
                
            end
        end
        
        function tbl = show_data(df)
            
            tbl = readtable(df.file_path);
            
        end
        
        function op = last_when(df,var_name)
        end
        
    end
    
    
end

