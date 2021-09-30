classdef SpatialUnit < matlab.mixin.Copyable 
    
    properties
        
        screen ExperimentScreen
        pix double = 0
        dva double = 0
        absolute double
        
    end
    
    properties (Dependent)
        
        no_of_items
        no_of_frames
        
    end
    
    methods
        
        function spa = SpatialUnit(scr,val,unit)
            
            spa.screen = scr;
            if nargin < 3; unit = 'dva'; end
            spa = spa.input(val,unit);
            
        end
        
        function spa = input(spa,val,unit)
            
            if nargin < 3; unit = 'dva'; end
            
            switch  lower(unit)
                
                case {'p','pix','pixel','pixels'}
                    
                    spa.pix = round(val);
                    spa.dva = spa.screen.pix2dva(spa.pix);
                    
                case {'d','dva','degree','degrees'}
                    
                    spa.pix = spa.screen.dva2pix(val);                    
                    spa.dva = spa.screen.pix2dva(spa.pix);
                    
            end            
            
        end        
        
        function spa = get_absolute_coordinates(spa)
            
            spa.absolute = spa.pix + spa.screen.origin.absolute;
            
        
        end
        
        
        function n = get.no_of_items(spa)
            
            n = size(spa.pix,2);
            
        end
        
        function n = get.no_of_frames(spa)
            
            n = size(spa.pix,1);
            
        end
        
        function op = plus(spa1,spa2)
            
            op = SpatialUnit.return_spatialunit(spa1,spa2);
            spa1 = SpatialUnit.return_scalar(spa1);
            spa2 = SpatialUnit.return_scalar(spa2);
            
            if length(spa1) == length(spa2)
                op = op.input(spa1+spa2,'pix');
            else
                error('Both inputs need to be a SpatialUnit class or Same Length');
            end
            
        end
        
        function op = minus(spa1,spa2)
            
            op = SpatialUnit.return_spatialunit(spa1,spa2);
            spa1 = SpatialUnit.return_scalar(spa1);
            spa2 = SpatialUnit.return_scalar(spa2);
            
            if length(spa1) == length(spa2)
                op = op.return_spatialunit(spa1,spa2).input(spa1-spa2,'pix');
            else
                error('Both inputs need to be a SpatialUnit class.');
            end
            
        end
        
        function op = times(spa1,spa2)
            
            op = SpatialUnit.return_spatialunit(spa1,spa2).input(SpatialUnit.return_scalar(spa1).*SpatialUnit.return_scalar(spa2),'pix');
            
        end
        
        function op = mtimes(spa1,spa2)
            
            op = spa1.*spa2;
            
        end
        
        function op = uminus(spa)
            
            op = -1.*spa;
            
        end
        
        
        function op = rdivide(spa1,spa2)
            
            op = SpatialUnit.return_spatialunit(spa1,spa2).input(SpatialUnit.return_scalar(spa1)./SpatialUnit.return_scalar(spa2),'pix');
            
        end
        
        function op = mrdivide(spa1,spa2)
            
            op = spa1./spa2;
            
        end
        
        function op = ldivide(spa1,spa2)
            
            op = SpatialUnit.return_spatialunit(spa1,spa2).input(SpatialUnit.return_scalar(spa1).\SpatialUnit.return_scalar(spa2),'pix');
            
        end
        
        function op = mldivide(spa1,spa2)
            
            op = spa1.\spa2;
            
        end
        
        function op = power(spa1,spa2)
            
            op = SpatialUnit.return_spatialunit(spa1,spa2).input(SpatialUnit.return_scalar(spa1).^SpatialUnit.return_scalar(spa2),'pix');
            
        end
        
        function op = mpower(spa1,spa2)
            
            op = spa1.^spa2;
            
        end
        
        
        function op = horzcat(varargin)
                        
            if all(strcmp(arrayfun(@(x) class(x{:}),varargin,'UniformOutput',false),'SpatialUnit'))
                spa = arrayfun(@(x) x{:}.pix,varargin,'UniformOutput',false);
                if iscell(spa)
                    spa = cell2mat(spa);
                end
                op = copy(varargin{1}).input(spa,'pix');
            else
                error('All inputs need to be a SpatialUnit class.');
            end
            
        end
        
        function op = vertcat(varargin)
            
            if all(strcmp(arrayfun(@(x) class(x{:}),varargin,'UniformOutput',false),'SpatialUnit'))
               spa = arrayfun(@(x) x{:}.pix,varargin,'UniformOutput',false);
                if iscell(spa)
                    spa = cell2mat(spa');
                end
                op = copy(varargin{1}).input(spa,'pix');
            else
                error('Both inputs need to be a SpatialUnit class.');
            end
            
        end
        
        function slxn = select(spa,varargin)
            
            slxn = copy(spa);
            slxn.pix = slxn.pix(varargin{:});
            slxn.dva = slxn.dva(varargin{:});
            if ~isempty(spa.absolute); slxn.absolute = slxn.absolute(varargin{:}); end
             
        end
        
        function slxn = frame(spa,idx)
            
            if spa.no_of_frames == 1; slxn = spa; return; end
            
            slxn = copy(spa);
            slxn.pix = slxn.pix(idx,:);
            slxn.dva = slxn.dva(idx,:);
            
            
        end
        
        function l = length(spa)
            
            l = length(spa.pix);
            
        end
        
        function spa = transpose(spa)
            
            spa = SpatialUnit(spa.screen,spa.pix','pix');
            
        end
        
        function spa = ctranspose(spa)
            
            spa = transpose(spa);
            
        end
        
        function isCol = iscolumn(spa)
            
            isCol = iscolumn(spa.pix);
            
        end
        
        function isRow = isrow(spa)
            
            isRow = isrow(spa.pix);
            
        end
        
        function sz = size(spa,idx)
            if nargin < 2
                sz = size(spa.pix);
            else
                sz = size(spa.pix,idx);
            end
        end
        
        function val2 = repmat(val1,varargin)
            
            val2 = SpatialUnit(val1.screen,repmat(val1.pix,varargin{:}),'pix');
            
        end
        
    end
    
    methods (Static)
        
        function isSpa = isspatialunit(x)
            
            isSpa = isa(x,'SpatialUnit');
            
        end
        
        function y = return_scalar(x)
            
            if SpatialUnit.isspatialunit(x)
                y = x.pix;
            else
                y = x;
            end
            
        end
        
        function z = return_spatialunit(varargin)
            
            for whArg = varargin
            
                if SpatialUnit.isspatialunit(whArg{:})
                    z = copy(whArg{:});
                    break;
                end
                
            end
            
        end
        
        
    end
    
end