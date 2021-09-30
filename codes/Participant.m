classdef Participant < handle
    
    properties
        
        name
        isNew
        no
        file
        conditions
        
    end

    
    methods
        
        function sub = Participant(dr,isDebug,isNew)
            
            sub.isNew = isNew;
            sub.conditions = dr.get_conditions();            
            sub = sub.get_id(dr,isDebug).get_paths(dr).get_trial_order();
            
        end
        
        function sub = get_id(sub,dr,isDebug)
            
            if isDebug
                
                sub.name = "test";
                sub.no = 0;
                
            else
                
                if sub.isNew; disp('Creating a NEW participant file!'); end
                
                sub.name = string(input('Please insert initials: ','s'));
                search_spec = sprintf('%s*.csv',sub.name);
                isFileExist = dr.isFileIn(dr.data,search_spec);
                
                if sub.isNew
                    
                    if isFileExist
                        
                        error('Another participant with the same initials exist!');
                        
                    end
                    sub.no = round(rand*100000);
                    
                else
                    
                    if ~isFileExist
                        
                        error('Participant file does not exist!');
                        
                    end
                    f_nm = split(dr.get_filename(dr.data,search_spec),'_');
                    sub.name = string(f_nm{1});
                    sub.no = str2double(f_nm{2});
                    
                end
                
            end
            
        end
        
        function sub = get_paths(sub,dr)
            
            sub.file.name = sprintf("%s_%d",sub.name,sub.no);
            sub.file.data = fullfile(dr.data,sprintf("%s_data.csv",sub.file.name));
            sub.file.timestamps = fullfile(dr.timestamps,sprintf("%s_timestamps.csv",sub.file.name));
            sub.file.trial_order = fullfile(dr.trial_order,sprintf("%s_trial_order.csv",sub.file.name));
            sub.file.session_log = fullfile(dr.session_log,sprintf("%s_session_log.csv",sub.file.name));
            
        end
                
        function sub = get_trial_order(sub)
            
            if sub.isNew
                                
                trl_ord = create_trial_order();
                writetable(trl_ord,sub.file.trial_order);
                
            end
                
        end
        
        function tbl = get_table_of_parameters(sub)
            
            tbl = table(sub.name,sub.no,sub.file.data,sub.file.timestamps,sub.file.trial_order,sub.file.session_log,...
                'VariableNames',{'participant_name','participant_no','data_file','timestamp_file','trial_order_file','session_log_file'});
            
        end
        
    end
    
end