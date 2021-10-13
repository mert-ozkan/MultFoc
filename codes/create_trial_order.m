function ord = create_trial_order()

% cue_blocks = readtable('./conditions.csv');
cue_blocks = Tablo('./conditions.csv');
n_blk = cue_blocks.nrow;
n_trl_per_blk = 4;
n_trl = n_blk*n_trl_per_blk;
dist_nept = [1,2,2,3,3,3,3,4,4,4,4,4,4,4];
max_n_ev = max(dist_nept);
validity = .8;

side_blocks = {cue_blocks.subset('Hemifield','Left').shuffle(), cue_blocks.subset('Hemifield','Right').shuffle()};
side_blocks = side_blocks(randperm(2));
mixed_blocks = cue_blocks.table;
mixed_blocks(1:2:cue_blocks.nrow,:) = side_blocks{1}.table;
mixed_blocks(2:2:cue_blocks.nrow,:) = side_blocks{2}.table;
mixed_blocks = Tablo(mixed_blocks);

cue_ids = struct('Left',20:3:26,'Right',11:-3:5);
test_ids = struct('Left',17:3:29,'Right',14:-3:2);

ord = cell(n_trl,10);
for whBlk = 1:n_blk
    
    for whTrlInBlk = 1:n_trl_per_blk
        
        shapeN = mixed_blocks.Shape{whBlk};
        hemN = mixed_blocks.Hemifield{whBlk};
        cueN = mixed_blocks.get({'C1','C2','C3'},whBlk)==1;
        
        cue_locN = nan(1,3);
        cue_locN(1:sum(cueN)) = cue_ids.(hemN)(cueN);
        
        whTrl = (whBlk-1)*n_trl_per_blk + whTrlInBlk;
        neptN = dist_nept(randi(length(dist_nept)));
        isTargetN = zeros(1,max_n_ev);
        isTargetN(1:neptN) = binornd(1,validity,1,neptN);
        sideN = repmat(" ",1,max_n_ev);
        sideN(1:neptN) = arrayfun(@(x) pick_one("L","R"),1:neptN);
        locN = zeros(1,max_n_ev);
        for whEv = 1:neptN
            
            if isTargetN(whEv)
                probe_locN = cue_locN(~isnan(cue_locN));
                
            else
                
                probe_locN = test_ids.(hemN)(~ismember(test_ids.(hemN),cue_locN(~isnan(cue_locN))));
                
            end
            
            locN(whEv) = pick_one(probe_locN);
            
        end
        
        ord(whTrl,:) = {whTrl,whBlk,shapeN,hemN,cue_locN,sum(isTargetN),neptN,isTargetN,sideN,locN};
    end
    
end
ord = Tablo(cell2table(ord,'VariableNames',{'Trial','Block','Shape','Hemifield','C','no_of_targets','no_of_events','T','S','L'}));    
end
function slxn = pick_one(varargin)

n = length(varargin);

if n == 1
    n = length(varargin{1});
    slxn = varargin{1}(randi(n));
else
    slxn = varargin{randi(n)};
end


end