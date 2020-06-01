
 
classdef gasContObj<dynamicprops
    
    properties
        state=1;
        handle
          %energy Consum
        zigEnCon=0;
        wiEnCon=0;
    end
    
    methods
        
        function gscObj=gasContObj(para)
            gscObj.state=para.state;% on or off in default
            
            poly=makepoly([10,0.25],pi/10,para.pos);
            if gscObj.state
                gscObj.handle=fill3(poly.x+poly.pos.x,poly.z+poly.pos.y,poly.y+poly.pos.z,'g');
                
            else
                gscObj.handle=fill3(poly.x+poly.pos.x,poly.z+poly.pos.y,poly.y+poly.pos.z,'r');
            end
        end
        
        
        
        function on(gscObj)
            gscObj.handle.FaceColor='g';
            gscObj.state=1;
            
        end
        
        function off(gscObj)
            gscObj.handle.FaceColor='r';
            gscObj.state=0;
        end
        
        
        
    end
    
end

