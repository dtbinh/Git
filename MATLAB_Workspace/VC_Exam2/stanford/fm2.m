
function fm2()

% loading matched points:

load image_points1;
load image_points2;
[a b]=size(image_points1);

% finding A matrix:

for i=1:a
  
    x1=image_points1(i,1);
    y1=image_points1(i,2);
    x2=image_points2(i,1);
    y2=image_points2(i,2);
    %A(i,:)=[x1*x2 x1*y2 x1    y1*x2 y1*y2 y1 x2 y2 1];    
    A(i,:) =[x1*x2 y1*x2 x2 x1*y2 y1*y2 y2 x1 y1 1];
    
end

% svd of A:

[U D V]=svd(A);

% finding F:

f=V(:,9);

F=[f(1) f(2) f(3); f(4) f(5) f(6); f(7) f(8) f(9)];

% modify F:

[FU FD FV]=svd(F);
FDnew=FD;
FDnew(3,3)=0;

FM = FU*FDnew*FV';

save FM;

% plotiing epipolar line:

close all;
img1=imread('rodin0020.jpg');
img2=imread('rodin0021.jpg');

img1=double(rgb2gray(img1));
img2=double(rgb2gray(img2));

[m n]=size(img1);

figure,imagesc(img1);colormap(gray);title('Click a point on Left Image');axis image;
   
figure,imagesc(img2);colormap(gray);title('Corresponding Epipolar Line in Right Image');axis image;

list =['r' 'b' 'g' 'y' 'm' 'k' 'w' 'c'];

for i=0:7
    
    figure(1);    
    [lx ly] = ginput(1);
    hold on;
    plot(lx,ly,'r*');

    Pl = [lx; ly; 1];

    u = FM*Pl;

    eprx=1:2*m;
    % ax+by+c=0; y = (-c-ax)/b
    epry=(-u(3)-u(1)*eprx)/u(2);
    figure(2);
    hold on;
    plot(eprx,epry,list(mod(i,8)+1));

    % now finding the other epipolar lie
    
    e=FV(:,3);
    e=e/e(3);
    
    eplx=1:2*m;
    eply=ly + (eplx-lx)*(e(2)-ly)/(e(1)-lx);
    figure(1);
    hold on;
    plot(eplx,eply,list(mod(i,8)+1));

end
