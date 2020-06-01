
% here zigbee and other application implemented
classdef APP<dynamicprops
    
    properties
       command;%1= passive scan ,2= active scan, 3=associate to a pan, 4-Disassociate to a pan, 
        
    end
    
    methods
        
        function stackApi802_15_4(obj,command) % this function used for  communicate with  stack layer 802.15.4 include mac and link layer and etc
       iot.DLL.mac     
        end
        
        
        %% Integrated Peripherals API that call  on chip drivers to access hardware registers. here the poard hardware combined to
        function JN516x(obj,command) % this function used for related  JN516x microcontroller: we used this one only
            
        end
        
        function JN517x(obj,command) % this function used for related  JN517x microcontroller
            
        end
        
        
    end
    
end

