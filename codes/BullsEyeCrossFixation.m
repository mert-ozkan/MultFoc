classdef BullsEyeCrossFixation < Shape
    
    properties

        inner_circle CircleObject
        inner_circle_color = [255;0;0;255]
        
    end
    
    properties (SetAccess = private)
        
        inner_circle_scalar = 1/4
        
    end
    
    methods
        
        function fix = BullsEyeCrossFixation(scr,out_r,in_clr)
            
            cent = SpatialUnit(scr,[0;0]);
            fix = fix@Shape(scr,cent);
            
            if nargin < 3; out_r = .25; end
            if nargin > 3 
                
                fix.inner_circle_color = in_clr;
                
            end 
            
            fix = fix.add_circle(out_r,'dva');
            fix.inner_circle = copy(fix.circle).scale(fix.inner_circle_scalar).set_color(fix.inner_circle_color);
            fix = fix.add_cross(out_r*2,fix.inner_circle.radius.dva);
            fix.cross = fix.cross.change_color(scr.background_color);
            
        end        
        
        function fix = draw(fix,varargin)
            
            fix.circle.draw();
            fix.cross.draw();
            fix.inner_circle.draw();
            
        end
        
    end
    
end

