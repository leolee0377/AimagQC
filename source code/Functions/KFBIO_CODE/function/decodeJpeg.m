function img = decodeJpeg (byteArray)
%decodeJpeg decodes jpeg to a color image.
%
% INPUT:   an array [1 x N] of uint8
% OUTPUT:  color image
%
% USAGE:
%   % get a stream of bytes representing an endcoded JPEG image
%   fid = fopen('test.jpg', 'rb');
%   data = fread(fid, Inf, '*uint8');
%   fclose(fid);
%
%   % decode jpeg
%   img = decodeJpeg(data);
%
%   % check results against directly reading the image using IMREAD
%   img2 = imread('test.jpg');
%   assert(isequal(img,img2))
%
% Taken directly from:
%   http://stackoverflow.com/questions/18659586/from-raw-bits-to-jpeg-without-writing-into-a-file
% Thanks user Amro for this
assert (isa(uint8(byteArray), 'uint8'));
% decode image stream using Java
jImg = javax.imageio.ImageIO.read(java.io.ByteArrayInputStream(byteArray));
h = jImg.getHeight;
w = jImg.getWidth;
% convert Java Image to MATLAB image
p = reshape(typecast(jImg.getData.getDataStorage, 'uint8'), [3,w,h]);
img = cat(3, ...
        transpose(reshape(p(3,:,:), [w,h])), ...
        transpose(reshape(p(2,:,:), [w,h])), ...
        transpose(reshape(p(1,:,:), [w,h])));
end
    