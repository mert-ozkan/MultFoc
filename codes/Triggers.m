classdef Triggers < DataFile
    
    properties
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
    end
    
end