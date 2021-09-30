classdef ArcObject < matlab.mixin.Copyable & CircleObject
    
    properties
        
        size Angle
        start_angle Angle
        penwidth SpatialUnit
    end
    
    methods
        
        function arc = ArcObject(radius,start_angle,ang_size,penwidth)
            
            arc = arc@CircleObject(radius);         
            arc.start_angle = arc.set_property(start_angle);
            arc.penwidth = arc.set_property(penwidth);
            arc.size = arc.set_property(ang_size);            
            
        end
        
        function prop= set_property(arc,val)
            
            if size(val,2) == arc.no_of_items
                prop = val;
            elseif size(val,2) == 1
                prop = repmat(val,1,arc.no_of_items);
            else
                error('Error setting the property value. Property matrix width is different than 1 does not match the number of items.');
            end
            
        end
        
        function arc = change_start_angle(arc, varargin)
            
            if length(varargin) == 1
                arc = arc.set_start_angle(varargin{1});
            else
                arc.start_angle(varargin{1}) = varargin{2};
            end
            
        end
        
        function arc = rotate(arc,ang)
            arc.start_angle = arc.start_angle + ang;
        end
        
        function draw(arc)

            for whArc = 1:arc.no_of_items
                Screen('FrameArc',arc.radius.screen.pointer, arc.color.rgba_values(:,whArc),arc.rect.absolute(:,whArc),arc.start_angle.d(:,whArc),arc.size.d(:,whArc), arc.penwidth.pix(:,whArc));
            end
            
        end
        
        function slxn = select(arc,varargin)
            
            slxn = copy(arc);
            slxn.size = slxn.size.select(varargin{:});
            slxn.start_angle = slxn.start_angle.select(varargin{:});
            slxn.penwidth = slxn.penwidth.select(varargin{:});
            slxn.radius = slxn.radius.select(varargin{:});
            slxn.color = slxn.color.select(varargin{:});
            slxn.center = slxn.center.select(varargin{:});
            
                
            
        end
        
    end
    
end