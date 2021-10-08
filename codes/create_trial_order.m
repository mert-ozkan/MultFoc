function ord = create_trial_order()

cue_blocks = readtable('./conditions.csv');
n_blk = height(cue_blocks);
n_trl_per_blk = 4;
n_trl = n_blk*n_trl_per_blk;
dist_nept = [1,2,2,3,3,4,4,4,4,4,4,4,4,5];
n_max_ev = max(dist_nept);
validity = .8;
cue_blocks.condition = join([cue_blocks.Hemifield,cue_blocks.Shape,string(cue_blocks.C2),string(cue_blocks.C3)]);

while any(strcmp(cue_blocks.condition(1:end-1),cue_blocks.condition(2:end)))
    
    cue_blocks = cue_blocks(randperm(n_blk),:);     
    
end

ord = cell(n_trl,10);
for whBlk = 1:n_blk
    
    for whTrlInBlk = 1:n_trl_per_blk
        
        shapeN = cue_blocks.Shape{whBlk};
        hemN = cue_blocks.Hemifield{whBlk};
        cueN = cue_blocks{whBlk,3:5};
        
        whTrl = (whBlk-1)*n_trl_per_blk + whTrlInBlk;
        neptN = dist_nept(randi(length(dist_nept)));
        isTargetN = zeros(1,n_max_ev);
        if strcmp(shapeN,'Broad')
            
            tar = ones(1,neptN);
            
        else
            
            tar = binornd(1,validity,1,neptN);
            
        end
        isTargetN(1:neptN) = tar;
        sideN = repmat(" ",1,n_max_ev);
        sideN(1:neptN) = arrayfun(@(x) pick_one("L","R"),1:neptN);
        
        locN = zeros(1,n_max_ev);
        locN(1:neptN) = arrayfun(@(x) pick_one(find(cueN==x)), isTargetN(1:neptN));
        
        
        ord(whTrl,:) = {whTrl,whBlk,shapeN,hemN,cueN,sum(isTargetN),neptN,isTargetN,sideN,locN};
        
    end
    
end

ord = cell2table(ord,'VariableNames',{'Trial','Block','Shape','Hemifield','C','no_of_targets','no_of_events','T','S','L'});
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