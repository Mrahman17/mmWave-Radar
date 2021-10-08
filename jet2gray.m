function final_img=jet2gray(input_img)
img_color=imread(input_img);
mapsize = 256;
map = jet(mapsize);
ind = rgb2ind(img_color, map);

colormap(map)
immm=image(ind)
colormap('gray')

newImg=immm.CData;
colormap('gray')
final_img=cat(3,newImg,newImg,newImg);