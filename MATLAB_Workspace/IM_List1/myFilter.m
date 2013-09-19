function filteredImg = myFilter(image, mask, options)

% Convolutes the provided 'mask' to the 'image' using the Matlab function
% imfilter. 'options' determine how negative values should be handled

filteredImg = imfilter(double(image),mask, 'symmetric', 'same', 'conv');

if(strcmp(options,'abs-uint8'))
    filteredImg = abs(filteredImg);
    filteredImg = filteredImg - min(min(filteredImg));
    filteredImg = filteredImg * 255.0 / max(max(filteredImg));
    filteredImg = uint8(filteredImg);
elseif(strcmp(options,'uint8'))
    filteredImg = filteredImg - min(min(filteredImg));
    filteredImg = filteredImg * 255.0 / max(max(filteredImg));
    filteredImg = uint8(filteredImg);
elseif(strcmp(options,'uint8-noscale'))
    filteredImg = uint8(filteredImg);
end