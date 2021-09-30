classdef Angle < matlab.mixin.Copyable
    
    properties
        
        unit = 'degree'
        d
        r

    end
    
    methods
        
        function ang = Angle(theta,unit)
            
            if nargin > 1; ang.unit = unit; end
            switch lower(ang.unit)
                
                case {'degree','degrees','d'}
                    
                    ang.d = theta;
                    ang.r = deg2rad(theta);
                    
                case {'radian','radians','r'}
                    
                    ang.r = theta;
                    ang.d = rad2deg(theta);
                    ang.unit = 'radian';
            
            end
        end               
        
        function op = index(ang,idx)
            
            op  = Angle(ang.d(idx));
            
        end
        
        function y = sin(ang)
            
            y = sin(ang.r);
            
        end
        
        function y = cos(ang)
            
            y = cos(ang.r);
            
        end
        
        function y = tan(ang)
            
            y = tan(ang.r);
            
        end
        
        function ang = repmat(ang,varargin)
            
            ang = Angle(repmat(ang.d,varargin{:}));
            
        end
        
        function iseq = eq(ang1,ang2)
            
            iseq = ang1.r == ang2.r;
            
        end
        
        function isne = ne(ang1,ang2)
            
            isne = ang1.r ~= ang2.r;
            
        end
        
        function el = get_degrees(ang1,ang2)
            
            el = cell.empty(0,2);
            angX = {ang1,ang2};
            for whAng = 1:2
                switch class(angX{whAng})
                    case 'Angle'
                        el{whAng} = angX{whAng}.d;
                    case 'double'
                        el{whAng} = angX{whAng};
                        
                    otherwise
                        error('get_degrees in Angle')
                end
            end
            
        end
        
        function op = horzcat(ang1,ang2)
            
            el = get_degrees(ang1,ang2);            
            op = Angle([el{1},el{2}]);
            
        end
        
        function op = plus(ang1,ang2)
            
            el = get_degrees(ang1,ang2);            
            op = Angle(el{1}+el{2});
            
        end
        
        function op = minus(ang1,ang2)
            
            el = get_degrees(ang1,ang2);            
            op = Angle(el{1}-el{2});     
            
        end
        
        function op = times(ang1,ang2)
            
           el = get_degrees(ang1,ang2);            
           op = Angle(el{1}.*el{2});            
            
        end      
        
        
        function op = rdivide(ang1,ang2)
            
            el = get_degrees(ang1,ang2);
            op = Angle(el{1}./el{2});       
            
        end
        
        function op = ldivide(ang1,ang2)
            
            el = get_degrees(ang1,ang2);
            op = Angle(el{1}.\el{2});           
            
        end
        
        function op = mtimes(ang1,ang2)
            
            op = ang1.*ang2;                      
            
        end
        
        function op = mldivide(ang1,ang2)
            
            op = ang1.\ang2;                      
            
        end
        
        function op = mrdivide(ang1,ang2)
            
            op = ang1./ang2;                      
            
        end       
        
        function ang_selection = select(ang,varargin)
            
            ang_selection = Angle(ang.d(varargin{:}));
            
        end
        
        function ang = transpose(ang)
            
            ang = SpatialUnit(ang.screen,ang.pix','pix');
            
        end
        
        function ang = ctranspose(ang)
            
            ang = transpose(ang);
            
        end
        
        function isCol = iscolumn(ang)
            
            isCol = iscolumn(ang.d);
            
        end
        
        function isRow = isrow(ang)
            
            isRow = isrow(ang.d);
            
        end
        
        function sz = size(ang,idx)
            
            if nargin < 2
                sz = size(ang.d);
            else
                sz = size(ang.d,idx);
            end
            
        end
        
    end
    
    
    methods (Static)
        
        function isAng = isAngle(ang)
            
            switch class(ang)
                case 'Angle'
                    isAng = true;
                otherwise
                    isAng = false;
            end
            
        end
        
    end
end