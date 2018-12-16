% CPLOTTER   Plots a contour.
% (scheme package)
%
% HP = cplotter (c, color, DD)
% ----------------------------
%
% plots a 2D contour obtained from contourc (see "contourc"). A contour is
% defined by:
% c = [contour1         x1 x2 x3 ... contour2         x1 x2 x3 ...;
%      #number_of_pairs y1 y2 y3 ... #number_of_pairs y1 y2 y3 ...]'
%
% Input
% -----
% - c::contour: as obtained from contour function
% - color::RGB 3-tupel, vector or matrix: RGB values {DEFAULT [0 0 0]}
% - DD:: XYZ-tupel: coordinates offset {DEFAULT [0,0,0]}
%
% Output
% ------
% - HP::handles: depending on options HP links to the graphical objects.
%
% Example
% -------
% c = hull_tree (sample_tree, 5, [], [], [], '-2d');
% cplotter (c);
%
% See also hull_tree cpoints
% Uses
%
% the TREES toolbox: edit, visualize and analyze neuronal trees
% Copyright (C) 2009  Hermann Cuntz

function HP = patchplotter (c, color, DD)

if (nargin<2)||isempty(color),
    color = [0 0 0]; % {DEFAULT color: black}
end

if (nargin<3)||isempty(DD),
    DD = [0 0 0]; % {DEFAULT 3-tupel: no spatial displacement from the root}
end
if length (DD) < 3,
    DD = [DD zeros(1, 3 - length (DD))]; % append 3-tupel with zeros
end

hold on;
iic     = 1;
counter = 1;
HP      = [];
while iic < size (c, 1),
    ic = c (iic, 2);
    CC = c (iic + 1 : iic + ic, :);
    HP (counter) = plot (CC (:, 1) + DD (1), CC (:, 2) + DD (2),  'k');
    if iic == 1
         patch(CC (:, 1) + DD (1), CC (:, 2) + DD (2),  'r','EdgeColor','none');
    else
        patch(CC (:, 1) + DD (1), CC (:, 2) + DD (2),  color,'EdgeColor','none');
    end
    iic = iic + ic + 1;
    counter = counter + 1;
end

