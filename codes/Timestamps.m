classdef Timestamps < handle
    
    properties
        
        file_id        
        variable_names = {'trial_no','trigger','time'}
        triggers cell
        
        
    end    
    
    methods
        
        function trg = Timestamps(sub,var_names)                       
                     
            if sub.isNew
                
                trg.file_id = fopen(sub.file.timestamps,'w');
                if nargin > 1; trg.variable_names = var_names; end
                var_names = join(trg.variable_names,', ');
                fprintf(trg.file_id,sprintf('%s\n',var_names{:}));
                
            else
                
                trg.file_id = fopen(sub.file.timestamps,'a+');
                
            end
             
        end
        
        function trg = write(trg,varargin)
            
            trg.triggers(end+1,:) = varargin;
            
        end
        
        function trg = flush(trg)
            
            trg.triggers = {};
            
        end
        
        function trg = print(trg)
        end
        
    end
    
end