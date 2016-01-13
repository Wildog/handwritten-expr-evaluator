function [Array] = getPicChar()
[filename, pathname, ~]=uigetfile({'*.jpg'}, 'Chose a picture');
picstr=[pathname filename];
pic=imread(picstr);

if size(pic, 1)<800 && size(pic, 2)<2000
    filtersize = [3, 3];
else
    filtersize = [15, 15];
end
pic = rgb2gray(pic);                %转灰度图像
pic = 255 - pic;                    %反色
pic = medfilt2(pic, filtersize);    %中值滤波, 平滑图像
pic = xylimit(pic);                 %图像整体边界限定

%提取有效行
m = size(pic, 1);
Ycount = zeros(1, m);
for i=1:m
    Ycount(i) = sum(pic(i, :));
end
lenYcount = length(Ycount);
Yflag = zeros(1, lenYcount);
for k=1:lenYcount-2
    if Ycount(k)<3 && Ycount(k+1)<3 && Ycount(k+2)<3
        Yflag(k) = 1;
    end
end
for k=lenYcount:1+2
    if Ycount(k)<3 && Ycount(k-1)<3 && Ycount(k-2)<3
        Yflag(k) = 1;
    end
end
Yflag2 = [0 Yflag(1:end-1)];
Yflag3 = abs(Yflag-Yflag2);         %做差分运算
[~, row] = find(Yflag3==1);         %找突变位置
row = [1 row m];                    %调整突变位置向量
select_row = [];
for k=1:2:length(row)               %剔除高度过低的行
    if row(k+1)-row(k)>20
        select_row = [select_row row(k) row(k+1)];
    end
end
row = select_row;
row1 = zeros(1, length(row)/2);     %所截行区域开始位置向量
row2 = row1;                        %所截行区域结束位置向量
for k=1:length(row)
    if mod(k, 2)==1;                %奇数开始
        row1((k+1)/2) = row(k);
    else                            %偶数结束
        row2(k/2) = row(k);
    end
end
pic2 = pic(row1(1):row2(1), :);     %截取第一列字符
alpha = 1024/size(pic2, 2);         %计算缩放系数(标准化全图长度至1024)
pic2 = imresize(pic2, alpha);       %调整第一列字符大小为基准
for k=2:length(row)/2
    pictemp = imresize(pic(row1(k):row2(k), :), [size(pic2,1) size(pic2,2)]);
    pic2 = cat(2, pic2, pictemp);   %横向连接图像
end
pic = xylimit(pic2);                %再次边界限定

%提取有效列
[~, n] = size(pic);
Xcount = zeros(1, n);
for j=1:n
    Xcount(j) = sum(pic(:, j));
end
lenXcount = length(Xcount);
Xflag = zeros(1, lenXcount);
for k=1:lenXcount-2
    if Xcount(k)<3 && Xcount(k+1)<3 && Xcount(k+2)<3
        Xflag(k)=1;
    end
end
for k=lenXcount:1+2
    if Xcount(k)<3 && Xcount(k-1)<3 && Xcount(k-2)<3
        Xflag(k)=1;
    end
end
Xflag2 = [0 Xflag(1:end-1)];
Xflag3 = abs(Xflag-Xflag2);
[~, col] = find(Xflag3==1);
col = [1 col size(pic, 2)];
coltemp = col(2:end)-col(1:end-1);
[~, ind] = find(coltemp<3);
col(ind) = 0;
col(ind+1) = 0;
col = col(col>0);
%解决开始/结束位置丢失
if mod(length(col), 2)==1
    if col(1)~=1
        col=[1 col];
    else
        col = [col size(pic, 2)];
    end
end
%剔除宽度过低的列
select_col = [];
for k=1:2:length(col)
    if col(k+1)-col(k)>5
        select_col = [select_col col(k) col(k+1)];
    end
end
col = select_col;
%显示分割位置, 测试用
%divided=pic;
%divided(:, col)=255;
%imshow(divided);
%pause;
col1 = zeros(1, length(col)/2);
col2 = col1;
for k=1:length(col)
    if mod(k, 2)==1
        col1((k+1)/2) = col(k);
    else
       col2(k/2) = col(k);
    end
end
picnum = length(col)/2;
cells = zeros(20, 20, picnum);      %存储所有截取区域
keep = ones(picnum, 1);             %标记可用区域
for k=1:picnum
    piccell = pic(:,col1(k):col2(k));
    if sum(sum(piccell))<5000       %标记过小区域为不可用
        keep(k) = 0;
        continue;
    end
    piccell = xylimit(piccell);     %再次边界限定
    piccell = double(piccell);
    piccell = piccell./255.0;
    width = size(piccell, 2);
    height = size(piccell, 1);
    level = graythresh(piccell);
    piccell = im2bw(piccell,level);
    %截取区域居中填充为正方形
    if height>width
        finalcell = [zeros(height, floor((height-width)/2)) piccell zeros(height, ceil((height-width)/2))];
    elseif width>=height
        finalcell = [zeros(floor((width-height)/2), width); piccell; zeros(ceil((width-height)/2), width)];
    end
    finalcell = imresize(finalcell, [20 20]);
    cells(:, :, k) = finalcell;
end

keep_idx = find(keep==1);
keepnum = length(keep_idx);

load('Theta.mat');                  %加载训练所得参数

%显示分割结果
if mod(keepnum, 8)
    rownum = ceil(keepnum/8)+1;
else
    rownum = keepnum/8;
end
for k=1:keepnum;
    subplot(rownum, 8, k);
    imshow(cells(:, :, keep_idx(k)));
end

%识别分割结果
Array = zeros(keepnum, 1);
for k=1:keepnum
    image = reshape(cells(:, :, keep_idx(k)), 1, 400);
    Array(k) = predict(Theta1, Theta2, image);
end

printOCR(Array);                    %输出识别结果
