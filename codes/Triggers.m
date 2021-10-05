classdef Triggers < DataFile
    
    properties (Dependent)
        
        last_trigger
        last_trigger_time
        last_trigger_trial
        
    end
    
    methods
        
        function trg = Triggers(varargin)
            
            trg = trg@DataFile(varargin{:},{'trial_no','trigger','time'});           
            
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
    end
    
end