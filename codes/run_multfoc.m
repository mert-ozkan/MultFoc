%% Multifocal Attention Exp 1

clear all; close all; sca;

%% Parameters
parent_path = '/Users/mertozkan/Dropbox (Dartmouth College)/DataCollection/MultFoc';
viewing_distance = 57;
isSkipSyncTests = 1;

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

arc_color = 127;

% Event triggers: trigger per stimulus display and keypress (latter not ready)
trg_brk = 'B';
trg_fix = 'F'; %fixation
trg_cue = 'C'; %cue
trg_arr = 'D'; %array of discs
trg_probe = 'P';
trg_rxn = 'R'; %response screen

precue_dur = 1;
cue_dur = 1.5; % gon change in the block desgn
prestim_dur = .5;
pretest_dur = 1;
test_dur = 6;
probe_dur = .15;
min_isi = 1;
posttest_dur = .8;

reaction_keys = {'RightArrow','LeftArrow'};
reaction_key_codes = 'RL';

n_blk_per_trl = 3;

%% Experiment
dr = Directories(parent_path);

sxn = Session('try');
sub = Participant(dr,sxn.isDebug,sxn.isNew);
sxn = sxn.get_initial_trial(sub);
trl = Trial(sub,sxn);
dat = DataFile(sub,'data',{'trial_no','cue1','cue2','cue3','shape','hemifield',...
    'no_of_targets','no_of_events',...
    'response_key','response_time','latest_probe_onset','latest_probe_location','latest_probe_side'});
trg = Triggers(sub,'timestamps');




scr = ExperimentScreen(viewing_distance,isSkipSyncTests).open_window().set_origin(fixation_coordinates);
instruction_page = TextPage(dr,scr,'instructions');
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

disc_ids = struct('Right',[5,8,11],'Left',[14,17,20]);

trl.add_counter('break',n_blk_per_trl);
isCueTrial = 1;
isBreakTrial = 1;
while trl.no <= trl.no_of_trials && ~kb.isEscaped
    
     
    trl = trl.add_tracker('probes',...
        {'T_1','T_2','T_3','T_4','T_5';...
        'L_1','L_2','L_3','L_4','L_5';...
        'S_1','S_2','S_3','S_4','S_5'},{'isTarget','Location','Side'});
    
    cued_discs = disc_ids.(trl.Hemifield)([trl.C_1,trl.C_2,trl.C_3]==1);
    
    
    intv = Intervals()...
        .add_interval(inf,trg_brk).conditional(isBreakTrial)...
...         .add_interval(precue_dur,trg_fix).conditional(isCueTrial)... % fixation
        .add_interval(inf,trg_cue).conditional(isCueTrial)... % Cue
        .add_interval(prestim_dur,trg_fix)... % Fixation
        .add_interval(pretest_dur,trg_arr).flicker_on()... % Disc Array
        .add_interval(test_dur,trg_arr).add_random_probes(probe_dur,trl.no_of_events,trg_probe,min_isi).flicker_on()... % Testing
        .add_interval(posttest_dur,trg_arr).flicker_on()...
        .add_interval(.05,trg_fix).complete().create_frames(scr,'f175',17.5,'f21',21,'f19',19);% Disc Array
    
    
    
    disc_clr = ones(intv.no_of_frames, disc.no_of_items);    
    disc_clr(:,disc_ids.(trl.Hemifield)) = [intv.frames.f175;intv.frames.f21;intv.frames.f19]';
    if isCueTrial
        
        disc_clr(intv.initial_frames_per_event(intv.triggers=='C')+(0:intv.frames_per_event(intv.triggers=='C')),disc_ids.(trl.Hemifield)) = 1;
        disc_clr(intv.initial_frames_per_event(intv.triggers=='C')+(0:intv.frames_per_event(intv.triggers=='C')),cued_discs) = 4;
        
    end
    disc.color.input(disc_clr);
    
    for whFrm = 1:intv.no_of_frames
              
        switch intv.trigger
            
            case 'F'
                
                fix.draw();
                
            case 'D'
                
                fix.draw();
                disc.frame(whFrm).draw(3);
                
            case 'C'
                
                fix.draw();
                disc.frame(whFrm).draw(3);
                scr.flip();
                trg.write(trl.no,intv.trigger,scr.time);
                kb.wait_for_next_key(intv.duration);
                trg.write(trl.no,trg_rxn,kb.press_time);
                
            case 'P'
                
                fix.draw();                                
                disc.frame(whFrm).draw(3);                
                arc.(trl.Hemifield).(trl.probes.Side()).select(trl.probes.Location()).draw();
                
            case 'B'
                
                instruction_page.draw();                
                scr.flip();
                trg.write(trl.no,intv.trigger,scr.time);
                kb.wait_for_next_key(intv.duration);
                trg.write(trl.no,trg_rxn,kb.press_time);
                
        end
        
        scr.flip();        
        kb.check().flush().quit_if_escaped();
        trg.write_if(kb.isKeyPressed,trl.no,trg_rxn,kb.press_time).write_if(intv.isIntervalOnset,trl.no,intv.trigger,scr.time);
        dat.write_if(kb.isKeyPressed,...
            trl.no,trl.C_1,trl.C_2,trl.C_3,trl.Shape,trl.Hemifield,trl.no_of_targets,trl.no_of_events,...
            kb.key,kb.press_time,trg.last_time('P'),trl.probes.Location(),trl.probes.Side());
        
        trl.probes.next(intv.isIntervalOffset && intv.trigger == trg_probe); 
        intv.end();
        kb.reset();
        
    end
    
    trg.print();
    dat.print();    
    trl.end(); 
    
    % Carry these in the beginning of the loop somehow
    isCueTrial = any(table2array(trl.isConditionSwitch(:,["C_1","C_2","C_3","Hemifield"]))); 
    trl.break.next(isCueTrial);
    isBreakTrial = trl.break.isComplete;
    if trl.break.isComplete; trl.break.reset(); end
    
end

sxn.get_last_trial(sub);
sxn.write_to_session_log(sub);