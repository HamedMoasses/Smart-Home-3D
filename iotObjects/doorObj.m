
classdef doorObj<dynamicprops
    
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
        
        function dObj=doorObj(para)  
            dObj.state=para.state;% on or off in default
            dObj.opcl=para.opcl;% on or off in default
            dObj.openCond=para.openCond;
            dObj.closeCond=para.closeCond;
            dObj.out=para.out;
            
            if isempty(dObj.handle)
            dObj.handle=surf(para.pos.x,para.pos.y,para.pos.z,'faceColor',[0.82,0.8,0.8] , 'edgeColor','k', 'lineWidth',2 );hold on;alpha(dObj.handle,0.8);
            end
           
           if dObj.state && dObj.opcl==1
               % opened mode
               dObj.handle.XData=dObj.openCond.x;
               dObj.handle.YData=dObj.openCond.y;
               dObj.opcl=1;
           elseif dObj.state && dObj.opcl==0
               dObj.handle.XData=dObj.closeCond.x;
                dObj.handle.YData=dObj.closeCond.y;
                dObj.opcl=0;
           end
        end
        
        
        
        function dObj=open(dObj)
            if dObj.state
                dObj.handle.XData=dObj.openCond.x;
                dObj.handle.YData=dObj.openCond.y;
                dObj.opcl=1;
            end
        end
        
        function dObj=close(dObj)
            if dObj.state
                dObj.handle.XData=dObj.closeCond.x;
                dObj.handle.YData=dObj.closeCond.y;
                dObj.opcl=0;
            end
        end
        
        
    
        
        
    end
    
end
 