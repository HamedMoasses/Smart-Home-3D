
% making 2d symetric polygon
% example:
% side=10;
% size=2;
% ph=pi/10;
% para.pos.x=1;
% para.pos.y=1;
% para.pos.z=1;
% poly=makepoly([side,size],pi/10,para.pos);


function poly=makepoly(sideSize,ph,pos)
side=sideSize(1);
size=sideSize(2);
if nargin==1
    
    poly.ph=pi/side;
    poly.pos.x=0;
    poly.pos.y=0;
    poly.pos.z=0;
elseif nargin==2
    poly.ph=ph;
    poly.pos.x=0;
    poly.pos.y=0;
    poly.pos.z=0;
elseif nargin==3
    poly.ph=ph;
    poly.pos=pos;
end
 t=linspace(0,2*pi,side+1);
poly.x=sin(t+poly.ph); poly.x=normalVect(poly.x,-size/2,size/2);  
poly.y= cos(t+poly.ph);poly.y=normalVect(poly.y,-size/2,size/2);  
poly.z=poly.y*0;

poly.xv=poly.x+poly.pos.x;
poly.yv=poly.y+poly.pos.y;
poly.zv=poly.z+poly.pos.z;
if nargout==0
plot3(poly.xv,poly.yv,poly.zv,'r')
end
end


function vect=normalVect(varargin)
if nargin==0
    msgbox('give a 1 argoment atleast');
    vect=[];
elseif ~isnumeric(varargin{1})
    msgbox('abnormal argoment');
    vect=[];
else
   vect=varargin{1}; 
if nargin==1
    vect=(vect-min(vect(:)))./(max(vect(:))-min(vect(:)));
elseif nargin==3 ||  nargin>3
    if varargin{2}~=varargin{3}
        vect=(vect-min(vect(:)))./(max(vect(:))-min(vect(:)));
        vMin=min([varargin{2},varargin{3}]);
        vMax=max([varargin{2},varargin{3}]);
        vDif=vMax-vMin;
        vect=(vect*vDif)+vMin;
        if nargin>3
            msgbox('we used 3 argoment only');
        end
    else
        vect=(vect-min(vect(:)))./(max(vect(:))-min(vect(:)));
        msgbox('abnormal limits: normaled 0: 1');
    end
end

end
end

