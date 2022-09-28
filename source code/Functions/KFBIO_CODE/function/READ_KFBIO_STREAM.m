function block = READ_KFBIO_STREAM(block_struct,FILENAME,Magnification)

Coord = block_struct.location-1  ;

LocalPTR = struct('DataFilePTR', int64(0)) ;

[bool, LocalPTR, ~] = calllib('lib','InitImageFileFunc',LocalPTR,FILENAME) ;
if bool==0
    disp('Issue Pointer dll READ_KFBIO_STREAM')
end


[bool, datalength] = calllib('lib','GetImageStreamSize',LocalPTR,Magnification,Coord(2),Coord(1),0);
pBuffer = libpointer('uint8Ptr',zeros(datalength,1));
[bool, pBuffer] = calllib('lib','GetImageStreamBySize',LocalPTR,Magnification,Coord(2),Coord(1),datalength,pBuffer);

[bool] = calllib('lib','UnInitImageFileFunc',LocalPTR) ;


try block = decodeJpeg (pBuffer) ;
catch
    % prolly empty pbduffer? so give empty imageoutput:
    block = 255.*uint8(true([(block_struct.blockSize),3]) );
end
try
    block = block(1:block_struct.blockSize(1),1:block_struct.blockSize(2),:) ;
catch
    % disp(['some size issue? ' num2str(block_struct.location)])
    % for edges bottom mostly
    tmp = 255.*uint8(true([(block_struct.blockSize),3]) );
    tmp(1:size(block,1),1:size(block,2),:) = block ;
    block =tmp ;
    block = block(1:block_struct.blockSize(1),1:block_struct.blockSize(2),:) ;
end