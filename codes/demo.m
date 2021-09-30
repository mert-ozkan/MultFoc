%%
a = {[1,2];[1,3]};
for [i,x] = enumerate(a)
    disp(i,x)
end

function [i,arr] = enumerate(arr)

i = 1:length(arr);

end

