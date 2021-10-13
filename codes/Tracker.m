classdef Tracker < dynamicprops
    
    properties
        
        names cell 
        values = {}
        step = 1
        
    end
    
    properties (Dependent)
        
        isComplete
        
    end
    
    
    properties (Dependent, Access = private)
        
        no_of_groups
        final_step        
        
    end
    
    methods
        
        function trck = Tracker(obj,lst,call_names)
                        
            if isstring(lst); lst = cellstr(lst); end
            
            trck.names = lst;
            trck.values = cell(size(trck.names));            
            
            if nargin < 3
                
                call_names = arrayfun(@(x) sprintf('Var%d',x),1:trck.no_of_groups,'UniformOutput',false);
            
            elseif length(call_names) ~= trck.no_of_groups
                
                error('Number of call names and groups do not match.')
            
            elseif isstring(call_names)
                
                call_names = cellstr(call_names);
                
            end
            
            for whGru = 1:trck.no_of_groups
                
                val = get(obj,trck.names(whGru,:));
                if ~iscell(val)
                    val = num2cell(val);
                end
                [trck.values{whGru,:}] = val{:};
                trck = trck.add_method(call_names{whGru},@() trck.values{whGru,trck.step});
                
            end
            
        end
        
        function n = get.no_of_groups(trck)
            
            n = size(trck.names,1);
            
        end
        
        function n = get.final_step(trck)
            
            n = size(trck.names,2);
            
        end
        
        function isComp = get.isComplete(trck)
            
            isComp = trck.step == trck.final_step;
            
        end
        
        function trck = add_method(trck,func_name,func)
            
            p = trck.addprop(func_name); p.NonCopyable = false;
            trck.(func_name) = func;
            
        end
        
        function trck = next(trck,isExecute)
            
            if nargin < 1; isExecute = true; end
            if ~isExecute; return; end
            if ~trck.isComplete; trck.step = trck.step+1; end
            
        end
        
    end
    
    methods (Static)
        
        function varargout = get(obj,varargin)
            
            varargout = cellfun(@(x) obj.(x),varargin,'UniformOutput',false);
            
        end
        
    end
    
end