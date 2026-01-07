import os
import cv2
import numpy as np
from scipy.io import savemat
from tqdm import tqdm


calib_folder = "data/calib"
calib_num = 14
calib_file = "18.bmp"

points_per_row = 7
points_per_col = 6

patternSize = (points_per_row, points_per_col)

params = cv2.SimpleBlobDetector_Params()
params.maxArea = 10e3
params.minArea = 20
params.minDistBetweenBlobs = 20
blobDetector = cv2.SimpleBlobDetector_create(params)
criteria = (cv2.TERM_CRITERIA_EPS + cv2.TERM_CRITERIA_MAX_ITER, 50, 0.0001)

corners_all = []

for idx in tqdm(range(1, calib_num + 1), "开始检测圆心"):
    # 因为是白点，需要颜色反过来
    file = os.path.join(calib_folder, str(idx), calib_file)
    img = 255 - cv2.imread(file, 0)
    ret, corners = cv2.findCirclesGrid(
            img, patternSize, cv2.CALIB_CB_ADAPTIVE_THRESH, blobDetector, None)
    if ret:
        corners_all.append(corners)
        img_c = np.stack((255 - img,) * 3, axis=-1)
        cv2.drawChessboardCorners(img_c, patternSize, corners, ret)
        cv2.imshow("corner", img_c)
        cv2.waitKey(0)
    else:
        print("检测圆心失败:", file)

imagePoints = np.zeros((points_per_row * points_per_col, 2, calib_num))

for idx, corners in enumerate(corners_all):
    for i, c in enumerate(corners):
        c = np.squeeze(c)
        imagePoints[i, :, idx] = c

savemat(os.path.join(calib_folder , "camera_imagePoints.mat"),  {
                "imagePoints": imagePoints
            })
print("完成！")