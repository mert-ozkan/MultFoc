classdef RGBA < matlab.mixin.Copyable
    
    % color values in Red Green Blue Alpha (transparency) format
    
    properties
        
        items uint8
        lookup_table uint8
        
    end
    
    properties (Dependent)
        
        rgba_values
        no_of_items
        no_of_frames
        explicit_items
        
    end
    
    properties (Access = private)
        
        isLUT = false;
        
    end
    
    methods
        
        function clr = RGBA(varargin)
            
            if isempty(varargin); return; end
            clr.items = RGBA().get_rgba_matrix(varargin{:});              
                                    
        end
        
        function rgba = get.rgba_values(clr)
            
            if ~clr.isLUT; rgba = clr.items; return; end
            rgba = clr.lookup(clr.items);
            
            
        end
        
        function n = get.no_of_items(clr)
            
            n= size(clr.items,2);
            
        end
        
        function n = get.no_of_frames(clr)
            
            n= size(clr.rgba_values,1)/4;
            
        end
        
        function idx = get.explicit_items(clr)
            
            if clr.isLUT
                idx = find(clr.items);
            else
                idx = find(~all(~clr.items,1)); %fix
            end
            
        end
        
        function clr = set_lookup_table(clr,varargin)
            
            clr.isLUT = true;
            if ~isempty(clr.items); clr.items(2:4,:) = []; end
            n_col = length(varargin);
            lut = zeros(4,n_col);
            for whCol = 1:n_col
                
                colN = varargin{whCol};
                if isrow(colN); colN = colN'; end
                lut(:,whCol) =  RGBA().get_rgba_matrix(colN);
                
            end
            clr.lookup_table = lut;
            
        end
        
        function slxn = select(clr,val)
            
            slxn = copy(clr);
            slxn.items = slxn.items(:,val);
            
        end
        
        function clr = input(clr,val)
            
            if clr.isLUT
                clr.items = val;
            else
            end
            
        end
        
        function slxn = lookup(clr,val)
            
            if isrow(val)
                
                slxn = nan(4,length(val));
                slxn(:,logical(val)) = clr.lookup_table(:,val(logical(val)));
                
            elseif iscolumn(val)
                
                slxn = nan(4*length(val),1);
                clrN = clr.lookup_table(:,val(logical(val)));
                slxn(repelem(logical(val),4,1)) = clrN(:);
                
            else
                
                rep = num2cell([4,ones(1,ndims(val)-1)]);
                slxn = nan(size(val));                
                slxn = repelem(slxn,rep{:});
                idx = repelem(logical(val),rep{:});
                slxn(idx) = clr.lookup_table(:,val(logical(val)));               
                                               
            end
            
        end
        
        function slxn = frame(clr,idx)
            
            if clr.no_of_frames == 1; slxn = clr; return; end
            
            slxn = copy(clr);
            slxn.items = slxn.items(idx,:);            
            
        end
        
        function clr = change_rgba(clr)
        end
        
        function clr = change_brightness(clr)
        end
        
        function clr = change_transparency(clr)
        end
        
        function clr = change_color(clr)
        end       
        
        
    end
    
    methods (Static)
        
        function items = get_rgba_matrix(val,no_of_it)
            
            [n_gun, n_it] = size(val);
            if ~ismember(n_gun,[1,3,4])
                
                error('RGBA requires 1, 3 or 4 values.');
            
            elseif n_gun == 1
                
                val = [repmat(val,3,1); repmat(255,1,n_it)];
                
            elseif n_gun == 3
            
                val(4,:) = 255;
            
            end
            
            if nargin < 2
            
                items = val;
            
            elseif n_it ~= 1
            
                error('Number of items are not corresponding to given RGBA values.');
            
            else
                
                items = repmat(val,1,no_of_it);
            
            end                 
            
        end
        
    end
    
    
end