classdef ExperimentKeyboard < handle
    
    properties
        
        isEscaped = false
        isKeyPressed = false
        accuracy
        key
        time
        escape_key = 'escape'
        next_key = 'space'
        reaction_keys
        reaction_key_codes
        correspondence
        response
        
    end
    
    properties (Dependent)
        
        escape_code
        
    end
    
    methods
        
        function kb = ExperimentKeyboard()
            
            PsychHID('UnifyKeyNames');
            PsychHID('KbQueueCreate');
            
        end
        
        function kb = set_reaction_keys(kb,keys,correspondence)
            
            kb.reaction_keys = keys;
            kb.reaction_key_codes = KbName(keys);
            if nargin < 3; correspondence = keys; end
            kb.correspondence = correspondence;
            
        end
        
        function kb = start(kb)
            
            PsychHID('KbQueueStart');
            
        end
        
        function kb = flush(kb)
            
            PsychHID('KbQueueFlush');
            
        end
        
        function kb = stop(kb)
            
            PsychHID('KbQueueStop');
            
        end
        
        function kb = check_for_accuracy(kb,correct_correspondence)
            
            if kb.isKeyPressed
                rxn_key = find(strcmp(kb.key,kb.reaction_keys));
                switch class(correct_correspondence)
                    case {'char','string'}
                        acc_key = find(strcmp(correct_correspondence,kb.correspondence));
                    case 'double'
                        acc_key = find(correct_correspondence==kb.correspondence);
                end
            
                kb.response = kb.correspondence(rxn_key);
                kb.accuracy = rxn_key == acc_key;
            else
                kb.response = -1;
                kb.accuracy = -1;                
            end
            
        end
        
        function kb = wait_for_next(kb,wait_secs)
            
            if nargin < 2; wait_secs = inf; end
            kb = kb.wait_for_key_press(kb.next_key,wait_secs);
            
        end
        
        function kb = wait_till(kb,till_secs)
                        
            kb.isKeyPressed = false;
            kb.isEscaped = false;
            while GetSecs < till_secs && ~kb.isKeyPressed
                
                [~,~, key_codes, ~] = KbCheck();
                kb.isEscaped = key_codes(kb.escape_code);               
                
            end
            
            kb.quit_if_escaped();
            
        end
        
        function kb = wait_for_key_press(kb,key,wait_secs)
            
            if nargin < 3; wait_secs = inf; end
            
            
            key_code = KbName(key);
            
            [t, key_codes, ~] = KbPressWait([],wait_secs);
            kb.isKeyPressed = sum(key_codes(key_code));
            kb.isEscaped = key_codes(kb.escape_code);
            kb.key = KbName(find(key_codes));
            kb.time = t;
            
            kb.quit_if_escaped();

        end
        
        function kb = check(kb)
            
            [isKeyDown, t, key_codes, ~] = KbCheck();
            
            if isKeyDown
                
                kb.flush();
                kb.isKeyPressed = true;
                kb.key = KbName(key_codes);
                kb.isEscaped = strcmpi(kb.key,kb.escape_key);                
                kb.time = t;
                
            end
            
            
        end
                     
        function quit_if_escaped(kb)
            
            if kb.isEscaped
                Screen('CloseAll');
                disp('Screen closed by key press.');
            end
            
        end
        
        function code = get.escape_code(kb)
            
            code = KbName(kb.escape_key);
            
        end
        function tbl = get_table_of_parameters(kb)
            
            tbl = table({kb.escape_key},{kb.next_key},kb.reaction_keys,{kb.correspondence},...
                'VariableNames',{'escape_key','next_key','reaction_keys','correspondence'});
            
        end
        
    end
    
end