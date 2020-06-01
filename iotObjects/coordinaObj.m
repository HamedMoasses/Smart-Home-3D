
        classdef coordinaObj <handle% dynamicprops %%
            %    dynamicprops is subclass of handl, and we can use dynamicprops instead of both handle and dynamicprops for adding listener and property
            %     dynamicprops used for adding property for objects and handles
            %     handle used for adding listener for objects
            properties

                name
                string
                numPorts
                ports
                pos %  scaler posation
                posV % vector posation
                colorSeting % is used for selection and moving of netobjects
                selcted=0; % when netobject is selected it become 1 else ...
                MAC_Table % mac table
                ARP_Table % arp table
                vlan_Table %  vlan table
                handles %
                typeDevice % switch type is 5
                reciveLisener
                sendListener
                connectLine
                tagNum=1
                hswPropfig
                recBuffer
                sendBuffer
                gatePort;
                
                ioControlFlag=zeros(1,5)% used for behavior control of packets
                QueueinProcPortIndex=[];
                %bit1: recived   frame  should  be droped
                %bit2: recived   frame  should  be accept    and  then    is      blocked
                %bit3: recived   frame  should  be unicast   from recived port
                %bit4: recived   frame  should  be unicast   from to      another port
                %bit5: recived   frame  should  be broadcast to   all     ports   except   recived packet

            end

            events
                recived
                sent
                moving

            end

            methods % object makeing methods
                function sw=coordinaObj(swSource_obj,actStat,swListener1)

                    if actStat==0

                        %% common parameters
                        sw.name=swSource_obj.name;
                        sw.string=swSource_obj.string;
                        sw.numPorts=swSource_obj.numPorts;
                        sw.pos=swSource_obj.pos ;
                        %%  creat a squar switch graphically
                        swSid=4;
                        t1=linspace(0,1,swSid+1);
                        swX=-sin(2*pi*t1+(pi/swSid))*2;%node X coordinates with phaze shift
                        swY=-cos(2*pi*t1+(pi/swSid));%node Y coordinates with phaze shift
                        swX=(((swX-min(swX))./(max(swX)-min(swX)))-0.5)*10;  swX([1,4,5])=swX([1,4,5])-2;
                        swY=(((swY-min(swY))./(max(swY)-min(swY)))-0.5)*10;
                        swZ=swY*0;

                        %% switch position

                        sw.posV.X=sw.pos.X+swX;
                        sw.posV.Y=sw.pos.Y+swY;
                        sw.posV.Z=sw.pos.Z+swZ;

                        %% creat portst and initialaze each port
                        for nP=1:swSource_obj.numPorts
                            ports(nP).name=['fa' num2str(nP-1) '/1'];
                            ports(nP).status=1;%up or down
                            ports(nP).bandWidth=1;%up or down
                            ports(nP).duplex=1;%up or down

                            ports(nP).modeValue=2;%% access or trunk
                            ports(nP).vlanValue=1;% default vlan
                            ports(nP).txRing='';
                            ports(nP).blocking='free';% block or free
                            ports(nP).inUse=0;%0= no in use, 1=in use
                            ports(nP).upDown='Down';%0= no in use, 1=in use
                            
                            ports(nP).ip='';
                            ports(nP).subnetMask='';
                            ports(nP).mac=macAddAloc;

                         end

                        %% Mac   table
                        vlan={};
                        macAddress={};
                        port={};
                        mac=table(vlan,macAddress,port);


                        %% Arp table
                        ipAddress={};
                        hardWareAddress={};
                        interface={};
                        arp=table(ipAddress,hardWareAddress,interface);


                        %% vlan table
                        vlan={'vlan 1'};
                        name={'default'};
                        status={'active'};
                        portsV={ports.name};
                        vlans=table(vlan,name,status,portsV);

                        %% give initialiezed ports and vlans to switch object
                        sw.ports=ports;% set switch ports
                        sw.vlan_Table= vlans;% set switch vlan table
                        sw.MAC_Table=mac;% set switch mac table
                        sw.ARP_Table=arp;% set switch arp table
                        sw.typeDevice=5;% switch type =3



                        %% plot switch with one unit dimension
                        handles(1)=fill(sw.posV.X,sw.posV.Y,[0.1,0.4,0.8],'edgeColor','k','tag',['p_' sw.name]);alpha(0.5);hold on; % fill switch graphically and set a tag and save object in handle(1)
                        handles(2)=text(sw.pos.X,sw.pos.Y,sw.string,'tag',['t_' sw.name], 'fontSize',8);alpha(0.5);hold on% set a text on switch object and set a tag and save object in handle(2)
                        handles(1).addprop('fatherClass'); 

                        sw.colorSeting.FaceAlpha=handles(1).FaceAlpha;
                        sw.colorSeting.FaceColor=handles(1).FaceColor;
                        
                        % give same callback funtion to both handles
                        %handles(1).ButtonDownFcn=@(sds,fdf )moveCallBack(sds,fdf,sw );
                        %handles(2).ButtonDownFcn=@(sds,fdf )moveCallBack(sds,fdf,sw );
                        %handles(1).ButtonDownFcn=@(graphicObj,even )mousClick(graphicObj,even,sw );
                        %handles(2).ButtonDownFcn=@(graphicObj,even )mousClick(graphicObj,even,sw );
                        
                        sw.handles=handles;% at the end switch object save all hndles

                    else


                        swListener1.sendListener{end+1}= addlistener(swSource_obj,'sent',@(src,event)swListener1.onReciveFram(src,event) );
                        swListener1.sendListener{end}.Recursive=1;
                        sw=swListener1;
                        sw.handles(1). fatherClass=sw; 

                        

                    end

                end
            end


            methods %% propery makeing methods
                function properyPage(swObj)
                     global toolTip;
                    delete(findobj('tag','captionText'))
                    toolTip=0;
                    swObj.selcted=1; % when netobject is selected it become 1 else ...

                    try
                        swObj.hswPropfig.Tag
                        figure(swObj.hswPropfig)
                    catch
                        swObj.hswPropfig = figure('name',[ swObj.string   '  property page' ],'NumberTitle','off','tag',swObj.name);
                        swObj.hswPropfig.CloseRequestFcn=@(pcfFig,eve)onDeleteNetObj_Callback(pcfFig,eve,swObj);
                        
                        
                        set(swObj.hswPropfig,'MenuBar','none' )
                        %set(f, 'WindowStyle','modal')

                        tgroup = uitabgroup('Parent', swObj.hswPropfig);

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
                            'units','normalized','HorizontalAlignment', 'left','Position', [.10 .90 .90 .10],'tag','100','CallBack', @swObj.tabButon_Callback) ;

                        fa0_1 = uicontrol('Parent', portsPanel, 'Style', 'pushbutton', 'String', 'fasEthernet0/1', ...
                            'units','normalized','HorizontalAlignment', 'left','Position', [.10 .78 .90 .10],'tag','1','CallBack', @swObj.tabButon_Callback) ;

                        fa1_1 = uicontrol('Parent', portsPanel, 'Style', 'pushbutton', 'String', 'fasEthernet1/1', ...
                            'units','normalized','HorizontalAlignment', 'left','Position', [.10 .66 .90 .10],'tag','2' ,'CallBack', @swObj.tabButon_Callback) ;

                        fa2_1 = uicontrol('Parent', portsPanel, 'Style', 'pushbutton', 'String', 'fasEthernet2/1', ...
                            'units','normalized','HorizontalAlignment', 'left','Position', [.10 .54 .90 .10],'tag','3' ,'CallBack', @swObj.tabButon_Callback) ;
                        fa3_1 = uicontrol('Parent', portsPanel, 'Style', 'pushbutton', 'String', 'fasEthernet3/1', ...
                            'units','normalized','HorizontalAlignment', 'left','Position', [.10 .42 .90 .10],'tag','4' ,'CallBack', @swObj.tabButon_Callback) ;


                        %% labels and popupmenu in panel setting
                        displayNameL = uicontrol('Parent', globalSettingPanel_config, 'Style', 'text', 'String', 'display name', ...
                            'units','normalized','HorizontalAlignment', 'left','Position', [.05 .80 .20 .10],'FontSize',8) ;


                        portStatusL = uicontrol('Parent', settingPanel, 'Style', 'text', 'String', 'port Status', ...
                            'units','normalized','HorizontalAlignment', 'left','Position', [.05 .90 .20 .10],'FontSize',8) ;
                        bandWidthL = uicontrol('Parent', settingPanel, 'Style', 'text', 'String', 'band Width', ...
                            'units','normalized','HorizontalAlignment', 'left','Position', [.05 .78 .20 .10],'FontSize',8) ;
                        duplexL = uicontrol('Parent', settingPanel, 'Style', 'text', 'String', 'duplex', ...
                            'units','normalized','HorizontalAlignment', 'left','Position', [.05 .66 .20 .10],'FontSize',8) ;

                        express='';
                        modeType = uicontrol( 'Parent', settingPanel,'Style', 'popupmenu', 'String', {'trunk','access'}, ...
                            'units','normalized','HorizontalAlignment', 'left','Position', [.05 .54 .20 .10],'FontSize',8,'tag','modeValue','CallBack',@(cla,contr,eve)swObj.radioBox_Callback(cla,contr,express)) ;
                        express='';
                        vlans = uicontrol( 'Parent', settingPanel,'Style', 'popupmenu', 'String', {'1:default','1002:fddi-default','1003:token-ring-default','1004:fddinet-default','1004:trnet-default'}, ...
                            'units','normalized','HorizontalAlignment', 'left','Position', [.28 .54 .20 .10],'FontSize',8,'tag','vlanValue', 'CallBack',@(cla,contr,eve)swObj.radioBox_Callback(cla,contr,express)) ;
                        txRingLimL = uicontrol('Parent', settingPanel, 'Style', 'text', 'String', 'tx RingLim', ...
                            'units','normalized','HorizontalAlignment', 'left','Position', [.05 .42 .20 .10],'FontSize',8) ;


                        %% edits and radio buttons
                        express='set(swObj.hswPropfig,''name'',swObj.string);set(swObj.handles(2),''String'',swObj.string)';
                        displayName = uicontrol('Parent', globalSettingPanel_config, 'Style', 'edit', 'tag', 'string', ...
                            'String', swObj.string,'units','normalized','HorizontalAlignment', 'left','Position', [.28 .80 .20 .10],'FontSize',8,'CallBack',@(cla,contr,eve)swObj.editor_Callback(cla,contr,express)) ;


                        express='';
                        portStatus = uicontrol('Parent', settingPanel, 'Style', 'checkbox', 'String', 'on', ...
                            'units','normalized','HorizontalAlignment', 'left','Position', [.28 .90 .20 .10],'FontUnits','normalized','FontSize',.5,'tag','status' ,'CallBack',@(cla,contr,eve)swObj.radioBox_Callback(cla,contr,express)) ;
                        express='';
                        bandWidth = uicontrol('Parent', settingPanel, 'Style', 'checkbox', 'String', 'Auto', ...
                            'units','normalized','HorizontalAlignment', 'left','Position',[.28 .78 .20 .10],'FontUnits','normalized','FontSize',.5,'tag','bandWidth' ,'CallBack',@(cla,contr,eve)swObj.radioBox_Callback(cla,contr,express)) ;

                        express='';
                        duplex = uicontrol('Parent', settingPanel, 'Style', 'checkbox', 'String', 'Auto', ...
                            'units','normalized','HorizontalAlignment', 'left','Position', [.28 .66 .20 .10],'FontUnits','normalized','FontSize',.5,'tag','duplex' ,'CallBack',@(cla,contr,eve)swObj.radioBox_Callback(cla,contr,express)) ;


                        express='htx=findobj(swObj.hswPropfig,''tag'',''txRing'');   set([htx''],''String'', uiedit.String )';
                        txRingLim = uicontrol('Parent', settingPanel, 'Style', 'edit', 'String', '10', ...
                            'units','normalized','HorizontalAlignment', 'left','Position', [.28 .42 .20 .10],'tag','txRing','CallBack',@(cla,contr,eve)swObj.editor_Callback(cla,contr,express) ) ;




                        %% port setting


                        %% default setting
                        swObj.tagNum=1;
                        defaultSettng_sw(swObj)




                    end
                end
                function tabButon_Callback( swObj, uibutton,~)
                    swObj.tagNum=str2double(uibutton.Tag);
                    defaultSettng_sw(swObj)
                end
                function editor_Callback( swObj, uiedit,~,actionScript)


                    if  swObj.tagNum==100
                        swObj.(uiedit.Tag)=uiedit.String;
                        eval(actionScript);
                    else
                        eval(actionScript);
                        swObj.ports(swObj.tagNum).(uiedit.Tag)=uiedit.String;

                    end



                end
                function radioBox_Callback( swObj, uicheckB,~,actionScript)
                    swObj.ports(swObj.tagNum).(uicheckB.Tag)=uicheckB.Value;
                    eval(actionScript)
                end
                function portNum=getPort(swObj,portName)
                    portNum=find(strcmp({swObj.ports.name},portName));
                end
            end


            methods %% event methods
                function onMoving(swSource )

                    notify(swSource,'moving');
                    
                end



                

                function onSentFram(swSource,pdu)
                    if ~isempty(pdu)
                        eventDat=dataFram(pdu);
                       
                        inProc=swSource.QueueinProcPortIndex(end);
                        ed=[swSource.connectLine{:}] ;
                        handl=[ed.handles];
                        handl=handl(1,:);
                        LinIndex=1:length(handl);LinIndex(LinIndex==inProc)=[];
                        handl(inProc)=[];
                        swSource.ports(inProc).inProc=0;
%                         conLine.x= {swSource.connectLine{:} };
                        conLine.x= {handl.XData};
                        conLine.y={handl.YData};

                        for revInd=1:length(conLine.x)
                            if  swSource.connectLine{revInd}.rev(swSource.typeDevice)==1
                                conLine.x{revInd}=flip( conLine.x{revInd});
                                conLine.y{revInd}=flip( conLine.y{revInd});
                            end
                            
                            outObj=swSource.ports(LinIndex(revInd)).outObj;
                            outport=swSource.ports(LinIndex(revInd)).outport;
                            outObj.sendListener{outport}.Enabled=1;
                            
                            destObjName=strrep(swSource.connectLine{LinIndex(revInd)}.name,[swSource.name,'l_l'],'');
                            pchetResource.name{revInd}=['pk_' strrep(destObjName,['l_l' swSource.name],'')];

                        end
                        pchetResource.conLine=conLine;


                        packetPathShell(pchetResource,pdu,swSource);
                        swSource.sendBuffer.pdu=pdu;
                        
                     
                        swSource.sendBuffer.inProcPortIndex=LinIndex;
                        
                        notify(swSource,'sent',eventDat);
                    end
                    tf2 = event.hasListener(swSource,'sent');

                end



                function onReciveFram(swListener,swSource,eventData)

                    pdu= eventData.pdu;
                    swListener.recBuffer.pdu=pdu;

                    portTagS=[swSource.connectLine{:}];
                    portTagS={portTagS.name};

                    portF1=find(cell2mat(cellfun(@strcmp, portTagS,repmat({[swSource.name 'l_l' swListener.name]},1,length(portTagS)),'UniformOutput' , false)),1);
                    portF2=find(cell2mat([cellfun(@strcmp, portTagS,repmat({[swListener.name 'l_l' swSource.name]},1,length(portTagS)),'UniformOutput' , false)]),1);
                    if ~isempty(portF1)
                        connectL= swSource.connectLine{portF1};
                        sourcPort=connectL.conPorts{1};
                        inProcPortIndex=connectL.conPorts{2};
                    else
                        connectL= swSource.connectLine{portF2};
                        sourcPort=connectL.conPorts{2};
                        inProcPortIndex=connectL.conPorts{1};% port that frame recived from that

                    end
                    swListener.recBuffer.inProcPortIndex=inProcPortIndex;



                    swListener.QueueinProcPortIndex(end+1)=inProcPortIndex;
                    linkLayer=tcpIp.link;
                    pdu=linkLayer.linkProt(pdu,swListener);

                    %bit1: recived   frame  should  be droped
                    %bit2: recived   frame  should  be accept    and  then    is      blocked
                    %bit3: recived   frame  should  be unicast   from recived port
                    %bit4: recived   frame  should  be unicast   from to      another port
                    %bit5: recived   frame  should  be broadcast to   all     ports   except   recived packet



                    if swListener.ioControlFlag(1)
                        swListener.ioControlFlag(1)=0;
                        dropAccept(swListener,'dr');

                    elseif swListener.ioControlFlag(2)
                        swListener.ioControlFlag(2)=0;

                        dropAccept(swListener,'ac');

                    elseif swListener.ioControlFlag(3)
                        swListener.ioControlFlag(3)=0;

                        aimPort=swListener.ports(inProcPortIndex).outport;
                        aimObj=swListener.ports(inProcPortIndex).outObj;
                        if aimObj.sendListener{aimPort}.Enabled==0
                            aimObj.sendListener{aimPort}.Enabled=1;
                        end
                        conLine.x={[swListener.pos.X,aimObj.pos.X]};
                        conLine.y={[swListener.pos.Y,aimObj.pos.Y]};

                        uniCast(swListener,aimObj,pdu,conLine,inProcPortIndex)

                    elseif swListener.ioControlFlag(4)
                        swListener.ioControlFlag(4)=0;
                        linkLayer=tcpIp.link;

                        %srcIndex=find(strcmp(swListener.MAC_Table.macAddress, pdu.ethernet.source ), 1);
                        dstIndex=find(strcmp(swListener.MAC_Table.macAddress, pdu.ethernet.destnation ), 1);

                        [aimObj,aimPort,conLine]=linkLayer.netObjectFinder(swListener,dstIndex); % thid function will delete later and replaced with out object
                        pdu.ethernet.destnation=aimObj.ports(aimPort).mac;

                        uniCast(swListener,aimObj,pdu,conLine,inProcPortIndex)

                    elseif swListener.ioControlFlag(5)
                        swListener.ioControlFlag(5)=0;

                        swSource.sendListener{sourcPort}.Enabled=0;
                        onSentFram(swListener,pdu);
                        swSource.sendListener{sourcPort}.Enabled=1;
                    end







                end



            end





        end




