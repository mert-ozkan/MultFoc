classdef CircleObject < matlab.mixin.Copyable
    
    properties
        
        radius SpatialUnit        
        color RGBA
        center Coordinates
        
    end
    
    properties (Dependent)
        
        rect %[left top right bottom]
        area
        diameter
        circumference
        no_of_items        
        no_of_frames
        
    end
    
    methods
        
        function circ = CircleObject(r)
            
            if iscolumn(r); r = r'; end
            circ.radius = r;            
            circ = circ.set_color([1;1;1;1]*255);
            
        end
        
        function circ = set_color(circ,val)            
            
            if isa(val,'RGBA'); circ.color = copy(val); return; end
            
            if size(val,2) == 1
                val = repmat(val,1,circ.no_of_items);
            elseif size(val,2) ~= circ.no_of_items
                error('Number of items do not match for the color property.')
            end
            
            circ.color = RGBA(val);
            
        end        
        
        function rect = get.rect(circ)
            
            rect = repmat([-1;-1;1;1],1,circ.no_of_items)*circ.radius;
            if ~isempty(circ.center)
                
                abs = circ.center.cartesian.absolute;
                rect.absolute = rect.pix + [abs(1,:);abs(2,:);abs(1,:);abs(2,:)];
                
            end
            
        end
        
        function n = get.no_of_items(circ)
            n = size(circ.diameter.pix,2);
        end
        
        function n_frm = get.no_of_frames(circ)
            
            n_clr = circ.color.no_of_frames;
            n_dia = size(circ.diameter.pix,1);
            
            if n_clr == n_dia
                
                n_frm = n_clr;
                
            elseif xor(n_clr==1, n_dia==1)
                
                n_frm = [n_clr,n_dia];
                n_frm = n_frm(n_frm~=1);
                
            else
                
                error('Frame counts do not match!');
                
            end
            
        end
        
        function dia = get.diameter(circ)
            
            dia = circ.radius*2;
            
        end
        
        function area = get.area(circ)
            
            area = pi*circ.radius.^2;
            
        end
        
        function circumference = get.circumference(circ)
            
            circumference = 2*pi*circ.radius;
            
        end
        
        function circ = change_color(circ,varargin)
            
            if length(varargin) == 1
                circ = circ.set_color(varargin{1});
            else
                circ.color(:,varargin{2}) = repmat(varargin{1},1,size(varargin{2},2));
            end
            
        end
        
        function circ = place(circ,varargin)
            
            % set_origin command
            circ.center = Coordinates(circ.radius.screen,varargin{:});
%             abs = circ.center.cartesian.absolute;
%             circ.rect.absolute = circ.rect.pix + [abs(1,:);abs(2,:);abs(1,:);abs(2,:)];
            
        end
        
        function scaled_circ = scale(circ,scalar)
            
            scaled_circ = CircleObject(circ.radius.*scalar).set_color(circ.color);
            scaled_circ.center = circ.center;
            
        end
        
        function circ = join(circ,circ1)
            
            circ.radius = [circ.radius,circ1.radius];
            circ.color = [circ.color,circ1.color];
            circ.center = circ.center.join(circ1.center);
            circ.rect = [circ.rect;circ1.rect];           
            
        end
        
        function slxn = select(circ,varargin)
            
            slxn = copy(circ);
            slxn.radius = slxn.radius.select(varargin{:});
            slxn.color = slxn.color.select(varargin{:});
            if ~isempty(circ.center); slxn = slxn.place(slxn.center.select(varargin{:})); end
            
        end
        
        function arc = circ2arc(circ,start_angle,ang_size,penwidth)
            
            arc = ArcObject(circ.radius,start_angle,ang_size,penwidth);
            if ~isempty(circ.center); arc = arc.place(circ.center); end
            
        end
        
        function circN = frame(circ,idx)
            
            circN = copy(circ);
            circN.radius = circN.radius.frame(idx);
            circN.color = circN.color.frame(idx);
            
        end
        
        function draw(circ,dot_type,varargin)
            
            if nargin < 2; dot_type=2; end
            
            clr = circ.color.rgba_values;
            if circ.no_of_items == 1; clr = clr'; end
            
            Screen('DrawDots',circ.radius.screen.pointer,circ.center.cartesian.pix,circ.diameter.pix,clr,circ.radius.screen.origin.absolute',dot_type);
            
        end

        
    end
    
    methods (Access = private)
        
        
        
        
        
    end
    
end