function get_bearing, lat1, lon1, lat2, lon2

dLon = lon2 - lon1
y = sin(dLon) * cos(lat2);
x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon);
brng = atan(y, x) * 180/!dpi;

return, brng
end