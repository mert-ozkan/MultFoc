classdef FilePath < dynamicprops
    
    properties
        
        path
        parent
        
    end
    
    properties (Dependent)
        
        working_directory
        contents
        
    end
    
    properties (Access = private)
        
        enter_spec = char(10)
        
    end
    
    methods
        
        function p = FilePath(parent,child)
            
            if nargin < 2
                
                p.path = parent;
                p.parent = parent;
                
            else
                
                p.parent = parent;
                p.path = cellfun(@(x) fullfile(p.parent,x),child);
                
            end
            
        end
        
        function pth = get.working_directory(p)
            
            pth = pwd;
            
        end
        
        function p = cd(p)
            
            cd(p.path);
            
        end
        
        function p = add2path(p)
            
            addpath(genpath(p.path));
            
        end
        
        function c = get.contents(p)
            
            c = split(ls(p.path));
            c = sort(c(1:end-1));
            c = cellfun(@(x) string(fullfile(p.path,x)),c);
            
        end
        
        function c = find(p,specs)                 
            
            c = split(ls(fullfile(p.path,specs)),p.enter_spec);
            c = sort(c(1:end-1));
                    
        end
    end
    
end