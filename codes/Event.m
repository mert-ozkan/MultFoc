classdef Event < handle
    
    properties

        onset double
%         offset
        duration double
        trigger char
        no_of_events
        
        
    end
    
    properties (Dependent)
        
        no_of_intervals
        no_of_triggers        
        
    end
    
    methods
        
        function ev = Event(strct)

            ev.onset(1) = GetSecs;
            for whIntv = 1:strct.no_of_intervals
                
                ev = ev.(strct.structure{whIntv}{1})(whIntv,strct.structure{whIntv}{2:end});                
                
            end
            
            
        end
        
        function ev = add_event(ev,dur,trg)

            ev.duration(end+1) = dur;
            ev.trigger(end+1) = trg;
            ev.no_of_events(end+1) = 1;
            
        end
        
%         function ev = add_jittered_event(ev,intv_no,min_secs,max_secs,trg)
%                         
%             dur = random('Uniform',min_secs,max_secs);
%             ev.duration(end+1) = dur;
%             ev.trigger(end+1) = trg;
%             ev.no_of_events(end+1) = 1;
%             
%         end
        
        function ev = add_random_probes_event(ev,dur,probe_dur,n_probes,min_isi,probe_trg,isi_trg,lastbeforesecs)
            
            if nargin < 8; lastbeforesecs = probe_dur;
            else; lastbeforesecs = lastbeforesecs + probe_dur;
            end
            probe_intv = dur - lastbeforesecs;
            min_isi = min_isi + probe_dur;
            
            probe_t = ev.get_random_intervals(0,probe_intv,min_isi,n_probes);
            intv = diff(unique([0,probe_t,probe_t+probe_dur,dur]));
            trg = repmat(isi_trg,1,length(intv));
            trg(ismember(probe_dur,intv)) = probe_trg;            
            
            for whEv = 1:length(trg)
                
                ev = ev.add_event(intv(whEv,trg(whEv)));
                
            end
            ev.no_of_events(end+1) = length(trg);
            
            
        end
       
    end
    
    methods (Static)
        
        function intv = get_random_intervals(start_t,end_t,min_isi,n_probes)
            
            intv = [];
            while isempty(intv) || ~all(diff(intv) > min_isi) && length(intv) ~= 1
                
                intv = sort(random('Uniform',start_t,end_t,1,n_probes));
                
            end
            
        end
        
    end
    
end