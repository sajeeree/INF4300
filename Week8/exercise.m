%% Multivariate Gaussian classifier% We are provided with a Landsat sattelite image containing 6 image% "bands". We will use each of these bands as a feature image. Lets load% them, I'm saving them in a so called cell array.tm = cell(6,1);tm{1} = imread('tm1.png');tm{2} = imread('tm2.png');tm{3} = imread('tm3.png');tm{4} = imread('tm4.png');tm{5} = imread('tm5.png');tm{6} = imread('tm6.png');% We are also going to need these training and test masks. These masks% indicate what pixels are known to belong to each class. Thus indicating% what pixels we should use for training, and what pixels we can use to% validate the result (test).tm_train = imread('tm_train.png');tm_test = imread('tm_test.png');figure(1)subplot(211)imshow(tm{1},[]);colorbartitle('Feature 1');subplot(212)imshow(tm{2},[]);colorbartitle('Feature 2');figure(2)subplot(211)imshow(tm{3},[]);colorbartitle('Feature 3');subplot(212)imshow(tm{4},[]);colorbartitle('Feature 4');figure(3)subplot(211)imshow(tm{5},[]);colorbartitle('Feature 5');subplot(212)imshow(tm{6},[]);colorbartitle('Feature 6');figure(4)subplot(211)imagesc(tm_train);colorbaraxis imagetitle('Training mask');subplot(212)imagesc(tm_test);colorbaraxis imagetitle('Test mask');drawnow%% Let's do the classification[M,N] = size(tm_train);res_train = zeros(M,N);res_test = zeros(M,N);% I have one implementation where I train the classifier, but also run the% classifier on the trining data. Giving me the accuarcy for the classifier% on the traning data[class_img,error_train,confusion_train,u,c] = trainMultiGaussClassifier(tm,tm_train);% The second implementation takes the mean values (u) and the covariance% matrices (c) from the traning part and classifies the image. From this I% calculate the accuracy on the test part of the image[class_img2,error_test,confusion_test] = multiGaussClassifierNoTraining(tm,tm_test,u,c);% Note that the two classified images will be the sam (class_img and% class_img2) the difference is which mask I use.% Lets make the resulting image within the training masksres_train(tm_train==1) = class_img(tm_train==1);res_train(tm_train==2) = class_img(tm_train==2);res_train(tm_train==3) = class_img(tm_train==3);res_train(tm_train==4) = class_img(tm_train==4);% And within the test masksres_test(tm_test==1) = class_img(tm_test==1);res_test(tm_test==2) = class_img(tm_test==2);res_test(tm_test==3) = class_img(tm_test==3);res_test(tm_test==4) = class_img(tm_test==4);% And display themfigure(5);imagesc(class_img);title('Classified image');colormap jetdrawnowfigure(6);imagesc(res_train);title('Classified pixels in training masks');colormap jetdrawnowfigure(7)imagesc(res_test);title('Classified pixels in test masks');colormap jetdrawnow% Lets load  the tm_classres load tm_classresfigure(8)imagesc(klassim)title('Given classification (from tm classres)');colormap jetdrawnowp = sum(sum(class_img == klassim))*100/(N*M);fprintf('Comparing my result with tm_classres: %f \n',p);error_trainconfusion_trainerror_testconfusion_test%% Exercise 4, (named Exercise 3) see the note for detailsC = [1.2 0.4; 0.4 1.8];mu1 = [0.1 ; 0.1];mu2 = [2.1 ; 1.9];mu3 = [-1.5 ; 2.0];x = [1.6 ; 1.5];g1 = -(1/2)*(x-mu1)'*inv(C)*(x-mu1)g2 = -(1/2)*(x-mu2)'*inv(C)*(x-mu2)g3 = -(1/2)*(x-mu3)'*inv(C)*(x-mu3)[a,c] = max([g1 g2 g3]);c%% Exercise 5, (named Exercise 4) see the note for detailsC = [1.1 0.3; 0.3 1.9];mu1 = [0 ; 0];mu2 = [3 ; 3];x = [1.0 ; 2.2];g1 = -(1/2)*(x-mu1)'*inv(C)*(x-mu1)g2 = -(1/2)*(x-mu2)'*inv(C)*(x-mu2)[a,c] = max([g1 g2]);c% post_id = 642; %delete this line to force new post;% permaLink = http://inf4300.olemarius.net/2015/10/27/exercise-m-2/;