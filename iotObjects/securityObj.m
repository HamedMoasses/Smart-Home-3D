
% here zigbee and other application implemented
classdef securityObj<dynamicprops
    
    properties
        state=0;%0= inactive ,1=active
        %         secCh=0;
        handle
        homeSysControl
        pos
        userPass
         %energy Consum
        zigEnCon=0;
        wiEnCon=0;
    end
    
    methods
        
        function secbj=securityObj(para)  
            secbj.state=para.state;% on or off in default
            secbj.pos=para.pos;
            poly=makepoly([4,0.25],pi/4,para.pos);
            
            if secbj.state
                secbj.handle=fill3(poly.z+poly.pos.x,poly.y+poly.pos.y,poly.x+poly.pos.z,'g');
                secbj.state=1;
            else
                secbj.handle=fill3(poly.z+poly.pos.x,poly.y+poly.pos.y,poly.x+poly.pos.z,'r');
                secbj.state=0;
            end

        end
        
        
        
        function on(secbj)
            secbj.handle.FaceColor='g';
            secbj.state=1;
        end
        
        function off(secbj)
            secbj.handle.FaceColor='r';
            secbj.state=0;
        end
        
        function secCh=checkPass(secbj,pass)
         if ismember(   pass ,secbj.userPass )
         secCh=1;
         else
          secCh=0;   
         end
        end
        
        
    end
    
end

