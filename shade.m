% Shade the area between two curves
function shade(x,y1,y2,color_shade)

% Fill the area between the curves
p=fill([x, fliplr(x)], [y1, fliplr(y2)], color_shade, 'FaceAlpha', 0.075,'LineWidth',.1);
p.EdgeColor='None';
hold on