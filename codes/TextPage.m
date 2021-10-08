classdef TextPage < handle
    
    properties
        
        screen
        text
        color = [255,255,255,255]        
        
    end
    
    properties (Access = private)
        
        isDynamic = false
        
    end
    
    methods
        
        function pg = TextPage(dr,scr,text_name)
            
            if nargin < 3 || isempty(text_name)
                pg.text = '';
            else
                pg.text = char(join(dr.get_text(text_name),'\n'));
            end
            
            pg.screen = scr;          
                        
        end
        
        function pg = dynamic(pg)
            
            pg.isDynamic = true;
            
        end
        
        function pg = write_text(pg,txt)
            
            pg.text = txt;
            
        end
        
        function draw(pg,varargin)
            
            if pg.isDynamic; txt = sprintf(pg.text,varargin{:});
            elseif iscell(pg.text) && length(pg.text) > 1
                txt = pg.text{varargin{:}};
            else; txt = pg.text;
            end
            
            DrawFormattedText(pg.screen.pointer, txt,'center','center',pg.color,[],[],[],1.5);
            
        end
        
    end
    
end

