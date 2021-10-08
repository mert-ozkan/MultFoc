function ord = create_trial_order1()
%%
dist_nept = [1,2,2,3,3,4,4,4,4,4,4,4,4,5];
validity = .8;
n_blk = 20;
n_trl_per_blk = 10;
ord = cell(n_trl_per_blk*n_blk,7);
% whTrl = 1;

for whBlk = 1:n_blk
    
    isComplete = false;
    while ~isComplete        
        [shapeN, hemN, cueN] = main_conditions();
        if whBlk >1
            isComplete = ~all(cellfun(@(x,y) all(strcmp(string(x),string(y))),ord(whTrl,2:4),{shapeN,hemN,cueN}));
        else
            isComplete = true;
        end
    end
    
    for whTrlInBlk = 1:n_trl_per_blk
        
        whTrl = (whBlk-1)*n_trl_per_blk + whTrlInBlk;
        neptN = dist_nept(randi(length(dist_nept)));
        isTargetN = zeros(1,5);
        tar = binornd(1,validity,1,neptN);
        isTargetN(1:neptN) = tar;
        ord(whTrl,:) = {whBlk,shapeN,hemN,cueN,sum(isTargetN),neptN,isTargetN};
        
    end
    
end
ord = cell2table(ord,'VariableNames',{'Block','Shape','Hemifield','C','no_of_targets','no_of_events','T'});

end

function slxn = pick_one(varargin)

n = length(varargin);
slxn = varargin{randi(n)};

end

function [shape, hem, cue] = main_conditions()

shape = pick_one('Single','Narrow','Split','Broad');
hem = pick_one('Left','Right');
switch shape
    case 'Single'
        cue = pick_one([1,0,0],[0,1,0],[0,0,1]);
    case 'Narrow'
        cue = pick_one([1,1,0],[0,1,1]);
    case 'Split'
        cue = [1,0,1];
    case 'Broad'
        cue = [1,1,1];
end

end