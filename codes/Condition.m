classdef Condition < handle
    
    properties
        
        cued_discs
        triggers
        arc_configurations
        no_of_events
        no_of_targets
        current = 1
                
    end
    
    properties (SetAccess = private)
        
        disc_ids = [5,8,11];
        
    end
    
    properties (Dependent)

        no_of_probes
        list_of_discs
        
    end
    
    methods
        
        function cond = Condition(trl)
            
            cond.cued_discs = cond.disc_ids(logical(table2array(trl(:,["C1","C2","C3"]))));
            cond.triggers = char(table2array(trl(:,["E1","E2","E3"])))';
            cond.triggers = cond.triggers(cond.triggers~='N');
            cfg = char(table2array(trl(:,["cfg1","cfg2","cfg3"]))');          
            cfg(cfg=='N') = ' ';
            cond.arc_configurations = cfg;
            cond.no_of_events = trl.n_ev;
            cond.no_of_targets = trl.n_tar;
            
        end
        
        function cond = next(cond)
            
            cond.current = cond.current + 1;
            
        end
        
    end

end