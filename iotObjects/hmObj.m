
% here zigbee and other application implemented
classdef hmObj<dynamicprops
    
    properties
        path
       handle
       pathLength
       pass
       valid=0;
    end
    
    methods
        
        function hObj=hmObj(para,lObj, bd,floor,seObj,mObj)
            hObj.pass=para.pass;
            view(0,90);
            [ hObj.path.x,  hObj.path.y] = getline(gca); %select the point of graph on pic
            hObj.path.x=hObj.path.x';
             hObj.path.y=hObj.path.y';
             %% this section used for secrity path aadding but is heavy and not necessary process
%              plot(hObj.path.x',hObj.path.y','b-'); hold on; plot( mObj(6).handleL.XData,mObj(6).handleL.YData,'b-') ;hold on

%             [x,y,l]=polyxpoly(hObj.path.x,  hObj.path.y,mObj(6).handleL.XData,mObj(6).handleL.YData,'unique') ;
%             l=l(:,1)';
%             count=0;
%             for lInd=1:length(l)
%                 indPos=l(lInd)+count;
%                 [in,on]=inpolygon(hObj.path.x(indPos),hObj.path.y(indPos),floor.x,floor.y);
%                 if in|| on
%                     
%                     hObj.path.x=  [hObj.path.x(1:indPos),seObj.pos.x,x(lInd),hObj.path.x(indPos+1:end)];
%                     hObj.path.y=  [hObj.path.y(1:indPos),seObj.pos.y,y(lInd),hObj.path.y(indPos+1:end)];
%                     count=count+1;
%                 else
%                      hObj.path.x=  [hObj.path.x(1:indPos),x(lInd),hObj.path.x(indPos+1:end)];
%                     hObj.path.y=  [hObj.path.y(1:indPos),y(lInd),hObj.path.y(indPos+1:end)];
%                     count=count+1;
%                 end
%             end
%             plot(hObj.path.x',hObj.path.y','r-'); hold on; plot( mObj(6).handleL.XData,mObj(6).handleL.YData,'r-') 

            [hObj.path.x,  hObj.path.y]=divider( hObj.path.x,  hObj.path.y,5);
            hObj.pathLength=length(hObj.path.x);
            hObj.path.z=hObj.path.x*0+0.5;
            
            for bdInd=1:length(lObj)
            in=inpolygon(hObj.path.x(1) ,  hObj.path.y(1) ,lObj(bdInd).bed.x,lObj(bdInd).bed.y);
            if in
               lObj(bdInd).on 
            end
            end

            hObj.handle=plot3( hObj.path.x(1) , hObj.path.y(2), hObj.path.z(1) ,'-o','markerSize',10);
            hObj.handle.MarkerFaceColor=hObj.handle.MarkerEdgeColor;
            hObj.handle.XData=hObj.path.x(1);
            hObj.handle.YData=hObj.path.y(1);
            hObj.handle.ZData=hObj.path.z(1);
            view(3);
        end
        
        
 
        
        
    end
    
end

