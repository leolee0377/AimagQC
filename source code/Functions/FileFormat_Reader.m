function ReaderIO = FileFormat_Reader(ImageFile,Reader)
% specify which image reader to use based on file format
% Author: Laurent Gole, A!maginostic™. All Rights Reserved, 2020.

switch Reader
    
%     case 'VectraPolaris'
%         ReaderIO = VectraPolarisIO([ImageFile]) ; %#ok<*NBRAK>
    case 'KFBIO'
        ReaderIO = KFBIO_IO([ImageFile]) ;
%     case 'KFBIO_tif'
%         ReaderIO = KFIO([ImageFile]) ;
%     case 'Aperio'
%         ReaderIO = Aperio_svsIO([ImageFile]) ;
%     case 'Leica'
%           ReaderIO = Leica_ScnIO([ImageFile]) ;
%     case 'Olympus'
%         % reader to be developped.
%     case 'Zeiss'
%         % reader to be developped.
%     case 'Philips'
%         % reader to be developped.
%     case 'General?'
%         
%     case 'OME_TIF'
%         ReaderIO = OmeTiff_IO([ImageFile]) ; 
%         % to allow for multiple type of image to be processed.
    otherwise
        disp('Unknown file format')
        ReaderIO = [] ;
end