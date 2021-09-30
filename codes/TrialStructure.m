classdef TrialStructure < handle
    
    properties
        
        order double        
        onset double
        offset double
        duration double
        trigger char
        isConditional logical
        condition cell
        isInterruptible logical
        isIndefinite logical
        
        current = 1
        
    end
    
    properties (Dependent)
        
        no_of_events
        no_of_triggers
        
    end
    
    methods
        
        function ev = TrialStructure()
            
        end

                
        function no = get.no_of_events(ev)
            
            no = max(ev.order);
            if isempty(no); no = 0; end
            
        end
        
        function ev = add_event(ev,dur,trg)                                   
            
            if ev.no_of_events
                ev.order = 1;
                ev.onset = 0;
            else
                ev.order(end+1) = ev.order(end)+1;
                ev.onset(end+1) = ev.onset(end) + ev.duration(end);                 
            end 
            
            ev.duration(end+1) = dur;
            ev.offset(end+1) = en.onset(end) + ev.duration(end);
            ev.trigger(end+1) = trg;
            ev.isConditional(end+1) = false;
            ev.condition{end+1} = {};            
            ev.isInterruptible(end+1) = dur==Inf;
            ev.isIndefinite(end+1) = dur==Inf;
            
        end
        
        function ev = constant_event(ev,dur,trg)

            ev = ev.add_event(dur,trg);
            
        end
        
        function ev = jittered_event(ev,dur,sd,trg)
                        
            dur = random('Uniform',dur-sd,dur+sd);
            ev = ev.add_event(dur,trg);
            
        end
        
        function ev = random_probes_event(ev,dur,probe_dur,min_isi,probe_trg,isi_trg,firstaftersecs,lastbeforesecs)
            % ugly
            if nargin < 8; firstaftersecs = 0; end
            if nargin < 9; lastbeforesecs = probe_dur; end
            n_probes = length(probe_trg);
            min_isi = min_isi + probe_dur;
            intv = ev.random_intervals(firstaftersecs,dur-lastbeforesecs,min_isi,n_probes);
            intv = sort([intv, intv+probe_dur]);
            intv = intv(intv<dur);
            intv = [intv(1),diff(intv)];            
            intv = [intv, dur-sum(intv)];
            trg = char(join([join(string([repmat(isi_trg,size(probe_trg));probe_trg]'),''),isi_trg],''));
            
            for whIntv = 1:length(intv)
                                
                trgN = trg(whIntv);
                intvN = intv(whIntv);
                if ~intvN; continue; end
                ev = ev.add_event(intvN,trgN);
                
            end
                       
        end
        
        function ev = random_intervals_event(ev,dur,probe_dur,min_isi,probe_trg,isi_trg,firstaftersecs,lastbeforesecs)
            % ugly
            if nargin < 8; firstaftersecs = 0; end
            if nargin < 9; lastbeforesecs = probe_dur; end
            n_probes = length(probe_trg);
            min_isi = min_isi + probe_dur;
            intv = ev.random_intervals(firstaftersecs,dur-lastbeforesecs,min_isi,n_probes);
            intv = sort([intv, intv+probe_dur]);
            intv = intv(intv<dur);
            intv = [intv(1),diff(intv)];            
            intv = [intv, dur-sum(intv)];
            trg = char(join([join(string([repmat(isi_trg,size(probe_trg));probe_trg]'),''),isi_trg],''));
            
            for whIntv = 1:length(intv)
                                
                trgN = trg(whIntv);
                intvN = intv(whIntv);
                if ~intvN; continue; end
                ev = ev.add_event(intvN,trgN);
                
            end
                       
        end
        
        function ev = indefinite_event(ev,trg)
            
            ev = ev.add_event(Inf,trg);
            
        end
        
        function ev = interruptible(ev)
            
            ev.isInterruptible(end) = true;
            
        end
        
        function ev = conditional(ev,fun)
            
            ev.isConditional(end) = true;
            ev.conditional(end) = fun;
            
        end
        
        function varargout = now(ev)
            
            i = ev.current;
            varargout = {ev.onset(i),ev.offset(i),ev.trigger(i)};
            
        end
        
        function ev = next(ev)
            
            ev.current = ev.current + 1;
            
        end
        
        
        
        
    end
    
    methods (Static)
        
        function intv = random_intervals(start_t,end_t,min_isi,n_probes)
            
            intv = [];
            while isempty(intv) || all(diff(intv) > min_isi) && length(intv) ~= 1
                
                intv = sort(random('Uniform',start_t,end_t,1,n_probes));
                
            end
            
        end
        
    end
    
end