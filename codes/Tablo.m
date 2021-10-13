classdef Tablo < dynamicprops & matlab.mixin.Copyable
    
    properties
        
        table
        
    end
    
    properties (Dependent)
        
        nrow
        ncol
        variable_names
        
    end
    
    methods
        
        function tbl = Tablo(path_or_tbl)
            
            if nargin == 0; tbl = Tablo.empty(); return; end
            switch class(path_or_tbl)
                
                case 'table'
                    
                    tbl.table = path_or_tbl;
                    
                case {'string','char'}
                    
                    tbl.table = readtable(path_or_tbl);
                    
                case 'cell'
                    
                    tbl = Tablo(path_or_tbl{:});
                    return
                    
            end
            
            for whVar = 1:tbl.ncol
                varN = tbl.variable_names{whVar};
                p = tbl.addprop(varN);
                p.NonCopyable = false;
                tbl.(varN) = tbl.table.(varN);
            end
            
        end
        
        function n = get.nrow(tbl)
            
            n = height(tbl.table);
            
        end
        
        function n = get.ncol(tbl)
            
            n = width(tbl.table);
            
        end
        
        function var = get.variable_names(tbl)
            
            var = tbl.table.Properties.VariableNames;
            
        end
        
        function tblN = subset(tbl,col,val)
            
            tblN = copy(tbl);
            idx = ismember(tbl.table.(col),val);
            tblN.table = tblN.table(idx,:);
            for varN = tbl.variable_names
                tblN.(varN{:}) = tblN.(varN{:})(idx);
                
            end
            
        end
        
        function tbl = shuffle(tbl)
            
            tbl.table = tbl.table(randperm(tbl.nrow),:);
            
        end
        
        function tblN = select(tbl,i)
            
            tblN = copy(tbl);
            tblN.table = tblN.table(i,:);
            for varN = tbl.variable_names
                tblN.(varN{:}) = tblN.(varN{:})(i);
                
            end
            
        end
        
        function tblN = exclude(tbl,i)
            
            if islogical(i)
                i = ~i;
            else
                lst = 1:tbl.nrow;
                lst(i) = [];
                i = lst;
            end
            tblN = tbl.select(i);
            
        end
        
        function tbl = keep(tbl,i)
            
            tbl = tbl.select(i);
            
        end
        
        function tbl = drop(tbl,i)
            
            tbl = tbl.exclude(i);
            
        end
        
        function val = get(tbl,vars,i)
            
            if nargin < 3; i = 1:tbl.nrow; end
            for whVar = 1:length(vars)
                varN = vars{whVar};
                val{whVar} = tbl.(varN)(i);
            end
                
            types = cellfun(@(x) class(x),val,'UniformOutput',false);
            if length(unique(types)) == 1 && strcmp(types{1},'double')
                
                val = cellfun(@(x) x, val);
                
            end
            
        end
        
        function tbl = build(tbl,variable_names,variable_types)
            
            tbl = Tablo(table('Size',[0,length(variable_names)],'VariableTypes',variable_types,'VariableNames',variable_names));
            
%             tbl.table = cell2table(cell(0,length(variable_names)),'VariableNames',variable_names);
            
        end
        
        function print(tbl,path)
            
            writetable(tbl.table,path);
            
        end
        
        function isE = isempty(tbl)
            
            isE = isempty(tbl.table);
            
        end
        
        
    end
end