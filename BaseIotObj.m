        classdef BaseIotObj <dynamicprops %%
            
            
            properties
                %common properties
                name
                string
                pos %  scaler posation
                posV % vector posation
                state
                numPorts
                ports
                handle
                
                hPropfig
                %spacial properties
                
            end
            
            events
                reciving
                sending
                moving
            end
            
            methods%common methods
                function bsObj=BaseIotObj(para)
                   %% class initial setting
                   bsObj.name=para.name;
                   bsObj.string=para.string;
                   bsObj.numPorts=para.numPorts;
                   bsObj.pos=para.pos ;

                   %% graphic initial setting
                   poly=makepoly([6,0.4],pi/6,para.pos);
                   if bsObj.state
                       bsObj.handle=fill3(poly.xv,poly.yv,poly.zv,'g');
                       
                   else
                       bsObj.handle= fill3(poly.xv,poly.yv,poly.zv,'w');
                   end
                   
                   %% connect class aspect to graphic aspect
                    bsObj.handle.addprop('fatherClass'); 
                    bsObj.handle. fatherClass=bsObj;
                   
                end
                
                
                function properyPage(iotObj)
                    try
                        iotObj.hPropfig.Tag
                        figure(iotObj.hPropfig)
                    catch
                        iotObj.hPropfig = figure('name',[ iotObj.string  '  property page' ],'NumberTitle','off','tag',iotObj.name);
                        iotObj.hPropfig.CloseRequestFcn=@(pcfFig,eve)onDeleteNetObj_Callback(pcfFig,eve,iotObj);
                        
                        
                        set(iotObj.hPropfig,'MenuBar','none' )
                        tgroup = uitabgroup('Parent', iotObj.hPropfig);
                        
                        
                        lanConf = uitab('Parent', tgroup, 'Title', 'lanConf');
                        panConf = uitab('Parent', tgroup, 'Title', 'panConf');
                        
                        
                        portsPanel_config = uipanel('Title','ports Panel','FontSize',12,...
                            'BackgroundColor','white',...
                            'Position',[.10 .10 .30 .90],'parent' , lanConf,'tag','portsPanel');
                        
                        settingPanel_config = uipanel('Title','setting Panel','FontSize',12,...
                            'BackgroundColor','white',...
                            'Position',[.42 .10 .90 .90],'parent' , lanConf,'tag','settingPanel','Visible','on');
                        
                        globalSettingPanel_config = uipanel('Title','global seeting','FontSize',12,...
                            'BackgroundColor','white',...
                            'Position',[.42 .10 .90 .90],'parent' , lanConf,'tag','gl','Visible','off');
                        
                        ipv4_config = uipanel('Title','ip configuration','FontSize',12,...
                            'BackgroundColor','white',...
                            'Position',[.02 .40 .90 .29],'parent' , settingPanel_config,'tag','ipv4_config');
                        
               
                    end
                end
                
                

            end
            
                 
            methods%special methods
                
                     
            end
            
            
        end
