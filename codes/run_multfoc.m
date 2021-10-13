%% Multifocal Attention Exp 1

clear all; close all; sca;

%% Parameters
parent_path = '/Users/mertozkan/Dropbox (Dartmouth College)/DataCollection/MultFoc';
viewing_distance = 38;
isSkipSyncTests = 1;

ecc = [7,9.6,13]; % eccentricity in dva
disc_radii = arrayfun(@(x) 1.3*(31*x+100)/(31*ecc(2)+100),ecc);
% disc_radii = [1,1.5,2.05]; % disc radius per eccentricity in dva
fixation_coordinates = [0,-20]; % with respect to screen center (if
% cartesian coordinates, negative values signifies up in y-axis and left in
% x-axis)

no_of_discs_per_ecc = 10;
polar_angle_first_disc = 180/no_of_discs_per_ecc/2; % in degrees. Polar coordinates of the
% center of the first disc. Angles are calculated with respect to the
% origin (fixation_coordinates in this script).
% stimulus_eccentricities are the length of the polar vector. Angle and
% length constitutes polar coordinates. 0 degrees points to the east-end,
% an x-degree clockwise rotation is positive (+x; -x if counter-clockwise).
disc_color = [255;255;255;255]; % rows correspond to [R; G; B; Alpha]
arc_pw = .1;
scale_factor = .5;
stim_clr = RGBA().set_lookup_table(255,0,127,[255,0,0]);

test_discs = struct('Left',17:3:29,'Right',14:-3:2);

arc_color = 127;

% Event triggers: trigger per stimulus display and keypress (latter not ready)
trg_brk = 'B';
trg_fix = 'F'; %fixation
trg_cue = 'C'; %cue
trg_arr = 'D'; %array of discs
trg_test = 'T';
trg_probe = 'P';
trg_rxn = 'R'; %response screen

cue_dur = 1.5; % gon change in the block desgn
prestim_dur = 1;
pretest_dur = .5;
test_dur = 5;
probe_dur = .15;
min_isi = .8;
posttest_dur = .3;
iti = .5;

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
    'response_key','response_time','latest_probe_onset','latest_probe_location','latest_probe_side','event_id'});
trg = Triggers(sub,'timestamps');




scr = ExperimentScreen(viewing_distance,isSkipSyncTests).open_window().set_origin(fixation_coordinates);
instruction_page = TextPage(dr,scr,'instructions');
kb = ExperimentKeyboard().set_reaction_keys(reaction_keys,reaction_key_codes);
fix = BullsEyeCrossFixation(scr);



disc_prop = combvec([1,2,3],polar_angle_first_disc+(0:(no_of_discs_per_ecc-1))*180/no_of_discs_per_ecc);
disc_prop(3,:) = disc_radii(disc_prop(1,:));
disc_prop(1,:) = ecc(disc_prop(1,:));
disc = CircleObject(SpatialUnit(scr,disc_prop(3,:)))...
    .set_color(stim_clr.input(2*ones(1,size(disc_prop,2))))...
    .place(Angle(disc_prop(2,:)),SpatialUnit(scr,disc_prop(1,:)));

start_angles_right = Angle(90)+disc.center.polar.angle.select(test_discs.Right) + Angle(45);
start_angles_left = Angle(90)+disc.center.polar.angle.select(test_discs.Left) + Angle(45);

% this ugly; gon change
arc_left = disc.select(test_discs.Right).scale(scale_factor).circ2arc(start_angles_right,Angle(90),SpatialUnit(scr,arc_pw)).set_color(arc_color);
arc_right = copy(arc_left).rotate(Angle(180));
arc.Right = Shape(scr,arc_left.center).add_object(arc_right,'R').add_object(arc_left,'L');
arc_left = disc.select(test_discs.Left).scale(scale_factor).circ2arc(start_angles_left,Angle(90),SpatialUnit(scr,arc_pw)).set_color(arc_color);
arc_right = copy(arc_left).rotate(Angle(180));
arc.Left = Shape(scr,arc_left.center).add_object(arc_right,'R').add_object(arc_left,'L');

surround = disc.scale(1.1).circ2arc(Angle(0),Angle(360),SpatialUnit(scr,.1)).set_color([255;0;0;100]);

trl.add_counter('break',n_blk_per_trl);
isCueTrial = 1;
isBreakTrial = 1;
while trl.no <= trl.no_of_trials && ~kb.isEscaped
    
     
    trl = trl.add_tracker('probes',...
        {'T_1','T_2','T_3','T_4';...
        'L_1','L_2','L_3','L_4';...
        'S_1','S_2','S_3','S_4'},{'isTarget','Location','Side'});
    
    cued_discs = trl.get('C_1','C_2','C_3');
    
    
    
    intv = Intervals()...  
        .add_interval(inf,trg_brk).conditional(isBreakTrial)...
        .add_interval(inf,trg_cue).conditional(isCueTrial)... % Cue
        .add_interval(prestim_dur,trg_fix).conditional(isCueTrial)... % Fixation Array
        .add_interval(prestim_dur,trg_arr)... % Disc Array
        .add_interval(pretest_dur,trg_test).flicker_on()... % Disc Array
        .add_interval(test_dur,trg_test).add_random_probes(probe_dur,trl.no_of_events,trg_probe,min_isi).flicker_on()... % Testing
        .add_interval(posttest_dur,trg_test).flicker_on()...
        .add_interval(iti,trg_fix).complete().create_frames(scr,'f30',30,'f20',20,'f15',15,'f17',120/7,'f24',24);% Disc Array
    
    
    
    disc_clr = ones(intv.no_of_frames, disc.no_of_items);    
    disc_clr(:,test_discs.(trl.Hemifield)) = [intv.frames.f30;intv.frames.f20;intv.frames.f15;intv.frames.f17;intv.frames.f24]';
    disc.color.input(disc_clr);
    disc.change_color(1,[],intv.get_frame_no(trg_arr));
    if isCueTrial;  disc.change_color(1,[],intv.get_frame_no(trg_cue)); end
    
    for whFrm = 1:intv.no_of_frames
              
        switch intv.trigger
            
            case 'F'
                
                fix.draw();
                
            case {'D','T'}
                
                fix.draw();
                surround.select(cued_discs).draw();
                disc.frame(whFrm).draw(3);
                
            case 'C'
                
                fix.draw();
                disc.frame(whFrm).change_color(4,cued_discs).draw(3);
                surround.select(cued_discs).draw();
                scr.flip();
                trg.write(trl.no,intv.trigger,scr.time);
                kb.wait_for_next_key(intv.duration);
                trg.write(trl.no,trg_rxn,kb.press_time);
                
            case 'P'
                
                fix.draw();                       
                surround.select(cued_discs).draw();
                disc.frame(whFrm).draw(3);                
                arc.(trl.Hemifield).(trl.probes.Side()).select(test_discs.(trl.Hemifield)==trl.probes.Location()).draw();
                
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
            kb.key,kb.press_time,trg.last_time('P'),trl.probes.Location(),trl.probes.Side(),trg.last_trigger_id);
        
        trl.probes.next(intv.isIntervalOffset && intv.trigger == trg_probe); 
        intv.end();
        kb.reset();
        
    end
    
    trg.print();
    dat.print();    
    trl.end(); 
    
    % Carry these in the beginning of the loop somehow
    isCueTrial = any(table2array(trl.isConditionSwitch(:,"Block"))); 
    trl.break.next(isCueTrial);
    isBreakTrial = trl.break.isComplete;
    if trl.break.isComplete; trl.break.reset(); end
    
end

sxn.get_last_trial(sub);
sxn.write_to_session_log(sub);