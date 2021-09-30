classdef Counter < handle
    
    properties
        
        count
        list
        step = 1
        
    end
    
    properties (Dependent)
        
        current
        isComplete
        
    end
    
    methods
        
        function ct = Counter(n)
            
            if length(n) > 1
                
                ct.count = length(n);
                ct.list = n;
                
            else
                
                ct.count = n;
                ct.list = 1:n;            
                
            end              
        
        end
        
        function curr = get.current(ct)
            
            curr = ct.list(ct.step);
            
        end
        
        function isComp = get.isComplete(ct)
            
            isComp = ct.step == ct.count;
            
        end
        
        function ct = next(ct)
            
            if ct.isComplete; return; end
            ct.step = ct.step + 1;
            
        end        
                
        function ct = increase(ct,val)
            
            if nargin < 2; val =1; end
            ct.count = ct.count + val;
            
        end
        
        function ct = decrease(ct,val)
            
            if nargin < 2; val =1; end
            ct.count = ct.count - val;
            
        end
        
        function ct = change_limit(ct,val)
            
            ct.count = val;
            
        end
        
        function ct = reset(ct)
            
            ct.step = 1;
            
        end
       
        
    end
    
end