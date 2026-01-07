close all;
clc; clear;
tic;

%% 01 参数配置
calib_folder = "data/calib";

N = 12;
n = 4;
num = n + 2 + 1;
B_min = 10;      % 低于这个调制度的我们就认为它的相位信息不可靠
IT = 0.5;       % 格雷码阈值
win_size = 7;   % 中值滤波窗口大小

W = 1280;
H = 720;

points_per_row = 7;
points_per_col = 6;

w = 2;
calib_file = "18.bmp";

load("data/calib/camera_imagePoints.mat");
[~, ~, calib_num] = size(imagePoints);

prjPoints = zeros(size(imagePoints));

%% 02 标定投影仪、相机

for calib_idx = 1: calib_num 
    disp(calib_idx);
    data_folder = calib_folder + "/" + num2str(calib_idx);
    % 近似查看图像圆心
    img = 255 - imread(data_folder + "/" + calib_file);
    for i = 1: points_per_row * points_per_col
        xy = imagePoints(i,  :, calib_idx);
        x = round(xy(1)); 
        y = round(xy(2));
        img(y, x) = 255;
        img(y-1, x) = 255;
        img(y + 1, x) = 255;
        img(y, x + 1) = 255;
        img(y, x - 1) = 255;
    end
    figure(); mesh(img); 
    
    %% 03 解X\Y相位
    files_phaseShiftX = cell(1, N);
    idx = 1;
    for i = 1: N
        files_phaseShiftX{i} = strcat(data_folder, "/", int2str(idx), ".bmp");
        idx = idx + 1;
    end
    files_grayCodeX = cell(1, num);
    for i = 1: num
        files_grayCodeX{i} = strcat(data_folder, "/", int2str(idx), ".bmp");
        idx = idx + 1;
    end

    files_phaseShiftY = cell(1, N);
    for i = 1: N
        files_phaseShiftY{i} = strcat(data_folder, "/", int2str(idx), ".bmp");
        idx = idx + 1;
    end

    files_grayCodeY = cell(1, num);
    for i = 1: num
        files_grayCodeY{i} = strcat(data_folder, "/", int2str(idx), ".bmp");
        idx = idx + 1;
    end

    [phaX, BX] = m_calc_absolute_phase(files_phaseShiftX, files_grayCodeX, IT, B_min, win_size);
    [phaY, BY] = m_calc_absolute_phase(files_phaseShiftY, files_grayCodeY, IT, B_min, win_size);
    
    
    phaX = phaX * W;
    phaY = phaY * H;
    
    for i = 1: points_per_row * points_per_col
        xy = imagePoints(i,  :, calib_idx);      
        x = xy(1); y = xy(2);
        x_round = round(x);
        y_round = round(y);
        % 对x、y附近对相位进行样条曲线插值
        xs = zeros(1, 2 * w + 1);
        ys = zeros(1, 2 * w + 1);
        phas_x = zeros(1, 2 * w + 1);
        phas_y = zeros(1, 2 * w + 1);
        ii = 1;
        for j = - 1 * w: w
            xs(1, ii) = x_round + j;
            ys(1, ii) = y_round + j;
            phas_x(1, ii) = phaX(y_round, xs(1, ii));
            phas_y(1, ii) = phaY(ys(1, ii), x_round);
            ii = ii + 1;
        end
        pha_x = spline(xs, phas_x, x);
        pha_y = spline(ys, phas_y, y);
        prjPoints(i,  :, calib_idx) = [pha_x, pha_y];
    end
end

save(calib_folder + "\projector_imagePoints.mat", 'prjPoints');

toc;