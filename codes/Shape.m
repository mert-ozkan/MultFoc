classdef Shape < dynamicprops & matlab.mixin.Copyable
    
    properties

        center Coordinates
        screen ExperimentScreen
        
    end
    
    methods
        
        function shp = Shape(scr,varargin)
            
            shp.screen = scr;
            shp.center = Coordinates(shp.screen,varargin{:});
            
            
            
        end   
               
        function shp = add_circle(shp,r,unit)
            
            if nargin < 3; unit = 'dva'; end
            shp.addprop('circle');
            shp.circle = make_circle(shp,r,unit);
            shp.circle = shp.circle.place(shp.center);
            
        end
        
        function circ = make_circle(shp,r,unit)
            
            if nargin < 3; unit = 'dva'; end
            if isa(r,'SpatialUnit'); r = r.pix; unit = 'pix'; end
            circ = CircleObject(SpatialUnit(shp.screen,r,unit));
            
        end           
        
        function shp = add_line(shp,varargin)
%             varargin = ln,pw,unit,th or lineobject
            
            if isa(varargin{1},'LineObject')
                
                shp.line = shp.line.append(varargin{1});
                
            else
                
                ln = varargin{1};
                pw = varargin{2};                
                if length(varargin) < 3; unit = 'dva';
                else; unit = varargin{3};
                end
                
                if ~isprop(shp,'line')

                    shp.addprop('line')
                    shp.line = make_line(shp,ln,pw,unit);

                else

                    shp.line = shp.line.append(make_line(shp,ln,pw,unit));

                end
            end
            
            shp.line = shp.line.place(shp.center);
            
        end
        
        function l = make_line(shp,ln,pw,unit)
            
            if nargin < 4; unit = 'dva'; end
            pw = SpatialUnit(shp.screen,pw,unit);
            ln = SpatialUnit(shp.screen,ln,unit);
            l = LineObject(ln,pw);
            
        end
        
        function shp = add_cross(shp,ln,pw,unit)
            
            if nargin < 4; unit = 'dva'; end
            
            shp.addprop('cross');
            cross = shp.make_line(ln,pw,unit);
            cross = cross.place(shp.center);
            shp.cross = cross.append(copy(cross).rotate(Angle(90))).place(shp.center);
            
            
            
        end
        
        function shp = add_object(shp,obj,obj_name)
            
            shp.addprop(obj_name);
            shp.(obj_name) = obj;
            
        end
       
%         function dim = set_poly()
%         end
        
        function dim = set_arc(dim,theta,penwidth,unit_width,unit_theta)
            
            if nargin < 4; unit_width = 'dva'; end
            if nargin < 5; unit_theta = 'degree'; end
            switch class(theta); case 'Angle'; theta = theta.d; end
            dim.penwidth = SpatialUnit(dim.screen,penwidth,unit_width);
            dim.arc_size = Angle(theta,unit_theta); 
            
        end
           
        
        function shp = set_rectangle(shp,w,h,unit)
            
            if nargin < 4; unit = 'dva'; end
            shp.width = SpatialUnit(shp.screen,w,unit);
            shp.height = SpatialUnit(shp.screen,h,unit);
            shp.rect = [-shp.width/2 -shp.height/2 shp.width/2 shp.height/2];
            
        end
        
        function shp = place(shp)
            
            props = properties(shp);
            props = props(~ismember(props,'center'));
            for whProp = 1:length(props)
                
                propN = props{whProp};
                switch class(shp.(propN))
                    
                    case {'CircleObject','LineObject','ArcObject'}
                        shp.(propN) = shp.(propN).place(shp.center);                  
                    
                end
                
                
            end
            
        end
        
        function shp = pivot(shp,varargin)
            
            shp.center = shp.center.pivot(varargin{:});
            shp = shp.place();
            
        end
        
        function new_val = input(dim,val,unit)
            
            new_val = SpatialUnit(dim.screen,val,unit);        
            
        end
        
         
    end 
    
end