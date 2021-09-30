classdef Data < handle
    
    properties
        
        id
        
    end
    
    methods
        
        function dat = Data(sub)
            
            if sub.isNew
                
                dat.id = fopen(sub.file.data,'w');
                fprintf(dat.id,'trial,cue1,cue2,hemifield,shape,target_no,response\n');
                
            else
                
                dat.id = fopen(sub.file.data,'a+');
                
            end
             
        end
        
        function print(dat,trl_no,cond,kb)
            
            fprintf(dat.id,'%d,%d,%d,%s,%s,%d,%s\n',...
                trl_no,cond.condition.T1,cond.condition.T2,cond.condition.Hemifield{:},cond.condition.Shape{:},cond.condition.NoOfTargets,num2str(kb.response));
            
        end
        
        
    end
    
end