function [Ks1, Ks2] = m_calc_gray_code(files, IT, n)
% 01 读取每一张图片进Is
[~, num] = size(files);
img = imread(files{1});
img = img(:, :, 1);
[h, w] = size(img);
Is = zeros(num, h, w);
for i = 1: num
    img = imread(files{i});
    img = img(:, :, 1);
    Is(i, :, :) = double(img);
end

% 02 计算Is_Max、Is_Min，对每个点进行阈值判断,计算出编码值
Is_max = max(Is);
Is_min = min(Is);
Is_std = (Is - Is_min) ./ (Is_max - Is_min);
gcs = Is_std > IT; 

% 03 建立 V1 - > K 的映射表
Vs1_row = zeros(1, 2 ^ n, 'uint8');
codes = m_gray_code(n);
for i = 1: 2 ^ n
    code = str2mat(codes(i)); %#ok<DSTRMT>
    V1 = 0;
    for j = 1: n
        V1 = V1 + str2num(code(j)) * 2 ^ (4 - j); %#ok<ST2NM>
    end
    Vs1_row(1, i) = V1;
end

V1K = containers.Map();
for K = 1: 2 ^ n
    V1 = Vs1_row(1, K);
    V1K(int2str(V1)) = K - 1;
end

% 04 建立 V2 - > K 的映射表
Vs2row = zeros(1, 2 ^ (n + 1), 'uint8');
gc5 = 0;
for i = 1: 2 ^ (n + 1)
    idx = round(i / 2);
    code = str2mat(codes(idx));
    r = mod(i, 4);
    if (r == 1) || (r == 0)
        gc5 = 0;
    else
        gc5 = 1;
    end
    V2 = 0; 
    for j = 1: n 
        V2 = V2 + str2num(code(j)) * 2 ^ (5 - j); %#ok<ST2NM>
    end
    V2 = V2 + gc5 * 2 ^ 0;
    Vs2row(1, i) = V2;
end
V2K = containers.Map();

for K = 1: 2 ^ (n + 1)
    V2 = Vs2row(1, K);
    k2 = floor(K / 2);
    V2K(int2str(V2)) = k2;
end

% 开始解码
Ks1 = zeros(h, w);
Ks2 = zeros(h, w);
for v = 1: h
    disp(strcat("第", int2str(v), "行"));
    for u = 1: w
        % 不需要最后黑、白两幅图片的编码
        gc1 = gcs(1: n, v, u);
        V1 = 0;
        for i = 1: n
            V1 = V1 + gc1(i) * 2 ^ (4 - i);
        end
        
        gc2 = gcs(n + 2 + 1,v, u);
        V2 = 0;
        for i = 1: n
            V2 = V2 + gc1(i) * 2 ^ (5 - i);
        end
        V2 = V2 + gc2 * 2 ^ 0;
        
        % 主要的性能瓶颈
        Ks1(v, u) = V1K(int2str(V1));
        Ks2(v, u) = V2K(int2str(V2));
    end
end
end

function [code] = m_gray_code(n)
    if (n < 1)
        disp("格雷码数量必须大于0");
        return;
    elseif (n == 1)
        % 产生0、1 两个数字
        code = ["0", "1"];
        % 返回code
    else
        code_pre = m_gray_code(n - 1);
        [~, num] = size(code_pre);
        % 初始化一个数组
        code = repmat("", 1, num * 2);
        % step1：每个字符串前面都+0
        idx = 0;
        for i = 1: num
            idx = idx + 1;
            code(idx) = "0" + code_pre(i);
        end
        % step2：翻转首个元素，其余取对称
        for i = num: -1: 1
            idx = idx + 1;
            code(idx) = "1" + code_pre(i);
        end
    end
end