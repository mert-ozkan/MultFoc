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
        isConditionSwitch
        
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
        
        function isSwitch = get.isConditionSwitch(trl)
            
            if trl.no ~= 1
                
                prev_var = cell(1,trl.no_of_variables);
                var = prev_var;
                [var{:}] = trl.get(trl.variables{:});
                [prev_var{:}] = trl.previous.get(trl.variables{:}); 
                isSwitch = array2table(cellfun(@(x,y) length(x) ~= length(y) || all(x~=y), var,prev_var),'VariableNames',trl.variables);
                
            else
                
                isSwitch = array2table(ones(1,trl.no_of_variables)==1,'VariableNames',trl.variables);

                
            end
            
            
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
        
        function trl = add_tracker(trl,tracker_name,varargin)
            
            if ~isprop(trl,tracker_name); p = trl.addprop(tracker_name); p.NonCopyable = false; end
            
            trl.(tracker_name) = Tracker(trl,varargin{:});
            
            
        end
       
    end
    
end