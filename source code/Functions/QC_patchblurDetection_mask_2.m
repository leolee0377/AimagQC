function blockorg = QC_patchblurDetection_mask_2(pathimage,bs,PageIndex,OutputPath,slideID,MASK,ImageType,ffmt)
% Patch Generator KEY QUALITY CONTROL ANALYSIS CODE!
% input :
% # path to QPtiff image
% # block structure of the blockproc function
% # page index of the channel to process ( highResolution Pages only)
% # outputpath
% # Name of the file
% # Intensity based simple trheshold for filtering tiles ( graythresh like)
% Author: Laurent GOLE, AIMAGINOSTIC PTE LTD ®. All Rights Reserved ©, 2020.
% Author: Laurent GOLE, A*STAR, IMCB ®. All Rights Reserved ©, 2019.

switch ffmt
    
    case 'KFBIO'
        Coord = bs.location-1  ;
        IMAGE_PTR.DataFilePTR = 0 ;
        [~, IMAGE_PTR, ~] = calllib('lib','InitImageFileFunc',IMAGE_PTR,pathimage) ;
        %     IMAGE_PTR
        [~, datalength] = calllib('lib','GetImageStreamSize',IMAGE_PTR,PageIndex,Coord(2),Coord(1),0);
        pBuffer = libpointer('uint8Ptr',zeros(datalength,1));
        [~, pBuffer] = calllib('lib','GetImageStreamBySize',IMAGE_PTR,PageIndex,Coord(2),Coord(1),datalength,pBuffer);
        
        
        try block = decodeJpeg (pBuffer) ;
        catch
            % prolly empty pbduffer? so give empty imageoutput:
            block = 255.*uint8(true([(bs.blockSize),3]) );
        end
        try
            block = block(1:bs.blockSize(1),1:bs.blockSize(2),:) ;
        catch
            % disp(['some size issue? ' num2str(bs.location)])
            % for edges bottom mostly
            tmp = 255.*uint8(true([(bs.blockSize),3]) );
            tmp(1:size(block,1),1:size(block,2),:) = block ;
            block =tmp ;
            block = block(1:bs.blockSize(1),1:bs.blockSize(2),:) ;
        end
        
        
    otherwise

        block = imread(pathimage,'Index',PageIndex,'PixelRegion',...
            {[bs.location(1) bs.location(1)+bs.blockSize(1)-1],...
            [bs.location(2) bs.location(2)+bs.blockSize(2)-1]}) ;     
end



blockorg = block ;




try BLOCKMASK  = MASK([bs.location(1):bs.location(1)+bs.blockSize(1)-1],...
        [bs.location(2):bs.location(2)+bs.blockSize(2)-1]) ; %#ok<NBRAK>
catch
    BLOCKMASK  = false(bs.blockSize(1),bs.blockSize(2)) ;
end








% MEASURE ONLY WHEN THE MASK COVERS MORE THAN 10% of the TILE
if sum(sum(BLOCKMASK))> (0.1*bs.blockSize(1)*bs.blockSize(2))  
    % CONVERTION TO OPTICAL DENSITY IMAGE FOR H&E INPUT:
    if strcmp(ImageType,'BrightField')
        [x, y, z] = size(block) ;
        Image   = double(block)                    ;
        I0      = 255                           ;
        % calculate optical density image :
        OD      = -log((Image+1)/I0)            ;
        ODim    = reshape(OD,[x, y, z])           ;
        ODim    = uint8(255.*ODim)              ;
        %ODg     = rgb2gray(ODim)                ;
        ODg     = ODim ;
        block = ODg ;
        block =  rgb2gray(block) ;
    end     
    % CONVERTION TO OPTICAL DENSITY IMAGE FOR H&E INPUT:
    if strcmp(ImageType,'BrightField') 
    [FM,BM,SM,CM,TM] = QC_imageMeasurements_BF_2(BLOCKMASK,block) ;
    else 
    [FM,BM,SM,CM,TM] = QC_imageMeasurements_MF_2(BLOCKMASK,block) ;
    end
    %AreaWeight
    AW = sum(BLOCKMASK(:)) ./ (size(BLOCKMASK,1)*size(BLOCKMASK,2)) ; 
    % output block image with Location and measured values:
    imwrite(blockorg,[OutputPath filesep  slideID 'Loc_' num2str(bs.location)...
        '_FM_' num2str(FM) '_BM_' num2str(BM)...
        '_SM_' num2str(SM) '_CM_' num2str(CM)...
        '_TM_' num2str(TM) '_AW_' num2str(AW)...
        '.png']) ;    
end

end


