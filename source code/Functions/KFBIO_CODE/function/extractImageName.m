function ImageName = extractImageName(ImagePath,fileformat)
%fileformat = '.tif' ;



tmp = strsplit(ImagePath,filesep) ;
tmp = strsplit(tmp{end},fileformat) ;
ImageName = tmp{1} ;
