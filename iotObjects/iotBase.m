
        classdef iotBase <handle% dynamicprops %%
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
                netPoTb % table include oppen and close ports
                netAdaptorName='NobonaySaz';%for nameing of network adaptor
                dhcpServer % each pc has a dhcp server
                icmpSessTb% for saving of icmp session
                comandHistory={'C:>>'};
                comandHistPoint=1;
                ioControlFlag=zeros(1,5)% used for behavior control of packets
                QueueinProcPortIndex=[];
                isVictim=0;
                browser= com.mathworks.mlwidgets.html.HTMLBrowserPanel;

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
                function pc=iotBase(pcSource_obj,actStat,pcListener1)
                    global maxMac;
                    global macPool;
                    global macReserv;
                    if actStat==0

                        %% common parameters
                        pc.name=pcSource_obj.name;
                        pc.isVictim=pcSource_obj.isVictim;
                        pc.domainName=pcSource_obj.domainName;
                        pc.string=pcSource_obj.string; 
                        pc.numPorts=pcSource_obj.numPorts;
                        pc.pos=pcSource_obj.pos ;

                        
                        %%  creat a squar pcitch graphically
                        pcSid=4;
                        t1=linspace(0,1,pcSid+1);
                        pcX=-sin(2*pi*t1+(pi/pcSid))*2;%node X coordinates with phaze shift
                        pcY=-cos(2*pi*t1+(pi/pcSid));%node Y coordinates with phaze shift
                        pcX=(((pcX-min(pcX))./(max(pcX)-min(pcX)))-0.5)*10;
                        pcY=(((pcY-min(pcY))./(max(pcY)-min(pcY)))-0.5)*10;
                        [pcX,pcY]=divider(pcX,pcY,2);

                        pcX([1 ,10:13])=pcX([1 ,10:13 ])-max(pcX([1 ,10:13]));
                        pcX(end+1:end+11)=pcX([1:2,9:13,1,2,9,10]);
                        pcY(end+1:end+11)=pcY([1:2,9:13,1,2,9,10]);
                        pcZ=pcY*0;
                        
                        %% pcitch position

                        pc.posV.X=pc.pos.X+pcX;
                        pc.posV.Y=pc.pos.Y+pcY;
                        pc.posV.Z=pc.pos.Z+pcZ;


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

                             %mac making
                            
                            ports(nP).mac=macAddAloc;

                            
                            ports(nP).dhcpv4=0;
                            ports(nP).staticv4=1;
                            
                            ports(nP).ip='';
                            ports(nP).subnetMask='';
                            ports(nP).broadcastAddress='';

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
                        pc.typeDevice=1;% pcitch type =1

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
                        %
                        %handles(1).ButtonDownFcn=@(graphicObj,even )mousClick(graphicObj,even,pc );
                        %handles(2).ButtonDownFcn=@(graphicObj,even )mousClick(graphicObj,even,pc );
                        %
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
                pcObj.browser= com.mathworks.mlwidgets.html.HTMLBrowserPanel;

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
                        
                        phisical = uitab('Parent', tgroup, 'Title', 'phisical');
                        config = uitab('Parent', tgroup, 'Title', 'config');
                        desktop = uitab('Parent', tgroup, 'Title', 'desktop');
                        programing = uitab('Parent', tgroup, 'Title', 'programing');
                        attributes = uitab('Parent', tgroup, 'Title', 'attributes');
                        
                        
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
                        
                        ipv6_config = uipanel('Title','ipv6 configuration','FontSize',12,'BackgroundColor','white',...
                            'Position',[.02 .10 .90 .29],'parent' , settingPanel_config,'tag','ipv6_config');
                        
                        
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
                        
                        desktopBut_ColiGate = uicontrol('Parent', desktopBut_Panel, 'Style', 'pushbutton', 'String', 'ColiGate', ...
                            'units','normalized','HorizontalAlignment', 'left','Position', [0.05 0.00 0.2 0.2],'tag','dButColiGate','FontUnits','normalized','FontSize',0.15,'BackgroundColor',[0.7,0.7,0.6],'UserData','desktopColiGate_Panel','CallBack', @(cla,contr,eve)pcObj.desktop_Callback(cla,contr,express)) ;
                        
%                         delete(desktopBut_ColiGate)
                        
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
                        
                        
                        desktopColiGate_Panel = uipanel('Title','ColiGate','FontSize',12,...
                            'BackgroundColor','white',...
                            'Position',[.05 .05 .90 .90] ,'parent' , desktopBase_Panel,'tag','desktopColiGate_Panel','visible','off');
                        
                        
                        
                        settingPanel4_desktop = uipanel('Title','ip configuration','FontSize',12,...
                            'BackgroundColor','white',...
                            'Position',[.02 .50 1 .45],'parent' , desktopIp_Panel,'tag','portsPanel_desktop');
                        
                        settingPanel6_desktop = uipanel('Title','ipv6 configuration','FontSize',12,...
                            'BackgroundColor','white',...
                            'Position',[.02 .0 1 .45],'parent' , desktopIp_Panel,'tag','settingPanel_desktop');
                        
                        %% programing tab panels
                        
                        
                        %% attributes tab panels
                        
                        %% config buttons in panel ports
                        
                        globalSeeting = uicontrol('Parent', portsPanel_config, 'Style', 'pushbutton', 'String', 'global seeting', ...
                            'units','normalized','HorizontalAlignment', 'left','Position', [.10 .90 .90 .10],'tag','100','CallBack', @pcObj.tabButon_Callback) ;
                        
                        fa0_0 = uicontrol('Parent', portsPanel_config, 'Style', 'pushbutton', 'String', 'fasEthernet0/0', ...
                            'units','normalized','HorizontalAlignment', 'left','Position', [.10 .80 .90 .10],'tag','1','CallBack', @pcObj.tabButon_Callback) ;
                        
                        
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
                            'if ~compareIp(uiedit.String,portIp),'...
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
                            'pdu.packetDat.sourceIp=makeIp(''min'');'...
                            'pdu.packetDat.destnationIp=makeIp(''max'');'...
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
                        
                        
                        express='hIpv4=findobj(pcObj.hpcPropfig,''tag'',''ip'');hsu=findobj(pcObj.hpcPropfig,''tag'',''subnetMask'');hGatWay4=findobj(pcObj.hpcPropfig,''tag'',''gatWay4'');hDns4=findobj(pcObj.hpcPropfig,''tag'',''dns4''); set([hIpv4'',hsu'',hGatWay4'',hDns4''],''Enable'',''on'')';
                        static4 = uicontrol('Parent', ipv4_config, 'Style', 'radiobutton', 'String', 'static', ...
                            'units','normalized','HorizontalAlignment', 'left','Position', [.05 .50 .20 .24] ,'FontSize',8,'tag','staticv4' ,'CallBack',@(cla,contr,eve)pcObj.radioBox_Callback(cla,contr,express) );
                        static4.addprop('groupN');
                        static4.groupN=1;
                        
                        
                        express='hIpv6=findobj(pcObj.hpcPropfig,''tag'',''ipv6'');hGatWay6=findobj(pcObj.hpcPropfig,''tag'',''gatWay6'');hDns6=findobj(pcObj.hpcPropfig,''tag'',''dns6'');set([hIpv6'',hGatWay6'',hDns6''],''Enable'',''off'')';
                        
                        dhcp6 = uicontrol('Parent', ipv6_config, 'Style', 'radiobutton', 'String', 'DHCP', ...
                            'units','normalized','HorizontalAlignment', 'left','Position', [.05 .75 .20 .24] ,'FontSize',8,'tag','dhcpv6' ,'CallBack',@(cla,contr,eve)pcObj.radioBox_Callback(cla,contr,express) );
                        dhcp6.addprop('groupN');
                        dhcp6.groupN=2;
                        
                        
                        express='hIpv6=findobj(pcObj.hpcPropfig,''tag'',''ipv6'');hGatWay6=findobj(pcObj.hpcPropfig,''tag'',''gatWay6'');hDns6=findobj(pcObj.hpcPropfig,''tag'',''dns6'');set([hIpv6'',hGatWay6'',hDns6''],''Enable'',''on'')';
                        static6 = uicontrol('Parent', ipv6_config, 'Style', 'radiobutton', 'String', 'static', ...
                            'units','normalized','HorizontalAlignment', 'left','Position', [.05 .50 .20 .24] ,'FontSize',8,'tag','staticv6' ,'CallBack',@(cla,contr,eve)pcObj.radioBox_Callback(cla,contr,express) );
                        static6.addprop('groupN');
                        static6.groupN=2;
                        
                        
                        %% config port setting
                        express='';
                        portStatus = uicontrol('Parent', settingPanel_config, 'Style', 'checkbox', 'String', 'on', ...
                            'units','normalized','HorizontalAlignment', 'left','Position', [.28 .91 .20 .06] ,'FontSize',8,'tag','status' ,'CallBack',@(cla,contr,eve)pcObj.checkBox_Callback(cla,contr,express) );
                        portStatus.addprop('groupN');
                        portStatus.groupN=3;
                        
                        
                        express='';
                        bandWidth = uicontrol('Parent', settingPanel_config, 'Style', 'checkbox', 'String', 'Auto', ...
                            'units','normalized','HorizontalAlignment', 'left','Position',[.28 .84 .20 .06] ,'FontSize',8,'tag','bandWidth' ,'CallBack',@(cla,contr,eve)pcObj.checkBox_Callback(cla,contr,express) );
                        bandWidth.addprop('groupN');
                        bandWidth.groupN=4;
                        
                        
                        express='';
                        duplex = uicontrol('Parent', settingPanel_config, 'Style', 'checkbox', 'String', 'Auto', ...
                            'units','normalized','HorizontalAlignment', 'left','Position', [.28 .77 .20 .06] ,'FontSize',8,'tag','duplex' ,'CallBack',@(cla,contr,eve)pcObj.checkBox_Callback(cla,contr,express) );
                        duplex.addprop('groupN');
                        duplex.groupN=5;
                        
                        
                        %% desktop desktopIp_Panel
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
                            'pdu.packetDat.sourceIp=makeIp(''min'');'...
                            'pdu.packetDat.destnationIp=makeIp(''max'');'...
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
                        
                        express='hIpv4=findobj(pcObj.hpcPropfig,''tag'',''ip'');hsu=findobj(pcObj.hpcPropfig,''tag'',''subnetMask'');hGatWay4=findobj(pcObj.hpcPropfig,''tag'',''gatWay4'');hDns4=findobj(pcObj.hpcPropfig,''tag'',''dns4''); set([hIpv4'',hsu'',hGatWay4'',hDns4''],''Enable'',''on'')';
                        static4_des = uicontrol('Parent', settingPanel4_desktop, 'Style', 'radiobutton', 'String', 'static', ...
                            'units','normalized','HorizontalAlignment', 'left','Position', [.28 .82 .20 .19] ,'FontSize',8,'tag','staticv4' ,'CallBack',@(cla,contr,eve)pcObj.radioBox_Callback(cla,contr,express) );
                        static4_des.addprop('groupN');
                        static4_des.groupN=1;
                        
                        
                        express='hIpv6=findobj(pcObj.hpcPropfig,''tag'',''ipv6'');hGatWay6=findobj(pcObj.hpcPropfig,''tag'',''gatWay6'');hDns6=findobj(pcObj.hpcPropfig,''tag'',''dns6'');set([hIpv6'',hGatWay6'',hDns6''],''Enable'',''off'')';
                        dhcp6_des = uicontrol('Parent', settingPanel6_desktop, 'Style', 'radiobutton', 'String', 'DHCP', ...
                            'units','normalized','HorizontalAlignment', 'left','Position', [.05 .82 .20 .19],'FontSize',8,'tag','dhcpv6' ,'CallBack',@(cla,contr,eve)pcObj.radioBox_Callback(cla,contr,express) );
                        dhcp6_des.addprop('groupN');
                        dhcp6_des.groupN=2;
                        
                        express='hIpv6=findobj(pcObj.hpcPropfig,''tag'',''ipv6'');hGatWay6=findobj(pcObj.hpcPropfig,''tag'',''gatWay6'');hDns6=findobj(pcObj.hpcPropfig,''tag'',''dns6'');set([hIpv6'',hGatWay6'',hDns6''],''Enable'',''on'')';
                        static6_des = uicontrol('Parent', settingPanel6_desktop, 'Style', 'radiobutton', 'String', 'static', ...
                            'units','normalized','HorizontalAlignment', 'left','Position', [.28 .82 .20 .19] ,'FontSize',8,'tag','staticv6' ,'CallBack',@(cla,contr,eve)pcObj.radioBox_Callback(cla,contr,express) );
                        static6_des.addprop('groupN');
                        static6_des.groupN=2;
                        
                        
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
                        
                        %
                        
                        %%desktop desktopColiGate_Panel
                        
%                         dfdfsdfdddddddddddddddddddddddddddddddd
                        desktopColiGate_Panel_tool = uipanel('Title','-_-','FontSize',12,...
                            'BackgroundColor',[0.2,0.4,1],'ShadowColor',[0.2,0.4,1],...
                            'Position',[.02 .02 .96 .2] ,'parent' , desktopColiGate_Panel,'tag','desktopColiGate_Panel_tool','visible','on');
                        
                        
%                         gh=axes(desktopColiGate_Panel_tool);
%                           pcSid=4;
%                         t1=linspace(0,1,pcSid+1);
%                         pcX=-sin(2*pi*t1+(pi/pcSid))*2;%node X coordinates with phaze shift
%                         pcY=-cos(2*pi*t1+(pi/pcSid));%node Y coordinates with phaze shift
%                         pcX=(((pcX-min(pcX))./(max(pcX)-min(pcX)))-0.5)*10;
%                         pcY=(((pcY-min(pcY))./(max(pcY)-min(pcY)))-0.5)*10;
%                         g=patch(gh,pcX,pcY,'r')
%                         delete(desktopColiGate_Panel_tool)

                        
                        desktopColiGate_Panel_tool = uipanel('Title','|||','FontSize',12,...
                            'BackgroundColor',[0.2,0.4,1],'ShadowColor',[0.2,0.4,1],...
                            'Position',[.02 .22 .96 .70] ,'parent' , desktopColiGate_Panel,'tag','desktopColiGate_Panel_tool','visible','on');
                        
                        
                        
                        
                        %% config default setting && desktop default setting
                        pcObj.tagNum=1;
                        defaultSettng_pc(pcObj)
                        
                        
                    end
                end
                function tabButon_Callback( pcObj, uibuttonB,~)
                    pcObj.tagNum=str2double(uibuttonB.Tag);
                    defaultSettng_pc(pcObj)
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
                            %                             eval(actionScript);
                        else
                            value=1;
                            %                             eval(actionScript);
                        end
                        activedObject=findobj(pcObj.hpcPropfig,'tag',uicheckB.Tag);
                        allObject=findobj(pcObj.hpcPropfig,'groupN',uicheckB.groupN);
                        
                        set(allObject,'Value',~value);
                        set(activedObject,'Value',value);
                        
                        for in=1:length(allObject)
                            pcObj.ports(pcObj.tagNum).(allObject(in).Tag)=~value;
                            
                        end
                        pcObj.ports(pcObj.tagNum).(uicheckB.Tag)=uicheckB.Value;
                        
                    else
                        pcObj.ports(pcObj.tagNum).(uicheckB.Tag)=uicheckB.Value;
                    end
                    
                    eval(actionScript);

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

                %% desktop section  callBack
                function desktop_Callback ( pcObj, uibuttonB,~,actionScript) %desktop base panel buttons  callBack
                    set(findobj(pcObj.hpcPropfig,'tag','desktopBack'),'UserData',uibuttonB.UserData);

                    set(findobj(pcObj.hpcPropfig,'tag',uibuttonB.UserData),'Visible','on');
                    set(findobj(pcObj.hpcPropfig,'tag','desktopBut_Panel'),'Visible','off');

                end

                function desktopBack_Callback ( pcObj, uibuttonB,~,actionScript) %desktop back button from childeren panels callback
                    set(findobj(pcObj.hpcPropfig,'tag',uibuttonB.UserData),'Visible','off');
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
                                        [ipStan,ipDec]=ip2IpS_dec(char(command(2)),0);%control that ip is right
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





