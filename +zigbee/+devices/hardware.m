classdef hardware<dynamicprops
 properties
     registers 
 end
 
 
 methods
     
     function  hardObj=hardware(obj,command)% uses for communicate with hardware up and down this function send command down  and get response to hardware funnction for doing something and get interrupts  from interUptHandller
        %here we make a circuit of hardware
         
     end
     
     
     %Peripheral Hardware Drivers or on chip drivers to access hardware registers.
     function  PeripheralHD(obj,command)% uses for communicate with hardware up and down this function send command down  and get response to hardware funnction for doing something and get interrupts  from interUptHandller
         
         
     end
     
     
     function  interrUptHandller(obj,command)% using for handle of interuption and passing to  PeripheralHD or to mac layer
         if x
            %call  PeripheralHD
         else
             %call  mac
         end
         
         
     end
     
     function  interrUpt(obj,command)% using for make interuption
         
     end
     
     %% functions of hardware commanded by app by using drivers(PeripheralHD)
     
     
     
     
 end
    
    
    
    
end