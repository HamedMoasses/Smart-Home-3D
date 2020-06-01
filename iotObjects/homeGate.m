
        classdef homeGate <handle% dynamicprops %%
            %    dynamicprops is subclass of handl, and we can use dynamicprops instead of both handle and dynamicprops for adding listener and property
            %     dynamicprops used for adding property for objects and handles
            %     handle used for adding listener for objects
            properties
                name
                domainName % is used in sub network comnucation as ip
                string
                numPorts
                ports
                pos %  scaler posation
                posV % vector posation
                colorSeting % is used for selection and moving of netobjects
                selcted=0; % when netobject is selected it become 1 else ...
                Routing_Table % mac table
                ARP_Table % arp table
                NAT_Table %  Nat table
                Vlan_Table %  vlan table
                handles %
                typeDevice % Router type is 6
                reciveLisener
                sendListener
                connectLine
                tagNum=1
                hrtPropfig
                recBuffer
                sendBuffer
                ioControlFlag=zeros(1,6)% used for behavior control of packets
                QueueinProcPortIndex=[];
                %bit1: recived   frame  should  be droped
                %bit2: recived   frame  should  be accept    and  then    is      blocked
                %bit3: recived   frame  should  be unicast   from recived port
                %bit4: recived   frame  should  be unicast   from to      another port
                %bit5: recived   frame  should  be broadcast to   all     ports   except   recived packet
                
                delayT=1;%20/60;% every 10 minutes from now routing table will update, this s
                rangAdd=[];
                Nat=[];
                tmObj
            end

            events
                recived
                sent
                moving
            end

            methods % object makeing methods
                function rt=homeGate(rtSource_obj,actStat,rtListener1)
                  
                    if actStat==0

                        %% common parameters
                        rt.name=rtSource_obj.name;
                        rt.domainName=rtSource_obj.domainName;
                        
                        rt.string=rtSource_obj.string;
                        rt.numPorts=rtSource_obj.numPorts;
                        rt.pos=rtSource_obj.pos ;

                        %%  creat a squar Router graphically
                        rtSid=20;
                        t1=linspace(0,1,rtSid+1);
                        rtX=-sin(2*pi*t1+(pi/rtSid))*2;%node X coordinates with phaze shift
                        rtY=-cos(2*pi*t1+(pi/rtSid));%node Y coordinates with phaze shift
                        rtX=(((rtX-min(rtX))./(max(rtX)-min(rtX)))-0.5)*10;
                        rtY=(((rtY-min(rtY))./(max(rtY)-min(rtY)))-0.5)*10;
                        rtZ=rtY*0;

                        %% Router position

                        rt.posV.X=rt.pos.X+rtX;
                        rt.posV.Y=rt.pos.Y+rtY;
                        rt.posV.Z=rt.pos.Z+rtZ;

                        %% creat portst and initialaze each port
                        for nP=1:rtSource_obj.numPorts
                            ports(nP).name=['fa0/' num2str(nP-1)];
                            ports(nP).passive_interface='off';%%  on or off, if it is on then can exchang hello messag other drop it
                            ports(nP).EIGRP ='on';%% can use eigrp protocol
                            ports(nP).OSPF ='on';%% can use OSPF protocol

                            ports(nP).status=1;%up or down
                            ports(nP).bandWidth=1;%up or down
                            ports(nP).duplex=1;%up or down

                            ports(nP).inUse=0;%0= no in use, 1=in use
                            ports(nP).upDown='Down';%0= no in use, 1=in use

                            
                          
                            ports(nP).mac=macAddAloc;
                            %mac making

                            ports(nP).ip='';
                            ports(nP).subnetMask='';
                            ports(nP).txRing='';
                            ports(nP).pool=[];

                        end

                        %% Routing   table
                        type={};
                        Network={};
                        port={};
                        NextHopIp={};
                        Metric={};
                        Routing=table(type,Network,port,NextHopIp,Metric);


                        %% Arp table
                        ipAddress={};
                        hardWareAddress={};
                        interface={};
                        arp=table(ipAddress,hardWareAddress,interface);

                        %% NAT table
                        Protocol={};
                        InsideGlobal={};
                        InsideLocal={};
                        OutsideLocal={};
                        outsideGlobal={};

                        NAT=table(Protocol,InsideGlobal,InsideLocal,OutsideLocal,outsideGlobal);




                        %% vlan   table
                        type={'vlan 1'};
                        name={'default'};
                        status={'active'};
                        portsV={ports.name};
                        vlans=table(type,name,status,portsV);

                        %% give initialiezed ports and vlans to Router object
                        rt.ports=ports;% set Router ports
                        rt.Routing_Table=Routing ;% set Router vlan table
                        rt.ARP_Table=arp;% set Router mac table
                        rt.NAT_Table=NAT;% set Router arp table
                        rt.Vlan_Table=vlans;% set Router arp table
                        rt.typeDevice=6;% Router type =6
                        
                        
                        %% plot Router with one unit dimension
                        handles(1)=patch(  rt.posV.X,rt.posV.Y,[0.1,0.4,0.8],'edgeColor','k','tag',['p_' rt.name]);alpha(0.5);hold on; % fill Router graphically and set a tag and save object in handle(1)
                        handles(2)=text(    rt.pos.X,rt.pos.Y,rt.name,'tag',['t_' rt.name], 'fontSize',8);alpha(0.5);hold on% set a text on Router object and set a tag and save object in handle(2)
                        handles(1).addprop('fatherClass'); 

                        rt.colorSeting.FaceAlpha=handles(1).FaceAlpha;
                        rt.colorSeting.FaceColor=handles(1).FaceColor;
                        
                        %handles(1).ButtonDownFcn=@(sds,fdf )moveCallBack(sds,fdf,rt );
                        %handles(2).ButtonDownFcn=@(sds,fdf )moveCallBack(sds,fdf,rt );
                        %handles(1).ButtonDownFcn=@(graphicObj,even )mousClick(graphicObj,even,rt );
                        %handles(2).ButtonDownFcn=@(graphicObj,even )mousClick(graphicObj,even,rt );
                        rt.handles=handles;% at the end Router object save all hndles
                        
                        rt.tmObj = timer('TimerFcn',@(tObj,data)routinTableTimer(tObj,data,rt,0),'tag',['T_' rt.name] );
                        rt.tmObj.UserData=0;% number of update
                        rt.handles(1). fatherClass=rt;
                        %two = 0.1/(60*60^2*24); % two seconds after ceation of connection timer start and every 10 minutes routing table will update
                        %fTime = now + two;
                        start(rt.tmObj);
                        
                        
                        
                        


                    else


                        rtListener1.sendListener{end+1}= addlistener(rtSource_obj,'sent',@(src,event)rtListener1.onReciveFram(src,event) );
                        rtListener1.sendListener{end}.Recursive=1;
                        rt=rtListener1;
                        rt.handles(1). fatherClass=rt;
                        
                        
                        
                      
                        
                      







                    end

                end
            end


            methods %% propery makeing methods
                function properyPage(rtObj)
                    

                  global toolTip;
                    delete(findobj('tag','captionText'))
                    toolTip=0;
                    
                    rtObj.selcted=1; % when netobject is selected it become 1 else ...

                    try
                        rtObj.hrtPropfig.Tag
                        figure(rtObj.hrtPropfig)
                    catch
                        rtObj.hrtPropfig = figure('name',[ rtObj.name  '  property page' ],'NumberTitle','off','tag',rtObj.name);
                        rtObj.hrtPropfig.CloseRequestFcn=@(pcfFig,eve)onDeleteNetObj_Callback(pcfFig,eve,rtObj);
                        
                        
                        set(rtObj.hrtPropfig,'name',[ rtObj.name  '  property page' ],'NumberTitle','off')
                        set(rtObj.hrtPropfig,'MenuBar','none' )
                        %set(f, 'WindowStyle','modal')

                        tgroup = uitabgroup('Parent', rtObj.hrtPropfig);

                        phisical = uitab('Parent', tgroup, 'Title', 'phisical');
                        config = uitab('Parent', tgroup, 'Title', 'config');
                        cli = uitab('Parent', tgroup, 'Title', 'cli');
                        attributes = uitab('Parent', tgroup, 'Title', 'attributes');

                        portsPanel = uipanel('Title','ports Panel','FontSize',12,...
                            'BackgroundColor','white',...
                            'Position',[.10 .10 .30 .90],'parent' , config,'tag','portsPanel');

                        settingPanel = uipanel('Title','setting Panel','FontSize',12,...
                            'BackgroundColor','white',...
                            'Position',[.42 .10 .90 .90],'parent' , config,'tag','settingPanel');

                        globalSettingPanel_config = uipanel('Title','global seeting','FontSize',12,...
                            'BackgroundColor','white',...
                            'Position',[.42 .10 .90 .90],'parent' , config,'tag','gl','Visible','off');



                        %% buttons in panel ports

                        globalSeeting = uicontrol('Parent', portsPanel, 'Style', 'pushbutton', 'String', 'global seeting', ...
                            'units','normalized','HorizontalAlignment', 'left','Position', [.10 .90 .90 .10],'tag','100','CallBack', @rtObj.tabButon_Callback) ;


                        fa0_0 = uicontrol('Parent', portsPanel, 'Style', 'pushbutton', 'String', 'fasEthernet0/0', ...
                            'units','normalized','HorizontalAlignment', 'left','Position', [.10 .78 .90 .10],'tag','1','CallBack', @rtObj.tabButon_Callback) ;


                        fa0_1 = uicontrol('Parent', portsPanel, 'Style', 'pushbutton', 'String', 'fasEthernet0/1', ...
                            'units','normalized','HorizontalAlignment', 'left','Position', [.10 .66 .90 .10],'tag','2' ,'CallBack', @rtObj.tabButon_Callback) ;

                        fa0_2 = uicontrol('Parent', portsPanel, 'Style', 'pushbutton', 'String', 'fasEthernet0/2', ...
                            'units','normalized','HorizontalAlignment', 'left','Position', [.10 .54 .90 .10],'tag','3' ,'CallBack', @rtObj.tabButon_Callback) ;
                        fa0_3 = uicontrol('Parent', portsPanel, 'Style', 'pushbutton', 'String', 'fasEthernet0/3', ...
                            'units','normalized','HorizontalAlignment', 'left','Position', [.10 .42 .90 .10],'tag','4' ,'CallBack', @rtObj.tabButon_Callback) ;

                        %% more capablity(add to other objecs and delete this comment)
                        addprop( fa0_0 , 'inerFace' );
                        addprop( fa0_1 , 'inerFace' );
                        addprop( fa0_2 , 'inerFace' );
                        addprop( fa0_3 , 'inerFace' );

                        set(  fa0_0  ,'inerFace','yes');
                        set(  fa0_1  ,'inerFace','yes');
                        set(  fa0_2  ,'inerFace','yes');
                        set(  fa0_3  ,'inerFace','yes')


                        %% labels in panel setting
                        displayNameL = uicontrol('Parent', globalSettingPanel_config, 'Style', 'text', 'String', 'display name', ...
                            'units','normalized','HorizontalAlignment', 'left','Position', [.05 .80 .20 .10],'FontSize',8) ;


                        portStatusL = uicontrol('Parent', settingPanel, 'Style', 'text', 'String', 'port Status', ...
                            'units','normalized','HorizontalAlignment', 'left','Position', [.05 .90 .20 .10]) ;
                        bandWidthL = uicontrol('Parent', settingPanel, 'Style', 'text', 'String', 'band Width', ...
                            'units','normalized','HorizontalAlignment', 'left','Position', [.05 .78 .20 .10]) ;
                        duplexL = uicontrol('Parent', settingPanel, 'Style', 'text', 'String', 'duplex', ...
                            'units','normalized','HorizontalAlignment', 'left','Position', [.05 .66 .20 .10]) ;
                        MacAddressL = uicontrol('Parent', settingPanel, 'Style', 'text', 'String', 'Mac Address', ...
                            'units','normalized','HorizontalAlignment', 'left','Position', [.05 .54 .20 .10]) ;
                        ipAddressL = uicontrol('Parent', settingPanel, 'Style', 'text', 'String', 'ip Address', ...
                            'units','normalized','HorizontalAlignment', 'left','Position', [.05 .30 .20 .10]) ;
                        subnetMaskL = uicontrol('Parent', settingPanel, 'Style', 'text', 'String', 'subnet Mask', ...
                            'units','normalized','HorizontalAlignment', 'left','Position', [.05 .18 .20 .10]) ;
                        txRingLimL = uicontrol('Parent', settingPanel, 'Style', 'text', 'String', 'tx RingLim', ...
                            'units','normalized','HorizontalAlignment', 'left','Position', [.05 .04 .20 .10]) ;


                        %% edits in panel setting

                        express='set(rtObj.hrtPropfig,''name'',rtObj.string);set(rtObj.handles(2),''String'',rtObj.string)';
                        displayName = uicontrol('Parent', globalSettingPanel_config, 'Style', 'edit', 'tag', 'string', ...
                            'String', rtObj.string,'units','normalized','HorizontalAlignment', 'left','Position', [.28 .80 .20 .10],'FontSize',8,'CallBack',@(cla,contr,eve)rtObj.editor_Callback(cla,contr,express)) ;



                        express='hMac=findobj(rtObj.hrtPropfig,''tag'',''mac'');   set([hMac''],''String'', uiedit.String )';
                        MacAddress = uicontrol('Parent', settingPanel, 'Style', 'edit', 'String','' , ...
                            'units','normalized','HorizontalAlignment', 'left','Position', [.28 .54 .30 .10],'tag','mac' ,'CallBack',@(cla,contr,eve)rtObj.editor_Callback(cla,contr,express)) ;

                        express='hIpv4=findobj(rtObj.hrtPropfig,''tag'',''ip'');   [sIp,decIP]=ip2IpS_dec(uiedit.String);  set([hIpv4''],''String'', sIp )';
                        ipAddress = uicontrol('Parent', settingPanel, 'Style', 'edit', 'String', '', ...
                            'units','normalized','HorizontalAlignment', 'left','Position', [.28 .30 .30 .10],'tag','ip','CallBack',@(cla,contr,eve)rtObj.editor_Callback(cla,contr,express)) ;

                        express='hsu=findobj(rtObj.hrtPropfig,''tag'',''subnetMask'');   set([hsu''],''String'', uiedit.String )';
                        subnetMask = uicontrol('Parent', settingPanel, 'Style', 'edit', 'String', '', ...
                            'units','normalized','HorizontalAlignment', 'left','Position', [.28 .18 .30 .10],'tag','subnetMask','CallBack',@(cla,contr,eve)rtObj.editor_Callback(cla,contr,express) ) ;

                        express='htx=findobj(rtObj.hrtPropfig,''tag'',''txRing'');   set([htx''],''String'', uiedit.String )';
                        txRingLim = uicontrol('Parent', settingPanel, 'Style', 'edit', 'String', '10', ...
                            'units','normalized','HorizontalAlignment', 'left','Position', [.28 .04 .20 .10],'tag','txRing','CallBack',@(cla,contr,eve)rtObj.editor_Callback(cla,contr,express) ) ;




                        %% port setting
                        express='';
                        portStatus = uicontrol('Parent', settingPanel, 'Style', 'checkbox', 'String', 'on', ...
                            'units','normalized','HorizontalAlignment', 'left','Position', [.28 .90 .20 .10],'FontUnits','normalized','FontSize',.5,'tag','status' ,'CallBack',@(cla,contr,eve)rtObj.radioBox_Callback(cla,contr,express)) ;
                        express='';
                        bandWidth = uicontrol('Parent', settingPanel, 'Style', 'checkbox', 'String', 'Auto', ...
                            'units','normalized','HorizontalAlignment', 'left','Position',[.28 .78 .20 .10],'FontUnits','normalized','FontSize',.5,'tag','bandWidth' ,'CallBack',@(cla,contr,eve)rtObj.radioBox_Callback(cla,contr,express)) ;

                        express='';
                        duplex = uicontrol('Parent', settingPanel, 'Style', 'checkbox', 'String', 'Auto', ...
                            'units','normalized','HorizontalAlignment', 'left','Position', [.28 .66 .20 .10],'FontUnits','normalized','FontSize',.5,'tag','duplex' ,'CallBack',@(cla,contr,eve)rtObj.radioBox_Callback(cla,contr,express)) ;



                        %% default setting
                        rtObj.tagNum=1;
                        defaultSettng_rt(rtObj)




                    end
                end
                function tabButon_Callback( rtObj, uibutton,~)
                    rtObj.tagNum=str2double(uibutton.Tag);
                    defaultSettng_rt(rtObj)
                end
                function editor_Callback( rtObj, uiedit,~,actionScript)

                    if  rtObj.tagNum==100
                        rtObj.(uiedit.Tag)=uiedit.String;
                        eval(actionScript);
                    else
                        eval(actionScript);
                        rtObj.ports(rtObj.tagNum).(uiedit.Tag)=uiedit.String;

                    end



                end
                function radioBox_Callback( rtObj, uicheckB,~,actionScript)
                    rtObj.ports(rtObj.tagNum).(uicheckB.Tag)=uicheckB.Value;
                    eval(actionScript)
                end
                function portNum=getPort(rtObj,portName)
                    portNum=find(strcmp({rtObj.ports.name},portName));
                end
            end


            methods %% event methods
                function onMoving(rtSource )

                    notify(rtSource,'moving');

                end


                function onSentFram(rtSource,pdu)
                    pdu=orderfields(pdu, length(fieldnames(pdu)):-1:1);
                    
                    if ~isempty(pdu)

                        eventDat=dataFram(pdu);

                        inProc=rtSource.QueueinProcPortIndex(end);
                        ed=[rtSource.connectLine{:}] ;
                        handl=[ed.handles];
                        handl=handl(1,:);
                        LinIndex=1:length(handl);LinIndex(LinIndex==inProc)=[];
                        handl(inProc)=[];
                        rtSource.ports(inProc).inProc=0;
                        % conLine.x= {rtSource.connectLine{:} };
                        conLine.x= {handl.XData};
                        conLine.y={handl.YData};
                        
                        
                        
                        
                        
                        
                        for revInd=1:length(conLine.x)
                            if  rtSource.connectLine{revInd}.rev(rtSource.typeDevice)==1
                                conLine.x{revInd}=flip( conLine.x{revInd});
                                conLine.y{revInd}=flip( conLine.y{revInd});
                            end
                            
                            
                            destObjName=strrep(rtSource.connectLine{LinIndex(revInd)}.name,[rtSource.name,'l_l'],'');
                            pchetResource.name{revInd}=['pk_' strrep(destObjName,['l_l' rtSource.name],'')];
                            
                            
                        end
                        
                        pchetResource.conLine=conLine;
                        
                        packetPathShell(pchetResource,pdu,rtSource);
                        rtSource.sendBuffer.pdu=pdu;
                        
                       
                        rtSource.sendBuffer.inProcPortIndex=LinIndex;
                        
                        
                        notify(rtSource,'sent',eventDat);
                    end
                    tf2 = event.hasListener(rtSource,'sent');

                end


                %                  function onReciveFram(rtListener,rtSource,eventData)
                %                  end


                function onReciveFram(rtListener,rtSource,eventData)
                    pdu= eventData.pdu;
                    rtListener.recBuffer.pdu=pdu;

                    portTagS=[rtSource.connectLine{:}];
                    portTagS={portTagS.name};

                    portF1=find(cell2mat(cellfun(@strcmp, portTagS,repmat({[rtSource.name 'l_l' rtListener.name]},1,length(portTagS)),'UniformOutput' , false)),1);
                    portF2=find(cell2mat([cellfun(@strcmp, portTagS,repmat({[rtListener.name 'l_l' rtSource.name]},1,length(portTagS)),'UniformOutput' , false)]),1);
                    if ~isempty(portF1)
                        connectL= rtSource.connectLine{portF1};
                        sourcPort=connectL.conPorts{1};
                        inProcPortIndex=connectL.conPorts{2};
                    else
                        connectL= rtSource.connectLine{portF2};
                        sourcPort=connectL.conPorts{2};
                        inProcPortIndex=connectL.conPorts{1};% port that frame recived from that

                    end
                    rtListener.recBuffer.inProcPortIndex=inProcPortIndex;




                    rtListener.QueueinProcPortIndex(end+1)=inProcPortIndex;
                    linkLayer=tcpIp.link;
                    pdu=linkLayer.linkProt(pdu,rtListener);
                    rtListener.QueueinProcPortIndex(end)=[];
                    %bit1: recived   frame  should  be droped
                    %bit2: recived   frame  should  be accept    and  then    is      blocked
                    %bit3: recived   frame  should  be unicast   from recived port
                    %bit4: recived   frame  should  be unicast   from to      another port
                    %bit5: recived   frame  should  be broadcast to   all     ports   except   recived packet



                    if rtListener.ioControlFlag(1)
                        rtListener.ioControlFlag(1)=0;
                        dropAccept(rtListener,'dr');
                        
                    elseif rtListener.ioControlFlag(2)
                        rtListener.ioControlFlag(2)=0;
                        
                        dropAccept(rtListener,'ac');
                        
                    elseif rtListener.ioControlFlag(3)
                        rtListener.ioControlFlag(3)=0;
                        
                        aimPort=rtListener.ports(inProcPortIndex).outport;
                        aimObj=rtListener.ports(inProcPortIndex).outObj;
                        if aimObj.sendListener{aimPort}.Enabled==0
                            aimObj.sendListener{aimPort}.Enabled=1;
                        end
                        conLine.x={[rtListener.pos.X,aimObj.pos.X]};
                        conLine.y={[rtListener.pos.Y,aimObj.pos.Y]};
                        
                        uniCast(rtListener,aimObj,pdu,conLine,inProcPortIndex,1)
                        
                    elseif rtListener.ioControlFlag(4)
                        rtListener.ioControlFlag(4)=0;
                        
                        
                        conLine.x={[rtListener.pos.X,aimObj.pos.X]};
                        conLine.y={[rtListener.pos.Y,aimObj.pos.Y]};
                        
                        uniCast(rtListener,aimObj,pdu,conLine,inProcPortIndex)
                        
                        
                    elseif rtListener.ioControlFlag(5)
                        rtListener.ioControlFlag(5)=0;
                        
                        rtSource.sendListener{sourcPort}.Enabled=0;
                        onSentFram(rtListener,pdu);
                        rtSource.sendListener{sourcPort}.Enabled=1;
                        
                    elseif rtListener.ioControlFlag(6) % nokhod siah!!
                        rtListener.ioControlFlag(6)=0;
                        dropAccept(rtListener,'dr');

                    end







                end




            end





        end




