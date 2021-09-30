classdef Trial < dynamicprops & matlab.mixin.Copyable
    
    properties
        
        order        
        no
        variables
        
    end
    
    properties (Dependent)
                
        current
        no_of_variables
        no_of_trials
        no_of_incomplete_trials
        
    end
    
    
    
    methods
        
        function trl = Trial(sub,sxn)
            
            trl.order = readtable(sub.file.trial_order);
            trl.no = sxn.initial_trial;
            trl.variables = trl.order.Properties.VariableNames;
            
            trlN = table2cell(trl.current);
            for whVar = 1:length(trlN)
                varN = trl.variables{whVar};
                p = trl.addprop(varN);
                p.NonCopyable = false;
                trl.(varN) = trlN{whVar};
            end
                        
        end
        
        function trl = end(trl)
            
            trl = trl.move(1);
            
        end
        
        function trlN = next(trl)
            
            trlN = copy(trl).move(1);
            
        end
        
        function trlN = previous(trl)
            
            trlN = copy(trl).move(-1);
            
        end
        
        function trl = move(trl,val)
            
            new_no = trl.no + val;
            if  new_no > 0 && new_no <= trl.no_of_trials
                trl.no = trl.no + val;
            else
                trl = Trial.empty();
                return
            end
            
            trlN = table2cell(trl.current);
            for whVar = 1:length(trlN)
                
                varN = trl.variables{whVar};                
                trl.(varN) = trlN{whVar};
                
            end
            
        end
        
        function n = get.no_of_trials(trl)
            
            n = height(trl.order);
                        
        end
        
        function n = get.no_of_incomplete_trials(trl)
            
            n = trl.no_of_trials - trl.no + 1;
                        
        end
        
        function trlN = get.current(trl)
            
            trlN = trl.order(trl.no,:);            
            
        end
        
        function n = get.no_of_variables(trl)
            
            n = length(trl.variables);
            
        end
        
        function varargout = get(trl,varargin)
            
            varargout = cellfun(@(x) trl.(x),varargin,'UniformOutput',false);
            
        end
        
        function trl = add_counter(trl,counter_name,limit)
            
            if ~isprop(trl,counter_name); p = trl.addprop(counter_name); p.NonCopyable = false; end
            trl.(counter_name) = Counter(limit);
            
            
        end
        
        function trl = add_timer(trl,timer_name,duration)
            
            if ~isprop(trl,timer_name); p = trl.addprop(timer_name); p.NonCopyable = false; end
            trl.(timer_name) = Timer(duration);
            
        end        
       
    end
    
end