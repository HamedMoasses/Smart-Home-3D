
% here zigbee and other application implemented
classdef lightObj<dynamicprops
    
    properties
        state=0;%board is on or off
        onOff=0; % on or off
        
        handle
        bed
        temper=27;
         %energy Consum
        zigEnCon=0;
        wiEnCon=0;
    end
    
    methods
        
        function lObj=lightObj(para)  
            lObj.state=para.state;% on or off in default
            lObj.bed=para.bed;% on or off in default
            
            if lObj.state && lObj.onOff
                lObj.handle=plot3(para.pos(1),para.pos(2),para.pos(3),'y*','markerSize',10);
                lObj.state=1;
                lObj.onOff=1;
                
            else
                lObj.handle=plot3(para.pos(1),para.pos(2),para.pos(3),'w*','markerSize',1);
                lObj.state=0;
                lObj.onOff=0;
                
            end

        end
        
        
        function on(lObj)
            lObj.handle.MarkerEdgeColor='y';
            lObj.handle.MarkerSize=10;
            lObj.state=1;
            lObj.onOff=1;
            
        end
        
        function off(lObj)
            lObj.handle.MarkerEdgeColor='w';
             lObj.handle.MarkerSize=1;
            lObj.state=1;
            lObj.onOff=0;
        end
        
   
        
        
    end
    
end

