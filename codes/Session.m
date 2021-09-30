classdef Session < handle
    
    properties
        
        random_generator_seed
        initial_trial
        initiation_datetime
        previous_log = []
        log_table
        isNew
        isDebug
        
    end
    
    methods
        
        function sxn = Session(isNew)
            
            sxn.initiation_datetime = datetime;
            sxn = sxn.initiate_session(isNew);
            if sxn.isDebug; sxn.random_generator_seed = 12348894;
            else; sxn.random_generator_seed = randi(2^32-1);
            end
            sxn.log_table = table(sxn.initiation_datetime,sxn.random_generator_seed,...
                'VariableNames',{'initiation_datetime','random_generator_seed'});                       
            rng(sxn.random_generator_seed);            
            
        end
        
        function sxn = get_initial_trial(sxn,sub)
             
            if sub.isNew
                
                sxn.initial_trial = 1;
                sxn.log_table = [sxn.log_table,table(sxn.initial_trial,'VariableNames',{'initial_trial'})];
                
            else
                
                sxn.previous_log = readtable(sub.file.session_log);
                sxn.initial_trial = sxn.previous_log.last_trial(end)+1;
                sxn.log_table = [sxn.log_table,table(sxn.initial_trial,'VariableNames',{'initial_trial'})];
                
            end
            
        end
        
        function sxn = get_last_trial(sxn,sub)            
            
            dat = readtable(sub.file.data);
            last_trial = dat.trial(end);
            sxn.log_table = [sxn.log_table,table(last_trial)];
            
        end
        
        
        function sxn = update_session_log(sxn,varargin)
            
            for whArg = varargin
                
                tblN = whArg{:}.get_table_of_parameters();
                sxn.log_table = [sxn.log_table,tblN];
                
            end
            
        end
        
        function write_to_session_log(sxn,sub)
            
            writetable(vertcat(sxn.previous_log,sxn.log_table),sub.file.session_log)
            
        end
        
        function sxn = initiate_session(sxn,isNew)
            
            if ~isempty(isNew)
                
                switch lower(isNew)
                    case {'test','try','demo','debug'}
                        sxn.isDebug = true;
                        sxn.isNew = true;
                    otherwise
                        sxn.isDebug = false;
                        sxn.isNew = isNew;
                end
                
            else
                
                sxn.isNew = false;
                sxn.isDebug = false;
                
            end
            
        end
    end
    
end