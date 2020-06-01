%dynamicprops used for adding property for objects and handles
%handle used for adding listener for objects
% if we dont used dynamicprops the class will be value type and we need to return calss object after modifying
classdef mac < dynamicprops
    %UNTITLED2 Summary of this class goes here
    %  %  Detailed explanation goes here
    
    properties
        
      
        pan; % save information about coordinators that is recived beacone from them
        
    end
    
    methods
        
        function scanProccess(macObj,msg)
            % The request includes the scan type, the channels to be scanned and the scan duration
            % (per channel). The possible scan types are described in Section 3.2.1
            
            switch msg.command
                case 1 % passive scan
                    
                case 2 % active scan
                    
            end
        end
        
        

        
        
    end
    
end

