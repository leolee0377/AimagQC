function DownsizeCoef = Path_QC_Magtodownsize(MagDropdownValue)
% downsize coefficient associated to image acquisition  magnification
% Author: Laurent GOLE, AIMAGINOSTIC PTE LTD ®. All Rights Reserved ©, 2020.

%app.MagnificationDropDown.Items
switch lower(MagDropdownValue)
    case '4x'
        DownsizeCoef = 1;
    case '10x'
        DownsizeCoef = 2;
    case '20x'
        DownsizeCoef = 4;
    case '40x'
        DownsizeCoef = 8;
    otherwise
        disp('default downsize is set at 4')
        DownsizeCoef = 4;
end