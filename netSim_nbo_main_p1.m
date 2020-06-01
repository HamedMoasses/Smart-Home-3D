



%%All rights reserved, Developed by ---->>>>>>> Hamed Moasses




%% clear commands
            delete(allchild(0));
            clear;
            clc;
          
            %% path commands
            file=matlab.desktop.editor.getActive;% get current script address
            try % if dont occur any error this block will run
                fileDetail=dir(file.Filename);% get current script details
                folderName=fileDetail.folder;% get current script folder name
            catch% else if an  error occurs then
                index=strfind( file.Filename,'\');% find index of back space(\) in path text
                folderName=file.Filename(1:index(end)-1);% select all path text from 1 to last Occurrence of \ as script folder name
            end
            paths=genpath(folderName);% make current path and all sub paths
            addpath(paths);% add all paths in known paths of matlab
            cd(folderName);% go to path that current scrip runned from that

            
                 
            
            %% base figure   
            sc=get(0,'screensize');
            sc(1)=sc(1)+50;sc(2)=sc(2)+50;sc(3)=sc(3)-200;sc(4)=sc(4)-200;
            hFig=figure('name','iot_zigbee vs wireless','NumberTitle','off','Position',sc);

          
  
            
            %%  sub objects of smart home objects: static  objecects 
            
            % smart home plan 
            pl.x=[0,4,4,3,3,4,4,4.2,4.2,1.5,1.5,3.9,3.9,2.9,2.9,0.2,0.2              NaN  ,    5,5,5.8,5.8,6,6,9,9,6,6,0.2,0.2,0,0,0.2,0.2, 0.2,2.9,2.9, 2.9,2.8,2.8,3,3,3.2,3.2 ,3,3,3,5.8,5.8, 5.8,4.2,4.2,4.3,4.3,5.6,5.6,4.2,4.2,5.8,5.8, 5.8 ,5.8,6,6,6,8.8,8.8,5.8,5.8,4.6,4.6,5.8,5.8,5.8,5.8,5                      NaN,            0.2,0,0,-1,-1,0,0,0.2 ,0.2,3,3,0.2,0.2,         NaN,    0.2,0,0,-1,-1,0,0,0.2,0.2,0.4,0.4,0.2,0.2           NaN  0.2,0,0];
            pl.x=[pl.x;pl.x];

            pl.y=[0,0,0.2,0.2,1.95,1.95,3.8,3.8,4,4,3.8,3.8,2.05,2.05,0.2,0.2,1.5    NaN  ,    0.2,0,0,0,0,3.8,3.8,8.2,8.2,12,12,12,12,10.7,10.7,11.8, 11.8,11.8,11.8,9.3,9.3,9.2,9.2,9.5,9.5,9.6,9.6,11.8,11.8,11.8,9.6,9.6,9.6,9.2,9.2,9.5,9.5, 8.2,8.2,  8, 8,8,8,7.5,7.5,8,8,8,4,4,4,4,3.8 ,3.8,3.8,0.2,0.2,0.2         NaN,           9.5,9.5,8.2,8.2,8,8,7,7,8,8,8.2,8.2,9.5,         NaN,          5,5,4,4,3.8,3.8,2.5,2.5,3.8,3.8,4,4,5,        NaN  1.3,1.3,0];
            pl.y=[pl.y;pl.y];

            pl.z=[1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1                                  NaN  ,    1,1,1,2,2,2,2,2,2,2,2,1,1,1,1,1, 2,2,1,1,1,1,1,1,1,1,1,1,2,2,2,1,1,1,1,1,1,1,1,1,1,2,1,1,1,1,2,2,2,2,1,1,1 ,1,2,2,1,1                                                                                                        NaN,           1,1,1,1,1,1,1,1,1,1,1,1,1,                       NaN           1,1,1,1,1,1,1,1,1,1,1,1,1,                    NaN  1,1,1];
            pl.z=[pl.z;pl.z*0];
            hpan=surf(pl.x  ,pl.y  ,pl.z ,'faceColor',[0.9 ,0.9 ,0.9 ]   );hold on;
            %hpan=plot3(h.x  ,h.y  ,h.z ,'-r' );hold on;plot3(h.x' ,h.y' ,h.z','-r' ); is used for without surface mode in the future!

            %baseplane out border;
            basPlBoUot.x=[0,6,6,9,9,6,6,0,0];
            basPlBoUot.y=[0,0,3.8,3.8,8.2,8.2,12,12,0];
            [basPlBoUot.x,basPlBoUot.y]=divider(basPlBoUot.x,basPlBoUot.y,20,1);
            basPlBoUot.z=basPlBoUot.x*0+2;
            plot3(basPlBoUot.x,basPlBoUot.y,basPlBoUot.z,'-')
            
            
            basPlBoUiN.x=[.2,5.8,5.8,8.8,8.8,5.8,5.8,.2,.2];
            basPlBoUiN.y=[.2,.2,4,4,8 ,8 ,11.8,11.8,.2];
            [basPlBoUiN.x,basPlBoUiN.y]=divider(basPlBoUiN.x,basPlBoUiN.y,20,1);
            basPlBoUiN.z=basPlBoUiN.x*0+2;
            plot3(basPlBoUiN.x,basPlBoUiN.y,basPlBoUiN.z,'-')
            
            basPl.basPlBoUot=basPlBoUot;
            basPl.basPlBoUiN=basPlBoUiN;
            
            
            
            
            % floor
            floor.x=[0,0,-6,-6,0];
            floor.y=[4,8,8,4,4];
            floor.z=[0,0,0,0,0];
            hf=fill3(floor.x,floor.y,floor.z,[0,0.8,0.4]);hold on;alpha(hf ,1);
          
            % room sections( on the floor)
            bd(1).x=[0.2,2.9,2.9,3.9,3.9,1.5,0.4,0.2,0.2];%Bedroom
            bd(1).y=[0.2,.2,2.05,2.05,3.8,3.8,3.8,3.8,0.2];
            
            bd(2).x=[3,5.8,5.8,4.6,4,4,3,3 ];%Bedroom
            bd(2).y=[0.2,.2,3.8,3.8,3.8,1.95,1.95,.2 ];
            
            bd(3).x=[.2,5.8,5.8,.2,.2  ];%dining room
            bd(3).y=[4,4,8,8,4 ];
            
            bd(4).x=[5.8,6,6,8.8,8.8,5.8,5.8  ];%kitchen
            bd(4).y=[7.5,7.5,8,8,4,4,7.5 ];
            
                 bd(5).x=[3,3,2.8,2.8,2.9,2.9,.2,.2,3 ];%Bedroom
            bd(5).y=[8.2,9.2,9.2,9.3,9.3,11.8,11.8,8.2,8.2 ];
            
            bd(6).x=[3,3,5.8,5.8,3 ];%bathroom
            bd(6).y=[9.6,11.8,11.8,9.6,9.6  ];
            
            plot(bd(1).x,bd(1).y,'r');hold on
            plot(bd(2).x,bd(2).y,'r');hold on
            plot(bd(3).x,bd(3).y,'r');hold on
            plot(bd(4).x,bd(4).y,'r');hold on
            plot(bd(5).x,bd(5).y,'r');hold on
            plot(bd(6).x,bd(6).y,'r');hold on
            

            
            % stove (stove and Refrigerator as object later that can control by iot  but here thay are static) 
            stove.x=[[6,7.8,7.8,7.8,8.8,8.8,6,6];[6,7.8,7.8,7.8,8.8,8.8,6,6]; [6,7.8,7.8,7.8,8.8,8.8,6,6];[6,7.8,7.8,7.8,8.8,8.8,6,6]];
            stove.y=[[ 7,7,5.5 ,4,4,8,8,7];[ 7,7,5.5 ,4,4,8,8,7];[ 8,8,8,8,8,8,8,8];[ 8,8,8,8,8,8,8,8]  ];
            stove.z=[ [0,0,0 ,0,0,0,0,0] ;[0,0,0 ,0,0,0,0,0]+1 ;[0,0 ,0,0,0,0,0,0]+1;[0,0,0 ,0,0,0,0,0]+1.5];
            surf(stove.x',stove.y', stove.z' );hold on
            plot3(stove.x,stove.y, stove.z,'k-');hold on

            %Refrigerator
            frig.x=[[6,7 ,7 ,6.5,6,6]; [6,7 ,7 ,6.5,6,6] ;   [6,7 ,7 ,6.5,6,6] ;   [6,7 ,7 ,6.5,6,6]] ;
            frig.y=[[ 4,4 ,5,5,5,4 ];   [ 4,4 ,5,5,5,4 ]; [ 4,4 ,5,5,5,4 ]; [ 5,5 ,5,5,5,5 ]] ;
            frig.z=[ [0,0 ,0,0,0,0 ] ;  [0,0 ,0,0,0,0 ]+0.5  ; [0,0 ,0,0,0,0 ]+2 ;[0,0 ,0,0,0,0 ]+2  ];
            surf(frig.x',frig.y', frig.z' ,'faceColor',[0.9,0.9,0.99]);hold on
            
            
            % yard 
            yard .x=[ 0 ,0 ,-6 ,-6 ,0;0,0,-6,-6,0  ];
            yard .y=[4 ,4 ,4 ,4 ,4;4,8,8,4,4   ] ;
            yard .z=[0 ,0 ,0 ,0 ,0;0 ,0 ,0 ,0 ,0  ];
            hy=surf(yard.x   ,yard.y   ,yard.z ,  'faceColor','g' ,'lineWidth',0.1 );hold on;alpha(hy,0.3)
            
            
            % cars(static in this senario)
            xC=[.5,.5,.7,2,2.5,2.7,2.8,3,3,2.8,2.7,2.5,2,0.7,0.5]; xC= xC-(max(xC)/2);
            yC=[.5,1.5,1.8,1.8,1.5,1.5,1.5,1.3,.7,.5,.5,.5,.2,0.2,0.5];yC= yC-(max(yC)/2);
            car .x=[ xC; xC/0.9 ;(xC/3)-0.2 ] ;
            car .y=[yC; yC/0.9 ;yC/3 ]/2  ;
            car .z=[ 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0; [1.5,1.5,1,1,1,1,.5,0.5,.5,1,1,1,1,1,1]/3 ;[1,1,1,1,1,1,1,1,1,1,1,1,1,1,1] /2  ];
            
            hc(1)=surf(car.x-4    ,car.y+5    ,car.z  );hold on;alpha(hc(1),0.8);
            hc(2)=surf(car.x-5   ,car.y+7   ,car.z ,'faceColor','r' );hold on;alpha(hc(2),0.9);
            
       
            %fan   is an static object till now
            paraWin.faState=1; %0=off 1=on
            paraWin.pos=[5.5,7.7,0];
            faObj=fanObj(paraWin);

            
            
            
            %% sub objects of smart home objects: active  with reciver  for comunication but no sensor       
            %gasPipe objects(1)( can lock and oben itself) 
            paraGsc.state=1;
            paraGsc.pos.x=-1; paraGsc.pos.y=8; paraGsc.pos.z=1;
            gscObj=gasContObj(paraGsc);
            
            % vectorize position of gase pipe (can control only)
            paraGsp.xv=[-1,-1,2,2,NaN,-1,3,3,4.2,4.2,5.8,7,7,NaN,7,8.8,8.8,5.8,5.8,NaN,5.8,4.6,4.6,4.2,4.2,3.9,2,2] ;
            paraGsp.yv=[8,8,8,8.3,NaN,8,8,8,8,8,8, 8,7.8,NaN,8,8,4,4,2.5,NaN,4,4,4,4,4,4,4,3.7] ;
            paraGsp.zv=[1,.2,.2,.2,NaN,.2,.2,2,2,.2,.2,0.2,0.2,NaN,0.2,.2,.2,.2,.2 ,NaN,.2,.2, 2,2,.2,.2,.2,0.2  ];
            paraGsp.outX=[2,7,5.8,2];
            paraGsp.outY=[8.3,7.8,2.5,3.7];
            paraGsp.outZ=[.2,.2,.2,.2];

            paraGsp.state=logical([1:length(paraGsp.outX)]*0) ;%0=no leakage 1= leakage; from one of out postion!
            r=randi(length(paraGsp.state),1,1);paraGsp.state(r)=1;
            gspObj=gasPipeObj(paraGsp);
            
            %windows objects(1)( can lock and oben itself) 
            paraWin.state=1; %0=off 1=on
            paraWin.opcl=0; %0= close 1=open 
            
            paraWin.closeCond.x=[ 4,4.5,NaN,4.5,5;4,4.5,NaN,4.5,5];
            paraWin.closeCond.y=[ 0.2, 0.2,NaN,0.2,0.2; 0.2,0.2,NaN,0.2,0.2];
            paraWin.closeCond.z=[ 1,1,NaN,1,1;0,0,NaN,0,0];
            
            paraWin.openCond.x=[ 4,4,NaN,5,5;4,4,NaN,5,5];
            paraWin.openCond.y=[ 0.2, 0.7,NaN,0.7,0.2; 0.2, 0.7,NaN,0.7,0.2];
            paraWin.openCond.z=[ 1,1,NaN,1,1; 0,0,NaN,0,0];
            
            paraWin.out.x=[ 4,5,5,4,4];% is used for Leading molecules out
            paraWin.out.y=[ 0,0,0,0,0]-1;
            paraWin.out.z=[ 0,0,1,1, 0];
           [paraWin.out.x , paraWin.out.y, paraWin.out.z]=divider3( paraWin.out.x , paraWin.out.y, paraWin.out.z,5);
            
           %plot3(para.out.x,para.out.y,para.out.z,'-*');hold on;
            paraWin.pos=paraWin.closeCond;
            wObj(1)=windowObj(paraWin);

            
            %windows objects(2)( can lock and oben itself) 
            paraWin.state=1; %0=off 1=on
            paraWin.opcl=0; %0= close 1=open 

            paraWin.closeCond.x=[ 0.2,.2,NaN,.2,0.2; 0.2,.2,NaN,.2,0.2];
            paraWin.closeCond.y=[ 10.7,10.1,NaN,10.1,9.5; 10.7,10.1,NaN,10.1,9.5];
            paraWin.closeCond.z=[ 1,1,NaN,1,1; 0,0,NaN,0,0];
            
            paraWin.openCond.x=[ 0.2,0.8,NaN,0.8,0.2; 0.2,0.8,NaN,0.8,0.2];
            paraWin.openCond.y=[ 10.7,10.7,NaN,9.5,9.5; 10.7,10.7,NaN,9.5,9.5];
            paraWin.openCond.z=[ 1,1,NaN,1,1; 0,0,NaN,0,0];

            paraWin.out.x=[ 0,0,0,0,0]-1;
            paraWin.out.y=[ 9.5,10.7,10.7,9.5,9.5] ;
            paraWin.out.z=[ 0,0,1,1, 0];
            [paraWin.out.x , paraWin.out.y, paraWin.out.z]=divider3( paraWin.out.x , paraWin.out.y, paraWin.out.z,5);

%             plot3(paraWin.out.x,paraWin.out.y,paraWin.out.z,'-*');hold on;
            
            paraWin.pos= paraWin.closeCond;
            wObj(2)=windowObj(paraWin);
           
            %windows objects(3)( can lock and oben itself) 
            paraWin.state=1; %0=off 1=on
            paraWin.opcl=0; %0= close 1=open
            
            paraWin.closeCond.x=[ 0.2,.2,NaN,.2,0.2; 0.2,.2,NaN,.2,0.2];
            paraWin.closeCond.y=[2.5,1.9,NaN,1.9,1.3;2.5,1.9,NaN,1.9,1.3];
            paraWin.closeCond.z=[ 1,1,NaN,1,1; 0,0,NaN,0,0];            
            
            paraWin.openCond.x=[ 0.2,0.8,NaN,0.8,0.2; 0.2,0.8,NaN,0.8,0.2];
            paraWin.openCond.y=[2.5,2.5,NaN,1.3,1.3;2.5,2.5,NaN,1.3,1.3];
            paraWin.openCond.z=[ 1,1,NaN,1,1; 0,0,NaN,0,0];
            
            paraWin.out.x=[ 0,0,0,0,0]-1;
            paraWin.out.y=[ 1.3,2.5,2.5,1.3,1.3] ;
            paraWin.out.z=[ 0,0,1,1, 0];
            [paraWin.out.x , paraWin.out.y, paraWin.out.z]=divider3( paraWin.out.x , paraWin.out.y, paraWin.out.z,5);
            
            paraWin.pos = paraWin.closeCond;
            wObj(3)=windowObj(paraWin);
             

            %door objects(1)( can lock and oben itself) 
            paraDor.state=1; %0=off 1=on
            paraDor.opcl=0; %0= close 1=open
            
            paraDor.closeCond.x=[.2,.2,NaN,.2,.2;.2,.2,NaN,.2,.2;.2,.2,NaN,.2,.2];
            paraDor.closeCond.y=[7, 6,NaN ,6 ,5;7,6,NaN,6,5;7,6,NaN,6,5];
            paraDor.closeCond.z=[0,0,NaN,0,0;.3,.3,NaN,.3,.3;1,1,NaN,1,1];
            
            paraDor.openCond.x=[.2,1.2,NaN,.2,.2;.2,1.2,NaN,.2,.2;.2,1.2,NaN,.2,.2];
            paraDor.openCond.y=[7, 7,NaN ,6 ,5;7, 7,NaN ,6 ,5;7, 7,NaN ,6 ,5];
            paraDor.openCond.z=[0,0,NaN,0,0;.3,.3,NaN,.3,.3;1,1,NaN,1,1];
            
            paraDor.out.x=[ 0,0,0,0,0]-1;
            paraDor.out.y=[ 6,7,7,6,6] ;
            paraDor.out.z=[ 0,0,1,1, 0];
            [paraDor.out.x , paraDor.out.y, paraDor.out.z]=divider3( paraDor.out.x , paraDor.out.y, paraDor.out.z,5);
            
            paraDor.pos = paraDor.closeCond;
            dObj(1)=doorObj(paraDor);
            
        
           %lights objects
            paraLig.state=1;
            paraLig.pos=[2,2,2];
            paraLig.bed=bd(1);
            lObj(1)=lightObj(paraLig);

            paraLig.state=1;
            paraLig.pos=[5,2,2];
            paraLig.bed=bd(2);
            lObj(2)=lightObj(paraLig);


            paraLig.state=1;
            paraLig.pos=[2,6,2];
            paraLig.bed=bd(3);
            lObj(3)=lightObj(paraLig);


            paraLig.state=1;
            paraLig.pos=[7,6,2];
            paraLig.bed=bd(4);
            lObj(4)=lightObj(paraLig);

            paraLig.state=1;
            paraLig.pos=[2,11,2];
            paraLig.bed=bd(5);
            lObj(5)=lightObj(paraLig);

            paraLig.state=1;
            paraLig.pos=[5,11,2];
            paraLig.bed=bd(6);
            lObj(6)=lightObj(paraLig);



            
            %% sub objects of smart home objects: activeable  with reciver and sosensor       
           
            %motation detectors
            paraMot.state=1;
            paraMot.pos=[1.5,4,1];
            paraMot.lineSen=[0.4,1.5;4,4];  
            mObj(1)=motDetObj(paraMot); % motation detector         
            
            paraMot.state=1;
            paraMot.pos=[4.6,4,1];
            paraMot.lineSen=[4.2,4.6;4,4];
            mObj(2)=motDetObj(paraMot); % motation detector

            paraMot.state=1;
            paraMot.pos=[5.8,7.5,1];
            paraMot.lineSen=[5.8,5.8;7.5,4];
            mObj(3)=motDetObj(paraMot);

            paraMot.state=1;
            paraMot.pos=[3,8.2,1];
            paraMot.lineSen=[3,3; 8,9.2];
            mObj(4)=motDetObj(paraMot);

            paraMot.state=1;
            paraMot.pos=[3.2,9.6,1];
            paraMot.lineSen=[3.2,4.2;9.6,9.6];
            mObj(5)=motDetObj(paraMot); % motation detector

            paraMot.state=1;
            paraMot.pos=[0,7,1];
            paraMot.lineSen=[0,0;5,7];
            mObj(6)=motDetObj(paraMot); % motation detector

            
            % gas detection
            paraGs.state=1;
            paraGs.pos.x=7; paraGs.pos.y=7.9; paraGs.pos.z=1.5;
            gsObj=gasDetObj(paraGs); 

            
            %fire detection
            paraFi.state=1;
            paraFi.pos.x=8.7; paraFi.pos.y=6; paraFi.pos.z=1.5;
            fiObj=fireDetObj(paraFi); 
            
            axis('equal')
            xlabel('x');ylabel('y');zlabel('z');
            
           
 
            %representation setting
            % security object(used for Homeowner recognition)
            paraSec.state=1;
            paraSec.pos.x=0; paraSec.pos.y=7.5; paraSec.pos.z=.75;
            seObj=securityObj(paraSec);
            
            userPass={};
            para.pass={'12r35'};
            userPass{end+1}=para.pass;
            hObj(1)=hmObj(para,lObj, bd,floor,seObj,mObj);
            para.pass={'nbr35'};
            userPass{end+1}=para.pass;
            hObj(2)=hmObj(para,lObj, bd,floor,seObj,mObj);
            para.pass={'rcr35'};
            userPass{end+1}=para.pass;
            hObj(3)=hmObj(para,lObj, bd,floor,seObj,mObj);

            seObj.userPass=table2array(cell2table(userPass));
            
%             hObj(1).pass={'12r45'};
            %% sub objects of smart home objects:network devices(active  without sensor  and reciver include routor(coordinator here),switch,hub,server or pc (homeSysControl here) 
            %coordinatoor
%             para.coState=1;
%             coObj=coordinaObj(para);
            
            % switch 
%             para.swState=1;
%             swObj=switchObj(para);
            
            % hub 
%             para.swState=1;
            %hbObj=hubObj(para);

            %server or pc ans  homeSysControl( this devic using network device can gather information and making dicision making)
%             para.hscState=1;
%             para.pos=[4,6,2];
%             




            paraSec.pos.x=3; paraSec.pos.y=6; paraSec.pos.z=2;
            paraSec.state=1;
            hscObj=homeSysControl(paraSec,gscObj,gspObj,wObj,dObj,lObj,mObj,gsObj,fiObj,hObj,seObj);

 
            
            uicontrol(hFig,'style','pushbutton','Position',[245,0,120,40],'tag','geCod','string','simulate' ,'Callback',@(bObj,ev)startSim(bObj,ev,hFig,basPl,bd,hscObj,gscObj,gspObj,wObj,dObj,lObj,mObj,gsObj,fiObj,hObj,seObj,folderName) )


            %representation setting
            axis('equal')
            xlabel('x');ylabel('y');zlabel('z');


            %% global parameters setting
%             dataRate=250;%kbps
%             freqCent=[868,915,2400];% MH
%             channelNum.t1=1;%868.3 MH; modulation :BPSK ,O-QPSK, ASK; Data-rates (kbps): 20,100, 250
%             channelNum.t2=10;%906:2:924 MH; modulation :BPSK ,O-QPSK, ASK; Data-rates (kbps): 40,250, 250
%             channelNum.t3=16; %2405:5:2480 MH; modulation :O-QPSK ; Data-rates (kbps): 250
% 
%             % 0 db output power
%             shortrang=30;% indoor; because obsorbation ,reflection,refraction,multipath ,...
%             longrang=200;% outdoor
% 
%             % 15 db output power
%             shortrang15=5*30;% indoor; because obsorbation ,reflection,refraction,multipath ,...
%             longrang15=5*200;% outdoor

            % adressing: local
            %1- mac address 64 bit
            %2- short address(16 bit uniq adress): when joining device to net allocate by coordinator, using this adress rather than mac make packet shorter
            %* If a device does not have a short address, it must be addressed using its IEEE address.


            
            
            %% 
 
            %
            %             Refrigerator, window, in, ventilator, TV, fire alarm, gas sensor, motion sensor, key, electronic, excitation system, security system, camera,
            %
            % Coordinator
            %             Coordinator.roles include:
            %             ? Assigning a PAN ID to the network
            %             ? Finding a suitable radio frequency for network operation
            %             ? Assigning a short address to itself
            %             ? Handling requests from other devices to join the network
            %             ? Relaying messages from one node to another (but not in all topologies)



            %%network setup:
            % Step 1:
            %Initialising the Stack
            % First of all, the PHY and MAC layers of the IEEE 802.15.4 stack (see Section 1.9) must
            % be initialised on each device which will form part of the network.

            % Step 2:
            %creating a PAN Co-ordinator
            % Every network must have one and only one PAN Co-ordinator, and one of the first
            % tasks in setting up a network is to select and initialise this Co-ordinator. This involves
            % activity only on the device nominated as the PAN Co-ordinator.

            % Step 3;
            % Selecting the PAN ID and Co-ordinator Short Address
            % The PAN Co-ordinator must assign a PAN ID to its network. The PAN ID may be predetermined.
            % The PAN Co-ordinator device already has a fixed 64-bit IEEE (MAC) address,
            % sometimes called the 'extended' address, but must also assign itself a local 16-bit
            % network address, usually called the 'short' address. Use of the short address makes
            % communications lighter and more efficient. This address is pre-determined - the PAN
            % Co-ordinator is usually assigned the short address 0x0000.
            % Note: The PAN Co-ordinator can choose a PAN ID
            % automatically by 'listening' for other networks and
            % selecting a PAN ID that does not conflict with the IDs of
            % any existing networks that it detects. It can perform this
            % scan for other PAN Co-ordinators over multiple radio
            % frequency channels. Alternatively, a radio frequency
            % channel can be chosen first and the PAN ID then
            % selected according to other PAN IDs detected in this
            % channel - in this case, Step 4 must be performed first.




            % Step 4:
            %Selecting a Radio Frequency
            % The PAN Co-ordinator must select the radio frequency channel in which the network
            % will operate, within the chosen frequency band. The PAN Co-ordinator can select the
            % channel by performing an Energy Detection Scan in which it scans the frequency
            % channels to find a quiet channel. The Co-ordinator can be programmed to only scan
            % specific channels. The Energy Detection Scan returns an energy level for each
            % channel scanned, which indicates the amount of activity on the channel. The
            % application running on the PAN Co-ordinator must then choose a channel using this
            % information


            %
            % Step 5 :
            %  Starting the Network
            % The network is started by first completing the configuration of the device which will act
            % as the PAN Co-ordinator and then starting the device in Co-ordinator mode. The PAN
            % Co-ordinator is then open to requests from other devices to join the network.
            %
            % Step 6:
            % Joining Devices to the Network
            % Other devices can now request to join the network. A device wishing to join the
            % network must first be initialised and must then find the PAN Co-ordinator.
            % To find the PAN Co-ordinator, the device performs an Active Channel Scan in which
            % it sends out beacon requests across the relevant frequency channels. When the PAN
            % Co-ordinator detects the beacon request, it responds with a beacon to indicate its
            % presence to the device

            % Note:
            % In the case of a beacon enabled network (in
            % which the PAN Co-ordinator sends out periodic
            % beacons), the device can perform a Passive Channel
            % Scan in which the device 'listens' for beacons from the
            % PAN Co-ordinator in the relevant frequency channels
            %
            % Once the device has detected the PAN Co-ordinator, it sends an association request
            % to the Co-ordinator, which acknowledges the request. The Co-ordinator then
            % determines whether it has the resources to support the new device and either accepts
            % or rejects the device.
            % If the PAN Co-ordinator accepts the device, it may assign a 16-bit short address to the
            % device



            %% simulation : we make a fire or Human movement, gas leak, temperature change in a random  and each time we used sensor and other system and at the end energy consumpation

            % Data Transfer:
            % Once an IEEE 802.15.4 network has been formed with a PAN Co-ordinator and at
            % least one other device, data can be exchanged between its nodes.


            %% 'Co-ordinator to End Device' Transfer:
            % Two methods of data transfer from a Co-ordinator to an End Device are available. In
            % a Star network, these nodes will be the PAN Co-ordinator and an End Device. In a
            % Tree or Mesh network, the nodes may be a PAN or local Co-ordinator and a child End
            % Device.

            %  Direct Transmission:
            %A Co-ordinator sends a data frame directly to an End
            % Device. Once it has received the data, the End Device sends an
            % acknowledgement to the Co-ordinator. In this case, the End Device must
            % always be capable of receiving data and must therefore be permanently active.
            % This approach is employed in the skeleton code described in this document.

            %  Indirect Transmission (Polling):
            %Alternatively, the Co-ordinator holds data
            % until the data is requested by the relevant End Device. In this case, in order to
            % obtain data from the Co-ordinator, an End Device must first poll the Coordinator to determine whether any data is available. To do this, the device
            % sends a data request, which the Co-ordinator acknowledges. The Co-ordinator
            % then determines whether it has any data for the requesting device; if it does, it
            % sends a data packet, which the receiving device may acknowledge. This
            % method is useful when the End Device is a low-power device that must sleep
            % for much of the time in order to conserve power.
            % The above two data transfer methods are illustrated in Figure 5 below

            %% 'End Device to Co-ordinator' Transfer"
            % An End Device always sends a data frame directly to the Co-ordinator. Once it has
            % received the data, the Co-ordinator may send an acknowledgement to the End Device.
            % ‘Co-ordinator to Co-ordinator’ Transfer
            % In a Tree or Mesh network, a Co-ordinator always sends a data frame directly to
            % another Co-ordinator. Once it has received the data, the target Co-ordinator may send
            % an acknowledgement to the source Co-ordinator

            %broadcast to same or other network
            % Note: A data frame can be broadcast to all nodes within
            % range and operating in the same network (i.e. using the
            % same PAN ID) by setting the destination (short) address
            % in the frame to 0xFFFF. Alternatively, a data frame can
            % be broadcast to all nodes within range and operating in
            % any network by setting the destination PAN ID in the
            % frame to 0xFFFF and the destination (short) address to
            % 0xFFFF.



            %%Physical (PHY) Layer responsibilities
            %  1- Channel assessment
            %   2-Bit-level communications (bit modulation, bit de-modulation, packet
            % synchronisation)
            %  3- PHY Data Service: Provides a mechanism for passing data to and from the
            % MAC sub-layer.
            %  4- PHY Management Services: Provides mechanisms to control radio
            % communication settings and functionality from the MAC sub-layer.
            %6- Information used to manage the PHY layer is stored in a database referred to as the
            % PHY PIB (PAN Information Base).


            %% Media Access Control (MAC) Sub-layer responsibilities
            % 1  Providing services for associating/disassociating devices with the network
            % 2  Providing access control to shared channels
            % 3  Beacon generation (if applicable)
            % 4  Guaranteed Timeslot (GTS) management (if applicable)
            % 5 MAC Data Service (MCPS): Provides a mechanism for passing data to and
            % from the next higher layer.
            % 6 MAC Management Services (MLME): Provides mechanisms to control
            % settings for communication, radio and networking functionality, from the next
            % higher layer.
            % 7- Information used to manage the MAC layer is stored in a database referred to as the
            % MAC PIB (PAN Information Base).


            %% channel selection
            % When a network is set up, the channel of operation within the relevant
            % frequency band must be chosen. This is done by the PAN Co-ordinator. IEEE
            % 802.15.4 provides an Energy Detection Scan which can be used to select a
            % suitable channel (normally the quietest channel).
            % When a new device is introduced into a network, it must find the channel being
            % used by the network. The new device is supplied with the PAN ID of the
            % network and performs either of the following scans:
            % ? Active Channel Scan in which the device sends beacon requests to be
            % detected by one or more Co-ordinators, which then send out a beacon in
            % response
            % ? Passive Channel Scan (beacon enabled networks only) in which the
            % device listens for periodic beacons being transmitted by a Co-ordinato




            %% channel rejection
            % If another signal at the same level (0 dB difference) or weaker is detected in an
            % adjacent channel, the adjacent channel's signal must be rejected.
            % If another signal at most 30 dB stronger is detected from an alternate channel,
            % the alternate channel's signal must be rejected.




            %% Orphan Devices
            % A device becomes an orphan if it loses communication with its Co-ordinator. This may
            % be due to reception problems in the communication channel, or because the Coordinator has changed its communication channel, or because one device has moved
            % out of range of the other device.
            % An orphan device will attempt to rejoin the Co-ordinator by first performing an Orphan
            % Channel Scan (see Section 1.10.1) to find the Co-ordinator - this involves sending out
            % an orphan notification command across the relevant frequency channels. On receiving
            % this message, the Co-ordinator checks whether the device was previously a member
            % of its network - if this was the case, it responds with a co-ordinator realignment
            % command.



            %% Routing

            % if we example have a tree or mesh topology then we should have a routing table in upper layer(like zigbee) to get destnation node by using coordinates

            %%  PAN Information Base (PIB)
            % A PAN Information Base (PIB)  exists on each node in an IEEE 802.15.4-based
            % network. The PIB consists of a number of attributes used by the MAC and PHY
            % (Physical) layers. These attributes describe the PAN in which the node exists. They
            % are divided into MAC attributes and PHY attributes. The PIB contents and access to
            % them are detailed in Section 3.10.




            %% Callback Mechanism
            % A Request is issued by the MAC User by means of a call to one of the API functions
            % described in Chapter 5. The most straightforward way for the MAC Layer to reply (with
            % a Confirm and/or Indication) is via a callback function, introduced below (use of the
            % callback mechanism for dealing with service primitives is described in more detail in
            % Section 1.15.4).
            % A callback function is registered with the MAC Layer by the application and is available
            % for the MAC Layer to call. When required (for example, as the result of an event), a
            % call to the callback function is made from the MAC Layer's thread of execution. The
            % callback mechanism is illustrated in Figure 13 below.


            %% Implementation of Service Primitives
            % This section describes the handling of service primitives, making use of the callback
            % mechanism introduced in Section 1.15.3. The cases of handling Request-Confirm
            % primitives and Indication-Response primitives are described separately


            %% security services on mac layer
            % Unsecured mode
            % ACL (Access Control List) mode
            % Secured mode





