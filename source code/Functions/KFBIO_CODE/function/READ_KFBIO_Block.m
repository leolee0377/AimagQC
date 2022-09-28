function block = READ_KFBIO_Block(CoordX,CoordY,IMAGE_PTR,Magnification)

% 
%  IMAGE_PTR.DataFilePTR = 0 ;
%     [~, IMAGE_PTR, ~] = calllib('lib','InitImageFileFunc',IMAGE_PTR,pathimage) ;
%     %     IMAGE_PTR


[bool, datalength] = calllib('lib','GetImageStreamSize',IMAGE_PTR,Magnification,CoordY,CoordX,0);

pBuffer = libpointer('uint8Ptr',zeros(datalength,1));

[bool, pBuffer] = calllib('lib','GetImageStreamBySize',IMAGE_PTR,Magnification,CoordY,CoordX,datalength,pBuffer);


bSize = 256 ;


try block = decodeJpeg (pBuffer) ;
catch
    % prolly empty pbduffer? so give empty imageoutput:
    block = 255.*uint8(true([bSize,bSize,3]) );
end
try
block = block(1:bSize,1:bSize,:) ;
catch
   % disp(['some size issue? ' num2str(bs.location)])
   % for edges bottom mostly
    tmp = 255.*uint8(true([bSize,bSize,3]) );
    tmp(1:size(block,1),1:size(block,2),:) = block ;
    block =tmp ;
    block = block(1:bSize,1:bSize,:) ;  
end




