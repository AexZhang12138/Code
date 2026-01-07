%% 生成互补格雷码

function [patterns] = m_make_gray_code_patterns(n, W, H)
    codes = m_gray_code(n);
    % 将字符串格雷码转换为矩阵格式
    [~, num] = size(codes);
    codes_mat = zeros(n, num, 'int8');
    for col = 1: num
        code_col = str2mat(codes(col)); %#ok<DSTRMT>
        for row = 1: n
            codes_mat(row, col) = str2num(code_col(row)); %#ok<ST2NM>
        end
    end
    W_per = round(W / num);
    % 每张图片
    patterns = zeros(n + 2, H, W, "uint8");
    for idx = 1: n
        % 一行图片
        row_one = zeros(1, W, "uint8");
        % 每个格子
        for i = 1 : num
            gray = codes_mat(idx, i);
            % 格子里每个像素  
            for w = 1: W_per
                row_one(1, (i - 1) * W_per + w) = gray;
            end
        end
        row_one = row_one * 255;
        pattern = repmat(row_one, H, 1);
        patterns(idx, :, :) = pattern;
    end  
    % 全黑、全白图片，用于确定每个像素阈值
    patterns(n + 2, :, :) = ones(H, W, 'uint8') * 255;
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