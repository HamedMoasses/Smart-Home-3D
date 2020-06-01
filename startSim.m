function startSim(bObj,ev,hFig,basPl,bd,hscObj,gscObj,gspObj,wObj,dObj,lObj,mObj,gsObj,fiObj,hObj,seObj,folderName)
%% Initial conditions of all devices
% unit power consumpation of zigbee for each rx/tx mode and idl/standby
zigbee.RxTxEn=56;%mw
zigbee.idlStand=1.2;%mw

% unit power consumpation of wifi for each rx/tx mode and idl/standby; low packet size, low conversation, optimized michanisim in standby(the period of wake up)
wifi.RxTxEn=435;%mw
wifi.idlStand=33;%mw

enwironment.temper=27;
detmolcol=0;
st=[];
tic; 

% hscObj.onRecive(gscObj);
% hscObj.onRecive(wObj);
% hscObj.onRecive(dObj);
% hscObj.onRecive(lObj);
% hscObj.onRecive(mObj);
% hscObj.onRecive(gsObj);
% hscObj.onRecive(fiObj);
% hscObj.onRecive(hObj);
% hscObj.onRecive(seObj);

%% all sensors sense environment

%% sensors send sensing data to central system based on the zigbee 802.8 and wireless 802.11






%%central system send commands to the cntrols of reciver devices for doing an action





view(0,90);
gasMolcol.x=[];
gasMolcol.y=[];
gasMolcol.z=[];
delete(gsObj.hG);
gsObj.hG= plot3(gasMolcol.x ,gasMolcol.y  ,gasMolcol.z  ,'g*');% forward point on the line

writerObj = VideoWriter('out.avi'); % Name it.
writerObj.FrameRate = 10; % How many frames per second.
open(writerObj);
maxLength=max([hObj.pathLength]);
userState=0; %%  entering or exit
counter=0;% counter of period
for ptInd=1:maxLength
    counter=counter+1;
    humanPos.x=[];
    humanPos.y=[];
    for ind=1:length(hObj)
        

        try
            hObj(ind).handle.XData=hObj(ind).path.x(ptInd);
            hObj(ind).handle.YData=hObj(ind).path.y(ptInd);
            hObj(ind).handle.ZData=hObj(ind).path.z(ptInd);
            humanPos.x(end+1)= hObj(ind).handle.XData;
            humanPos.y(end+1)= hObj(ind).handle.YData;
            for bdInd=1:length(lObj)
                in=inpolygon(hObj(ind).path.x(ptInd) ,  hObj(ind).path.y(ptInd) ,lObj(bdInd).bed.x,lObj(bdInd).bed.y);
                
               
                [x,y,l]=polyxpoly(hObj(ind).path.x,  hObj(ind).path.y,mObj(bdInd).handleL.XData,mObj(bdInd).handleL.YData) ;
                if ~isempty(x)
                    hscObj.onRecive(mObj(bdInd));
                else
                    mObj(bdInd).zigEnCon=  mObj(bdInd).zigEnCon+zigbee.idlStand;
                    mObj(bdInd).wiEnCon=  mObj(bdInd).wiEnCon+wifi.idlStand;
                end
               
               
                if in && lObj(bdInd).state
                   
                    if in && lObj(bdInd).state
                        hscObj.onRecive(lObj(bdInd),'on');
                        
                    else
                        lObj(bdInd).zigEnCon=  lObj(bdInd).zigEnCon+zigbee.idlStand;
                        lObj(bdInd).wiEnCon=  lObj(bdInd).wiEnCon+wifi.idlStand;
                    end

                end

            end
            
            
            frame = getframe(gca ); % 'gcf' can handle if you zoom in to take a movie.
            writeVideo(writerObj, frame);
        catch
            humanPos.x(end+1)= hObj(ind).handle.XData;
            humanPos.y(end+1)= hObj(ind).handle.YData;
        end
        
        
        %% security control

        [x,y,l]=polyxpoly(hObj(ind).path.x,  hObj(ind).path.y,mObj(6).handleL.XData,mObj(6).handleL.YData) ;
        l=l(:,1)';
        if sum(l==ptInd)
            if hObj(ind).path.x(ptInd)<hObj(ind).path.x(ptInd+1)
                userState=[0,1];%  entering
                hscObj.onRecive(seObj , hObj(ind) );
                
            elseif hObj(ind).path.x(ptInd)>hObj(ind).path.x(ptInd+1)
                userState=[1,0];%Exiting
                seObj.zigEnCon=  seObj.zigEnCon+zigbee.idlStand;
                seObj.wiEnCon= seObj.wiEnCon+wifi.idlStand;
            end
        else
            userState=[0,0];%Neither entering nor Exiting
            seObj.wiEnCon= seObj.wiEnCon+wifi.idlStand;
        end
    
       
        
        movingUser=[hObj.pathLength]>=ptInd;
        xh=[hObj(movingUser).handle];
        xh=[xh.XData];
        
        if  hObj(ind).valid && (userState(1) || userState(2))
            hscObj.onRecive(dObj ,'open' );   
        elseif  hObj(ind).valid && ~(userState(1) || userState(2)) && sum(abs(xh-mObj(6).handleL.XData(1))>1)==length(xh)  
             hscObj.onRecive(dObj ,'close' );
        end
          
    end
    
    
    for bdInd=1:length(lObj)
        
        in=inpolygon(humanPos.x,humanPos.y ,lObj(bdInd).bed.x,lObj(bdInd).bed.y);
       
    
 
        if sum(in)==0
             hscObj.onRecive(  lObj(bdInd) ,'off' );
        end
        
                %% if gas contor is active and leak is occuring do this
                if  gscObj.state

                gasLeak.x=[gspObj.out(gspObj.state).xv];
                gasLeak.y=[gspObj.out(gspObj.state).yv];
                gasLeak.z=[gspObj.out(gspObj.state).zv];

                gasMolcol.x(end+1:end+length(gasLeak.x))= gasLeak.x;
                gasMolcol.y(end+1:end+length(gasLeak.y))= gasLeak.y;
                gasMolcol.z(end+1:end+length(gasLeak.z))= gasLeak.z;
                end
                rp=randsample(length(basPl.basPlBoUiN.x),length(gasMolcol.x),true)';
                 [xi,yi,inG]= polyxpoly([ basPl.basPlBoUiN.x(rp );gasMolcol.x  ],[  basPl.basPlBoUiN.y(rp) ;gasMolcol.y ], basPl.basPlBoUiN.x  ,basPl.basPlBoUiN.y );
             
                 [~,ind]=intersect(inG(:,2),rp);% find all first intrsection point of multi linses with one polygon
                 
                 xi=xi(ind);
                 yi=yi(ind);
                 delete(gsObj.hG);
                for in2=1:length(xi)

                    if  ~(fiObj.temper>40) && gsObj.alarm>5 && dObj.opcl &&  wObj(1).opcl
                      
                        
                        xVect =  [wObj(1).out.x,wObj(2).out.x,wObj(3).out.x,dObj.out.x] ;
                        yVect =  [wObj(1).out.y ,wObj(2).out.y ,wObj(3).out.y,dObj.out.y ] ;
                        zVect =  [wObj(1).out.z ,wObj(2).out.z ,wObj(3).out.z ,dObj.out.z ] ;
                        
                        
                        
                        xVect2= (xVect-gasMolcol.x(in2)).^2;
                        yVect2= ( yVect-gasMolcol.y(in2)).^2;
                        zVect2= (zVect-gasMolcol.z(in2)).^2;
                        
                       dist=sqrt(xVect2+yVect2+zVect2);
                       [~,outInd]= min(dist);
                        
                        v1 =xVect(outInd)-gasMolcol.x(in2);
                        v2 =yVect(outInd)-gasMolcol.y(in2);
                        v3 =zVect(outInd)-gasMolcol.z(in2);
                        
                    else
                        v1 =basPl.basPlBoUiN.x(rp(in2))-gasMolcol.x(in2);
                        v2 =basPl.basPlBoUiN.y(rp(in2))-gasMolcol.y(in2);
                        v3 =basPl.basPlBoUiN.z(rp(in2))-gasMolcol.z(in2);
                    end
                    
                    
                    
                   
                    
                    mag=sqrt(v1^2 +v2^2 +v3^2);
                    xUnit=v1/mag;
                    yUnit=v2/mag;
                    zUnit=v3/mag;
                    

                    
                    r1=(rand^40 - 0.5^40)*5;
                    r2=(rand^40 - 0.5^40)*5;
                    r3=(rand^40 - 0.5^40)*5;
                    tempX=gasMolcol.x(in2)+xUnit*r1;
                    minPathx=min([gasMolcol.x(in2),xi(in2)]);
                    maxPathx=max([gasMolcol.x(in2),xi(in2)]);
                    tempX=min(max(minPathx,tempX),maxPathx);
                    
                    
                    tempY=gasMolcol.y(in2)+yUnit*r2;
                    minPathy=min([gasMolcol.y(in2),yi(in2)]);
                    mxPathy=max([gasMolcol.y(in2),yi(in2)]);
                    tempY=min(max(minPathy,tempY),mxPathy);
                    
                    [in,on]=inpolygon(tempX ,  tempY ,basPl.basPlBoUiN.x,basPl.basPlBoUiN.y);
                    if  in
                        gasMolcol.x(in2)=tempX;
                        gasMolcol.y(in2)=tempY;
                    end
                    
                    
 
                    
                    
                    gasMolcol.z(in2)=gasMolcol.z(in2)+zUnit*r3;gasMolcol.z(in2)=min(max(0,gasMolcol.z(in2)),2);
                    if gasMolcol.z(in2)>1.9 
                    gasMolcol.z(in2)=gasMolcol.z(in2)-rand*1.5;
                    end
                    
                    if  inpolygon(gasMolcol.x(in2),gasMolcol.y(in2),gsObj.handle.XData ,gsObj.handle.YData)
                        
                        if ismember(in2,detmolcol)
                        else
                            
                        gsObj.alarm=gsObj.alarm+1;
                        detmolcol(end+1)=in2; 
                        end

                    end
                    
                   fiObj.temper=fiObj.temper+0.001*(mean([lObj.temper])-enwironment.temper);

                    
                    if  ~(fiObj.temper>40) && gsObj.alarm>5 &&((dObj.opcl ||  wObj(1).opcl) && mag<1.5) 
                       
                        gasMolcol.x(in2)=[];
                        gasMolcol.y(in2)=[];
                        gasMolcol.z(in2)=[];
                        
                        % if windows is being open then gas Molcols will go out and the temperature will decreas untile down to environment temperature
                        gsObj.alarm=gsObj.alarm-0.05;
                        fiObj.temper=max([enwironment.temper,fiObj.temper-0.0001*mean([lObj.temper])]);
                        
                     end
                  
                  
                end
                
                
                
                
                
                  if gsObj.alarm>5 
                    
                      
                      if mod(in2,2)  
                          gsObj.handle.FaceColor='y';
                      else 
                          gsObj.handle.FaceColor='r';

                      end
                      
                       if ~(fiObj.temper>40) && ~wObj(1).opcl
                          hscObj.onRecive(wObj(1) ,'open' );   
                          hscObj.onRecive(wObj(2) ,'open' );   
                          hscObj.onRecive(wObj(3) ,'open' );   

                      end 
                      
                  end
                
                
                if fiObj.temper>40 && gsObj.alarm>5 
                    hscObj.onRecive(wObj(1) ,'close' );
                    hscObj.onRecive(wObj(2) ,'close' );
                    hscObj.onRecive(wObj(3) ,'close' );   

                    fiObj.alarm=fiObj.alarm+1;
                    gsObj.hG(in2)= plot3(gasMolcol.x ,gasMolcol.y ,gasMolcol.z ,'r*');%  
                     if  ~mod(in2,2)
                          fiObj.handle.FaceColor='y';
                      else
                          fiObj.handle.FaceColor='r';
                      end

                else
                   
                    gsObj.hG(in2)= plot3(gasMolcol.x ,gasMolcol.y ,gasMolcol.z ,'g*');% 
                    
                end
                
 
        
        
    end
    
    st(end+1).zig=sum([hscObj.zigEnCon,gscObj.zigEnCon, wObj.zigEnCon,dObj.zigEnCon,lObj.zigEnCon,mObj.zigEnCon,gsObj.zigEnCon,fiObj.zigEnCon, seObj.zigEnCon]);
    st(end).widf=sum([hscObj.wiEnCon,gscObj.wiEnCon, wObj.wiEnCon,dObj.wiEnCon,lObj.wiEnCon,mObj.wiEnCon,gsObj.wiEnCon,fiObj.wiEnCon, seObj.wiEnCon]);
    st(end).tim=toc;
    st(end).period=counter; 
    
    
%     pause(0.02);
end

gsObj.alarm=0;
gsObj.handle.FaceColor='g';

fiObj.alarm=0;
fiObj.temper=27;
fiObj.handle.FaceColor='g';
hPerEn=figure;plot([st.period],[st.zig]/1000,'-^g');hold on;plot([st.widf]/1000,'-*r');xlabel('period');ylabel('net comulative power consumpation(wat)');
hTimEn=figure;plot([st.tim],[st.zig]/1000,'-^g');hold on;plot([st.tim],[st.widf]/1000,'-*r');xlabel('time(sec)');ylabel('net comulative power consumpation(wat)');
hFig.UserData=st;


saveas(hFig, [ folderName '/outPut/hFig_' num2str(st(end).period)])
saveas(hPerEn, [ folderName '/outPut/h1PerEn_' num2str(st(end).period)])
saveas(hTimEn, [ folderName '/outPut/h1TimEn_' num2str(st(end).period)])
save([ folderName '/outPut/st_' num2str(st(end).period)],'st')


view(findobj(hFig,'type','Axes') ,3);
end