classdef Intervals < matlab.mixin.Copyable
    
    properties
        
        onsets double
        offsets double
        current uint64 = 1
        durations double
        triggers char          
        frame_counts uint64             
        
        frames Frames
        
    end
    
    properties (Dependent)
        
        no_of_intervals
        no_of_frames
        onset
        offset
        duration
        trigger
        initial_frames_per_event
        
    end
    
    properties (Access = private)
        
        intervalF struct = struct('type',[],'trigger',[],'isCreateEvent',[])
        isCreateEvent logical
        isFlickerOn logical
        
    end
    
    methods
        
        function intv = Intervals()
            
            intv.onsets = GetSecs;
            
        end
        
        function intv = add_interval(intv,dur,trg)
            
            intv.durations(end+1) = dur;
            intv.triggers(end+1) = trg;
            intv.isCreateEvent = true;
            intv.isFlickerOn(end+1) = false;
            
            intv.intervalF.type = 'constant';
            intv.intervalF.trigger = trg;
            intv.intervalF.isCreateEvent = true;
            
        end
        
        function intv = conditional(intv,isCreateEvent)            
                        
            if ~isCreateEvent
                intv.isCreateEvent = isCreateEvent;
                intv.durations(end) = [];
                intv.triggers(end) = [];
                intv.isFlickerOn(end) = [];
                           
                intv.intervalF.trigger = [];                
            end
            intv.intervalF.type = 'conditional';
            intv.intervalF.isCreateEvent = isCreateEvent;
            
        end        
        
        function intv = jitter(intv,val)
            
            if ~intv.isCreateEvent; return; end
            dur = intv.durations(end);
            intv.durations(end) = random('Uniform',dur-val,dur+val);
            
            intv.intervalF.type = 'jittered';            
        end
        
        function intv = add_random_probes(intv,probe_dur,n_probes,probe_trg,min_isi,lastbeforesecs)
            
            if ~intv.isCreateEvent; return; end
            dur = intv.durations(end);
            isi_trg = intv.triggers(end);
            intv.durations(end) = [];
            intv.triggers(end) = [];
            intv.isFlickerOn(end) = [];
            
            if nargin < 5; min_isi = probe_dur; end
            if nargin < 6; lastbeforesecs = probe_dur;
            else; lastbeforesecs = lastbeforesecs + probe_dur;
            end
            
            probe_intv = dur - lastbeforesecs;
            min_isi = min_isi + probe_dur;
            
            probe_times = intv.get_random_intervals(0,probe_intv,min_isi,n_probes);
            event_dur = diff(unique([0,probe_times,probe_times+probe_dur,dur]));
            trg = repmat(isi_trg,1,length(event_dur));
            trg(ismembertol(event_dur,probe_dur)) = probe_trg;
            
            for whEv = 1:length(trg)
                
                intv = intv.add_interval(event_dur(whEv),trg(whEv));
                
            end
            
            intv.intervalF.type = 'random_probes';
            intv.intervalF.trigger = trg;
            
        end
        
        function intv = flicker_on(intv)
            
            no_of_events_at_intervalF = length(intv.intervalF.trigger);
            intv.isFlickerOn((end-no_of_events_at_intervalF+1):end) = true;
            
            
        end
        
        function intv = complete(intv)
            
            
            repeating_events = find(diff(intv.triggers)==0)+[0;1];
            if ~isempty(repeating_events)
                intv.durations(repeating_events(1,:)) = intv.durations(repeating_events(1,:)) + intv.durations(repeating_events(2,:));
                intv.durations(repeating_events(2,:)) = [];
                intv.triggers(repeating_events(1,:)) = [];
                intv.isFlickerOn(repeating_events(1,:)) = [];
            end
            intv.onsets = intv.onsets + [0, arrayfun(@(x) sum(intv.durations(1:x)), 1:intv.no_of_intervals-1)];
            intv.offsets = intv.onsets+intv.durations;
            
        end        
        
        function intv = end(intv)
            
            if isempty(intv.frames)
                
                intv.current = intv.current + 1;
                
            else
                
                intv.frames.end();
                intv.current = find(intv.frames.no>=intv.initial_frames_per_event,1,'last');
                
            end
            
        end
        
        
        function prev_intv = previous(intv)
            
            prev_intv = Intervals.empty();            
            if isempty(intv.frames)
                
                if intv.current > 1
                    prev_intv = copy(intv);
                    prev_intv.current = prev_intv.current - 1;
                end
            
            else
                
                prev_intv = copy(intv);
                prev_intv.frames = prev_intv.frames.previous();
                prev_intv.current = find(prev_intv.frames.no>=prev_intv.initial_frames_per_event,1,'last');
                
            end             
                        
        end
        
        function next_intv = next(intv)
            
            next_intv = Intervals.empty();            
            if isempty(intv.frames)
                
                if intv.current < intv.no_of_intervals
                    next_intv = copy(intv);
                    next_intv.current = next_intv.current + 1;
                end
            
            else
                
                next_intv = copy(intv);
                next_intv.frames = next_intv.frames.next();
                intv.current = find(next_intv.frames.no>=next_intv.initial_frames_per_event,1,'last');
                
            end             
                        
        end
        
        function n = get.no_of_intervals(intv)
            
            n = length(intv.durations);
            
        end
        
        function t = get.onset(intv)
            
            t = intv.onsets(intv.current);
            
        end
        
        function t = get.offset(intv)
            
            t = intv.offsets(intv.current);
            
        end
        
        function t = get.duration(intv)
            
            t = intv.durations(intv.current);
            
        end
        
        function trg = get.trigger(intv)
            
            trg = intv.triggers(intv.current);
            
        end
        
        function frms = get.initial_frames_per_event(intv)
            
            frms = cumsum([1,intv.frame_counts(1:end-1)]);
            
        end
        
        function n = get.no_of_frames(intv)
            
            n = intv.frames.total;
            
        end
        
        function intv = create_frames(intv,scr,varargin)
            
            intv.frames = Frames.empty();
            intv.frame_counts = zeros(1,intv.no_of_intervals);
            for whIntv = 1:intv.no_of_intervals
                frmN = Frames(scr,intv.durations(whIntv));
                frmN.isFlickerOn = intv.isFlickerOn(whIntv);
                intv.frame_counts(whIntv) = frmN.total;
                intv.frames = intv.frames.append(frmN);                
            end
            
            if nargin > 2
                intv = intv.with_flicker(varargin{:});
            end
            
        end
        
        function intv = with_flicker(intv,varargin)
            
            intv.frames.add_flicker(varargin{:});
            
        end
        
        function isFlickerOn = get_flicker_events(intv)
            
            isFlickerOn = intv.isFlickerOn;
            
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