%% Multifocal Attention Exp 1

clear all; close all; sca;

%% Parameters
parent_path = 'C:\Users\f0052jm\Desktop\EXPERIMENTS\Mert\MultFoc';

stimulus_eccentricities = [7,10.5,16]; % eccentricity in dva
disc_radii = [1.1,1.9,2.7]; % disc radius per eccentricity in dva
fixation_coordinates = [0,-10]; % with respect to screen center (if
% cartesian coordinates, negative values signifies up in y-axis and left in
% x-axis)

no_of_discs_per_ecc = 8;
polar_angle_first_disc = 11.25; % in degrees. Polar coordinates of the
% center of the first disc. Angles are calculated with respect to the
% origin (fixation_coordinates in this script).
% stimulus_eccentricities are the length of the polar vector. Angle and
% length constitutes polar coordinates. 0 degrees points to the east-end,
% an x-degree clockwise rotation is positive (+x; -x if counter-clockwise).
disc_color = [255;255;255;255]; % rows correspond to [R; G; B; Alpha]
arc_pw = .05;
stim_clr = RGBA().set_lookup_table(255,0,127,[255,0,0]);

test_disc_id = [5,8,11,14,17,20]; % this ugly; gon change.

arc_color = 127;% [255,0,0]';

% Event triggers: trigger per stimulus display and keypress (latter not ready)
trg_fix = 'F'; %fixation
trg_cue = 'C'; %cue
trg_arr = 'D'; %array of discs
trg_probe = 'P';
trg_rxn = 'R'; %response screen

precue_dur = .5;
cue_dur = 1.5; % gon change in the block desgn
prestim_dur = .8;
pretest_dur = .5;
test_dur = 6;
probe_dur = .15;
min_isi = 1;
posttest_dur = .3;

% refractory_period = 

latest_rxn = 1; % it is fixed right now, gonna change
fdbck_dur = .1;

reaction_keys = {'RightArrow','LeftArrow'};
reaction_key_codes = 'RL'; % 'c' for 0, 'v' for 1 etc.
% feedback_texts = {'Correct','Wrong','Too Late!'};

%% Experiment
dr = Directories(parent_path);

sxn = Session('try');
sub = Participant(dr,sxn.isDebug,sxn.isNew);
sxn = sxn.get_initial_trial(sub);
trl = Trial(sub,sxn);
dat = DataFile(sub,'data',{'trial_no','cue1','cue2','cue3','shape','hemifield','no_of_targets','no_of_event','isTarget','event_order','target_order','response','response_time'});
trg = DataFile(sub,'timestamps',{'trial_no','trigger','time'});


instruction_page = TextPage(dr,'instructions');
reaction_page = TextPage(dr,'reaction');
% feedback_page = TextPage(dr).write_text(feedback_texts);

scr = ExperimentScreen().open_window().set_origin(fixation_coordinates);
kb = ExperimentKeyboard().set_reaction_keys(reaction_keys,reaction_key_codes);
fix = BullsEyeCrossFixation(scr);



disc_prop = combvec([1,2,3],polar_angle_first_disc+(0:(no_of_discs_per_ecc-1))*180/no_of_discs_per_ecc);
disc_prop(3,:) = disc_radii(disc_prop(1,:));
disc_prop(1,:) = stimulus_eccentricities(disc_prop(1,:));
disc = CircleObject(SpatialUnit(scr,disc_prop(3,:)))...
    .set_color(stim_clr.input(2*ones(1,24)))...
    .place(Angle(disc_prop(2,:)),SpatialUnit(scr,disc_prop(1,:)));

start_angles_right = Angle(90)+disc.center.polar.angle.select(test_disc_id(1:3)) + Angle(45);
start_angles_left = Angle(90)+disc.center.polar.angle.select(test_disc_id(4:6)) + Angle(45);

% this ugly; gon change
arc_left = disc.select(test_disc_id(1:3)).scale(.5).circ2arc(start_angles_right,Angle(90),SpatialUnit(scr,arc_pw)).set_color(arc_color);
arc_right = copy(arc_left).rotate(Angle(180));
arc.Right = Shape(scr,arc_left.center).add_object(arc_right,'R').add_object(arc_left,'L');
arc_left = disc.select(test_disc_id(4:6)).scale(.5).circ2arc(start_angles_left,Angle(90),SpatialUnit(scr,arc_pw)).set_color(arc_color);
arc_right = copy(arc_left).rotate(Angle(180));
arc.Left = Shape(scr,arc_left.center).add_object(arc_right,'R').add_object(arc_left,'L');
% Instruction Page
scr.draw(instruction_page).flip();
kb.start().wait_for_next().flush().reset();

disc_ids = struct('Right',[5,8,11],'Left',[14,17,20]);

isCueTrial = true;
while trl.no <= trl.no_of_trials && ~kb.isEscaped
    
    trl = trl.add_counter('probes',trl.no_of_events);
    [c1,c2,c3,hem] = trl.get('C1','C2','C3','Hemifield');
    cued_discs = disc_ids.(hem)(logical([c1,c2,c3]));
    if trl.no ~= sxn.initial_trial
        [p_c1,p_c2,p_c3,p_hem] = trl.previous.get('C1','C2','C3','Hemifield');
        isCueTrial = ~all([c1==p_c1,c2==p_c2,c3==p_c3,strcmp(hem,p_hem)]);
    end
    
    intv = Intervals()...
        .add_interval(precue_dur,trg_fix).conditional(isCueTrial)... % fixation
        .add_interval(cue_dur,trg_cue).conditional(isCueTrial)... % Cue
        .add_interval(prestim_dur,trg_fix)... % Fixation
        .add_interval(pretest_dur,trg_arr).flicker_on()... % Disc Array
        .add_interval(test_dur,trg_arr).add_random_probes(probe_dur,trl.no_of_events,trg_probe,min_isi).flicker_on()... % Testing
        .add_interval(posttest_dur,trg_arr).flicker_on()...
        .add_interval(.05,trg_fix).complete().create_frames(scr,'f175',17.5,'f21',21,'f19',19);% Disc Array
    
    disc_clr = ones(intv.no_of_frames, disc.no_of_items);    
    disc_clr(:,disc_ids.(hem)) = [intv.frames.f175;intv.frames.f21;intv.frames.f19]';
    if isCueTrial
        disc_clr(intv.initial_frames_per_event(intv.triggers=='C')+(0:intv.frames_per_event(intv.triggers=='C')),disc_ids.(hem)) = 1;
        disc_clr(intv.initial_frames_per_event(intv.triggers=='C')+(0:intv.frames_per_event(intv.triggers=='C')),cued_discs) = 4;
    end
    disc.color.input(disc_clr);
    
    for whFrm = 1:intv.no_of_frames
                
        fix.draw();
        switch intv.trigger
            
            case {'C','D'}
                
                disc.frame(whFrm).draw(3);
                
            case {'P'}
                                
                disc.frame(whFrm).draw(3);
                
                arc_loc = trl.(sprintf('L%d',trl.probes.current));
                arc.(hem).(trl.(sprintf('A%d',trl.probes.current))).select(arc_loc).draw();                
                
        end
        
        scr.flip();        
        kb.check().flush().quit_if_escaped();
        trg.write_if(kb.isKeyPressed,trl.no,trg_rxn,kb.time).write_if(intv.isEventOnset,trl.no,intv.trigger,scr.time);
        trl.probes.next(intv.isEventOffset && intv.trigger == trg_probe); 
        intv.end();
        kb.reset();
        
    end
    
    trg.print();
    trl.end();
    
end

sxn.get_last_trial(sub);
sxn.write_to_session_log(sub);