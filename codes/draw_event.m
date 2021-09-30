function [scr,kb,ev] = draw_event(scr,kb,ev,varargin)

[~,offset,trg] = ev.now();
switch trg
    
    case 'F'        
        
        varargin{1}.draw();
        scr = scr.flip();
        kb = kb.wait_till(offset);        
        if kb.isEscaped; return; end
        ev = ev.next();
        
    case 'C'
        
        varargin{1}.draw();
        varargin{2}.change_color([255;0;0;255],varargin{3}.cued_discs).draw(3);         
        scr = scr.flip();
        varargin{2}.change_color([255;255;255;255],varargin{3}.cued_discs);
        kb = kb.wait_till(offset);
        if kb.isEscaped; return; end
        ev = ev.next();        
        
    case 'A'
        
        varargin{1}.draw();
        varargin{2}.draw(3);        
        scr = scr.flip();
        kb = kb.wait_till(offset);
        if kb.isEscaped; return; end
        ev = ev.next();
        
    case {'T','D'}
        
        varargin{1}.draw();
        varargin{2}.draw(3);
        cond = varargin{3};
        cfg = cond.arc_configurations(cond.current,:);
        
        for idx = find(cfg~=' ')
            varargin{4}.(cfg(idx)).select(idx).draw();
        end
        scr.flip();
        kb = kb.wait_till(offset);
        if kb.isEscaped; return; end
        ev = ev.next();
        cond.next();
        
    case 'R'
        
        scr = scr.draw(varargin{5}).flip();
        kb = kb.wait_for_key_press(kb.reaction_keys,offset).check_for_accuracy(varargin{3}.no_of_targets).flush();
        if kb.isEscaped; return; end
        ev = ev.next();
        
    case 'E'
        
        if ~kb.isKeyPressed; whMsg = 3;
        elseif kb.accuracy; whMsg = 1;
        else; whMsg = 2;
        end
        scr = scr.draw(varargin{6},whMsg).flip();
        kb = kb.wait_till(offset);
        if kb.isEscaped; return; end
        ev = ev.next();
        
end

end