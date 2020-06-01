
% here zigbee and other application implemented
classdef fireDetObj<dynamicprops
    
    properties
        state=0;
        alarm=0;
        temper=27;
        handle
        
        %energy Consum
        zigEnCon=0;
        wiEnCon=0;
    end
    
    methods
        
        function fiObj=fireDetObj(para)  
              fiObj.state=para.state;% on or off in default

           
              poly=makepoly([6,0.4],pi/6,para.pos);
              if fiObj.state
                  fiObj.handle=fill3(poly.xv,poly.yv,poly.zv,'g');
                  
              else
                  fiObj.handle= fill3(poly.xv,poly.yv,poly.zv,'w');
                  
              end
            
        end
    end
    

end