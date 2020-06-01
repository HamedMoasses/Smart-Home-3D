
% here zigbee and other application implemented
classdef gasDetObj<dynamicprops
    
    properties
        state=0;
        alarm=0;
        hG=[];
        handle
        %energy Consum
        zigEnCon=0;
        wiEnCon=0;
    end
    
    methods
        
        function gsObj=gasDetObj(para)
            gsObj.state=para.state;% on or off in default
            
            poly=makepoly([4,0.4],pi/4,para.pos);
            if gsObj.state
                gsObj.handle=fill3(poly.xv,poly.yv,poly.zv,'g');
                
            else
                gsObj.handle= fill3(poly.xv,poly.yv,poly.zv,'w');
                
            end
            
            
            
        end
        
        
        
        
        
    end
    
end

