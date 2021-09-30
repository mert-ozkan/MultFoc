classdef Pattern < Shape
    
    properties
        
        no_of_copies
        operations
        
    end
    
    properties
        
        no_of_operations
        
    end
    
    methods
        
        function pat = Pattern(scr, varargin)
            % varargin inputs the center of the shape to be repeated
            % relative to the origin [needs improvement, flexible origins]
            
            pat = pat@Shape(scr,varargin{:});
            %pat.operations = reshape(varargin,2,[]);            
                                   
        end
        
        function no_of_op = get.no_of_operations(pat)
            
            no_of_op = size(pat.operations,1);
            
        end
        
        function pat = tile(pat,n_copy,varargin)
            
            pat.no_of_copies = n_copy;
            pat.operations = reshape(varargin,[],2);
            
            copies = Pattern.empty(0,pat.no_of_copies);
            
            for whCopy = 1:pat.no_of_copies
                
                patN = pat.copy_all();
                for whOp = 1:pat.no_of_operations
                    opN = pat.operations{whOp,1};
                    ipN = pat.operations{whOp,2};
                    patN = patN.(lower(opN))(ipN);
                end
                
                copies(whCopy) = patN;
            end
            
        end
        
    end
    
end