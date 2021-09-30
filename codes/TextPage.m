classdef TextPage < handle
    
    properties
        
        text
        color = [255,255,255,255]
        isDynamic = false
        
    end
    
    methods
        
        function pg = TextPage(dr,text_name,isDynamic)
            
            if nargin < 2 || isempty(text_name)
                pg.text = '';
            else
                pg.text = char(join(dr.get_text(text_name),'\n'));
            end
            
            if nargin > 2; pg.isDynamic = isDynamic; end
            
        end
        
        function pg = write_text(pg,txt)
            
            pg.text = txt;
            
        end
        
        function scr = draw(pg,scr,varargin)
            
            if pg.isDynamic; txt = sprintf(pg.text,varargin{:});
            elseif iscell(pg.text) && length(pg.text) > 1
                txt = pg.text{varargin{:}};
            else; txt = pg.text;
            end
            
            DrawFormattedText(scr.pointer, txt,'center','center',pg.color,[],[],[],1.5);
            
        end
        
    end
    
end

