% here zigbee and other application implemented
classdef homeSysControl<dynamicprops
    
    properties
       state=0; 
       lineSen;
       handle
       %undrline devices
       gscObj
       gspObj
       wObj
       dObj
       lObj
       mObj
       gsObj
       fiObj
       hObj
       seObj
       
       %energy Consum
       zigEnCon=0;
       wiEnCon=0;
       
    end
    
    methods
        
        function hscObj=homeSysControl(para,gscObj,gspObj,wObj,dObj,lObj,mObj,gsObj,fiObj,hObj,seObj)  
            hscObj.gscObj=gscObj;
            hscObj.gspObj=gspObj;
            hscObj.wObj=wObj;
            hscObj.dObj=dObj;
            hscObj.lObj=lObj;
            hscObj.mObj=mObj;
            hscObj.gsObj=gsObj;
            hscObj.fiObj=fiObj;
            hscObj.hObj=hObj;
            hscObj.seObj=seObj;
            
            hscObj.state=para.state;% on or off in default
             poly=makepoly([4,1],pi/4,para.pos);
            [poly.xv,poly.yv,poly.zv]= divider3(poly.xv,poly.yv,poly.zv,2);
             
              if hscObj.state
                  hscObj.handle=fill3(poly.xv,poly.yv,poly.zv,'.b');alpha( hscObj.handle,.4)
                  
              else
                  hscObj.handle= fill3(poly.xv,poly.yv,poly.zv,'.w');alpha( hscObj.handle,.4)
                  
                  
              end
            
            
            
           
       
           
        end
        
        function onRecive(reciver,source,command)
            zigbee.RxTxEn=56;%mw
            zigbee.idlStand=1.2;%mw
            
            % unit power consumpation of wifi for each rx/tx mode and idl/standby
            wifi.RxTxEn=435;%mw
            wifi.idlStand=33;%mw
            enwironment.temper=27;
            
            reciver.zigEnCon= reciver.zigEnCon+zigbee.RxTxEn;
            source.zigEnCon= source.zigEnCon+zigbee.RxTxEn;
            
            reciver.wiEnCon= reciver.wiEnCon+wifi.RxTxEn;
            source.wiEnCon= source.wiEnCon+wifi.RxTxEn;
          
            if reciver.fiObj.temper >40 && reciver.gsObj.alarm >5
              reciver.fiObj.temper=max([enwironment.temper,reciver.fiObj.temper-0.0001*mean([reciver.lObj.temper])]);

              for lobId=1:length(reciver.lObj)
                  if reciver.lObj(lobId).state
                      reciver.lObj(lobId).off;
                      reciver.lObj(lobId).wiEnCon= reciver.lObj(lobId).wiEnCon+wifi.RxTxEn;
                      reciver.lObj(lobId).zigEnCon=  reciver.lObj(lobId).zigEnCon+zigbee.RxTxEn;
                      reciver.lObj(lobId).temper=max([ enwironment.temper,reciver.lObj(lobId).temper-1]);
                      
                  end
              end
              
              
              
            end  
            %% homeSysControl get the current Situation of all device by this function  
            if reciver.fiObj.temper >40 % fire detection
                if reciver.gscObj.state
                reciver.gscObj.off;
                reciver.gscObj.wiEnCon= reciver.gscObj.wiEnCon+wifi.RxTxEn;
                reciver.gscObj.zigEnCon=  reciver.gscObj.zigEnCon+zigbee.RxTxEn;
                end
                
              
                for woId=1:length(reciver.wObj)
                   if reciver.wObj(woId).opcl
                    reciver.wObj(woId).close;
                    reciver.wObj(woId).wiEnCon=  reciver.wObj(woId).wiEnCon+wifi.RxTxEn;
                    reciver.wObj(woId).zigEnCon=   reciver.wObj(woId).zigEnCon+zigbee.RxTxEn;
                   end
                end
                
                for woId=1:length(reciver.dObj)
                    if reciver.dObj(woId).opcl
                        reciver.dObj(woId).close;
                        reciver.dObj(woId).wiEnCon=  reciver.dObj(woId).wiEnCon+wifi.RxTxEn;
                        reciver.dObj(woId).zigEnCon=   reciver.dObj(woId).zigEnCon+zigbee.RxTxEn;
                    end
                end
                
            elseif reciver.gsObj.alarm >5 % gas leak detection
              
               if reciver.gscObj.state
                reciver.gscObj.off;
                reciver.gscObj.wiEnCon= reciver.gscObj.wiEnCon+wifi.RxTxEn;
                reciver.gscObj.zigEnCon=  reciver.gscObj.zigEnCon+zigbee.RxTxEn;
                end
                
                for lobId=1:length(reciver.lObj)
                    if reciver.lObj(lobId).state
                        reciver.lObj(lobId).off;
                        reciver.lObj(lobId).wiEnCon= reciver.lObj(lobId).wiEnCon+wifi.RxTxEn;
                        reciver.lObj(lobId).zigEnCon=  reciver.lObj(lobId).zigEnCon+zigbee.RxTxEn;
                        reciver.lObj(lobId).temper=max([ enwironment.temper,reciver.lObj(lobId).temper-1]);
                        
                    end
                    
                    
                end
                for woId=1:length(reciver.wObj)
                   if ~reciver.wObj(woId).opcl
                    reciver.wObj(woId).open;
                    reciver.wObj(woId).wiEnCon=  reciver.wObj(woId).wiEnCon+wifi.RxTxEn;
                    reciver.wObj(woId).zigEnCon=   reciver.wObj(woId).zigEnCon+zigbee.RxTxEn;
                   end
                end
                
                for woId=1:length(reciver.dObj)
                    if  ~reciver.dObj(woId).opcl
                        reciver.dObj(woId).open;
                        reciver.dObj(woId).wiEnCon=  reciver.dObj(woId).wiEnCon+wifi.RxTxEn;
                        reciver.dObj(woId).zigEnCon=   reciver.dObj(woId).zigEnCon+zigbee.RxTxEn;
                    end
                end

            else % normale state
                
                
                switch class(source)
                    
                    case class(reciver.gspObj)
                    
                        
                    case class(reciver.wObj)
                        if  strcmp(command,'open')
                            source.(command);
                        elseif strcmp(command,'close')
                            source.(command);
                        end
                        
                        reciver.zigEnCon= reciver.zigEnCon+zigbee.RxTxEn;
                        source.zigEnCon= source.zigEnCon+zigbee.RxTxEn;
                        
                        reciver.wiEnCon= reciver.wiEnCon+wifi.RxTxEn;
                        source.wiEnCon= source.wiEnCon+wifi.RxTxEn;
            
                        
                    case class(reciver.dObj)
                        if  strcmp(command,'open')
                            source.(command);
                        elseif strcmp(command,'close')
                            source.(command); 
                        end
                        
                        reciver.zigEnCon= reciver.zigEnCon+zigbee.RxTxEn;
                        source.zigEnCon= source.zigEnCon+zigbee.RxTxEn;
                        
                        reciver.wiEnCon= reciver.wiEnCon+wifi.RxTxEn;
                        source.wiEnCon= source.wiEnCon+wifi.RxTxEn;
            
                        
                        
                    case class(reciver.lObj)
                        source.(command);
                        
                        
                        
                        
                        if  strcmp(command,'on') && source.onOff==0 % it is off and command is on
                            source.(command);
                            source.temper=source.temper+1;
                            
                            reciver.zigEnCon= reciver.zigEnCon+zigbee.RxTxEn;
                            source.zigEnCon= source.zigEnCon+zigbee.RxTxEn;
                            
                            reciver.wiEnCon= reciver.wiEnCon+wifi.RxTxEn;
                            source.wiEnCon= source.wiEnCon+wifi.RxTxEn;
                            
                        elseif strcmp(command,'off') && source.onOff==1% it is on and command is off
                            source.(command);
                            source.temper=max([ enwironment.temper,source.temper-1]);
                            
                            reciver.zigEnCon= reciver.zigEnCon+zigbee.RxTxEn;
                            source.zigEnCon= source.zigEnCon+zigbee.RxTxEn;
                            
                            reciver.wiEnCon= reciver.wiEnCon+wifi.RxTxEn;
                            source.wiEnCon= source.wiEnCon+wifi.RxTxEn;
                        else
                            % dont do any thing
                            disp('');
                        end
                        
                       
            
                        
                        
                    case class(reciver.mObj)
                        reciver.zigEnCon= reciver.zigEnCon+zigbee.RxTxEn;
                        source.zigEnCon= source.zigEnCon+zigbee.RxTxEn;
                        
                        reciver.wiEnCon= reciver.wiEnCon+wifi.RxTxEn;
                        source.wiEnCon= source.wiEnCon+wifi.RxTxEn;
                        
                        
                        
                    case class(reciver.gsObj)
                        reciver.zigEnCon= reciver.zigEnCon+zigbee.RxTxEn;
                        source.zigEnCon= source.zigEnCon+zigbee.RxTxEn;
                        
                        reciver.wiEnCon= reciver.wiEnCon+wifi.RxTxEn;
                        source.wiEnCon= source.wiEnCon+wifi.RxTxEn;
                        
                        
                        
                    case class(reciver.fiObj)
                        reciver.zigEnCon= reciver.zigEnCon+zigbee.RxTxEn;
                        source.zigEnCon= source.zigEnCon+zigbee.RxTxEn;
                        
                        reciver.wiEnCon= reciver.wiEnCon+wifi.RxTxEn;
                        source.wiEnCon= source.wiEnCon+wifi.RxTxEn;

                    case class(reciver.seObj)
                        
                        if  source.checkPass( command.pass )
                            command.valid=1;
                        else
                           command.valid=0; 
                        end
                        
                        reciver.zigEnCon= reciver.zigEnCon+zigbee.RxTxEn;
                        source.zigEnCon= source.zigEnCon+zigbee.RxTxEn;
                        
                        reciver.wiEnCon= reciver.wiEnCon+wifi.RxTxEn;
                        source.wiEnCon= source.wiEnCon+wifi.RxTxEn;
                        
                        
                        
                end
            end
        end
   
        function onSend( source,reciver)
            %% homeSysControl make decision based on current Situation of all device  and send relative commands to all devices
        end
        
    end
    
end
