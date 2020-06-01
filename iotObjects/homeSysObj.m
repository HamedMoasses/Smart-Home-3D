
        % as a server at home
        classdef homeSysObj <handle% dynamicprops %%
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
                MAC_Table % mac table
                ARP_Table % arp table
                handles %
                typeDevice % pc type is 1
                reciveLisener
                sendListener
                connectLine
                tagNum=1
                hpcPropfig
                recBuffer
                sendBuffer


                %% service  tab parameters
                httpTableData
                dhcpTableData
                dnsTableData
                httpOn
                httpOff
                httpsOn
                httpsOff
                dhcpOn
                dhcpOff
                dnsOn
                dnsOff
                netPoTb % table include oppen and close ports
                netAdaptorName='NobonaySaz';%for nameing of network adaptor
                dhcpServer % each pc has a dhcp server
                icmpSessTb% for saving of icmp session
                comandHistory={'C:>>'};
                comandHistPoint=1;
                ioControlFlag=zeros(1,5)% used for behavior control of packets
                QueueinProcPortIndex=[];
                browser=com.mathworks.mlwidgets.html.HTMLBrowserPanel;
                isVictim=0;

                %bit1: recived   frame  should  be droped
                %bit2: recived   frame  should  be accept    and  then    is      blocked
                %bit3: recived   frame  should  be unicast   from recived port
                %bit4: recived   frame  should  be unicast   from to      another port
                %bit5: recived   frame  should  be broadcast to   all     ports   except   recived packet
                
                
                %iot section devices
                state=0;
                lineSen;
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

            end

            events
                recived
                sent
                moving
            end

            methods % object makeing methods
                function pc=homeSysObj(pcSource_obj,actStat,pcListener1)
                    global maxMac;
                    global macPool;
                    global macReserv;
                    if actStat==0

                        %% common parameters
                        pc.name=pcSource_obj.name;
                        pc.domainName=pcSource_obj.domainName;
                        pc.string=pcSource_obj.string;
                        pc.numPorts=pcSource_obj.numPorts;
                        pc.pos=pcSource_obj.pos ;


                        %%  creat a squar switch graphically
                        pcSid=4;
                        t1=linspace(0,1,pcSid+1);
                        pcX=-sin(2*pi*t1+(pi/pcSid))*2;%node X coordinates with phaze shift
                        pcY=-cos(2*pi*t1+(pi/pcSid));%node Y coordinates with phaze shift
                        pcX=(((pcX-min(pcX))./(max(pcX)-min(pcX)))-0.5)*8;
                        pcY=(((pcY-min(pcY))./(max(pcY)-min(pcY)))-0.5)*12;

                        pcZ=pcY*0;











                        %% pcitch position
                        pc.posV.X=pc.pos.X+pcX;
                        pc.posV.Y=pc.pos.Y+pcY;
                        pc.posV.Z=pc.pos.Z+pcZ;

                        pc.httpOn=1;
                        pc.httpOff=0;
                        pc.httpsOn=1;
                        pc.httpsOff=0;
                        pc.dhcpOn=0;
                        pc.dhcpOff=1;
                        pc.dnsOn=0;
                        pc.dnsOff=1;


                        appProtName={'ftp_data','ftp','ssh','telnet','smtp','time','time_u','dns','dns','dhcp_s','dhcp_d','tftp','http',...
                            'pop3','snmp','print_srv','bgp','irc','ipx','https','https_u','login','who',...
                            'cmd','syslog','printer','irc_serv','irc_serv_u','dhcpv6_clien','dhcpv6_clien_u',...
                            'dhcpv6_serve','dhcpv6_serve_u','monitor','ftps_data','ftps','telnets','ircs','pop3s',...
                            'pop3s_u','phone','ingreslock','l2tp','pptp','remote_winso','xbox','net_device','net_device_u','wsd','wsd_u','man'}';
                        trPortName={'tcp','tcp','tcp','tcp','tcp','tcp','udp','tcp','udp','udp','udp','udp','tcp','tcp','udp','tcp','tcp',...
                            'tcp','udp','tcp','udp','tcp','udp','tcp','udp','tcp','tcp','udp','tcp',...
                            'udp','tcp','udp','udp','tcp','tcp','tcp','tcp','tcp','udp','udp','tcp','udp',...
                            'tcp','udp','tcp','tcp','udp','tcp','tcp','tcp'}';

                        trPortValue=[20,21,22,23,25,37,37,53,53,67,68,69,80,110,161,170,179,194,213,443,443,513,513,514,514,515,529,529,546,546,547,547,...
                            561,989,990,992,994,995,995,1167,1524,1701,1723,1745,3074,4350,4350,5357,5358,9535]';

                        %dhcp enabled, if incomeing frame destnation port become 68  and  outcoming frame destnation port become 67
                        %dhcp servieice enabled, if incomeing frame destnation port become 67 and  outcoming frame destnation port become 68
                        inComPort=  ([1,1,0,0,1,0,0,0,0, 0,1 ,0,1,1,1,0,0,0,0,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0])' ;
                        outComPort= ([1,1,0,0,1,0,0,1,1, 1,0 ,0,1,1,1,0,0,0,0,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0])' ;

                        pc.netPoTb=table( appProtName,  trPortName,trPortValue,inComPort,outComPort);

                        % table for catch icmp frames based on ip;
                        ip={};
                        id={};
                        pc.icmpSessTb=table(ip,id);



                        %% creat portst and initialaze each port
                        for nP=1:pcSource_obj.numPorts
                            ports(nP).name=['fa' num2str(nP-1)];
                            ports(nP).decription=[ pc.netAdaptorName ' PCIe faE Family Controller(' ports(nP).name ')'];
                            ports(nP).status=1;%up or down
                            ports(nP).bandWidth=1;%up or down
                            ports(nP).duplex=1;%up or down

                            ports(nP).inUse=0;%0= no in use, 1=in use
                            ports(nP).upDown='Down';%0= no in use, 1=in use


                            ports(nP).mac=macAddAloc;


                            ports(nP).dhcpv4=0;
                            ports(nP).poolList=[];
                            ports(nP).staticv4=1;

                            ports(nP).ip='';
                            ports(nP).subnetMask='';

                            ports(nP).dhcpv6=0;
                            ports(nP).staticv6=1;
                            ports(nP).ipv6='';
                            ports(nP).linkLocal=['FE80::' ports(nP).mac];

                            ports(nP).gatWay4='';
                            ports(nP).dns4='';

                            ports(nP).gatWay6='';
                            ports(nP).dns6='';

                        end



                        %% Arp table
                        ipAddress={};
                        hardWareAddress={};
                        interface={};
                        arp=table(ipAddress,hardWareAddress,interface);




                        %% give initialiezed ports and vlans to pcitch object
                        pc.ports=ports;% set pcitch ports
                        pc.ARP_Table=arp;% set pcitch arp table
                        pc.typeDevice=2;% pcitch type =2 server

                        %% plot pcitch with one unit dimension
                        if pc.isVictim
                            handles(1)=fill(pc.posV.X,pc.posV.Y,[0.9,0.2,0.2],'edgeColor','k','tag',['p_' pc.name]);alpha(0.5);hold on; % fill pcitch graphically and set a tag and save object in handle(1)
                        else
                            handles(1)=fill(pc.posV.X,pc.posV.Y,[0.1,0.4,0.8],'edgeColor','k','tag',['p_' pc.name]);alpha(0.5);hold on; % fill pcitch graphically and set a tag and save object in handle(1)
                        end
                        handles(2)=text(pc.pos.X,pc.pos.Y,pc.string,'tag',['t_' pc.name], 'fontSize',8);alpha(0.5);hold on% set a text on pcitch object and set a tag and save object in handle(2)
                        handles(1).addprop('fatherClass');

                        pc.colorSeting.FaceAlpha=handles(1).FaceAlpha;
                        pc.colorSeting.FaceColor=handles(1).FaceColor;

                        % give same callback funtion to both handles
                        %handles(1).ButtonDownFcn=@(graphicObj,even )moveCallBack(graphicObj,even,pc );
                        %handles(2).ButtonDownFcn=@(graphicObj,even )moveCallBack(graphicObj,even,pc );
                        %handles(1).ButtonDownFcn=@(graphicObj,even )mousClick(graphicObj,even,pc );
                        %handles(2).ButtonDownFcn=@(graphicObj,even )mousClick(graphicObj,even,pc );
                        
                        pc.handles=handles;% at the end pcitch object save all hndles
                        pc.handles(1). fatherClass=pc;
                    else



                        pcListener1.sendListener{end+1}=addlistener(pcSource_obj,'sent',@(src,event)pcListener1.onReciveFram(src,event) );
                        pcListener1.sendListener{end}.Recursive=1;
                        pc=pcListener1;
                        pc.handles(1). fatherClass=pc;


                    end

                end
            end


            methods %% propery makeing methods

                function properyPage(pcObj)
                    global toolTip;
                    delete(findobj('tag','captionText'))
                    toolTip=0;
                    pcObj.selcted=1; % when netobject is selected it become 1 else ...

                    try
                        pcObj.hpcPropfig.Tag
                        figure(pcObj.hpcPropfig)
                    catch
                        pcObj.hpcPropfig = figure('name',[ pcObj.string  '  property page' ],'NumberTitle','off','tag',pcObj.name);
                        pcObj.hpcPropfig.CloseRequestFcn=@(pcfFig,eve)onDeleteNetObj_Callback(pcfFig,eve,pcObj);



                        set(pcObj.hpcPropfig,'MenuBar','none' )
                        %set(f, 'WindowStyle','modal')

                        tgroup = uitabgroup('Parent', pcObj.hpcPropfig);

                        phisical = uitab('Parent', tgroup, 'Title', 'phisical','tag','phisical');
                        config = uitab('Parent', tgroup, 'Title', 'config','tag','config');
                        service = uitab('Parent', tgroup, 'Title', 'service','tag','service');
                        desktop = uitab('Parent', tgroup, 'Title', 'desktop','tag','desktop');
                        programing = uitab('Parent', tgroup, 'Title', 'programing','tag','programing');
                        attributes = uitab('Parent', tgroup, 'Title', 'attributes','tag','attributes');


                        %phisical tab panels


                        %% config tab panels




                        portsPanel_config = uipanel('Title','ports Panel','FontSize',12,...
                            'BackgroundColor','white',...
                            'Position',[.10 .10 .30 .90],'parent' , config,'tag','portsPanel');

                        settingPanel_config = uipanel('Title','setting Panel','FontSize',12,...
                            'BackgroundColor','white',...
                            'Position',[.42 .10 .90 .90],'parent' , config,'tag','settingPanel','Visible','on');

                        globalSettingPanel_config = uipanel('Title','global seeting','FontSize',12,...
                            'BackgroundColor','white',...
                            'Position',[.42 .10 .90 .90],'parent' , config,'tag','gl','Visible','off');

                        ipv4_config = uipanel('Title','ip configuration','FontSize',12,...
                            'BackgroundColor','white',...
                            'Position',[.02 .40 .90 .29],'parent' , settingPanel_config,'tag','ipv4_config');

                        ipv6_config = uipanel('Title','ipv6 configuration','FontSize',12,...
                            'BackgroundColor','white',...
                            'Position',[.02 .10 .90 .29],'parent' , settingPanel_config,'tag','ipv6_config');

                        %% servive tab panels
                        butPanel_service = uipanel('Title','services','FontSize',12,...
                            'BackgroundColor','white',...
                            'Position',[.05 .10 .20 .90],'parent' , service,'tag','servicBut');

                        setPanelHttp_service = uipanel('Title','HTTP','FontSize',12,...
                            'BackgroundColor','white',...
                            'Position',[.27 .10 .90 .90],'parent' , service,'tag','serviceSetHttp','Visible','on');

                        setPanelHttpN_service = uipanel('Title','','FontSize',12,...
                            'BackgroundColor','white',...
                            'Position',[.27 .10 .90 .90],'parent' , service,'tag','serviceSetHttpN','Visible','off');




                        setPanelDhcp_service = uipanel('Title','Dhcp','FontSize',12,...
                            'BackgroundColor','white',...
                            'Position',[.27 .10 .90 .90],'parent' , service,'tag','serviceSetDhcp','Visible','off');

                        setPanelDns_service = uipanel('Title','Dns','FontSize',12,...
                            'BackgroundColor','white',...
                            'Position',[.27 .10 .90 .90],'parent' , service,'tag','serviceSetDns','Visible','off');


                        httpOnOff_service = uipanel('Title','HTTP','FontSize',12,...
                            'BackgroundColor','white',...
                            'Position',[.05 .80 .35 .15],'parent' , setPanelHttp_service,'tag','httpOnOff');

                        httpsOnOff_service = uipanel('Title','HTTPs','FontSize',12,...
                            'BackgroundColor','white',...
                            'Position',[.42 .80 .37 .15],'parent' , setPanelHttp_service,'tag','httpsOnOff');

                        filMan_service = uipanel('Title','file manager','FontSize',12,...
                            'BackgroundColor','white',...
                            'Position',[.05 .10 .74 .65],'parent' , setPanelHttp_service,'tag','filMan');






                        %% desktop tab panels

                        %% desktop tab panels

                        desktopBase_Panel = uipanel('Title','','FontSize',12,'BackgroundColor','white',...
                            'Position',[0 0 1 1],'parent' , desktop,'tag','desktopBase_Panel');

                        %desktopBase_Panel  buttons
                        express=''  ;
                        desktopBackBut = uicontrol('Parent', desktopBase_Panel, 'Style', 'pushbutton', 'String', 'X', ...
                            'units','normalized','HorizontalAlignment', 'left','Position', [0.90 0.95 0.05 0.05],'tag','desktopBack','FontUnits','normalized','FontSize',0.5,'BackgroundColor',[1,1,1],'CallBack', @(cla,contr,eve)pcObj.desktopBack_Callback(cla,contr,express)) ;

                        desktopBut_Panel = uipanel('Title','','FontSize',12,'BackgroundColor','white',...
                            'Position',[0 0 1 1] ,'parent' , desktopBase_Panel,'tag','desktopBut_Panel','visible','on', 'BackgroundColor',[0.34,0.77,0.9]);

                        express=''  ;
                        desktopBut_Ip = uicontrol('Parent', desktopBut_Panel, 'Style', 'pushbutton', 'String', 'ip configration', ...
                            'units','normalized','HorizontalAlignment', 'left','Position', [0.05 0.8 0.2 0.2],'tag','dButIp','FontUnits','normalized','FontSize',0.15,'BackgroundColor',[0.7,0.7,0.6],'UserData','desktopIp_Panel','CallBack', @(cla,contr,eve)pcObj.desktop_Callback(cla,contr,express)) ;

                        express='' ;
                        desktopBut_Cmd = uicontrol('Parent', desktopBut_Panel, 'Style', 'pushbutton', 'String', 'command prompt', ...
                            'units','normalized','HorizontalAlignment', 'left','Position', [0.75 0.8 0.2 0.2],'tag','dButCmd','FontUnits','normalized','FontSize',0.15,'BackgroundColor',[0.7,0.7,0.6],'UserData','desktopCmd_Panel','CallBack', @(cla,contr,eve)pcObj.desktop_Callback(cla,contr,express)) ;

                        express='' ;
                        desktopBut_Web = uicontrol('Parent', desktopBut_Panel, 'Style', 'pushbutton', 'String', 'web browser', ...
                            'units','normalized','HorizontalAlignment', 'left','Position', [0.05 0.40 0.2 0.2],'tag','dButWeb','FontUnits','normalized','FontSize',0.15,'BackgroundColor',[0.7,0.7,0.6],'UserData','desktopWebbrow_Panel','CallBack', @(cla,contr,eve)pcObj.desktop_Callback(cla,contr,express)) ;

                        express='';
                        desktopBut_Email = uicontrol('Parent', desktopBut_Panel, 'Style', 'pushbutton', 'String', 'email', ...
                            'units','normalized','HorizontalAlignment', 'left','Position', [0.75 0.40 0.2 0.2],'tag','dButEmail','FontUnits','normalized','FontSize',0.15,'BackgroundColor',[0.7,0.7,0.6],'UserData','desktopEmail_Panel','CallBack', @(cla,contr,eve)pcObj.desktop_Callback(cla,contr,express)) ;

                        desktopIp_Panel = uipanel('Title','ip configuration','FontSize',12,'BackgroundColor','white',...
                            'Position',[.05 .05 .90 .90] ,'parent' , desktopBase_Panel,'tag','desktopIp_Panel','visible','off');

                        desktopCmd_Panel = uipanel('Title','command prompt','FontSize',12,...
                            'BackgroundColor','white',...
                            'Position',[.05 .05 .90 .90] ,'parent' , desktopBase_Panel,'tag','desktopCmd_Panel','visible','off');
                        desktopWebbrow_Panel = uipanel('Title','web browser','FontSize',12,...
                            'BackgroundColor','white',...
                            'Position',[.05 .05 .90 .90] ,'parent' , desktopBase_Panel,'tag','desktopWebbrow_Panel','visible','off');

                        desktopEmail_Panel = uipanel('Title','email','FontSize',12,...
                            'BackgroundColor','white',...
                            'Position',[.05 .05 .90 .90] ,'parent' , desktopBase_Panel,'tag','desktopEmail_Panel','visible','off');






                        settingPanel4_desktop = uipanel('Title','ip configuration','FontSize',12,...
                            'BackgroundColor','white',...
                            'Position',[.02 .50 1 .45],'parent' , desktopIp_Panel,'tag','portsPanel_desktop');

                        settingPanel6_desktop = uipanel('Title','ipv6 configuration','FontSize',12,...
                            'BackgroundColor','white',...
                            'Position',[.02 .0 1 .45],'parent' , desktopIp_Panel,'tag','settingPanel_desktop');
                        %% programin tab panels


                        %% attributes tab panels

                        %% config buttons in panel ports

                        express='defaultSettng_pcS(pcObj)';
                        globalSeeting = uicontrol('Parent', portsPanel_config, 'Style', 'pushbutton', 'String', 'global seeting', ...
                            'units','normalized','HorizontalAlignment', 'left','Position', [.10 .90 .90 .10],'tag','100','CallBack', @(cla,contr,eve)pcObj.tabButon_Callback(cla,contr,express)) ;


                        express='defaultSettng_pcS(pcObj)';
                        fa0_0 = uicontrol('Parent', portsPanel_config, 'Style', 'pushbutton', 'String', 'fasEthernet0/0', ...
                            'units','normalized','HorizontalAlignment', 'left','Position', [.10 .80 .90 .10],'tag','1','CallBack', @(cla,contr,eve)pcObj.tabButon_Callback(cla,contr,express)) ;
                        addprop(fa0_0,'inerFace');
                        fa0_0.inerFace='yes';

                        %% config labels in panel setting
                        displayNameL = uicontrol('Parent', globalSettingPanel_config, 'Style', 'text', 'String', 'display name', ...
                            'units','normalized','HorizontalAlignment', 'left','Position', [.05 .80 .20 .10],'FontSize',8) ;


                        portStatusL = uicontrol('Parent', settingPanel_config, 'Style', 'text', 'String', 'port Status', ...
                            'units','normalized','HorizontalAlignment', 'left','Position', [.05 .91 .20 .06] ,'FontSize',8) ;

                        bandWidthL = uicontrol('Parent', settingPanel_config, 'Style', 'text', 'String', 'band Width', ...
                            'units','normalized','HorizontalAlignment', 'left','Position', [.05 .84 .20 .06] ,'FontSize',8) ;
                        duplexL = uicontrol('Parent', settingPanel_config, 'Style', 'text', 'String', 'duplex', ...
                            'units','normalized','HorizontalAlignment', 'left','Position', [.05 .77 .20 .06] ,'FontSize',8) ;
                        macAddressL = uicontrol('Parent', settingPanel_config, 'Style', 'text', 'String', 'Mac Address', ...
                            'units','normalized','HorizontalAlignment', 'left','Position', [.05 .70 .20 .06] ,'FontSize',8) ;


                        ipAddressL4 = uicontrol('Parent', ipv4_config, 'Style', 'text', 'String', 'ip Address', ...
                            'units','normalized','HorizontalAlignment', 'left','Position', [.05 .25 .20 .24] ,'FontSize',8) ;
                        subnetMaskL4 = uicontrol('Parent', ipv4_config, 'Style', 'text', 'String', 'subnet Mask', ...
                            'units','normalized','HorizontalAlignment', 'left','Position', [.05 .0 .20 .24] ,'FontSize',8) ;
                        ipAddressL6 = uicontrol('Parent', ipv6_config, 'Style', 'text', 'String', 'ipv6 Address', ...
                            'units','normalized','HorizontalAlignment', 'left','Position', [.05 .25 .20 .24] ,'FontSize',8) ;
                        linkLocalL6 = uicontrol('Parent', ipv6_config, 'Style', 'text', 'String', 'linkLocalAddress', ...
                            'units','normalized','HorizontalAlignment', 'left','Position', [.05 .0 .20 .24] ,'FontSize',8) ;



                        %% labels and edit





                        %% config edits in panel setting
                        express='set(pcObj.hpcPropfig,''name'',pcObj.string);set(pcObj.handles(2),''String'',pcObj.string)';
                        displayName = uicontrol('Parent', globalSettingPanel_config, 'Style', 'edit', 'tag', 'string', ...
                            'String', pcObj.string,'units','normalized','HorizontalAlignment', 'left','Position', [.28 .80 .20 .10],'FontSize',8,'CallBack',@(cla,contr,eve)pcObj.editor_Callback(cla,contr,express)) ;




                        express='hMac=findobj(pcObj.hpcPropfig,''tag'',''mac'');   set([hMac''],''String'', uiedit.String )';
                        MacAddress = uicontrol('Parent', settingPanel_config, 'Style', 'edit', 'String','' , ...
                            'units','normalized','HorizontalAlignment', 'left','Position', [.28 .70 .20 .06] ,'FontSize',8,'tag','mac' ,'CallBack',@(cla,contr,eve)pcObj.editor_Callback(cla,contr,express) ) ;




                        express=['pdu.packetDat.sourceIp=uiedit.String; pdu.packetDat.destnationIp=uiedit.String;'...
                            '[~,dec1]=ip2IpS_dec(uiedit.String,0);[~,dec2]=ip2IpS_dec(pcObj.ports(pcObj.tagNum).ip,0);'...
                            'hIpv4=findobj(pcObj.hpcPropfig,''tag'',''ip'');'...
                            '[sIp, decIP]=ip2IpS_dec(uiedit.String);portIp=pcObj.ports(pcObj.tagNum).ip;pcObj.ports(pcObj.tagNum).ip=sIp;  set([hIpv4''],''String'', sIp );'...
                            'if ~compareIp(uiedit.String,portIp) ,'...
                            'linkLayer=tcpIp.link; linkLayer.linkOutProt(pdu,pcObj)'...
                            ',end,'];


                        ipAddress4 = uicontrol('Parent', ipv4_config, 'Style', 'edit', 'String', '', ...
                            'units','normalized','HorizontalAlignment', 'left','Position', [.28 .25 .20 .24] ,'FontSize',8,'tag','ip','CallBack',@(cla,contr,eve)pcObj.editor_Callback(cla,contr,express)) ;

                        express='hsu=findobj(pcObj.hpcPropfig,''tag'',''subnetMask'');   set([hsu''],''String'', uiedit.String )';
                        subnetMask4 = uicontrol('Parent', ipv4_config, 'Style', 'edit', 'String', '', ...
                            'units','normalized','HorizontalAlignment', 'left','Position', [.28 .0 .20 .24] ,'FontSize',8,'tag','subnetMask','CallBack',@(cla,contr,eve)pcObj.editor_Callback(cla,contr,express) ) ;

                        % ipv6
                        express='hIpv6=findobj(pcObj.hpcPropfig,''tag'',''ipv6'');   set([ hIpv6''],''String'', uiedit.String )';
                        ipAddress6 = uicontrol('Parent', ipv6_config, 'Style', 'edit', 'String', '', ...
                            'units','normalized','HorizontalAlignment', 'left','Position', [.28 .25 .40 .24] ,'FontSize',8,'tag','ipv6','CallBack',@(cla,contr,eve)pcObj.editor_Callback(cla,contr,express)) ;

                        express='hLl=findobj(pcObj.hpcPropfig,''tag'',''linLocal'');   set([ hLl''],''String'', uiedit.String )';
                        linLocal = uicontrol('Parent', ipv6_config, 'Style', 'edit', 'String', '', ...
                            'units','normalized','HorizontalAlignment', 'left','Position', [.28 .0 .40 .24] ,'FontSize',8,'tag','linLocal','CallBack',@(cla,contr,eve)pcObj.editor_Callback(cla,contr,express) ) ;

                        %% config radiobuttons in panel setting
                        %ipv4 gatWay4

                        express=['hIpv4=findobj(pcObj.hpcPropfig,''tag'',''ip'');'...
                            'hsu=findobj(pcObj.hpcPropfig,''tag'',''subnetMask'');'...
                            'hGatWay4=findobj(pcObj.hpcPropfig,''tag'',''gatWay4'');'...
                            'hDns4=findobj(pcObj.hpcPropfig,''tag'',''dns4'');'...
                            'set([hIpv4'',hsu'',hGatWay4'',hDns4''],''Enable'',''off'');'...
                            '[statIn4,statOut4,index4]=isPortOpen(pcObj,67,''udp'');'...
                            '[statIn3,statOut3,index3]=isPortOpen(pcObj,68,''udp''); '...
                            'if statOut4 &&  statIn3,'...
                            'pdu.packetDat.sourceIp=ip2IpS_dec(''0'',0);'...
                            'pdu.packetDat.destnationIp=strrep(pdu.packetDat.sourceIp,''0'',''255'');'...
                            'pdu.packetDat.SourcePort=68;'...
                            'pdu.packetDat.destinationPort=67;'...
                            'pdu.packetDat.option.dhcp=1;'...
                            'appLayer=tcpIp.application;'...
                            'pdu=dhcp(appLayer,pdu,pcObj);'...
                            'end'];
                        dhcp4_des = uicontrol('Parent', ipv4_config, 'Style', 'radiobutton', 'String', 'DHCP', ...
                            'units','normalized','HorizontalAlignment', 'left','Position', [.05 .75 .20 .24] ,'FontSize',8,'tag','dhcpv4' ,'CallBack',@(cla,contr,eve)pcObj.radioBox_Callback(cla,contr,express) ) ;
                        dhcp4_des.addprop('groupN');
                        dhcp4_des.groupN=1;
                        dhcp4_des.addprop('mather');
                        dhcp4_des.mather='port';

                        express='hIpv4=findobj(pcObj.hpcPropfig,''tag'',''ip'');hsu=findobj(pcObj.hpcPropfig,''tag'',''subnetMask'');hGatWay4=findobj(pcObj.hpcPropfig,''tag'',''gatWay4'');hDns4=findobj(pcObj.hpcPropfig,''tag'',''dns4''); set([hIpv4'',hsu'',hGatWay4'',hDns4''],''Enable'',''on'')';
                        static4 = uicontrol('Parent', ipv4_config, 'Style', 'radiobutton', 'String', 'static', ...
                            'units','normalized','HorizontalAlignment', 'left','Position', [.05 .50 .20 .24] ,'FontSize',8,'tag','staticv4' ,'CallBack',@(cla,contr,eve)pcObj.radioBox_Callback(cla,contr,express) );
                        static4.addprop('groupN');
                        static4.groupN=1;
                        static4.addprop('mather');
                        static4.mather='port';



                        express='hIpv6=findobj(pcObj.hpcPropfig,''tag'',''ipv6'');hGatWay6=findobj(pcObj.hpcPropfig,''tag'',''gatWay6'');hDns6=findobj(pcObj.hpcPropfig,''tag'',''dns6'');set([hIpv6'',hGatWay6'',hDns6''],''Enable'',''off'')';

                        dhcp6 = uicontrol('Parent', ipv6_config, 'Style', 'radiobutton', 'String', 'DHCP', ...
                            'units','normalized','HorizontalAlignment', 'left','Position', [.05 .75 .20 .24] ,'FontSize',8,'tag','dhcpv6' ,'CallBack',@(cla,contr,eve)pcObj.radioBox_Callback(cla,contr,express) );
                        dhcp6.addprop('groupN');
                        dhcp6.groupN=2;
                        dhcp6.addprop('mather');
                        dhcp6.mather='port';


                        express='hIpv6=findobj(pcObj.hpcPropfig,''tag'',''ipv6'');hGatWay6=findobj(pcObj.hpcPropfig,''tag'',''gatWay6'');hDns6=findobj(pcObj.hpcPropfig,''tag'',''dns6'');set([hIpv6'',hGatWay6'',hDns6''],''Enable'',''on'')';
                        static6 = uicontrol('Parent', ipv6_config, 'Style', 'radiobutton', 'String', 'static', ...
                            'units','normalized','HorizontalAlignment', 'left','Position', [.05 .50 .20 .24] ,'FontSize',8,'tag','staticv6' ,'CallBack',@(cla,contr,eve)pcObj.radioBox_Callback(cla,contr,express) );
                        static6.addprop('groupN');
                        static6.groupN=2;
                        static6.addprop('mather');
                        static6.mather='port';

                        %% config port setting
                        express='';
                        portStatus = uicontrol('Parent', settingPanel_config, 'Style', 'checkbox', 'String', 'on', ...
                            'units','normalized','HorizontalAlignment', 'left','Position', [.28 .91 .20 .06] ,'FontSize',8,'tag','status' ,'CallBack',@(cla,contr,eve)pcObj.checkBox_Callback(cla,contr,express) );
                        portStatus.addprop('groupN');
                        portStatus.groupN=3;
                        portStatus.addprop('mather');
                        portStatus.mather='port';

                        express='';
                        bandWidth = uicontrol('Parent', settingPanel_config, 'Style', 'checkbox', 'String', 'Auto', ...
                            'units','normalized','HorizontalAlignment', 'left','Position',[.28 .84 .20 .06] ,'FontSize',8,'tag','bandWidth' ,'CallBack',@(cla,contr,eve)pcObj.checkBox_Callback(cla,contr,express) );
                        bandWidth.addprop('groupN');
                        bandWidth.groupN=4;
                        bandWidth.addprop('mather');
                        bandWidth.mather='port';


                        express='';
                        duplex = uicontrol('Parent', settingPanel_config, 'Style', 'checkbox', 'String', 'Auto', ...
                            'units','normalized','HorizontalAlignment', 'left','Position', [.28 .77 .20 .06] ,'FontSize',8,'tag','duplex' ,'CallBack',@(cla,contr,eve)pcObj.checkBox_Callback(cla,contr,express) );
                        duplex.addprop('groupN');
                        duplex.groupN=5;
                        duplex.addprop('mather');
                        duplex.mather='port';








                        %% service http buttons

                        express= 'serviceButtonSetting(pcObj,uibutton)';
                        HTTP_1 = uicontrol('Parent', butPanel_service, 'Style', 'pushbutton', 'String', 'HTTP', ...
                            'units','normalized','HorizontalAlignment', 'left','Position', [.10 .90 .90 .10],'tag','3','CallBack', @(cla,contr,eve)pcObj.tabButon_Callback(cla,contr,express)) ;

                        express= 'serviceButtonSetting(pcObj,uibutton)';
                        DHCP_2 = uicontrol('Parent', butPanel_service, 'Style', 'pushbutton', 'String', 'DHCP', ...
                            'units','normalized','HorizontalAlignment', 'left','Position', [.10 .78 .90 .10],'tag','4' ,'CallBack', @(cla,contr,eve)pcObj.tabButon_Callback(cla,contr,express)) ;

                        express= 'serviceButtonSetting(pcObj,uibutton)';
                        DNS_3 = uicontrol('Parent', butPanel_service, 'Style', 'pushbutton', 'String', ' DNS', ...
                            'units','normalized','HorizontalAlignment', 'left','Position', [.10 .66 .90 .10],'tag','5' ,'CallBack', @(cla,contr,eve)pcObj.tabButon_Callback(cla,contr,express)) ;


                        %% service https radio buttons

                        express='[statIn,statOut,index]=isPortOpen(pcObj,80); pcObj.netPoTb.inComPort(index)=uicheckB.Value;';
                        httpOnS = uicontrol('Parent', httpOnOff_service, 'Style', 'radiobutton', 'String', 'on', ...
                            'units','normalized','HorizontalAlignment', 'left','Position', [.05 .05 .25 .95] ,'FontSize',8,'tag','httpOn','BackGroundColor',httpOnOff_service.BackgroundColor,'Value',pcObj.httpOn  ,'CallBack',@(cla,contr,eve)pcObj.radioBox_Callback(cla,contr,express) );
                        httpOnS.addprop('groupN');
                        httpOnS.groupN=6;
                        httpOnS.addprop('mather');
                        httpOnS.mather='pc';

                        express='[statIn,statOut,index]=isPortOpen(pcObj,80); pcObj.netPoTb.inComPort(index)=~uicheckB.Value;';
                        httpOffS = uicontrol('Parent', httpOnOff_service, 'Style', 'radiobutton', 'String', 'off', ...
                            'units','normalized','HorizontalAlignment', 'left','Position', [0.7 .05 .25 .95] ,'FontSize',8,'tag','httpOff','BackGroundColor',httpOnOff_service.BackgroundColor,'Value',pcObj.httpOff    ,'CallBack',@(cla,contr,eve)pcObj.radioBox_Callback(cla,contr,express) );
                        httpOffS.addprop('groupN');
                        httpOffS.groupN=6;
                        httpOffS.addprop('mather');
                        httpOffS.mather='pc';

                        express='[statIn,statOut,index]=isPortOpen(pcObj,443); pcObj.netPoTb.inComPort(index)=uicheckB.Value;';
                        httpsOnS = uicontrol('Parent', httpsOnOff_service, 'Style', 'radiobutton', 'String', 'on', ...
                            'units','normalized','HorizontalAlignment', 'left','Position', [.05 .05 .25 .95] ,'FontSize',8,'tag','httpsOn','BackGroundColor',httpOnOff_service.BackgroundColor,'Value',pcObj.httpsOn  ,'CallBack',@(cla,contr,eve)pcObj.radioBox_Callback(cla,contr,express) );
                        httpsOnS.addprop('groupN');
                        httpsOnS.groupN=7;
                        httpsOnS.addprop('mather');
                        httpsOnS.mather='pc';



                        express='[statIn,statOut,index]=isPortOpen(pcObj,80); pcObj.netPoTb.inComPort(index)=uicheckB.Value;';
                        httpsOffS = uicontrol('Parent', httpsOnOff_service, 'Style', 'radiobutton', 'String', 'off', ...
                            'units','normalized','HorizontalAlignment', 'left','Position', [0.7 .05 .25 .95] ,'FontSize',8,'tag','httpsOff','BackGroundColor',httpOnOff_service.BackgroundColor,'Value',pcObj.httpsOff   ,'CallBack',@(cla,contr,eve)pcObj.radioBox_Callback(cla,contr,express) );
                        httpsOffS.addprop('groupN');
                        httpsOffS.groupN=7;
                        httpsOffS.addprop('mather');
                        httpsOffS.mather='pc';

                        %% service http filemanager buttons
                        httpTable=uitable('Parent', filMan_service, 'units','normalized','Position',[0.20 .20 .80 .80] ,'tag','httpTable');
                        httpTable.ColumnName={'file name','edit','delete'};
                        folderPath=['netObjects/nbo32/' pcObj.name ];


                        if   isdir(folderPath) % is exist this folder
                            files=dir(folderPath);
                            fNames={files.name};
                            fNames={fNames{3:end}};
                            httpTable.Data=[];
                            for fn=1:length(fNames)
                                row={fNames{fn} ,'(edit)','(delete)'};
                                httpTable.Data=[httpTable.Data;row];

                            end
                            pcObj.httpTableData=httpTable.Data;
                            addpath(folderPath)
                        else
                            mkdir(folderPath);

                        end

                        httpTable.CellSelectionCallback=@pcObj.httpTablSelection;




                        newFileHt  = uicontrol('Parent', filMan_service, 'Style', 'pushbutton', 'String', 'new file', ...
                            'units','normalized','HorizontalAlignment', 'left','Position', [.35 .05  .20 .10],'FontSize',8, 'tag','newFile', 'backGroundColor',setPanelDhcp_service.BackgroundColor ) ;

                        importS  = uicontrol('Parent', filMan_service, 'Style', 'pushbutton', 'String', 'import', ...
                            'units','normalized','HorizontalAlignment', 'left','Position', [.65 .05  .20 .10],'FontSize',8, 'tag',' import', 'backGroundColor',setPanelDhcp_service.BackgroundColor ) ;

                        newFileHt.Callback=@pcObj.newFile;
                        importS.Callback=@pcObj.importFile;




                        %%service html file maker
                        fileNameLHt = uicontrol('Parent', setPanelHttpN_service, 'Style', 'text', 'String', 'fileName ', ...
                            'units','normalized','HorizontalAlignment', 'left','Position', [.01 .80 .15 .05] ,'FontSize',8,'backGroundColor',setPanelHttpN_service.BackgroundColor) ;


                        express='';
                        fileNameHt = uicontrol('Parent', setPanelHttpN_service, 'Style', 'edit', 'tag', 'fileNameHt', ...
                            'String','','units','normalized','HorizontalAlignment', 'left','Position', [.17 .80 .60 .05],'FontSize',8,'backGroundColor',setPanelHttpN_service.BackgroundColor,'CallBack',@(cla,contr,eve)pcObj.editor_Callback(cla,contr,express)) ;

                        express='';
                        editHt = uicontrol('Parent', setPanelHttpN_service, 'Style', 'edit', 'tag', 'editHt', ...
                            'String','','units','normalized','HorizontalAlignment', 'left','Position', [.17 .10 .60 .65],'FontSize',8, 'max',100,'backGroundColor',setPanelHttpN_service.BackgroundColor,'CallBack',@(cla,contr,eve)pcObj.editor_Callback(cla,contr,express)) ;




                        fileManageHt  = uicontrol('Parent', setPanelHttpN_service, 'Style', 'pushbutton', 'String', 'file manage', ...
                            'units','normalized','HorizontalAlignment', 'left','Position', [.17 .01  .15 .10],'FontSize',8, 'tag','fileManageHt', 'backGroundColor',setPanelDhcp_service.BackgroundColor ) ;

                        SaveHt  = uicontrol('Parent', setPanelHttpN_service, 'Style', 'pushbutton', 'String', 'save', ...
                            'units','normalized','HorizontalAlignment', 'left','Position', [.45 .01  .20 .10],'FontSize',8, 'tag',' SaveHt', 'backGroundColor',setPanelDhcp_service.BackgroundColor ) ;

                        fileManageHt.Callback=@pcObj.fileManageHtF;
                        SaveHt.Callback=@pcObj.SaveHtF;





                        %% service dns
                        dnsServiceL = uicontrol('Parent', setPanelDns_service, 'Style', 'text', 'String', ' dns service', ...
                            'units','normalized','HorizontalAlignment', 'left','Position', [.05 .90  .15 .05],'FontSize',8,'backGroundColor',setPanelDhcp_service.BackgroundColor) ;



                        express='[statIn,statOut,index_tc]=isPortOpen(pcObj,53,''tcp'');[statIn,statOut,index_ud]=isPortOpen(pcObj,53,''udp'');  pcObj.netPoTb.inComPort(index_tc)=uicheckB.Value; pcObj.netPoTb.inComPort(index_ud)=uicheckB.Value;';
                        dnsOnS = uicontrol('Parent', setPanelDns_service, 'Style', 'radiobutton', 'String', 'on', ...
                            'units','normalized','HorizontalAlignment', 'left','Position', [.25 .90 .10 .05] ,'FontSize',8,'tag','dnsOn','BackGroundColor',httpOnOff_service.BackgroundColor,'Value',pcObj.dhcpOn  ,'CallBack',@(cla,contr,eve)pcObj.radioBox_Callback(cla,contr,express) );
                        dnsOnS.addprop('groupN');
                        dnsOnS.groupN=9;
                        dnsOnS.addprop('mather');
                        dnsOnS.mather='pc';


                        express='[statIn,statOut,index_tc]=isPortOpen(pcObj,53,''tcp'');[statIn,statOut,index_ud]=isPortOpen(pcObj,53,''udp'');  pcObj.netPoTb.inComPort(index_tc)=~uicheckB.Value; pcObj.netPoTb.inComPort(index_ud)=~uicheckB.Value;';
                        dnsOffS = uicontrol('Parent', setPanelDns_service, 'Style', 'radiobutton', 'String', 'off', ...
                            'units','normalized','HorizontalAlignment', 'left','Position', [.60 .90 .10 .05] ,'FontSize',8,'tag','dnsOff','BackGroundColor',httpOnOff_service.BackgroundColor,'Value',pcObj.dhcpOff   ,'CallBack',@(cla,contr,eve)pcObj.radioBox_Callback(cla,contr,express) );
                        dnsOffS.addprop('groupN');
                        dnsOffS.groupN=9;
                        dnsOffS.addprop('mather');
                        dnsOffS.mather='pc';


                        resourceNameL = uicontrol('Parent', setPanelDns_service, 'Style', 'text', 'String', 'resource name ', ...
                            'units','normalized','HorizontalAlignment', 'left','Position', [.05 .70  .20 .05],'FontSize',8,'backGroundColor',setPanelDns_service.BackgroundColor) ;

                        resourceName = uicontrol('Parent', setPanelDns_service, 'Style', 'edit', 'String', '', ...
                            'units','normalized','HorizontalAlignment', 'left','Position', [.30 .70  .15 .05],'FontSize',8,'tag','resourceName','backGroundColor',setPanelDns_service.BackgroundColor) ;



                        typeL = uicontrol('Parent', setPanelDns_service, 'Style', 'text', 'String', 'type ', ...
                            'units','normalized','HorizontalAlignment', 'left','Position', [.58 .70  .5 .05],'FontSize',8,'backGroundColor',setPanelDns_service.BackgroundColor) ;

                        typePop = uicontrol('Parent', setPanelDns_service, 'Style', 'popUp', 'String', {'record','cname','soa','ns record'}, ...
                            'units','normalized','HorizontalAlignment', 'left','Position', [.65 .70  .15 .05],'FontSize',8,'tag','typePop') ;

                        addressDnsL = uicontrol('Parent', setPanelDns_service, 'Style', 'text', 'String', 'address ', ...
                            'units','normalized','HorizontalAlignment', 'left','Position', [.05 .60  .20 .05],'FontSize',8,'backGroundColor',setPanelDns_service.BackgroundColor) ;

                        addressDns = uicontrol('Parent', setPanelDns_service, 'Style', 'edit', 'String', '', ...
                            'units','normalized','HorizontalAlignment', 'left','Position', [.30 .60  .50 .05],'FontSize',8,'tag','addressDns','backGroundColor',setPanelDns_service.BackgroundColor) ;


                        addButDns = uicontrol('Parent', setPanelDns_service, 'Style', 'pushbutton', 'String', 'add', ...
                            'units','normalized','HorizontalAlignment', 'left','Position', [.05 .46  .20 .06],'FontSize',8, 'tag','addButDns',   'backGroundColor',setPanelDns_service.BackgroundColor ) ;

                        saveButDns  = uicontrol('Parent', setPanelDns_service, 'Style', 'pushbutton', 'String', 'save', ...
                            'units','normalized','HorizontalAlignment', 'left','Position', [.35 .46  .20 .06],'FontSize',8, 'tag','saveButDns', 'backGroundColor',setPanelDns_service.BackgroundColor ) ;

                        removButDns  = uicontrol('Parent', setPanelDns_service, 'Style', 'pushbutton', 'String', 'remove', ...
                            'units','normalized','HorizontalAlignment', 'left','Position', [.65 .46  .20 .06],'FontSize',8, 'tag','removButDns', 'backGroundColor',setPanelDns_service.BackgroundColor ) ;


                        dnsTable=uitable('Parent', setPanelDns_service, 'units','normalized','Position',[0.05 .05 .75 .40],'tag','dnsTable' );
                        dnsTable.ColumnName={'name','type','detail'};

                        dnsTable.Data=pcObj.dnsTableData;


                        addButDns.Callback=@pcObj.addServFunDns;
                        saveButDns.Callback=@pcObj.saveServFunDns;
                        removButDns.Callback=@pcObj.removeServFunDns;

                        dnsTable.CellSelectionCallback=@pcObj.dnsTableSelection;












                        %% service dhcp
                        interfaceL = uicontrol('Parent', setPanelDhcp_service, 'Style', 'text', 'String', 'interface ', ...
                            'units','normalized','HorizontalAlignment', 'left','Position', [.05 .90  .15 .05],'FontSize',8,'backGroundColor',setPanelDhcp_service.BackgroundColor) ;

                        interfaceString= get(findobj(pcObj.hpcPropfig,'inerFace','yes'),'String');
                        interfacePop = uicontrol('Parent', setPanelDhcp_service, 'Style', 'popUp', 'String', interfaceString, ...
                            'units','normalized','HorizontalAlignment', 'left','Position', [.25 .90  .15 .05],'FontSize',8) ;

                        servicL = uicontrol('Parent', setPanelDhcp_service, 'Style', 'text', 'String', 'service ', ...
                            'units','normalized','HorizontalAlignment', 'left','Position', [.45 .90  .10 .05],'FontSize',8, 'backGroundColor',setPanelDhcp_service.BackgroundColor ) ;

                        express=['[statIn3,statOut3,index3]=isPortOpen(pcObj,67,''udp''); pcObj.netPoTb.inComPort(index3)=uicheckB.Value;',...
                            '[statIn4,statOut4,index4]=isPortOpen(pcObj,68,''udp''); pcObj.netPoTb.outComPort(index4)=uicheckB.Value;'];
                        dhcpOnS = uicontrol('Parent', setPanelDhcp_service, 'Style', 'radiobutton', 'String', 'on', ...
                            'units','normalized','HorizontalAlignment', 'left','Position', [.60 .90 .10 .05] ,'FontSize',8,'tag','dhcpOn','BackGroundColor',httpOnOff_service.BackgroundColor,'Value',pcObj.dhcpOn  ,'CallBack',@(cla,contr,eve)pcObj.radioBox_Callback(cla,contr,express) );
                        dhcpOnS.addprop('groupN');
                        dhcpOnS.groupN=8;
                        dhcpOnS.addprop('mather');
                        dhcpOnS.mather='pc';









                        express=['[statIn3,statOut3,index3]=isPortOpen(pcObj,67,''udp''); pcObj.netPoTb.inComPort(index3)=~uicheckB.Value;',...
                            '[statIn4,statOut4,index4]=isPortOpen(pcObj,68,''udp''); pcObj.netPoTb.outComPort(index4)=~uicheckB.Value;'];


                        dhcpOffS = uicontrol('Parent', setPanelDhcp_service, 'Style', 'radiobutton', 'String', 'off', ...
                            'units','normalized','HorizontalAlignment', 'left','Position', [.75 .90 .10 .05] ,'FontSize',8,'tag','dhcpOff','BackGroundColor',httpOnOff_service.BackgroundColor,'Value',pcObj.dhcpOff   ,'CallBack',@(cla,contr,eve)pcObj.radioBox_Callback(cla,contr,express) );
                        dhcpOffS.addprop('groupN');
                        dhcpOffS.groupN=8;
                        dhcpOffS.addprop('mather');
                        dhcpOffS.mather='pc';


                        poolNameL = uicontrol('Parent', setPanelDhcp_service, 'Style', 'text', 'String', 'pool name ', ...
                            'units','normalized','HorizontalAlignment', 'left','Position', [.05 .83  .15 .05],'FontSize',8, 'backGroundColor',setPanelDhcp_service.BackgroundColor ) ;

                        poolName = uicontrol('Parent', setPanelDhcp_service, 'Style', 'edit', 'String', [pcObj.string ' pool' ], ...
                            'units','normalized','HorizontalAlignment', 'left','Position', [.45 .83  .40 .05],'FontSize',8, 'tag','poolName', 'backGroundColor',setPanelDhcp_service.BackgroundColor ) ;

                        GatWayServL = uicontrol('Parent', setPanelDhcp_service, 'Style', 'text', 'String', 'default gateway ', ...
                            'units','normalized','HorizontalAlignment', 'left','Position', [.05 .74  .25 .05],'FontSize',8, 'backGroundColor',setPanelDhcp_service.BackgroundColor ) ;

                        GatWayServ = uicontrol('Parent', setPanelDhcp_service, 'Style', 'edit', 'String', '', ...
                            'units','normalized','HorizontalAlignment', 'left','Position', [.45 .74  .40 .05],'FontSize',8, 'tag','GatWayServ', 'backGroundColor',setPanelDhcp_service.BackgroundColor ) ;


                        DnsServL = uicontrol('Parent', setPanelDhcp_service, 'Style', 'text', 'String', 'dns server', ...
                            'units','normalized','HorizontalAlignment', 'left','Position', [.05 .66  .25 .05],'FontSize',8, 'backGroundColor',setPanelDhcp_service.BackgroundColor ) ;

                        DnsServ = uicontrol('Parent', setPanelDhcp_service, 'Style', 'edit', 'String', '', ...
                            'units','normalized','HorizontalAlignment', 'left','Position', [.45 .66  .40 .05],'FontSize',8, 'tag','DnsServ', 'backGroundColor',setPanelDhcp_service.BackgroundColor ) ;


                        startIpL = uicontrol('Parent', setPanelDhcp_service, 'Style', 'text', 'String', 'start ip address', ...
                            'units','normalized','HorizontalAlignment', 'left','Position', [.05 .59  .25 .05],'FontSize',8, 'backGroundColor',setPanelDhcp_service.BackgroundColor ) ;

                        startIp = uicontrol('Parent', setPanelDhcp_service, 'Style', 'edit', 'String', '', ...
                            'units','normalized','HorizontalAlignment', 'left','Position', [.45 .59  .40 .05],'FontSize',8, 'tag','startIp', 'backGroundColor',setPanelDhcp_service.BackgroundColor ) ;

                        subnetMaskL = uicontrol('Parent', setPanelDhcp_service, 'Style', 'text', 'String', 'subnet mask', ...
                            'units','normalized','HorizontalAlignment', 'left','Position', [.05 .52  .25 .05],'FontSize',8, 'backGroundColor',setPanelDhcp_service.BackgroundColor ) ;

                        subnetMask  = uicontrol('Parent', setPanelDhcp_service, 'Style', 'edit', 'String', '', ...
                            'units','normalized','HorizontalAlignment', 'left','Position', [.45 .52  .40 .05],'FontSize',8, 'tag','subnetMask', 'backGroundColor',setPanelDhcp_service.BackgroundColor ) ;



                        muximumUserL = uicontrol('Parent', setPanelDhcp_service, 'Style', 'text', 'String', 'subnet mask', ...
                            'units','normalized','HorizontalAlignment', 'left','Position', [.05 .45  .25 .05],'FontSize',8, 'backGroundColor',setPanelDhcp_service.BackgroundColor ) ;

                        muximumUser  = uicontrol('Parent', setPanelDhcp_service, 'Style', 'edit', 'String', '253', ...
                            'units','normalized','HorizontalAlignment', 'left','Position', [.45 .45  .40 .05],'FontSize',8, 'tag','muximumUser', 'backGroundColor',setPanelDhcp_service.BackgroundColor ) ;


                        tftpServerL = uicontrol('Parent', setPanelDhcp_service, 'Style', 'text', 'String', 'tftp server', ...
                            'units','normalized','HorizontalAlignment', 'left','Position', [.05 .38  .25 .05],'FontSize',8, 'backGroundColor',setPanelDhcp_service.BackgroundColor ) ;

                        tftpServerL  = uicontrol('Parent', setPanelDhcp_service, 'Style', 'edit', 'String', '0.0.0.0', ...
                            'units','normalized','HorizontalAlignment', 'left','Position', [.45 .38  .40 .05],'FontSize',8, 'tag','tftpServer', 'backGroundColor',setPanelDhcp_service.BackgroundColor ) ;

                        wlcAdressL = uicontrol('Parent', setPanelDhcp_service, 'Style', 'text', 'String', 'wlc adress', ...
                            'units','normalized','HorizontalAlignment', 'left','Position', [.05 .31  .25 .05],'FontSize',8, 'backGroundColor',setPanelDhcp_service.BackgroundColor ) ;

                        wlcAdress  = uicontrol('Parent', setPanelDhcp_service, 'Style', 'edit', 'String', '0.0.0.0', ...
                            'units','normalized','HorizontalAlignment', 'left','Position', [.45 .31  .40 .05],'FontSize',8, 'tag','wlcAdress', 'backGroundColor',setPanelDhcp_service.BackgroundColor ) ;



                        addBut = uicontrol('Parent', setPanelDhcp_service, 'Style', 'pushbutton', 'String', 'add', ...
                            'units','normalized','HorizontalAlignment', 'left','Position', [.05 .23  .20 .06],'FontSize',8, 'tag','addBut',   'backGroundColor',setPanelDhcp_service.BackgroundColor ) ;

                        saveBut  = uicontrol('Parent', setPanelDhcp_service, 'Style', 'pushbutton', 'String', 'save', ...
                            'units','normalized','HorizontalAlignment', 'left','Position', [.35 .23  .20 .06],'FontSize',8, 'tag','saveBut', 'backGroundColor',setPanelDhcp_service.BackgroundColor ) ;

                        removBut  = uicontrol('Parent', setPanelDhcp_service, 'Style', 'pushbutton', 'String', 'remove', ...
                            'units','normalized','HorizontalAlignment', 'left','Position', [.65 .23  .20 .06],'FontSize',8, 'tag','removBut', 'backGroundColor',setPanelDhcp_service.BackgroundColor ) ;


                        dhcpTable=uitable('Parent', setPanelDhcp_service, 'units','normalized','Position',[0.05 .05 .90 .20],'tag','dhcpTable' );
                        dhcpTable.ColumnName={'pool name','default gateway','dns server','start ip','subnet mask','max user','tftp server','wlc address'};


                        dhcpTable.Data=pcObj.dhcpTableData;


                        addBut.Callback=@pcObj.addServFun;
                        saveBut.Callback=@pcObj.saveServFun;
                        removBut.Callback=@pcObj.removeServFun;

                        dhcpTable.CellSelectionCallback=@pcObj.dhcpTableSelection;






                        %% desktop labels
                        ipAddressL4_des = uicontrol('Parent', settingPanel4_desktop, 'Style', 'text', 'String', 'ip Address', ...
                            'units','normalized','HorizontalAlignment', 'left','Position', [.05 .62  .20 .19],'FontSize',8) ;

                        subnetMaskL4_des = uicontrol('Parent', settingPanel4_desktop, 'Style', 'text', 'String', 'subnet Mask', ...
                            'units','normalized','HorizontalAlignment', 'left','Position', [.05 .42 .20 .19] ,'FontSize',8) ;
                        defaultGateway4_des = uicontrol('Parent', settingPanel4_desktop, 'Style', 'text', 'String', 'default gateway', ...
                            'units','normalized','HorizontalAlignment', 'left','Position', [.05 .22  .20 .19] ,'FontSize',8) ;
                        dnsServer4_des = uicontrol('Parent', settingPanel4_desktop, 'Style', 'text', 'String', 'dns server', ...
                            'units','normalized','HorizontalAlignment', 'left','Position', [.05 .02  .20 .19] ,'FontSize',8) ;


                        ipAddressL6_des = uicontrol('Parent', settingPanel6_desktop, 'Style', 'text', 'String', 'ipv6 Address', ...
                            'units','normalized','HorizontalAlignment', 'left','Position', [.05 .62  .20 .19] ,'FontSize',8) ;
                        linkLocalAddressL6_des = uicontrol('Parent', settingPanel6_desktop, 'Style', 'text', 'String', 'linkLocalAddress', ...
                            'units','normalized','HorizontalAlignment', 'left','Position', [.05 .42  .20 .19] ,'FontSize',8) ;
                        defaultGatewayL6_des = uicontrol('Parent', settingPanel6_desktop, 'Style', 'text', 'String', 'ipv6 Gateway', ...
                            'units','normalized','HorizontalAlignment', 'left','Position', [.05 .22  .20 .19] ,'FontSize',8) ;
                        dnsServerL6_des = uicontrol('Parent', settingPanel6_desktop, 'Style', 'text', 'String', 'ipv6 dns Server', ...
                            'units','normalized','HorizontalAlignment', 'left','Position', [.05 .02  .20 .19] ,'FontSize',8) ;


                        %% desktop edits in panel setting
                        % ipv4

                        express=['pdu.packetDat.sourceIp=uiedit.String; pdu.packetDat.destnationIp=uiedit.String;'...
                            '[~,dec1]=ip2IpS_dec(uiedit.String,0);[~,dec2]=ip2IpS_dec(pcObj.ports(pcObj.tagNum).ip,0);'...
                            'hIpv4=findobj(pcObj.hpcPropfig,''tag'',''ip'');'...
                            '[sIp, decIP]=ip2IpS_dec(uiedit.String);portIp=pcObj.ports(pcObj.tagNum).ip;pcObj.ports(pcObj.tagNum).ip=sIp;  set([hIpv4''],''String'', sIp );'...
                            'if ~compareIp(uiedit.String,portIp) ,'...
                            'linkLayer=tcpIp.link; linkLayer.linkOutProt(pdu,pcObj)'...
                            ',end,'];

                        ipAddress4_des = uicontrol('Parent', settingPanel4_desktop, 'Style', 'edit', 'String', '', ...
                            'units','normalized','HorizontalAlignment', 'left','Position', [.28 .62  .70 .19] ,'FontSize',8,'tag','ip','CallBack',@(cla,contr,eve)pcObj.editor_Callback(cla,contr,express) ) ;

                        express='hsu=findobj(pcObj.hpcPropfig,''tag'',''subnetMask'');   set([hsu''],''String'', uiedit.String )';
                        subnetMask4_des = uicontrol('Parent', settingPanel4_desktop, 'Style', 'edit', 'String', '', ...
                            'units','normalized','HorizontalAlignment', 'left','Position', [.28 .42  .70 .19] ,'FontSize',8,'tag','subnetMask','CallBack',@(cla,contr,eve)pcObj.editor_Callback(cla,contr,express) ) ;

                        express='hIpv4=findobj(pcObj.hpcPropfig,''tag'',''gatWay4'');   [sIp,decIP]=ip2IpS_dec(uiedit.String);  set([hIpv4''],''String'', sIp )';
                        defaultGateway4_des = uicontrol('Parent', settingPanel4_desktop, 'Style', 'edit', 'String', '', ...
                            'units','normalized','HorizontalAlignment', 'left','Position', [.28 .22  .70 .19] ,'FontSize',8,'tag','gatWay4','CallBack',@(cla,contr,eve)pcObj.editor_Callback(cla,contr,express) ) ;

                        express='hDns4=findobj(pcObj.hpcPropfig,''tag'',''dns4'');   set([hDns4''],''String'', uiedit.String )';
                        dnsServer4_des = uicontrol('Parent', settingPanel4_desktop, 'Style', 'edit', 'String', '', ...
                            'units','normalized','HorizontalAlignment', 'left','Position', [.28 .02  .70 .19] ,'FontSize',8,'tag','dns4','CallBack',@(cla,contr,eve)pcObj.editor_Callback(cla,contr,express) ) ;


                        express='hIpv6=findobj(pcObj.hpcPropfig,''tag'',''ipv6'');   set([ hIpv6''],''String'', uiedit.String )';
                        ipAddress6_des = uicontrol('Parent', settingPanel6_desktop, 'Style', 'edit', 'String', '', ...
                            'units','normalized','HorizontalAlignment', 'left','Position', [.28 .62  .70 .19] ,'FontSize',8,'tag','ipv6','CallBack',@(cla,contr,eve)pcObj.editor_Callback(cla,contr,express) ) ;


                        express='hLl=findobj(pcObj.hpcPropfig,''tag'',''linLocal'');   set([ hLl''],''String'', uiedit.String )';
                        linLocal6_des = uicontrol('Parent', settingPanel6_desktop, 'Style', 'edit', 'String', '', ...
                            'units','normalized','HorizontalAlignment', 'left','Position', [.28 .42  .70 .19] ,'FontSize',8,'tag','linLocal','CallBack',@(cla,contr,eve)pcObj.editor_Callback(cla,contr,express) ) ;


                        express='hGatWay6=findobj(pcObj.hpcPropfig,''tag'',''gatWay6'');   set([ hGatWay6''],''String'', uiedit.String )';
                        defaultGateway6_des = uicontrol('Parent', settingPanel6_desktop, 'Style', 'edit', 'String', '', ...
                            'units','normalized','HorizontalAlignment', 'left','Position', [.28 .22  .70 .19] ,'FontSize',8,'tag','gatWay6','CallBack',@(cla,contr,eve)pcObj.editor_Callback(cla,contr,express) ) ;


                        express='hDns6=findobj(pcObj.hpcPropfig,''tag'',''dns6'');   set([ hDns6''],''String'', uiedit.String )';
                        dnsServer6_des = uicontrol('Parent', settingPanel6_desktop, 'Style', 'edit', 'String', '', ...
                            'units','normalized','HorizontalAlignment', 'left','Position', [.28 .02  .70 .19] ,'FontSize',8,'tag','dns6','CallBack',@(cla,contr,eve)pcObj.editor_Callback(cla,contr,express) ) ;


                        %% desktop radiobuttons in panel setting
                        express=['hIpv4=findobj(pcObj.hpcPropfig,''tag'',''ip'');'...
                            'hsu=findobj(pcObj.hpcPropfig,''tag'',''subnetMask'');'...
                            'hGatWay4=findobj(pcObj.hpcPropfig,''tag'',''gatWay4'');'...
                            'hDns4=findobj(pcObj.hpcPropfig,''tag'',''dns4'');'...
                            'set([hIpv4'',hsu'',hGatWay4'',hDns4''],''Enable'',''off'');'...
                            '[statIn4,statOut4,index4]=isPortOpen(pcObj,67,''udp'');'...
                            '[statIn3,statOut3,index3]=isPortOpen(pcObj,68,''udp''); '...
                            'if statOut4 &&  statIn3,'...
                            'pdu.packetDat.sourceIp=ip2IpS_dec(''0'',0);'...
                            'pdu.packetDat.destnationIp=strrep(pdu.packetDat.sourceIp,''0'',''255'');'...
                            'pdu.packetDat.SourcePort=68;'...
                            'pdu.packetDat.destinationPort=67;'...
                            'pdu.packetDat.option.dhcp=1;'...
                            'appLayer=tcpIp.application;'...
                            'pdu=dhcp(appLayer,pdu,pcObj);'...
                            'end'];

                        dhcp4_des = uicontrol('Parent', settingPanel4_desktop, 'Style', 'radiobutton', 'String', 'DHCP', ...
                            'units','normalized','HorizontalAlignment', 'left','Position', [.05 .82 .20 .19] ,'FontSize',8,'tag','dhcpv4' ,'CallBack',@(cla,contr,eve)pcObj.radioBox_Callback(cla,contr,express) ) ;
                        dhcp4_des.addprop('groupN');
                        dhcp4_des.groupN=1;
                        dhcp4_des.addprop('mather');
                        dhcp4_des.mather='port';



                        express='hIpv4=findobj(pcObj.hpcPropfig,''tag'',''ip'');hsu=findobj(pcObj.hpcPropfig,''tag'',''subnetMask'');hGatWay4=findobj(pcObj.hpcPropfig,''tag'',''gatWay4'');hDns4=findobj(pcObj.hpcPropfig,''tag'',''dns4''); set([hIpv4'',hsu'',hGatWay4'',hDns4''],''Enable'',''on'')';
                        static4_des = uicontrol('Parent', settingPanel4_desktop, 'Style', 'radiobutton', 'String', 'static', ...
                            'units','normalized','HorizontalAlignment', 'left','Position', [.28 .82 .20 .19] ,'FontSize',8,'tag','staticv4' ,'CallBack',@(cla,contr,eve)pcObj.radioBox_Callback(cla,contr,express) );
                        static4_des.addprop('groupN');
                        static4_des.groupN=1;
                        static4_des.addprop('mather');
                        static4_des.mather='port';


                        express='hIpv6=findobj(pcObj.hpcPropfig,''tag'',''ipv6'');hGatWay6=findobj(pcObj.hpcPropfig,''tag'',''gatWay6'');hDns6=findobj(pcObj.hpcPropfig,''tag'',''dns6'');set([hIpv6'',hGatWay6'',hDns6''],''Enable'',''off'')';
                        dhcp6_des = uicontrol('Parent', settingPanel6_desktop, 'Style', 'radiobutton', 'String', 'DHCP', ...
                            'units','normalized','HorizontalAlignment', 'left','Position', [.05 .82 .20 .19],'FontSize',8,'tag','dhcpv6' ,'CallBack',@(cla,contr,eve)pcObj.radioBox_Callback(cla,contr,express) );
                        dhcp6_des.addprop('groupN');
                        dhcp6_des.groupN=2;
                        dhcp6_des.addprop('mather');
                        dhcp6_des.mather='port';

                        express='hIpv6=findobj(pcObj.hpcPropfig,''tag'',''ipv6'');hGatWay6=findobj(pcObj.hpcPropfig,''tag'',''gatWay6'');hDns6=findobj(pcObj.hpcPropfig,''tag'',''dns6'');set([hIpv6'',hGatWay6'',hDns6''],''Enable'',''on'')';
                        static6_des = uicontrol('Parent', settingPanel6_desktop, 'Style', 'radiobutton', 'String', 'static', ...
                            'units','normalized','HorizontalAlignment', 'left','Position', [.28 .82 .20 .19] ,'FontSize',8,'tag','staticv6' ,'CallBack',@(cla,contr,eve)pcObj.radioBox_Callback(cla,contr,express) );
                        static6_des.addprop('groupN');
                        static6_des.groupN=2;
                        static6_des.addprop('mather');
                        static6_des.mather='port';


                        %%desktop desktopCmd_Panel
                        express='yes';
                        desktopComandEdi_cmd = uicontrol( 'Parent', desktopCmd_Panel,'Style', 'edit', 'String', 'C:>>', ...
                            'units','normalized','HorizontalAlignment', 'left','Position', [.0 .0  1 1] ,'FontSize',8,'max',200,'BackgroundColor','black','ForegroundColor','white','tag','desktopComandEdi_cmd', 'KeyReleaseFcn',@(cla,contr,eve)pcObj.desktopComandEdi_cmd_Callback(cla,contr,express) ) ;
                        desktopComandEdi_cmd.UserData.LineNumber=1;


                        %%desktop desktopWebbrow_Panel

                        desktopBackBut_web = uicontrol('Parent', desktopWebbrow_Panel, 'Style', 'pushbutton', 'String', '<', ...
                            'units','normalized','HorizontalAlignment', 'left','Position', [.01 .90 .05 .05],'tag','desktopBackBut_web','CallBack', @pcObj.desktopBackForBut_web_Callback) ;
                        desktopforwBut_web = uicontrol('Parent', desktopWebbrow_Panel, 'Style', 'pushbutton', 'String', '>', ...
                            'units','normalized','HorizontalAlignment', 'left','Position', [.07 .90 .05 .05],'tag','desktopforwBut_web','CallBack', @pcObj.desktopBackForBut_web_Callback) ;

                        express='';
                        desktopAddEdi_web = uicontrol('Parent', desktopWebbrow_Panel, 'Style', 'edit', 'String', '', ...
                            'units','normalized','HorizontalAlignment', 'left','Position', [.15 .90  .70 .05] ,'FontSize',8,'tag','desktopAddEdi_web' , 'CallBack',@(cla,contr,eve)pcObj.desktopAddEdi_web(cla,contr,express)) ;

                        desktopGoBut_web = uicontrol('Parent', desktopWebbrow_Panel, 'Style', 'pushbutton', 'String', 'go', ...
                            'units','normalized','HorizontalAlignment', 'left','Position', [.86 .90 .05 .05],'tag','desktopforwBut_web','CallBack', @pcObj.desktopGoBut_web) ;



                        %                 addpath(url)



                        %%desktop desktopEmail_Panel



                        %% config default setting && desktop default setting
                        pcObj.tagNum=1;
                        defaultSettng_pcS(pcObj)


                    end
                end
                function tabButon_Callback( pcObj, uibutton,~,actionScript)
                    pcObj.tagNum=str2double(uibutton.Tag);
                    eval(actionScript)
                end

                function  serviceButtonSetting(pcObj,~)

                    httpP= findobj(pcObj.hpcPropfig,'tag','serviceSetHttp');
                    dhcpP= findobj(pcObj.hpcPropfig,'tag','serviceSetDhcp');
                    dnsP= findobj(pcObj.hpcPropfig,'tag','serviceSetDns');

                    switch pcObj.tagNum
                        case 3  % http
                            set([httpP],  'Visible','on');
                            set([dhcpP,dnsP],  'Visible','off');


                            %% this code can used insted all blow code,  the blow code is dynamic but slow; httpTable=pcObj.httpTableData;
                            folderPath=['netObjects/nbo32/' pcObj.name ];
                            httpTable=findobj(pcObj.hpcPropfig,'tag','httpTable');
                            if   isdir(folderPath) % is exist this folder

                            else
                                mkdir(folderPath);
                            end
                            files=dir(folderPath);
                            fNames={files.name};
                            fNames={fNames{3:end}};
                            httpTable.Data=[];
                            for fn=1:length(fNames)
                                row={fNames{fn} ,'(edit)','(delete)'};
                                httpTable.Data=[httpTable.Data;row];

                            end
                            pcObj.httpTableData=httpTable.Data;



                        case 4 %dhcp
                            set([dhcpP],  'Visible','on')
                            set([httpP,dnsP],  'Visible','off')

                            dhcpTable=findobj(pcObj.hpcPropfig,'tag','dhcpTable');

                            dhcpTable=pcObj.dhcpTableData;


                        case 5 % dns
                            set([dnsP],  'Visible','on')
                            set([httpP,dhcpP],  'Visible','off')

                            dnsTable=findobj(pcObj.hpcPropfig,'tag','dnsTable');

                            dnsTable=pcObj.dnsTableData;


                    end




                end



                function newFile(pcObj, uicheckB,action)
                    serviceSetHttp=findobj(pcObj.hpcPropfig,'tag','serviceSetHttp');% subnet mask
                    serviceSetHttpN=findobj(pcObj.hpcPropfig,'tag','serviceSetHttpN');% subnet mask

                    set(serviceSetHttp ,'Visible','off')
                    set(serviceSetHttpN ,'Visible','on')



                end


                function importFile(pcObj, uicheckB,action)
                    try
                        [fileName, pathFile]=uigetfile();
                        filePath=[pathFile fileName];
                        folderPath=['netObjects/nbo32/' pcObj.name ];
                        copyfile(filePath,folderPath);

                        httpTable=findobj(pcObj.hpcPropfig,'tag','httpTable');
                        if   isdir(folderPath) % is exist this folder

                        else
                            mkdir(folderPath);
                        end
                        files=dir(folderPath);
                        fNames={files.name};
                        fNames={fNames{3:end}};
                        httpTable.Data=[];
                        for fn=1:length(fNames)
                            row={fNames{fn} ,'(edit)','(delete)'};
                            httpTable.Data=[httpTable.Data;row];

                        end
                        pcObj.httpTableData=httpTable.Data;
                    catch

                    end



                end



                function fileManageHtF(pcObj, uicheckB,action)
                    serviceSetHttp=findobj(pcObj.hpcPropfig,'tag','serviceSetHttp');% subnet mask
                    serviceSetHttpN=findobj(pcObj.hpcPropfig,'tag','serviceSetHttpN');% subnet mask
                    set(serviceSetHttp ,'Visible','on')
                    set(serviceSetHttpN ,'Visible','off')
                end


                function SaveHtF(pcObj, uicheckB,action)
                    folderPath=['netObjects/nbo32/' pcObj.name ];

                    if   isdir(folderPath) % is exist this folder

                    else
                        mkdir(folderPath);
                    end

                    fileN=get(findobj(pcObj.hpcPropfig,'tag','fileNameHt'),'String');%
                    if isempty(fileN)
                        fileN='index.html'; % if we dont use any name
                    end

                    % we get all file name, and if that name already used, change the file name
                    files=dir(folderPath);
                    filesName={files(3:end).name};

                    index= find(ismember(filesName,fileN));
                    if ~isempty(index)
                        splitArrey=split(filesName(index),'.');
                        fileN=[char(splitArrey(1)),num2str(length(filesName)+1),'.' char(splitArrey(2))];

                    end


                    codeN=get(findobj(pcObj.hpcPropfig,'tag','editHt'),'String');%
                    htmlFile = fopen([folderPath '/' fileN  ], 'w+' );
                    fwrite(htmlFile,codeN')
                    fclose(htmlFile);
                    httpTable=findobj(pcObj.hpcPropfig,'tag','httpTable');

                    files=dir(folderPath);
                    fNames={files.name};
                    fNames={fNames{3:end}};
                    httpTable.Data=[];
                    for fn=1:length(fNames)
                        row={fNames{fn} ,'(edit)','(delete)'};
                        httpTable.Data=[httpTable.Data;row];

                    end
                    pcObj.httpTableData=httpTable.Data;





                    serviceSetHttp=findobj(pcObj.hpcPropfig,'tag','serviceSetHttp');% subnet mask
                    serviceSetHttpN=findobj(pcObj.hpcPropfig,'tag','serviceSetHttpN');% subnet mask
                    set(serviceSetHttp ,'Visible','on')
                    set(serviceSetHttpN ,'Visible','off')

                end





                function addServFun(pcObj, uicheckB,action)

                    serviceSetDhcp=findobj(pcObj.hpcPropfig,'tag','serviceSetDhcp');
                    children=findobj(get(serviceSetDhcp,'Children'), 'style','edit');

                    dhcpTable=findobj(pcObj.hpcPropfig,'tag','dhcpTable');
                    Data= flip( get(children,'string')');
                    dhcpTable.Data=[dhcpTable.Data;Data];
                    Indices=size(dhcpTable.Data);
                    dhcpTable.UserData=Indices;
                    pcObj.dhcpTableData=dhcpTable.Data;



                end

                function saveServFun(pcObj, uicheckB,action)
                    try
                        serviceSetDhcp=findobj(pcObj.hpcPropfig,'tag','serviceSetDhcp');
                        children=flip(findobj(get(serviceSetDhcp,'Children'), 'style','edit'));
                        dhcpTable=findobj(pcObj.hpcPropfig,'tag','dhcpTable');
                        Data=  get(children,'string')';
                        Indices= dhcpTable.UserData;
                        dhcpTable.Data(Indices(1),:)=  Data;
                        pcObj.dhcpTableData=dhcpTable.Data;

                    catch
                        msgbox('please select a row','windows','modal')
                    end


                end

                function removeServFun(pcObj, uicheckB,action)
                    try
                        dhcpTable=findobj(pcObj.hpcPropfig,'tag','dhcpTable');
                        Indices= dhcpTable.UserData;
                        dhcpTable.Data( Indices(1),:)=  [];

                        serviceSetDhcp=findobj(pcObj.hpcPropfig,'tag','serviceSetDhcp');
                        children=flip(findobj(get(serviceSetDhcp,'Children'), 'style','edit'));

                        for ch= 1:length(children)
                            set( children(ch),'string', '')
                        end
                        pcObj.dhcpTableData=dhcpTable.Data;

                    catch
                        msgbox('please select a row','windows','modal')
                    end
                end

                function dhcpTableSelection(pcObj, uicheckB,action)

                    try

                        action.Source.UserData=action.Indices;

                        serviceSetDhcp=findobj(pcObj.hpcPropfig,'tag','serviceSetDhcp');
                        children=flip(findobj(get(serviceSetDhcp,'Children'), 'style','edit'));
                        dhcpTable=findobj(pcObj.hpcPropfig,'tag','dhcpTable');
                        Data= dhcpTable.Data(action.Indices(1),:);
                        for ch= 1:length(children)
                            set( children(ch),'string', Data{ch})
                        end

                    catch

                    end

                end




                function addServFunDns(pcObj, uicheckB,action)

                    serviceSetDns=findobj(pcObj.hpcPropfig,'tag','serviceSetDns');

                    chi1_s=get(findobj(serviceSetDns , 'tag','resourceName'),'string');
                    ch2_val=get(findobj(serviceSetDns , 'tag','typePop'),'Value');
                    chi3_s=get(findobj(serviceSetDns , 'tag','addressDns'),'string');
                    dnsTable=findobj(serviceSetDns,'tag','dnsTable');

                    Data={chi1_s,ch2_val,chi3_s};

                    dnsTable.Data=[dnsTable.Data;Data];
                    Indices=size(dnsTable.Data);
                    dnsTable.UserData=Indices;
                    pcObj.dnsTableData=dnsTable.Data;



                end

                function saveServFunDns(pcObj, uicheckB,action)
                    try
                        serviceSetDns=findobj(pcObj.hpcPropfig,'tag','serviceSetDns');
                        chi1_s=get(findobj(serviceSetDns , 'tag','resourceName'),'string');
                        ch2_val=get(findobj(serviceSetDns , 'tag','typePop'),'Value');
                        chi3_s=get(findobj(serviceSetDns , 'tag','addressDns'),'string');
                        dnsTable=findobj(serviceSetDns,'tag','dnsTable');
                        Data={chi1_s,ch2_val,chi3_s};
                        Indices= dnsTable.UserData;

                        dnsTable.Data(Indices(1),:)=  Data;
                        pcObj.dhcpTableData=dnsTable.Data;

                    catch
                        msgbox('please select a row','windows','modal')
                    end


                end

                function removeServFunDns(pcObj, uicheckB,action)
                    try

                        serviceSetDns=findobj(pcObj.hpcPropfig,'tag','serviceSetDns');
                        dnsTable=findobj(serviceSetDns,'tag','dnsTable');
                        Indices= dnsTable.UserData;
                        dnsTable.Data( Indices(1),:)=  [];
                        children=flip(findobj(get(serviceSetDns,'Children'), 'style','edit'));

                        for ch= 1:length(children)
                            set( children(ch),'string', '');
                        end
                        pcObj.dnsTableData=dnsTable.Data;

                    catch
                        msgbox('please select a row','windows','modal')
                    end
                end


                function dnsTableSelection(pcObj, uicheckB,action)

                    try

                        action.Source.UserData=action.Indices;

                        serviceSetDns=findobj(pcObj.hpcPropfig,'tag','serviceSetDns');
                        dnsTable=findobj(pcObj.hpcPropfig,'tag','dnsTable');
                        Data= dnsTable.Data(action.Indices(1),:);

                        set(findobj(serviceSetDns , 'tag','resourceName'),'string',Data{1});
                        set(findobj(serviceSetDns , 'tag','typePop'),'Value',Data{2});
                        set(findobj(serviceSetDns , 'tag','addressDns'),'string',Data{3});



                    catch

                    end

                end





                function httpTablSelection(pcObj, uicheckB,action)

                    try

                        action.Source.UserData=action.Indices;

                        httpTable=findobj(pcObj.hpcPropfig,'tag','httpTable');
                        folderPath=['netObjects/nbo32/' pcObj.name ];
                        switch action.Indices(2)
                            case 1

                            case 2
                                fileName= char(httpTable.Data(action.Indices(1),1));




                                fid=fopen([ folderPath '/' fileName],'r+');
                                Data = fgets(fid);
                                fclose(fid);

                                set(findobj(pcObj.hpcPropfig,'tag','fileNameHt'),'String',fileName);%
                                set(findobj(pcObj.hpcPropfig,'tag','editHt'),'String',Data);%
                                serviceSetHttp=findobj(pcObj.hpcPropfig,'tag','serviceSetHttp');% subnet mask
                                serviceSetHttpN=findobj(pcObj.hpcPropfig,'tag','serviceSetHttpN');% subnet mask

                                set(serviceSetHttp ,'Visible','off')
                                set(serviceSetHttpN ,'Visible','on')



                            case 3
                                fileName= char(httpTable.Data(action.Indices(1),1));
                                delete([ folderPath '/' fileName])
                                files=dir(folderPath);
                                fNames={files.name};
                                fNames={fNames{3:end}};
                                httpTable.Data=[];
                                for fn=1:length(fNames)
                                    row={fNames{fn} ,'(edit)','(delete)'};
                                    httpTable.Data=[httpTable.Data;row];

                                end
                                pcObj.httpTableData=httpTable.Data;




                        end



                        %
                    catch
                        %               msgbox('i dont no','windows' ,'modal')
                    end

                end







                function checkBox_Callback( pcObj, uicheckB,~,actionScript)
                    value=uicheckB.Value;
                    tag=uicheckB.Tag;
                    set(uicheckB,'Value',value);
                    eval(actionScript);
                    pcObj.ports(pcObj.tagNum).(tag)=~value;

                end

                function radioBox_Callback( pcObj, uicheckB,~,actionScript)
                    if isprop(uicheckB,'groupN')

                        if uicheckB.Value
                            value=uicheckB.Value;
                            eval(actionScript);

                        else
                            value=1;
                            eval(actionScript);

                        end

                        activedObject=findobj(pcObj.hpcPropfig,'tag',uicheckB.Tag);
                        allObject=findobj(pcObj.hpcPropfig,'groupN',uicheckB.groupN);

                        set(allObject,'Value',~value);
                        set(activedObject,'Value',value);
                        if strcmp(uicheckB.mather,'pc')
                            for in=1:length(allObject)
                                pcObj.(allObject(in).Tag)=~value;

                            end
                            pcObj.(uicheckB.Tag)=uicheckB.Value;



                        else
                            for in=1:length(allObject)
                                pcObj.ports(pcObj.tagNum).(allObject(in).Tag)=~value;

                            end
                            pcObj.ports(pcObj.tagNum).(uicheckB.Tag)=uicheckB.Value;
                        end


                    end

                end



                function editor_Callback( pcObj, uiedit,~,actionScript)
                    if  pcObj.tagNum==100
                        pcObj.(uiedit.Tag)=uiedit.String;
                        eval(actionScript);
                    else

                        eval(actionScript);
                        pcObj.ports(pcObj.tagNum).(uiedit.Tag)=uiedit.String;
                    end
                    %            set(pcObj1,'name',uiedit.String)
                end



                function desktop_Callback ( pcObj, uicheckB,~,actionScript)
                    set(findobj(pcObj.hpcPropfig,'tag','desktopBack'),'UserData',uicheckB.UserData);

                    set(findobj(pcObj.hpcPropfig,'tag',uicheckB.UserData),'Visible','on');
                    set(findobj(pcObj.hpcPropfig,'tag','desktopBut_Panel'),'Visible','off');

                end

                function desktopBack_Callback ( pcObj, uicheckB,~,actionScript)
                    set(findobj(pcObj.hpcPropfig,'tag',uicheckB.UserData),'Visible','off');
                    set(findobj(pcObj.hpcPropfig,'tag','desktopBut_Panel'),'Visible','on');

                end


                function desktopComandEdi_cmd_Callback( pcObj, uiedit,keyPressEvent,actionScript) % s used for command prompt proccessing

                    if strcmp(keyPressEvent.Key,'backspace')   && strcmp(actionScript,'yes')
                        pcObj.desktopComandEdi_cmd_Callback(  uiedit,keyPressEvent,'no')

                    end





                    %             if strcmp(keyPressEvent.Key,'backspace') &&  strcmp(actionScript,'no')
                    %                  delete(msgbox(''));
                    %                 linString=deblank(strtrim(uiedit.String(end,:)));disp(linString)
                    %                 if isempty(strfind(linString,'C:>>'))
                    % %
                    %                 if  ~isempty(strfind(linString,'C:>')) && ~isempty(strfind(linString,'C:>')==1)
                    %                     linString=deblank(strtrim(strrep( linString,'C:>','C:>>'));
                    %                     uiedit.String(end,:)=[];
                    %                     uiedit.String(end+1,1:length(linString ))=linString;
                    %                 else
                    %                     uiedit.String(end,:)=[];
                    %                     uiedit.String(end+1,1:length('C:>>' ))='C:>>';
                    %
                    %
                    %                 end
                    %                 end
                    %
                    %             end
                    %


                    if strcmp(keyPressEvent.Key,'return')   && strcmp(actionScript,'yes')
                        pcObj.desktopComandEdi_cmd_Callback(  uiedit,keyPressEvent,'no')

                    end

                    if strcmp(keyPressEvent.Key,'return') && strcmp(actionScript,'no')

                        delete(msgbox(''));
                        if isempty(strfind(uiedit.String(end,:),'C:>>'))
                            correctStr=[ deblank(strtrim(uiedit.String(end-1,:))), deblank(strtrim(uiedit.String(end,:))) ];
                            uiedit.String(end-1,1:length(correctStr))=correctStr;
                            uiedit.String(end,:)=[];
                        end
                        %
                        %                  if size(uiedit.String,1)>1
                        %                     if isempty(strfind(uiedit.String(end-1,:),'C:>>'))
                        %                      correctStr=[ deblank(strtrim(uiedit.String(end-1,:))), deblank(strtrim(uiedit.String(end,:))) ];
                        %                      uiedit.String(end-1,1:length(correctStr))=correctStr;
                        %                      uiedit.String(end,:)=[];
                        %                      end
                        %                  end



                        commandList.baseList=char({'help';'cls';'arp';'ipconfig';'ping'});
                        commandList.ipconfig=char({'ipconfig/all','ipconfig/renew','ipconfig/release'});
                        commandList.arp=char({'ipconfig/all','ipconfig/renew','ipconfig/release'});


                        st= keyPressEvent.Source;
                        lineText=strrep(st.String(end,:),'C:>>','');lineText=strtrim(lineText );
                        command=split(lineText);
                        subCommand=split(lineText,'/');


                        pcObj.comandHistory{end+1}=uiedit.String(end,:);
                        pcObj.comandHistPoint=length(pcObj.comandHistory)+1;


                        if length(subCommand)>=2 && strcmp(char(subCommand(2)),'')
                            comandType=strtrim(char(subCommand(1)));

                            uiedit.String(end+1:end+size(char(commandList.(comandType)),1),1:size(char(commandList.(comandType)),2))=char(commandList.(comandType));

                            uiedit.String(end+1,1:length( 'C:>>' ))='C:>>';


                        else
                            comandType=strtrim(char(command(1)));


                            switch comandType
                                case {'help' ,'?'}
                                    uiedit.String(end+1:end+size(char(commandList.baseList),1),1:size(char(commandList.baseList),2))=char(commandList.baseList);

                                    uiedit.String(end+1,1:length( 'C:>>' ))='C:>>';


                                case 'cls'
                                    uiedit.String='C:>>';


                                case 'arp'

                                    arpTable=pcObj.ARP_Table;

                                    ip=['ipAddress           ';'----------------------';arpTable.ipAddress];
                                    hw=['hardWareAddress     ';'----------------------';arpTable.hardWareAddress];
                                    in=['interface           ';'----------------------';arpTable.interface];

                                    arpTaRes=[char(ip)  char(hw) char(in)];
                                    uiedit.String(end+1:end+size(arpTaRes,1),1:size(arpTaRes,2))=arpTaRes;



                                    uiedit.String(end+1,1:length( 'C:>>' ))='C:>>';


                                case 'ipconfig'

                                    ipconfig= {['Connection-specific DNS Suffix  . : '  pcObj.ports(1).dns4];...
                                        ['Link-local IPv6 Address . . . . . : ' pcObj.ports.linkLocal];...
                                        ['IPv4 Address. . . . . . . . . . . : ' pcObj.ports.ip];...
                                        ['Subnet Mask . . . . . . . . . . . : ' pcObj.ports.subnetMask];...
                                        ['Default Gateway . . . . . . . . . : ' pcObj.ports.gatWay4]};
                                    ipconfig=char(ipconfig);
                                    uiedit.String(end+1:end+size(char(ipconfig),1),1:size(char(ipconfig),2))=char(ipconfig);


                                    uiedit.String(end+1,1:length( 'C:>>' ))='C:>>';


                                case {'ipconfig /all' ,'ipconfig/all'}

                                    [statIn4,statOut4,index4]=isPortOpen(pcObj,67,'udp');%dhcp (dhcp server port)
                                    [statIn3,statOut3,index3]=isPortOpen(pcObj,68,'udp');%dhcp (dhcp client port)
                                    if (statOut4 && statIn3)
                                        yesNo='yes';
                                    else
                                        yesNo='no';
                                    end

                                    dtTim=datetime;LeaseObtained=char(dtTim );
                                    dtTim.Day=dtTim.Day+3; LeaseExpires=char(dtTim);



                                    ipconfig={['Windows IP Configuration'];...
                                        ['Host Name . . . . . . . . . . . . :' pcObj.name];...
                                        ['Primary Dns Suffix  . . . . . . . :'];...
                                        ['Node Type . . . . . . . . . . . . :' 'Hybrid'];...
                                        ['IP Routing Enabled. . . . . . . . :' 'No'];...
                                        ['WINS Proxy Enabled. . . . . . . . :' 'No'];...
                                        ['DNS Suffix Search List. . . . . . :' pcObj.ports.outObj.ports(pcObj.ports.outObj.gatePort).outObj.name];...
                                        ['Ethernet adapter Local Area Connection:'];...
                                        ['Connection-specific DNS Suffix  . :' pcObj.ports(1).dns4  ];...
                                        ['Description . . . . . . . . . . . :' pcObj.ports(1).decription];...
                                        ['Physical Address. . . . . . . . . :' pcObj.ports(1).mac];...
                                        ['DHCP Enabled. . . . . . . . . . . :' yesNo];...
                                        ['Autoconfiguration Enabled . . . . :' 'Yes'];...
                                        ['Link-local IPv6 Address . . . . . :' pcObj.ports(1).linkLocal ];...
                                        ['IPv4 Address. . . . . . . . . . . :' pcObj.ports(1).ip ];...
                                        ['Subnet Mask . . . . . . . . . . . :' pcObj.ports(1).subnetMask];...
                                        ['Lease Obtained. . . . . . . . . . :' LeaseObtained];...
                                        ['Lease Expires . . . . . . . . . . :' LeaseExpires];...
                                        ['Default Gateway . . . . . . . . . :' pcObj.ports(1).gatWay4];...
                                        ['DHCP Server . . . . . . . . . . . :' pcObj.dhcpServer];...
                                        ['DHCPv6 IAID . . . . . . . . . . . :' '...'];...
                                        ['DHCPv6 Client DUID. . . . . . . . :' '...'];...
                                        ['DNS Servers . . . . . . . . . . . :' pcObj.ports(1).dns4];...
                                        ['NetBIOS over Tcpip. . . . . . . . :' 'diabled']};

                                    ipconfig=char(ipconfig);
                                    uiedit.String(end+1:end+size(char(ipconfig),1),1:size(char(ipconfig),2))=char(ipconfig);


                                    uiedit.String(end+1,1:length( 'C:>>' ))='C:>>';


                                case 'ping'
                                    internetLayer= tcpIp.internet;
                                    pdu.packetDat.sourceIp=pcObj.ports.ip;
                                    try
                                        [ipStan,ipDec]=ip2IpS_dec(char(command(2)),0,'sub');%control that ip is right
                                        if ipDec
                                            pdu.packetDat.destnationIp=ipStan;

                                        else
                                            uiedit.String(end+1,1:length( 'give a right ip' ))='give a right ip';
                                            uiedit.String(end+1,1:length( 'C:>>' ))='C:>>';

                                            return  ;
                                        end

                                        pdu.packetDat.data='';
                                    catch
                                        uiedit.String(end+1,1:length( 'give a right ip' ))='give a right ip';
                                        uiedit.String(end+1,1:length( 'C:>>' ))='C:>>';

                                        return  ;
                                    end

                                    try
                                        indexValue=ismember(pcObj.icmpSessTb.ip,pdu.packetDat.destnationIp) ;
                                        index=find(indexValue);
                                        id=pcObj.icmpSessTb.id{index};

                                        id=id+1;
                                        pcObj.icmpSessTb.id{index}=id;
                                    catch
                                        id=1;
                                        pcObj.icmpSessTb=[pcObj.icmpSessTb;{pdu.packetDat.destnationIp,[id]}];

                                    end


                                    pdu.packetDat.seqNumber=randi([10^2,10^3],1);% it is incremnted 1 for each reques and reply
                                    pdu.packetDat.id=id;
                                    domainName='';
                                    str1=['Pinging' domainName '[' pdu.packetDat.destnationIp '] with 32 bytes of data:'];
                                    uiedit.String(end+1,1:length( str1 ))=str1;

                                    recPacket=0;
                                    lostPacket=0;
                                    timArrey=[];
                                    semdPackNum=4;
                                    for pinNum=1:semdPackNum

                                        tic;
                                        internetLayer.icmp(pdu,pcObj,'ip');
                                        TimeSpent=toc;

                                        if isfield(pcObj.sendBuffer.pdu,'icmp') && isfield(pcObj.recBuffer.pdu,'icmp') &&  pcObj.sendBuffer.pdu.icmp.seqNumber==pcObj.sendBuffer.pdu.icmp.seqNumber && pcObj.sendBuffer.pdu.icmp.seqNumber ==pdu.packetDat.seqNumber
                                            icmpMessage=['Reply from' pdu.packetDat.destnationIp ': bytes=32 time=' num2str(TimeSpent) ' ms TTL= '  num2str(pcObj.recBuffer.pdu.ip.TTl) ];
                                            uiedit.String(end+1,1:length( icmpMessage ))=icmpMessage;

                                            pdu.packetDat.seqNumber=pdu.packetDat.seqNumber+1;
                                            recPacket=recPacket+1;
                                            timArrey(end+1)=TimeSpent;
                                        else
                                            icmpMessage='Request timed out.';
                                            uiedit.String(end+1,1:length( icmpMessage ))=icmpMessage;

                                            pdu.packetDat.seqNumber=pdu.packetDat.seqNumber+1;
                                            lostPacket=lostPacket+1;

                                        end
                                    end




                                    icmpMessageFinal= {['Ping statistics for : ' pdu.packetDat.destnationIp];...
                                        [' Packets: Sent: ' num2str(semdPackNum)  ' Packets: Received: ' num2str(recPacket) ' Packets: lost: ' num2str(lostPacket) ];...
                                        ['Approximate round trip times in milli-seconds:'];...
                                        ['Minimum = ' num2str(min(timArrey)) ' ms Maximum = ' num2str(max(timArrey)) ' ms Average = ' num2str(mean(timArrey)) ' ms' ]};
                                    icmpMessageFinal=char(icmpMessageFinal);
                                    uiedit.String(end+2:end+1+size(char(icmpMessageFinal),1),1:size(char(icmpMessageFinal),2))=char(icmpMessageFinal);




                                    uiedit.String(end+2,1:length( 'C:>>' ))='C:>>';


                                otherwise
                                    if ~isempty(comandType)
                                        errorM=[lineText ': is not recognized as an internal or external command'];
                                        uiedit.String(end+1,1:length( errorM ))=errorM;
                                    end


                                    uiedit.String(end+1,1:length( 'C:>>' ))='C:>>';


                            end
                        end




                    end


                    if (strcmp(keyPressEvent.Key,'uparrow') ||  strcmp(keyPressEvent.Key,'downarrow'))   && strcmp(actionScript,'yes')
                        pcObj.desktopComandEdi_cmd_Callback(  uiedit,keyPressEvent,'no')

                    end

                    if (strcmp(keyPressEvent.Key,'uparrow') ||  strcmp(keyPressEvent.Key,'downarrow'))   && strcmp(actionScript,'no')
                        delete(msgbox(''));
                        switch keyPressEvent.Key

                            case 'uparrow'

                                pcObj.comandHistPoint=pcObj.comandHistPoint-1;
                                if  pcObj.comandHistPoint==0
                                    pcObj.comandHistPoint=1;
                                end





                                str=deblank(strtrim(pcObj.comandHistory{pcObj.comandHistPoint}));
                                uiedit.String(end,:)=[];
                                uiedit.String(end+1,1:length(str ))=str;


                            case 'downarrow'


                                pcObj.comandHistPoint=pcObj.comandHistPoint+1;
                                if  pcObj.comandHistPoint> length(pcObj.comandHistory)
                                    pcObj.comandHistPoint=length(pcObj.comandHistory);
                                end




                                str=deblank(strtrim(pcObj.comandHistory{pcObj.comandHistPoint}));
                                uiedit.String(end,:)=[];
                                uiedit.String(end+1,1:length(str ))=str;


                        end

                        editCommandLine= split(uiedit.String(end,:));

                        if   isempty(strfind(char(editCommandLine(1)),'C:>>'))
                            uiedit.String(end,1:length(['C:>>' uiedit.String(end,:)]))=strtrim(['C:>>' uiedit.String(end,:)]);
                        end

                    end



                    %
                end


                function desktopBackForBut_web_Callback ( pcObj, uicheckB,~,actionScript) %desktop back button from childeren panels callback
                    disp('');
                end


                function desktopAddEdi_web ( pcObj, uicheckB,~,actionScript) %desktop back button from childeren panels callback
                    disp('');

                end


                function desktopGoBut_web( pcObj, uicheckB,~,actionScript) %desktop back button from childeren panels callback



                    pdu.packetDat=[];
                    desktopAddEdi_web=findobj(pcObj.hpcPropfig,'tag','desktopAddEdi_web');
                    desktopAddEdi_web.String=strrep(desktopAddEdi_web.String,' ','');

                    if length(split(desktopAddEdi_web.String,'.'))<3
                        msgbox('this is not valid addrese','windows','modal');
                        return;
                    end

                    pdu.packetDat.SourcePort=randi([1025,65535],1);
                    https=~isempty(strfind(desktopAddEdi_web.String,'https://'));
                    http=~isempty(strfind(desktopAddEdi_web.String,'http://'));
                    if   http + https
                        if https
                            pdu.packetDat.destinationPort=443;
                        else
                            pdu.packetDat.destinationPort=80;
                        end

                    else

                        desktopAddEdi_web.String=['http://' desktopAddEdi_web.String];
                        pdu.packetDat.destinationPort=80;

                    end

                    pdu.packetDat.fullAdd=desktopAddEdi_web.String;


                    appLayer= tcpIp.application;
                    appLayer.http(pdu,pcObj) ;



                end





                function portNum=getPort(pcObj,portName)
                    portNum=find(strcmp({pcObj.ports.name},portName));
                end

            end

            methods %% event methods

                function onMoving(pcSource )
                    notify(pcSource,'moving');
                end


                function  onSentFram(pcSource,pdu)
                    pdu=orderfields(pdu, length(fieldnames(pdu)):-1:1);

                    if ~isempty(pdu)
                        eventDat=dataFram(pdu);
                        ed=[pcSource.connectLine{:}] ;
                        handl=[ed.handles];handl=handl(1,:);

                        %                         conLine.x= {pcSource.connectLine{:}   };
                        conLine.x= {handl.XData};
                        conLine.y={handl.YData};

                        for revInd=1:length(conLine.x)
                            if  pcSource.connectLine{revInd}.rev(pcSource.typeDevice)==1
                                conLine.x{revInd}=flip( conLine.x{revInd});
                                conLine.y{revInd}=flip( conLine.y{revInd});
                            end


                            destObjName=strrep(pcSource.connectLine{revInd}.name,[pcSource.name,'l_l'],'');
                            pchetResource.name{revInd}=['pk_' strrep(destObjName,['l_l' pcSource.name],'')];


                        end

                        pchetResource.conLine=conLine;

                        packetPathShell(pchetResource,pdu,pcSource);
                        pcSource.sendBuffer.pdu=pdu;

                        inUseIntIndex=find([pcSource.ports.inUse]==1);
                        netObjIpS={pcSource.ports(inUseIntIndex).mac};
                        portNum=find(ismember(netObjIpS,pdu.ethernet.source));
                        pcSource.sendBuffer.inProcPortIndex=portNum;




                        notify(pcSource,'sent',eventDat);
                    end
                    tf2 = event.hasListener(pcSource,'sent');


                end



                function  onReciveFram(pcListener,pcSource,eventData)
                    pdu= eventData.pdu;

                    pcListener.recBuffer.pdu=pdu;
                    %             pcSource.connectLine{2}=pcSource.connectLine{1};
                    portTagS=[pcListener.connectLine{:}];
                    portTagS={portTagS.name};

                    portF1=find(cell2mat(cellfun(@strcmp, portTagS,repmat({[pcSource.name 'l_l' pcListener.name]},1,length(portTagS)),'UniformOutput' , false)));
                    portF2=find(cell2mat([cellfun(@strcmp, portTagS,repmat({[pcListener.name 'l_l' pcSource.name]},1,length(portTagS)),'UniformOutput' , false)]));
                    if ~isempty(portF1)
                        connectL= pcListener.connectLine{portF1};
                        sourcPort=connectL.conPorts{1};
                        inProcPortIndex=connectL.conPorts{2};
                    else
                        connectL= pcListener.connectLine{portF2};
                        sourcPort=connectL.conPorts{2};
                        inProcPortIndex=connectL.conPorts{1}; % port that frame recived from that

                    end
                    pcListener.recBuffer.inProcPortIndex=inProcPortIndex;


                    pcListener.QueueinProcPortIndex(end+1)=inProcPortIndex;
                    linkLayer=tcpIp.link;
                    pdu=linkLayer.linkProt(pdu,pcListener);
                    pcListener.QueueinProcPortIndex(end)=[];
                    %bit1: recived   frame  should  be droped
                    %bit2: recived   frame  should  be accept    and  then    is      blocked
                    %bit3: recived   frame  should  be unicast   from recived port
                    %bit4: recived   frame  should  be unicast   from to      another port
                    %bit5: recived   frame  should  be broadcast to   all     ports   except   recived packet




                    if pcListener.ioControlFlag(1)
                        pcListener.ioControlFlag(1)=0;
                        dropAccept(pcListener,'dr');

                    elseif pcListener.ioControlFlag(2)
                        pcListener.ioControlFlag(2)=0;

                        dropAccept(pcListener,'ac');

                    elseif pcListener.ioControlFlag(3)
                        pcListener.ioControlFlag(3)=0;
                        if isfield(pdu,'packetDat')
                            pdu=rmfield(pdu,'packetDat');
                        end
                        aimPort=pcListener.ports(inProcPortIndex).outport;
                        aimObj=pcListener.ports(inProcPortIndex).outObj;
                        if aimObj.sendListener{aimPort}.Enabled==0
                            aimObj.sendListener{aimPort}.Enabled=1;
                        end
                        conLine.x={[pcListener.pos.X,aimObj.pos.X]};
                        conLine.y={[pcListener.pos.Y,aimObj.pos.Y]};

                        uniCast(pcListener,aimObj,pdu,conLine,inProcPortIndex)

                    elseif pcListener.ioControlFlag(4)
                        pcListener.ioControlFlag(4)=0;
                        % this section only used for router and switch


                    elseif pcListener.ioControlFlag(5)
                        pcListener.ioControlFlag(5)=0;

                        %                         pcListener.sendListener{sourcPort}.Enabled=0;
                        onSentFram(pcListener,pdu);
                        %                         pcListener.sendListener{sourcPort}.Enabled=1;
                    end








                end




            end





        end





