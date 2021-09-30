classdef Timer < handle
    
    properties
        
        initial_time
        duration
                
    end
    
    properties
        
        isTimeOff
        end_time
        
    end
    
    methods 
        
        function timer = Timer(dur)
            
            timer.initial_time = GetSecs;        
            timer.duration = dur;
            
        end
        
        function end_t = get.end_time(timer)
            
            end_t = timer.initial_time + timer.duration;
            
        end
        
        function isOff = get.isTimeOff(timer)
            
            isOff = GetSecs > timer.end_time;
            
        end
        
        function timer = reset(timer)
            
            timer.initial_time = GetSecs;            
            
        end
        
    end
    
    
end