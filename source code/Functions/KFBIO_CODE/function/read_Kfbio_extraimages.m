function Image = read_Kfbio_extraimages(IMAGE_PTR,function1,function2)



 
 [bool, datalength] = calllib('lib',function1,IMAGE_PTR,0);
 pBuffer = libpointer('uint8Ptr',zeros(datalength,1));
 [bool, pBuffer, w, h] = calllib('lib',function2,IMAGE_PTR, pBuffer, 0, 0, datalength);
 
 
 
 Image = decodeJpeg (pBuffer) ;
 