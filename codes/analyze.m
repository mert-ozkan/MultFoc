% function analyze_results()
% end
%%
clear all
f = FilePath('/Users/mertozkan/Dropbox (Dartmouth College)/DataCollection/MultFoc/analys');
t = Tablo(f.find('*timestamps*')).subset('trigger',{'P','R'});
ord = Tablo(f.find('*order*'));
dat = Tablo(f.find('*data*'));
%%
results = Tablo().build({'trial_no','probe_no','isProbe','isResponse','isTarget','isValid','isAccurate','response_time'},...
    {'uint64','uint64','logical','logical','logical','logical','logical','double'});
%%
% for whTrg = 1:t.nrow
%     
%     trgN = t.select(whTrg);
%     timeN = t.time(whTrg);
%     idN = t.id(whTrg);
%     trlN = ord.subset('Trial',t.trial_no(whTrg));
%     
%     switch trgN.trigger{:}
%         case 'P'
%             
%             time_range = t.time - timeN < .8 & t.time - timeN > .15;
%             rxnN = t.select(time_range).subset('trigger','R');
%             datN = dat.subset('event_id',rxnN.id);
%             
% %             isRxnN = isempty(rxnN);
%             if isempty(rxnN)
%                 
%             elseif rxnN.nrow == 1
%                 
%                 
%             else
%                 
%             end
%             
%             
%             
%         case 'R'
%             
%             time_range = timeN - t.time < 1 & timeN - t.time > .15;
%             tN = t.select(time_range);
%             trgN
%     end
%     
%     
% end

%%
for whTrl = 1:max(t.trial_no)
    
    trlN = ord.subset('Trial',whTrl);
    trgN = t.subset('trial_no',whTrl);
    datN = dat.subset('event_id',trgN.id);
    trgN = trgN.drop(ismember(trgN.trigger,'R') & ~ismember(trgN.id,dat.event_id));
    
    evN = Tracker(trlN,...
        {'T_1','T_2','T_3','T_4';...
        'L_1','L_2','L_3','L_4';...
        'S_1','S_2','S_3','S_4'},...
        {'isTarget','Location','Side'});
    for whTrg = 1:trgN.nrow
        
        switch trgN.trigger{whTrg}
            
            case 'P'
            case 'R'
                
        end
    end
    
end
