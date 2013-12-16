function threshold = findImageThreshold(image, percentage)

hist = imhist(image)';
histsum = zeros(size(hist));
histsum(1) = hist(1);
for i = 2:length(histsum)
    histsum(i) = histsum(i-1) + hist(i);
end

histsum = histsum / max(histsum);

[~, c] = find(histsum > percentage);
threshold = c(1) / 256;