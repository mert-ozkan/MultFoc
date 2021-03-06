classdef ExperimentKeyboard < handle
    
    properties
        
        isEscaped logical = false
        isKeyPressed logical = false
        isAccurate logical
        key char
        isValid logical
        press_time double
        release_time double
        escape_key char = 'escape'
        next_key char = 'space'
        reaction_keys cell        
        correspondence
        isKeyReleased logical = false
        
    end
    
    properties (Dependent, Access = private)
        
        key_code
        escape_code
        next_code 
        reaction_codes        
        
    end
    
    methods
        
        function kb = ExperimentKeyboard()
            
            PsychHID('UnifyKeyNames');
            KbQueueCreate();
            
        end
        
        function kb = set_reaction_keys(kb,keys,correspondence)
            
            kb.reaction_keys = keys;
            if nargin < 3; correspondence = keys; end
            kb.correspondence = correspondence;
            
        end
        
        function kb = start(kb)
            
            KbQueueStart();
            
        end
        
        function kb = flush(kb)
            
            if kb.isKeyPressed && kb.isKeyReleased; KbQueueFlush(); end
                        
        end
        
        function kb = reset(kb)
            
            if kb.isKeyPressed
                
                kb.isEscaped = false;
                kb.isKeyPressed = false;
                kb.isAccurate = logical.empty();
                kb.isValid = logical.empty();
                kb.key = '';
                kb.press_time = [];         
                
            end

            
        end
        
        function kb = stop(kb)
            
            KbQueueStop();
            
        end
        
        function kb = evaluate(kb,correct_correspondence)
            
            if ~kb.isKeyPressed; return; end
            correct_key = ismember(kb.correspondence,correct_correspondence);
            kb.isAccurate = kb.reaction_codes(correct_key) == kb.key_code;
            kb.isValid = ismember(kb.key_code,kb.reaction_codes);               
                              
            
        end
        
        function kb = wait_for_next_key(kb,wait_secs)
            
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
            
            kb.stop();
            [t, key_codes, ~] = KbPressWait([],wait_secs);
            kb.isKeyPressed = sum(key_codes(KbName(key)));
            kb.isEscaped = key_codes(kb.escape_code);
            kb.key = KbName(find(key_codes));
            kb.press_time = t;
                        
            kb.quit_if_escaped();
            kb.start();

        end
        
        function kb = check(kb)
            
            [isKeyDown, press_t, release_t] = KbQueueCheck();
            
%             [isKeyDown, t, key_codes, ~] = KbCheck();
            
            if isKeyDown
                
                kb.isKeyPressed = true;
                press_codes = press_t > 0;
                if sum(press_codes) > 1; kb.isValid = false; return; end
                kb.release_time = release_t(press_codes);
                kb.isKeyReleased = kb.release_time > 0;                               
                kb.key = KbName(press_codes);
                kb.isEscaped = strcmpi(kb.key,kb.escape_key);                
                kb.press_time = press_t(press_codes);
                kb.flush();
                
            end
            
            
        end
                     
        function kb = quit_if_escaped(kb)
            
            if kb.isEscaped
                sca;
                warning('Screen closed by key press.');
            end
            
        end
        
        function code = get.escape_code(kb)
            
            code = KbName(kb.escape_key);
            
        end
        
        function code = get.next_code(kb)
            
            code = KbName(kb.next_key);
            
        end
        
        function code = get.reaction_codes(kb)
            
            code = KbName(kb.reaction_keys);
            
        end
        
        function code = get.key_code(kb)
            
            code = KbName(kb.key);
            
        end
        
        function tbl = get_table_of_parameters(kb)
            
            tbl = table({kb.escape_key},{kb.next_key},kb.reaction_keys,{kb.correspondence},...
                'VariableNames',{'escape_key','next_key','reaction_keys','correspondence'});
            
        end
        
    end
    
end