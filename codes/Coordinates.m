classdef Coordinates < matlab.mixin.Copyable
    
    properties
        
        screen ExperimentScreen
        origin SpatialUnit
        polar = struct('length',[],'angle',[])
        cartesian SpatialUnit           
        
    end
    
    methods
        
        function coord = Coordinates(scr,varargin)
            
            coord.screen = scr;
            coord.origin = scr.origin;
            if isa(varargin{1},'Coordinates')
                
                coord = copy(varargin{1});
                return
                
            elseif length(varargin) == 2
                
                coord.polar.length = varargin{2};
                coord.polar.angle = varargin{1};
                coord = coord.get_cartesian_coordinates();
                
            elseif length(varargin) == 1
                
                coord.cartesian = varargin{1};
                coord = coord.get_polar_coordinates();
                
            end
            
            coord = coord.get_absolute_coordinates();
            
        end
        
        function coord = set_origin(coord,org,type)
            
            if nargin < 3; type = 'dva'; end
            if isrow(org); org = org'; end
            coord.origin = SpatialUnit(coord.screen,org,type);
            coord.origin.addprop('absolute');
            coord.origin.absolute = coord.screen.center + coord.origin.pix;
            coord = coord.get_absolute_coordinates();
            
        end
        
        function coord = get_cartesian_coordinates(coord)
            
            if ~isa(coord.polar.angle,'Angle')
                    error('The first input must be of Angle class.');
            end
            
            if ~isa(coord.polar.length,'SpatialUnit')
                    error('The first input must be of SpatialUnit class.');
            end            
            
            coord.cartesian = coord.pol2cart();
                        
            coord.polar = coord.cart2pol();
            
        end
        
        function coord = get_polar_coordinates(coord)
            
            coord.polar = coord.cart2pol();
            
        end
        
        function cart = pol2cart(coord)
            
            [x,y] = pol2cart(coord.polar.angle.r,coord.polar.length.dva);
            cart = SpatialUnit(coord.screen,[x;y],'dva');
            
        end
        
        function polar = cart2pol(coord)
            
            [th,rho] = cart2pol(coord.cartesian.pix(1,:),coord.cartesian.pix(2,:));
            polar.angle = Angle(th,'radian');
            polar.length = SpatialUnit(coord.screen,rho,'pix');
            
        end
        
        function coord = get_absolute_coordinates(coord)
            
            if ~isprop(coord.cartesian,'absolute'); coord.cartesian.addprop('absolute'); end
            coord.cartesian.absolute = coord.origin.absolute + coord.cartesian.pix;
            
        end
        
        function coord = pivot(coord,angle)
            
            coord.polar.angle = coord.polar.angle + angle;
            coord = coord.get_cartesian_coordinates();
            coord = coord.get_absolute_coordinates();
            
        end
        
        function coord = join(coord,coord1)
            
            coord.origin = [coord.origin;coord1.origin];
            coord.polar.angle = [coord.polar.angle,coord1.polar.angle];
            coord.polar.length = [coord.polar.length,coord1.polar.length];
            coord.cartesian = [coord.cartesian;coord1.cartesian];
            
        end
        
        function coord_selection = select(coord,varargin)
            
            coord_selection = copy(coord);
%             custom origins
%             coord_selection.origin =  coord_selection.origin.select(':',varargin{:});
            coord_selection.cartesian = coord_selection.cartesian.select(':',varargin{:});
            coord_selection.polar.angle = coord_selection.polar.angle.select(varargin{:});
            coord_selection.polar.length = coord_selection.polar.length.select(varargin{:});
            
        end
        
                
    end
    
    methods (Static)
        
        function y = make_row(x)
            
            if iscolumn(x); x = x'; end
            
        end
        
        function y = make_column(x)
            
            if isrow(x); x = x'; end
            
        end
        
    end
    
end