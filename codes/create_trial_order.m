function trl_ord = create_trial_order()

cond = sortrows(readtable('./conditions.csv'),'Shape','ascend');

nept = [repmat(2,1,4), repmat(3,1,12), repmat(4,1,28), repmat(5,1,4)];
no_of_trl_pc = length(nept); % no of trials per cond

cond_lst = join([cond.Shape, cond.Hemifield],'_');

cond_rep = arrayfun(@(x)  no_of_trl_pc/sum(strcmp(cond_lst,x)),cond_lst);

trl_ord = arrayfun(@(x) repmat(cond(x,:),cond_rep(x),1),1:height(cond),'UniformOutput',false);
trl_ord = vertcat(trl_ord{:});

no_of_events = arrayfun(@(x) vecshuffle(nept)',unique(cond_lst),'UniformOutput',false);
trl_ord.no_of_events = vertcat(no_of_events{:});

trl_ord.block = repelem(vecshuffle(1:(height(trl_ord)/12)),1,12)';
trl_ord = sortrows(trl_ord,'block');

n_trl = height(trl_ord);
ev = zeros(n_trl,5);
loc = zeros(n_trl,5);
arc = repmat('',n_trl,5);

for whTrl = 1:n_trl
    n_ev = trl_ord.no_of_events(whTrl);
    cueN = table2array(trl_ord(whTrl,1:3));
    
    switch trl_ord.Shape{whTrl}; case 'Broad'; p_tar = 1; otherwise; p_tar = .8; end
    evN = binornd(1,p_tar,1,n_ev);
    % Broad
    loc(whTrl,1:n_ev) = arrayfun(@(x) pick_at_random(find(cueN==x)), evN);    
    ev(whTrl,1:n_ev) = evN;
    arc(whTrl,1:n_ev) = arrayfun(@(x) pick_at_random(['L','R']), evN);
end
trl_ord.no_of_targets = sum(ev,2); 
trl_ord = [trl_ord, array2table([ev,loc],'VariableNames',{'E1','E2','E3','E4','E5','L1','L2','L3','L4','L5'}),...
    array2table(arc,'VariableNames',{'A1','A2','A3','A4','A5'})];

end

function arr = vecshuffle(arr)

n_col = size(arr,2);
arr = arr(randperm(n_col));

end

function y = pick_at_random(arr)

len = length(arr);

y = arr(binornd(len-1,1/len)+1);

end