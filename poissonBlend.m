function [ im_blend ] = poissonBlend( im_source, mask, im_bg )
%POISSONBLEND

[source_h, source_w, ~] = size(im_source);
[bg_h, bg_w, ~] = size(im_bg);

source_pixel_count = source_h * source_w;
bg_pixel_count = bg_h * bg_w;
im2var = zeros(bg_h, bg_w);
im2var(1:bg_pixel_count) = 1:bg_pixel_count;

% Number of identity equations
num_equations = bg_pixel_count - source_pixel_count;
% Number of blending equations
num_equations = num_equations + 4*(source_pixel_count) - (2*bg_h + 2*bg_w);

v_rgb = {};

for channel = 1:3
  sparse_i = [];
  sparse_j = [];
  sparse_k = [];
  b = zeros(num_equations, 1);
  
  e = 1; % Equation counter
  
  for y = 1:bg_h
    for x = 1:bg_w
      if ~mask(y,x)
        % Just background
        sparse_i = [sparse_i e];
        sparse_j = [sparse_j im2var(y,x)];
        sparse_k = [sparse_k 1];
        
        b(e) = im_bg(y, x, channel);
        e = e + 1;
      else
        % Neighbor Equations
        % Up
        if y ~= 1
          sparse_i = [sparse_i e];
          sparse_j = [sparse_j im2var(y,x)];
          sparse_k = [sparse_k 1];
          
          sparse_i = [sparse_i e];
          sparse_j = [sparse_j im2var(y-1,x)];
          sparse_k = [sparse_k -1];
          
          b(e) = im_source(y,x, channel) - im_source(y-1,x, channel);
          e = e + 1;
        end
        
        % Down
        if y ~= bg_h
          sparse_i = [sparse_i e];
          sparse_j = [sparse_j im2var(y,x)];
          sparse_k = [sparse_k 1];
          
          sparse_i = [sparse_i e];
          sparse_j = [sparse_j im2var(y+1,x)];
          sparse_k = [sparse_k -1];
          
          b(e) = im_source(y,x, channel) - im_source(y+1,x, channel);
          e = e + 1;
        end
        
        % Right
        if x ~= bg_w
          sparse_i = [sparse_i e];
          sparse_j = [sparse_j im2var(y,x)];
          sparse_k = [sparse_k 1];
          
          
          sparse_i = [sparse_i e];
          sparse_j = [sparse_j im2var(y,x+1)];
          sparse_k = [sparse_k -1];
          
          b(e) = im_source(y,x, channel) - im_source(y,x+1, channel);
          e = e + 1;
        end
        
        % Left
        if x ~= 1
          sparse_i = [sparse_i e];
          sparse_j = [sparse_j im2var(y,x)];
          sparse_k = [sparse_k 1];
          
          sparse_i = [sparse_i e];
          sparse_j = [sparse_j im2var(y,x-1)];
          sparse_k = [sparse_k -1];
          
          b(e) = im_source(y,x, channel) - im_source(y,x-1, channel);
          e = e + 1;
        end
      end
    end
  end
  
  A = sparse(sparse_i, sparse_j, sparse_k, num_equations, bg_pixel_count);
  v_rgb{channel} = A\b;
end

for c = 1:3
  im_blend(:,:,c) = reshape(v_rgb{c}, [bg_h bg_w]);
end

end

