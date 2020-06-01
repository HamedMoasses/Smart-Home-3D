function [ newx, newy, newz]=rotateParameter(matrixObj,azel,alpha)

u = azel(:)/norm(azel);
alph = alpha*pi/180;
cosa = cos(alph);
sina = sin(alph);
vera = 1 - cosa;
x = u(1);
y = u(2);
z = u(3);
rot = [cosa+x^2*vera x*y*vera-z*sina x*z*vera+y*sina; ...
    x*y*vera+z*sina cosa+y^2*vera y*z*vera-x*sina; ...
    x*z*vera-y*sina y*z*vera+x*sina cosa+z^2*vera]';
try
x = matrixObj.x;
y = matrixObj.y;
z = matrixObj.z;
catch
x = matrixObj.XData ;
y = matrixObj.YData ;
z = matrixObj.ZData ;   
      
end

[m,n] = size(z);
if numel(x) < m*n
    [x,y] = meshgrid(x,y);
end

[m,n] = size(x);
newxyz = [x(:) , y(:) , z(:) ];
newxyz = newxyz*rot;
newx =   reshape(newxyz(:,1),m,n);
newy =  reshape(newxyz(:,2),m,n);
newz =  reshape(newxyz(:,3),m,n);

end