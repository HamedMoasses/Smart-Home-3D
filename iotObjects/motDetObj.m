
% here zigbee and other application implemented
classdef motDetObj<dynamicprops
    
    properties
       state=1; 
       lineSen;
       handle %position handle
       handleL% line handle
       
       %energy Consum
       zigEnCon=0;
       wiEnCon=0;
    end
    
    methods
        
        function mObj=motDetObj(para)  
           mObj.state=para.state;% on or off in default
           mObj.lineSen=para.lineSen;% on or off in default
           
           if mObj.state
           mObj.handle=plot3(para.pos(1),para.pos(2),para.pos(3),'co','markerSize',5, 'markerfacecolor','c');
           mObj.handleL=plot(para.lineSen(1,:),para.lineSen(2,:),'b--');

           else
           mObj.handle=plot3(para.pos(1),para.pos(2),para.pos(3),'wo','markerSize',1, 'markerfacecolor','w');
           mObj.handleL=plot(para.lineSen(1,:),para.lineSen(2,:),'w--');
           end
        end
        
        
   
        
        
    end
    
end

