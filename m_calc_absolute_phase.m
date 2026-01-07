function [pha, B] = m_calc_absolute_phase(files_phaseShift, files_grayCode, IT, B_min, win_size)
[~, N] = size(files_phaseShift);
[pha_wrapped, B] = m_calc_warppred_phase(files_phaseShift, N);

[~, n] = size(files_grayCode);
n = n - 3;
[Ks1, Ks2] = m_calc_gray_code(files_grayCode, IT, n);

pha_wrapped = pha_wrapped - pi;
mask1 = (pha_wrapped <= - pi / 2);
mask2 = ((-pi / 2 < pha_wrapped) & (pha_wrapped < pi / 2));
mask3 = (pha_wrapped >= pi / 2);
pha = (pha_wrapped + 2 * pi * Ks2) .* mask1 + (pha_wrapped + 2 * pi * Ks1) .* mask2 + (pha_wrapped + 2 * pi * Ks2 - 2 * pi) .* mask3;
pha = pha / (2 * pi * 2 ^ n);

%% 05 过滤异常数据
B_mask = B > B_min;
pha = pha .* B_mask;
%figure(); mesh(pha); colorbar(); title("互补格雷码");
end