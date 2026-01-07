% 版权：3D视觉工坊
% 作者：天涯居士
% 日期：2022.2.22
% 邮箱：fly_cjb@163.com

close all;
clc; clear;
tic;

%% 01 参数配置
save_folder = "data/project"; mkdir(save_folder);
save_file_csv = strcat(save_folder, "/","patterns.csv");  % 用于写入到投影仪

W = 1280;
H = 720;
A = 130;
B = 90;
N = 12;

n = 4;
T_X = W / (2 ^ n);
T_Y = H / (2 ^ n);

%% 02 生成相移法图像
[~, patterns_phaseshift_X] = m_make_phase_shift_patterns(A, B, T_X, N, W, H);
[~, patterns_phaseshift_Y_t] = m_make_phase_shift_patterns(A, B, T_Y, N, H, W);
patterns_phaseshift_Y = zeros(size(patterns_phaseshift_X));
for i = 1: N
    patterns_phaseshift_Y(i, :, :) = squeeze(patterns_phaseshift_Y_t(i, :, :))';
end

%% 03 生成格雷码图像
patterns_graycode_X = m_make_gray_code_patterns(n, W, H);
patterns_graycode_Y_t =  m_make_gray_code_patterns(n, H, W);
patterns_graycode_Y = zeros(size(patterns_graycode_X));
for i = 1: n + 2
    patterns_graycode_Y(i, :, :) = squeeze(patterns_graycode_Y_t(i, :, :))';
end

%% 04 生成互补格雷码
patterns_supplement_X = zeros(H, W);
for i = 0: W - 1
    x = floor(i / (T_X / 2));
    r = mod(x, 4);
    if (r == 1) || (r == 2)
        patterns_supplement_X(:, i) = 255;
    end     
end
patterns_supplement_Y = zeros(W, H);
for i = 0: H -1
    y = floor(i / (T_Y / 2));
    r = mod(y, 4);
    if (r == 1) || (r == 2)
        patterns_supplement_Y(:, i) = 255;
    end 
end
patterns_supplement_Y = patterns_supplement_Y';
%% 05 写入图片
idx = 0;

%% X方向
for i = 1: N
    idx = idx + 1;
    % 写入图片
    save_file_img = strcat(save_folder, "/", int2str(idx), ".bmp"); 
    disp("写入文件到:" + save_file_img);
    img = squeeze(patterns_phaseshift_X(i, :, :));
    imwrite(img, save_file_img);
end

% 写入X方向格雷码
for i = 1: n + 2
    idx = idx + 1;
    % 写入图像
    save_file_img = strcat(save_folder, "/", int2str(idx), ".bmp");
    disp("写入文件到:" + save_file_img);
    img = squeeze(patterns_graycode_X(i, :, :));
    imwrite(img, save_file_img);
end

% 写入互补格雷码
idx = idx + 1;
save_file = strcat(save_folder, "/", int2str(idx), ".bmp");
disp("写入文件到:" + save_file);
imwrite(patterns_supplement_X, save_file);

%% Y方向
for i = 1: N
    idx = idx + 1;
    % 写入图片
    save_file_img = strcat(save_folder, "/", int2str(idx), ".bmp"); 
    disp("写入文件到:" + save_file_img);
    img = squeeze(patterns_phaseshift_Y(i, :, :));
    imwrite(img, save_file_img);
end

% 写入X方向格雷码
for i = 1: n + 2
    idx = idx + 1;
    % 写入图像
    save_file_img = strcat(save_folder, "/", int2str(idx), ".bmp");
    disp("写入文件到:" + save_file_img);
    img = squeeze(patterns_graycode_Y(i, :, :));
    imwrite(img, save_file_img);
end

% 写入互补格雷码
idx = idx + 1;
save_file = strcat(save_folder, "/", int2str(idx), ".bmp");
disp("写入文件到:" + save_file);
imwrite(patterns_supplement_Y, save_file);

disp("写入完成");
toc;