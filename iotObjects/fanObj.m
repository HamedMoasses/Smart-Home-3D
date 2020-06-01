
% here zigbee and other application implemented
classdef fanObj<dynamicprops
    
    properties
       faState=0; 
 
       handle
       
          %energy Consum
        zigEnCon=0;
        wiEnCon=0;
    end
    
    methods
        
        function faObj=fanObj(para)  
            faObj.faState=para.faState;% on or off in default
            side=20;
            t=linspace(0,2*pi,side+1);
            f.x=sin(t);f.x=normalVect(f.x,-0.25,0.25);
            f.y=cos(t);f.y=normalVect(f.y,-0.25,0.25);
            f.z=f.x*0;
            f1.x=[f.x/8;f.x/1.2;f.x;f.x/1.2;f.x/8];
            f1.y=[f.y/8;f.y/1.2;f.y;f.y/1.2;f.y/8];
            f1.z=[f.z  ;f.z-0.1;f.z;f.z+0.1;f.z-0.1] ;
            [f1.x,f1.y,f1.z]=rotateParameter(f1,[1,0,0], 90);
            
            f.x=[f.x;f.x/10;f.x/10;f.x*NaN;f1.x  ];
            f.y=-[f.y;f.y/10;f.y/10;f.y*NaN;f1.y+0.1  ];
            f.z= [f.z;f.z+0.2;f.z+1;f.z*NaN;f1.z+0.99  ];
            
            [x,y,z]=rotateParameter(f ,[0,0,1], -45);

            if faObj.faState
                faObj.handle=surf(x+para.pos(1),y+para.pos(2),z+para.pos(3),'faceColor',[0.5,0.5,0.5], 'edgeColor',[0.82,0.8,0.8]);
            else
                faObj.handle=surf(x+para.pos(1),y+para.pos(2),z+para.pos(3));
            end
        end
    end
    
end