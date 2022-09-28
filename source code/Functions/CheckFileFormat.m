function formatCheck = CheckFileFormat(ListofImages,fileFormat)
% Check the image file input format
% Author: Laurent GOLE, AIMAGINOSTIC PTE LTD ®. All Rights Reserved ©, 2020.


warning('off','imageio:tifftagsread:expectedTagDataFormat') ;


switch fileFormat
    
    case '.kfb'
        Type = 'KFBIO_SDK' ;
    case '.kfbf'
        Type = 'KFBIO_SDK' ;
    case '.tif'
        Type = 'Pyramid_tif' ;
    case '.Qptiff'
        Type = 'Pyramid_tif' ;
    case '.scn'
        Type = 'Pyramid_tif' ;
    case '.svs'
        Type = 'Pyramid_tif' ;
        
    case '.ome.tif'
        Type = 'OmeTif' ;
        
end


switch Type
    
    case 'KFBIO_SDK'
        
        for i = 1:numel(ListofImages)
            %   disp('i guess we ll skip for now, need to laod library and all ')
            formatCheck(i) = 1 ; %#ok<*AGROW>
        end
    case 'Pyramid_tif'
        
        for i = 1:numel(ListofImages)
            W =  imfinfo(ListofImages{i}) ;
            
            try ID = W.ImageDescription ;
                
                if numel(W)<2
                    disp('this image is not in pyramid format')
                    formatCheck(i) = 0 ;
                    
                elseif contains(ID,' J2K/')
                    disp('this image jpeg2000 compression format is not supported')
                    formatCheck(i) = 1 ;
                else
                    formatCheck(i) = 1 ;
                end
                
            catch
                disp('this image is not in pyramid format')
                formatCheck(i) = 0 ;
            end
            
        end
        
    case 'OmeTif'
        for i = 1:numel(ListofImages)
            
            if contains(ListofImages{i},'.ome.tif')
                formatCheck(i) = 1 ;
            else
                formatCheck(i) = 0 ;
            end
        end
end







