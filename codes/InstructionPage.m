classdef InstructionPage < handle
    
    properties
        
        text
        size = 10
        color = [255,255,255,255]
        
    end
    
    properties (Dependent)
        
        number_of_lines
        middle_line
        
    end
    
    methods
        function ins = InstructionPage(dr)
            
            ins.text = dr.get_instructions();
            
        end
        
        function number_of_lines = get.number_of_lines(ins)
            
            number_of_lines = length(ins.text);
            
        end
        
        function middle_line = get.middle_line(ins)
            
            middle_line = round(ins.number_of_lines/2);
            
        end        
        
        function draw(ins,scr)
           
            DrawFormattedText(scr.window.pointer,char(join(ins.text,'\n')),'center','center',ins.color);
            
        end
        
    end
    
end

