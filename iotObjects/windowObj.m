
% here zigbee and other application implemented
classdef windowObj<dynamicprops
    
    properties
        state=0;
        opcl=0; % opended or closed
        openCond
        closeCond
        out
        handle
        %energy Consum
        zigEnCon=0;
        wiEnCon=0;
    end
    
    methods
        
        function wObj=windowObj(para)  
            wObj.state=para.state;% on or off in default
            wObj.opcl=para.opcl;% on or off in default
            wObj.openCond=para.openCond;
            wObj.closeCond=para.closeCond;
            wObj.out=para.out;
            
            if isempty(wObj.handle)
                wObj.handle=surf(para.pos.x,para.pos.y,para.pos.z,'faceColor','g', 'edgeColor','k', 'lineWidth',1);alpha( wObj.handle,0.2)
            end
           
           if wObj.state && wObj.opcl==1
               % opened mode
               wObj.handle.XData=wObj.openCond.x;
               wObj.handle.YData=wObj.openCond.y;
               wObj.opcl=1;
           elseif wObj.state && wObj.opcl==0
               wObj.handle.XData=wObj.closeCond.x;
                wObj.handle.YData=wObj.closeCond.y;
                wObj.opcl=0;
           end
        end
        
        
        
        function wObj=open(wObj)
            if wObj.state
                wObj.handle.XData=wObj.openCond.x;
                wObj.handle.YData=wObj.openCond.y;
                wObj.opcl=1;
            end
        end
        
        function wObj=close(wObj)
            if wObj.state
                wObj.handle.XData=wObj.closeCond.x;
                wObj.handle.YData=wObj.closeCond.y;
                wObj.opcl=0;
            end
        end
        
        
    
        
        
    end
    
end