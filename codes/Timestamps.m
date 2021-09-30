classdef Timestamps < handle
    
    properties
        
        id
        triggers
        next_event
        trial_no
        
    end
    
    properties (Access = private)
        
        variable_names = {'trial_no','trigger','estimated_onset','onset','lag'}
        
    end
    
    methods
        
        function t = Timestamps(sub)                       
            
            if sub.isNew
                
                t.id = fopen(sub.file.timestamps,'w');
                fprintf(t.id,sprintf('%s,%s,%s,%s,%s\n',t.variable_names{1},t.variable_names{2},t.variable_names{3},t.variable_names{4},t.variable_names{5}));
                
            else
                
                t.id = fopen(sub.file.timestamps,'a+');
                
            end
             
        end
        
        function t = update_trial(t,trl_no)
            
            t.trial_no= trl_no;
            
        end
        
        function send_trigger(t,scr_or_kb,ev)
            
            fprintf(t.id,'%d,%s,%.10f,%.10f,%.10f\n',t.trial_no,ev.get_trigger(),ev.get_onset(),scr_or_kb.time,ev.get_onset()-scr_or_kb.time);
                    
        end
        
    end
    
end