function newpic = xylimit(pic)

[m, n] = size(pic);

%纵向扫描
Ycount = zeros(1,m);
for i=1:m
    Ycount(i) = sum(pic(i, :));     %获取每一行的像素点个数
end
Ybottom = m;                        %底部定界
Yvalue = Ycount(Ybottom);
while (Yvalue<3)
    Ybottom = Ybottom-1;
    Yvalue = Ycount(Ybottom);
end
Yceil = 1;                          %顶部定界
Yvalue = Ycount(Yceil);
while(Yvalue<3)
    Yceil = Yceil+1;
    Yvalue = Ycount(Yceil);
end

%横向扫描
Xcount = zeros(1, n);
for j=1:n
    Xcount(j) = sum(pic(:, j));     %获取每一列的像素点个数
end
Xleft = 1;                          %左侧定界
Xvalue = Xcount(Xleft);
while (Xvalue<2)
    Xleft = Xleft+1;
    Xvalue = Xcount(Xleft);
end
Xright = n;                         %右侧定界
Xvalue = Xcount(Xright);
while (Xvalue<2)
    Xright = Xright-1;
    Xvalue = Xcount(Xright);
end

%截取图片
newpic = pic(Yceil:Ybottom, Xleft:Xright);
