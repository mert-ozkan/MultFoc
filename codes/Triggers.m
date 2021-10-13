classdef Triggers < DataFile
    
    properties (Dependent)
        
        last_trigger
        last_trigger_time
        last_trigger_trial
        last_trigger_id
        
    end
    
    properties (Access = private)
        
        id = 0
        
    end
    
    methods
        
        function trg = Triggers(varargin)
            
            trg = trg@DataFile(varargin{:},{'trial_no','trigger','time','id'});           
            
        end
        
        function op = last_time(trg,var)
            
            if isempty(trg.data); op = NaN; return; end
            idx = find(strcmp(trg.data(:,2),var),1,'last');
            if isempty(idx); op = NaN; return; end
            op = trg.data{idx,3};
            
            
        end
        
        function op = first_time(trg,var)
            
            if isempty(trg.data); op = NaN; return; end
            idx = find(strcmp(trg.data(:,2),var),1,'first');
            if isempty(idx); op = NaN; return; end
            op = trg.data{idx,3};
            
        end
        
        function op = get.last_trigger(trg)
            
            op = trg.data{end,2};
            
        end
        
        function op = get.last_trigger_time(trg)
            
            op = trg.data{end,3};
            
        end
        
        function op = get.last_trigger_trial(trg)
            
            op = trg.data{end,3};
            
        end
        
        function op = get.last_trigger_id(trg)
            
            op = trg.data{end,4};
            
        end
        
        function trg = write(trg,varargin)
                        
            trg.id = trg.id + 1;
            varargin{end+1} = trg.id;            
            write@DataFile(trg,varargin{:});            
                        
        end
        
    end
    
end