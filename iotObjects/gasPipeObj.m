%object description:
 
classdef gasPipeObj<dynamicprops
    
    properties
        state=0; % is it in Leaking or not 0=no leaking; 1= Leaking;
        out=[]; %output of gas pipe
        handle
        ghandle=[];
    end
    
    methods
        
        function gspObj=gasPipeObj(para)  
            gspObj.state=para.state;   
            gspObj.handle = plot3( para.xv, para.yv,  para.zv,'Color',[ .2,.5,.6],'lineWidth',3 );hold on
            
            for outInd=1:length(para.outX)
                gspObj.out(outInd).xv= para.outX(outInd);
                gspObj.out(outInd).yv= para.outY(outInd);
                gspObj.out(outInd).zv= para.outZ(outInd);
                if gspObj.state(outInd)==1
                 gspObj.ghandle(outInd).handle=plot3(gspObj.out(outInd).xv,gspObj.out(outInd).yv,gspObj.out(outInd).zv,'or');
                else
                  gspObj.ghandle(outInd).handle=plot3(gspObj.out(outInd).xv,gspObj.out(outInd).yv,gspObj.out(outInd).zv,'og');
                end
            end
            
            
        end
    end
    

end