classdef Frames < dynamicprops & matlab.mixin.Copyable
    
    properties
        
        rate double
        rank uint64
        no uint64 = 1
        isFlickerOn logical
        duration double
        
    end
    
    properties (Dependent)
        
        total
        ifi %interframe interval
        actual_duration
        onsets
        
    end
    
    
    methods
        
        function frm = Frames(scr_or_frmrate,dur_of_frm)
            
            if isa(scr_or_frmrate,'ExperimentScreen'); frm.rate = scr_or_frmrate.frame_rate;
            else; frm.rate = scr_or_frmrate;
            end
            
            frm.duration = dur_of_frm;                
            frm.rank = 1:frm.total;
            frm.isFlickerOn = false;
            
        end
        
        function total = get.total(frm)
            
            total = uint64(round(frm.duration*frm.rate));
            
        end
        
        function ifi = get.ifi(frm)
            
            ifi = 1/frm.rate;
            
        end
        
        function dur = get.actual_duration(frm)
            
            dur = double(frm.total)*frm.ifi;
            
        end
        
        function t = get.onsets(frm)
            
            t = double(frm.rank-1)*frm.ifi;
            
        end
        
        function frm = end(frm)
            
            frm.no = frm.no+1;
            
        end
        
        function set.isFlickerOn(frm,val)
            
            if length(val) == 1
                val = repmat(val,1,frm.total);
            elseif length(val) ~= frm.total
                error('arbitrary values for frm.isFlickerOn');
            end
            
            frm.isFlickerOn = val;
            
        end
        
        function frm = add_flicker(frm,varargin)
            
            if ~any(frm.isFlickerOn); frm.isFlickerOn = ~frm.isFlickerOn; end
            n_frm_w_flck = sum(frm.isFlickerOn);
            
            for whFreq = 1:2:length(varargin)
                name = varargin{whFreq};
                freq = varargin{whFreq+1};                
                if ~isprop(frm,name); p = frm.addprop(name); p.NonCopyable =false; end
                
                pivots = find(diff(mod(frm.onsets(frm.isFlickerOn),1/freq))<=0);
                intvs= horzcat([1;pivots'+1],[pivots';n_frm_w_flck]);
                flck = arrayfun(@(x,y,z) ones(1,y-x+1)*mod(z,2)+1,intvs(:,1),intvs(:,2),(1:size(intvs,1))','UniformOutput',false);
                frm.(name) = nan(1,frm.total);
                frm.(name)(frm.isFlickerOn) = horzcat(flck{:});
            end
            
        end
        
        function frm = append(frm1,frm2)
            
            if ~(isempty(frm1) || isempty(frm1))
                frm = Frames(frm1.rate, frm1.actual_duration + frm2.actual_duration);                
            else
                dur = [frm1.actual_duration, frm2.actual_duration];
                frmrate = [frm1.rate, frm2.rate];
                frm = Frames(frmrate,dur);
            end
            
            frm.isFlickerOn = [frm1.isFlickerOn, frm2.isFlickerOn];
            
        end
        
        function frm1 = select(frm,idx_or_logical_or_intv)
            
            frm1 = copy(frm);
            frm1.duration = length(idx_or_logical_or_intv)*frm1.ifi;
            frm1.isFlickerOn = frm1.isFlickerOn(idx_or_logical_or_intv);
            frm1.rank = frm1.rank(idx_or_logical_or_intv);
            
            
        end
        
        function prev_frm = previous(frm)
            
            if frm.no > 1
                
                prev_frm = copy(frm);
                prev_frm.no = prev_frm.no - 1;
                
            else
                
                prev_frm = Frames.empty();
            
            end
            
        end
        
        function next_frm = next(frm)
            
            if frm.no < frm.total
                
                next_frm = copy(frm);
                next_frm.no = next_frm.no + 1;
                
            else
                
                next_frm = Frames.empty();
            
            end
            
        end
        
    end
end