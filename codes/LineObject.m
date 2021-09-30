classdef LineObject < matlab.mixin.Copyable
    
    properties
        
        length SpatialUnit
        penwidth SpatialUnit
        orientation = Angle(0)
        rect
        color = [1;1;1;1]*255
        no_of_lines = 1
        midpoint Coordinates
        
    end
    
    methods
        
        function l = LineObject(len,pw)
            
            l.length = len;
            l.penwidth = pw;
            l.rect = l.length*[-1/2, 1/2; 0, 0];
            
        end
                
        
        function l = change_color(l,val)
            
            if ~iscolumn(val); val = val'; end
            l.color = repmat(val,1,2*l.no_of_lines);
            
        end
        
        function scaled_l = scale(l,scalar)
            
            scaled_l = LineObject(l.length.*scalar,l.color);
            
        end      
             
        function l = append(l,l2)
            
            l.length = [l.length,l2.length];
            l.orientation = [l.orientation, l2.orientation];
            l.penwidth = [l.penwidth, l2.penwidth];
            l.rect = [l.rect, l2.rect];
            l.color = [l.color,l2.color];
            l.no_of_lines = l.no_of_lines+1;
            
        end
        
        function l = place(l,varargin)
            
            l.midpoint = Coordinates(l.length.screen,varargin{:});
            mp = l.midpoint.cartesian.absolute;
            if ~isprop(l.rect,'absolute'); l.rect.addprop('absolute'); end
            l.rect.absolute = l.rect.pix + [mp(1);mp(2)];
            
        end
        
        function l = rotate(l,th)
            
            if th == Angle(0); return; end
            l.orientation = l.orientation+th;
            [x,y] = pol2cart(l.orientation.r,l.length.dva);
            l.rect = SpatialUnit(l.length.screen,[x;y].*[-1/2,1/2;-1/2,1/2],'dva');
            l = l.place(l.midpoint);
        end  
        
        function draw(l)
                      
            scr = l.length.screen;
            Screen('DrawLines', scr.pointer, l.rect.pix, l.penwidth.pix, l.color, l.midpoint.origin.absolute', 2);
            
        end
        
    end
    
    methods (Static)
        
        function isL = isline(l)
            
            isL = isa(l,'LineObject');
            
        end
        
    end
end