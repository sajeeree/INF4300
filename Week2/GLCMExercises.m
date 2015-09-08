%% Week 2 : GLCM exercise
% In this exercise we will implement GLCM texture features. This code is
% strongly linked to the lecture about texture so you need to study this
% to be able to understand this code. Please let me know about any errors
% in the code
%
% I have structured all the code for this week into three functions. The
% CLCMExercise is the "main" function calling and running the two other
% funtions glidingGLCM and GLCM. See the other functions for more detailed
% descriptions.


function [img, glcmVar, glcmCtr, glcmEnt] = GLCMExercise()
%clear all
close all

%% Task 1
% This task is to implement code
% Testing my GLCM implementation
testImage = [0 0 1 1; 0 0 1 1; 0 2 2 2; 2 2 3 3]
disp('Parameters: dx = 1, dy = 0, gives this result:');
GLCM(testImage,4,1,0,0,0)
disp('Parameters: dx = 0, dy = 1, gives this result:');
GLCM(testImage,4,0,1,0,0)

% Read the input image
img = imread('zebra_2.tif');

% All zebra images have 2^4 = 16 possible intensities. 'zebra_1.tif' stores
% these using an 8 bits intensity range (the other images uses 4 bits as
% they should do). To convert the read 'zebra_1.tif' to use a 4 bits
% intensity range, use e.g.:

%img = uint8(floor(double(img)/16)); % only when using 'zebra_1.tif'
figure(1), imshow(img, []) % notice the black-and-white frame in 'zebra_1.tif'
title('Original image');

G = 8; % We just want to use G gray levels

% Make the histogram (approx.) uniform with G grey levels.
% See the curriculum for INF2310 if you do not know histogram equalization
img_std = histeq(img,G);
img_std = uint8(round(double(img_std) * (G-1) / double(max(img_std(:)))));

figure(2); imshow(img_std, [0 G-1])
title('Image after histogram equalization');
% Lets look at the histograms of the original image and the image after
% histogramequalization
figure(2);
subplot(211)
h = imhist(img);
plot([0:255],h/sum(h),'linewidth',2);
xlim([0 15])
title('Normalized histogram of original image');
subplot(212)
h = imhist(img_std);
plot([0:255],h/sum(h),'linewidth',2);
xlim([0 15])
title('Normalized histogram of image after histeq');

disp('Original image consists of these values:')
unique(img)'
disp('Image after histeq and normalization has these values:');
unique(img_std)'

% Define GLCM-parameters.
windowSize = 31;
dx = 0;
dy = 2;

% Call the function to calculate the feature images with gliding GLCM
[glcmVar,glcmCtr,glcmEnt] = glidingGLCM(img_std,G,dx,dy,windowSize);

%% Task 2 : Treshold the GLCM feature images
% We want to treshold the resulting GLCM variance, GLCM contrast and GLCM
% entropy

% Display the results
figure(3);clf
subplot(211)
imshow(glcmVar, []); title('GLCM Variance');
subplot(212)
imshow(img.*uint8(glcmVar > (max(glcmVar(:)) * 0.5)),[])
title('Image thresholded with GLCM Variance');

figure(4);clf
subplot(211)
imshow(glcmCtr, []); title('GLCM Contrast');
subplot(212)
imshow(img.*uint8(glcmCtr > (max(glcmCtr(:)) * 0.2)),[]);
title('GLCM Contrast thresholded');

figure(5);clf
subplot(211)
imshow(glcmEnt, []); title('GLCM Entropy' );
subplot(212)
imshow(img.*uint8(abs(glcmEnt) < (max(abs(glcmEnt(:))) * 0.7)),[]);
title('GLCM Entropy tresholded');

%% Task 3: Compare with first order texture measurements
% Here we want to use the first order texture measures variance and entropy
% using the built in matlab functions stdfilt and entropyfilt

% Remember that the variance is the square of the standard deviation
std_var = stdfilt(img, ones(windowSize)).^2;
figure(6), subplot(211), imshow(std_var, []), title('Variance');
subplot(212), imshow(img.*uint8(std_var > (max(std_var(:)) * 0.25)),[])
title('Tresholded Variance')

% See page 532 in Gonzales and woods for a definition on entropy ("average
% information")
std_ent = entropyfilt(img, ones(windowSize));
figure(7), subplot(211), imshow(std_ent, []), title('Entropy' );
subplot(212), imshow(img.*uint8(std_ent > (max(std_ent(:)) * 0.6)),[])
title('Tresholded entropy')

% Variance on image after histeq
std_var_of_img_std = stdfilt(img_std, ones(windowSize)).^2;
figure(8), subplot(211), imshow(glcmVar, []), title('GLCM Variance');
subplot(212), imshow(std_var_of_img_std, []), title('Variance')

%% Task 4: Using Laws texture mask to find texture features
% See the lecture foils for more info on Laws texture masks

% "Building blocks" for Laws 3x3 texture masks
L3 = [ 1  2  1];
E3 = [-1  0  1];
S3 = [-1  2 -1];

% "Building blocks" for Laws 5x5 texture masks are made from the X3 masks
L5 = conv2(L3, L3, 'full')
E5 = conv2(L3, E3, 'full');
S5 = conv2(L3, S3, 'full');
W5 = conv2(E3, S3, 'full'); % not mentioned in the lecture notes
R5 = conv2(S3, S3, 'full');

% A 5x5 mask
E5E5 = conv2(E5', E5, 'full');

laws_energy = imfilter(double(img), E5E5, 'symmetric', 'conv');
figure(10);
imshow(laws_energy, [])

laws_mean_abs_feat = imfilter(abs(laws_energy), ones(35), 'symmetric');
figure(9);
subplot(121)
imshow(laws_mean_abs_feat, [])
subplot(122),
imshow(laws_mean_abs_feat > (max(laws_mean_abs_feat(:)) * 0.2))

laws_std_feat  = stdfilt(laws_energy, ones(35));
figure(10)
subplot(121)
imshow(laws_std_feat,[])
subplot(122)
imshow(laws_std_feat > (max(laws_std_feat(:))* 0.25))

end

%% Function for Task 1 : Gliding window GLCM
% The function glidingGLCM takes as input a gray level image, the window
% size, the number of graylevels, the GLCM parameters dx and dy, and my
% implemetation takes in a number of functions in the "fun" argument.

function[glcmVar,glcmCtr,glcmEnt] = glidingGLCM(img,G,dx,dy,windowSize)
%GlidingGLCM
% Calulates the GLCM and the feature in fun for
% every gliding window in img. It is first added
% a frame of ones around img to make sure that the
% resulting feature images is the same size as img.

[Mo,No] = size(img);            %Size of original image
halfSize = floor(windowSize/2); %Size of "half" the filter

% Expand the original image with a zero border
imgWithBorders = zeros(Mo+windowSize-1, No+windowSize-1);
imgWithBorders(halfSize:end-halfSize-1,halfSize:end-halfSize-1) = img;

figure(100)
imagesc(imgWithBorders);
colormap gray
title('The resuting image with borders')

% Size of the image with borders
[M,N] = size(imgWithBorders);

% Index matrices. These are needed for the online implementation of the
% GLCM features
i = repmat((0:(G-1))', 1, G);
j = repmat( 0:(G-1)  , G, 1);

% Defining buffers for the resulting glcm feature images
glcmVar = zeros(Mo,No);
glcmCtr = zeros(Mo,No);
glcmEnt = zeros(Mo,No);


% Go through the image
for m = 1+halfSize:M-halfSize-1
    for n = 1+halfSize:N-halfSize-1
        
        % Extracting the wanted window
        window = imgWithBorders(m-halfSize:m+halfSize,n-halfSize:n+halfSize);
        % Calculate the
        p = GLCM(window,G, dx,dy,0,0);
        
        % Compute GLCM's variance feature.
        mu = mean(window(:));
        glcmVar(m-halfSize,n-halfSize) = sum(sum(p .* ((i-mu).^2)));
        % Computed using for-loops:
        % for i = 0:(G-1)
        %     for j = 0:(G-1)
        %         glcm_var(m,n) = glcm_var(m,n) + p(i+1,j+1) * (i-mu)^2;
        %     end
        % end
        
        % Compute GLCM's contrast feature.
        glcmCtr(m-halfSize,n-halfSize) = sum(sum(p .* ((i - j).^2)));
        % Computed using for-loops:
        % for i = 0:(G-1)
        %     for j = 0:(G-1)
        %         glcm_ctr(m,n) = glcm_ctr(m,n) + p(i+1,j+1) * (i-j)^2;
        %     end
        % end
        
        % Compute GLCM's entropy feature (with base 2).
        glcmEnt(m-halfSize,n-halfSize) = -sum(p(p>0) .* log2(p(p>0)));
    end
end
end


%% Function for Task 1 : The GLCM function
function [glcm] = GLCM(img,G,dx,dy,normalize,symmetric)
%GLCM calculates the GLCM (Gray Level Coocurrence
%Matrices) of an image
%   img         : the input image
%   G           : number of gray levels
%   dx          : distance in x-direction
%   dy          : distance in y-direction
%   normalize   : if 1 normalize by pixel pairs
%                 so sum(glcm(:)) = 1
%   symmetric   : if 1 make GLCM matrix symmetric
[N,M] = size(img);
glcm = zeros(G);

% For the image go through the entire image and count how many transitions
% from the first to the second graylevel
for i = 1:N
    for j = 1:M
        if i+dy < N && j+dx<M
            firstGLevel = img(i,j);
            secondGLevel = img(i+dy,j+dx);
            glcm(firstGLevel+1, secondGLevel+1) = ...
                glcm(firstGLevel+1, secondGLevel+1) + 1;
        end
    end
end

% If we want a symmetric GLCM add the transpose. Read about the symmetric
% GLCM in the book or the lecture foils. It is basically counting both 2,1
% and 1,2 graylevel. Thus "counting both ways".
if symmetric
    glcm = glcm+glcm';
end
% If we want to normalize the GLCM
if normalize
    glcm = glcm/sum(sum(glcm));
end
end