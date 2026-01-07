%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Calibration using the linear triangular stereo model.
% Related Reference:
% "Calibration of fringe projection profilometry: A comparative review"
% Shijie Feng, Chao Zuo, Liang Zhang, Tianyang Tao, Yan Hu, Wei Yin, Jiaming Qian, and Qian Chen
% last modified on 07/27/2020
% by Shijie Feng (Email: shijiefeng@njust.edu.cn)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Clear everything existing.
close all;
clc; clear;

%% step1：标定相机
tic;
points_per_col_x = 6; %number of circles in the x direction of the calibration board
points_per_row = 7;  % 棋盘格



dist_circ = 10; %distance between neighbouring centers(in millimetre)
calib_dir = "data/calib/";


disp('开始相机标定...');

% 角点的像素坐标系（每个棋盘格中心）
load(calib_dir + 'camera_imagePoints.mat'); % load the camera image points of the centers

% 角点的世界坐标系
worldPoints = generateCheckerboardPoints([points_per_row + 1,points_per_col_x + 1], dist_circ); 

% 标定相机
[cameraParams,imagesUsed,estimationErrors] = estimateCameraParameters(imagePoints,worldPoints, 'EstimateTangentialDistortion', true);

figure;showReprojectionErrors(cameraParams);title('相机标定的重投影误差');
figure;showExtrinsics(cameraParams);title('相机标定的外参');


% save Rc_1, Tc_1, KK, inv_KK,
% 相机相对于世界坐标系原点的位姿（旋转+平移）
Rc_1 = cameraParams.RotationMatrices(:,:,1); 
Rc_1 = Rc_1';    % 转置
Tc_1 = cameraParams.TranslationVectors(1, :);
Tc_1 = Tc_1'; 
KK = cameraParams.IntrinsicMatrix';  % 相机内参
save('CamCalibResult.mat', 'Rc_1', 'Tc_1', 'KK');

%% step2: 标定投影仪
disp('开始投影仪标定...');
% 加载投影仪下圆心的像素坐标
load(calib_dir + 'projector_imagePoints.mat'); % load the projector image points of the centers
% 圆心的世界坐标
worldPoints = generateCheckerboardPoints([points_per_row+1,points_per_col_x+1], dist_circ);
[prjParams,imagesUsed,estimationErrors] = estimateCameraParameters(prjPoints,worldPoints, 'EstimateTangentialDistortion', true);
figure; showReprojectionErrors(prjParams); title('投影仪的重投影误差');
figure; showExtrinsics(prjParams);title('投影仪的外参');

% 保存参数
Rc_1 = prjParams.RotationMatrices(:,:,1);
Rc_1 = Rc_1';
Tc_1 = prjParams.TranslationVectors(1, :);
Tc_1 = Tc_1';
KK = prjParams.IntrinsicMatrix';
save('PrjCalibResult.mat', 'Rc_1', 'Tc_1', 'KK');
