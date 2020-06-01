classdef lineObj < dynamicprops
    
    
    properties
        name
        conPorts %
        conObjects%
        handles %
        listenerObj
        rev=zeros(1,10)

    end
    
    %     events
    %         recived
    %         sent
    %     end
    %
    methods
      
        function lnObj=lineObj(netObj1,netObj2,lineType)
            try
                if netObj2.typeDevice ==1
                    % for making error
                end
                lnObj.name=[netObj1.name 'l_l' netObj2.name];
                
                [x1,y1] = polyxpoly([netObj1.pos.X,netObj2.pos.X],[netObj1.pos.Y,netObj2.pos.Y],netObj1.posV.X,netObj1.posV.Y);
                x1=x1(1);y1=y1(1); % some time poly x repeat the point worningly!
                [x2,y2] = polyxpoly([netObj1.pos.X,netObj2.pos.X],[netObj1.pos.Y,netObj2.pos.Y],netObj2.posV.X,netObj2.posV.Y);
                x2=x2(1);y2=y2(1); % some time poly x repeat the point worningly!
                
                obj1.x=x1;obj1.y=y1;
                obj2.x=x2;obj2.y=y2;
                
                if isempty(lineType)
                    switch netObj1.typeDevice==netObj2.typeDevice
                        case 0
                            cable='-k';
                        case 1
                            cable='--k';
                    end

                handles=plot( [x1,x2],[y1,y2],cable, [x1,x2],[y1,y2],'go','markerSize',1,'markerFacecolor','g','lineWidth' , 2,'tag',lnObj.name);

                else
                handles=makeLine(obj1,obj2,lineType);
                set(handles ,'tag',lnObj.name);
                
                end
                lnObj.handles=handles;
                
            catch
                
                listener1= addlistener(netObj1,'moving',@netObj2.onMoving);
                netObj2.listenerObj{end+1}= listener1;
                lnObj= netObj2;
                
            end
            
            
        end
        
        function onMoving(lineDest,swSource,eventData)
            objects={lineDest.conObjects{:}};
            
            obj1.pos=objects{1}.pos;
            obj2.pos=objects{2}.pos;
            obj1.posV=objects{1}.posV;
            obj2.posV=objects{2}.posV;

            try
            [x1,y1] = polyxpoly([obj1.pos.X,obj2.pos.X],[obj1.pos.Y,obj2.pos.Y],obj1.posV.X,obj1.posV.Y);
            x1=x1(1);y1=y1(1); % some time poly x repeat the point worningly!
            [x2,y2] = polyxpoly([obj1.pos.X,obj2.pos.X],[obj1.pos.Y,obj2.pos.Y],obj2.posV.X,obj2.posV.Y);
            x2=x2(1);y2=y2(1); % some time poly x repeat the point worningly!
            lineDest.handles(1).XData= [x1,x2];
            lineDest.handles(1).YData= [y1,y2];
            
            lineDest.handles(2).XData= [x1,x2];
            lineDest.handles(2).YData= [y1,y2];
            catch
                lineDest.handles(1).XData= [obj1.pos.X,obj2.pos.X];
                lineDest.handles(1).YData= [obj1.pos.Y,obj2.pos.Y];
                lineDest.handles(2).XData= [obj1.pos.X,obj2.pos.X];
                lineDest.handles(2).YData= [obj1.pos.Y,obj2.pos.Y];
            end
            lineDest.handles(3).Position= [mean([mean(lineDest.handles(1).XData    ),lineDest.handles(1).XData(1)]),mean([mean(lineDest.handles(1).YData    ),lineDest.handles(1).YData(1)])];
            lineDest.handles(4).Position= [mean([mean(lineDest.handles(1).XData    ),lineDest.handles(1).XData(2)]),mean([mean(lineDest.handles(1).YData    ),lineDest.handles(1).YData(2)])];
            
            
            
    

            
        end
        
    end
    
    
    
    
    
end
