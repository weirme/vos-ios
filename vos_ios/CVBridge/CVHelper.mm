#import <opencv2/opencv.hpp>
#import <opencv2/imgcodecs/ios.h>

#include <iostream>
#include <vector>
#include <string>
#include <sstream>
#include <cassert>
#include <algorithm>

#import "CVHelper.h"
#import "../TorchBridge/DEXTR.h"

#define PAD 50
#define THRES 0.8
#define RESIZE_HEIGHT 512
#define RESIZE_WIDTH 512
#define ALPHA 0.5

const std::string DEXTR_PATH = [[NSBundle mainBundle] pathForResource:@"dextr" ofType:@"pt"].UTF8String;


static void splitCoords2CVec(NSArray<NSArray*>* coords, std::vector<int>& xcoords, std::vector<int>& ycoords) {
    for (id point in coords) {
        int x, y;
        [point[0] getValue:&x];
        xcoords.push_back(x);
        [point[1] getValue:&y];
        ycoords.push_back(y);
    }
}


static std::vector<int> getBbox(UIImage* image, std::vector<int>& xcoords, std::vector<int>& ycoords, int pad) {
    int xminBound = 0;
    int yminBound = 0;
    int xmaxBound = image.size.width - 1;
    int ymaxBound = image.size.height - 1;
    
    int xmin = std::max(*std::min_element(xcoords.begin(), xcoords.end()) - pad, xminBound);
    int ymin = std::max(*std::min_element(ycoords.begin(), ycoords.end()) - pad, yminBound);
    int xmax = std::min(*std::max_element(xcoords.begin(), xcoords.end()) + pad, xmaxBound);
    int ymax = std::min(*std::max_element(ycoords.begin(), ycoords.end()) + pad, ymaxBound);
    
    return {xmin, ymin, xmax, ymax};
}


static cv::Mat cropFromBbox(cv::Mat& imgMat, std::vector<int>& bbox) {
    std::vector<int> bounds = {0, 0, imgMat.size[1] - 1, imgMat.size[0] - 1};
    std::vector<int> bboxValid = {
        std::max(bbox[0], bounds[0]),
        std::max(bbox[1], bounds[1]),
        std::min(bbox[2], bounds[2]),
        std::min(bbox[3], bounds[3])};
    
    int cropWidth = bboxValid[2] - bboxValid[0];
    int cropHeight = bboxValid[3] - bboxValid[1];
    std::vector<int> offsets = {bboxValid[0], bboxValid[1]};
    cv::Range rangex(offsets[0], offsets[0] + cropWidth);
    cv::Range rangey(offsets[1], offsets[1] + cropHeight);
    cv::Mat crop(imgMat, {rangey, rangex});
    
    return crop;
}


static cv::Mat makeHeatmap(std::vector<int>& xcoords, std::vector<int>& ycoords, int sigma=4) {
    cv::Mat heatmap = cv::Mat::zeros(RESIZE_HEIGHT, RESIZE_WIDTH, CV_32FC1);
    for(int i = 0; i < 4; i++)
        heatmap.at<float>(ycoords[i], xcoords[i]) = 1;
    cv::GaussianBlur(heatmap, heatmap, cv::Size(0, 0), sigma);
    cv::normalize(heatmap, heatmap, 0, 255, cv::NORM_MINMAX);
    heatmap.convertTo(heatmap, CV_8UC1);
    return heatmap;
}


static cv::Mat crop2FullMask(cv::Mat& cropMask, std::vector<int>& bbox, int width, int height, int pad) {
    std::vector<int> bounds = {0, 0, width - 1, height - 1};
    std::vector<int> bboxValid = {
        std::max(bbox[0], bounds[0]),
        std::max(bbox[1], bounds[1]),
        std::min(bbox[2], bounds[2]),
        std::min(bbox[3], bounds[3])};
    
    int cropWidth = bboxValid[2] - bboxValid[0] + 1;
    int cropHeight = bboxValid[3] - bboxValid[1] + 1;
    std::vector<int> offsets = {bboxValid[0], bboxValid[1]};
    
    cv::Mat mask;
    cv::resize(cropMask, mask, cv::Size(cropWidth, cropHeight), cv::INTER_CUBIC);
    cv::compare(mask, THRES, mask, cv::CMP_GT);
    cv::Mat fullMask = cv::Mat::zeros(height, width, CV_8UC1);
    cv::Rect roiRect = cv::Rect(offsets[0], offsets[1], cropWidth, cropHeight);
    mask.copyTo(fullMask(roiRect));
    return fullMask;
}


static void getOverlay(cv::Mat& imgMat, cv::Mat& mask) {
    int imgHeight = imgMat.rows;
    int imgWidth = imgMat.cols;
    cv::Mat rgbMask = cv::Mat(imgHeight, imgWidth, CV_8UC3);
    std::vector<cv::Mat> rgbChannels;
    rgbChannels.push_back(cv::Mat::zeros(imgHeight, imgWidth, CV_8UC1));
    rgbChannels.push_back(cv::Mat::zeros(imgHeight, imgWidth, CV_8UC1));
    rgbChannels.push_back(mask);
    cv::merge(rgbChannels, rgbMask);
    
    cv::Mat overlay = cv::Mat::zeros(imgHeight, imgWidth, CV_8UC3);
    cv::cvtColor(imgMat, imgMat, cv::COLOR_RGBA2RGB);
    cv::addWeighted(rgbMask, ALPHA, imgMat, ALPHA, 1 - ALPHA, overlay);
    
    std::vector< std::vector<cv::Point> > contours;
    cv::findContours(mask, contours, cv::RETR_TREE, cv::CHAIN_APPROX_SIMPLE);
    cv::drawContours(imgMat, contours, -1, cv::Scalar(0, 0, 255), 2);
    overlay.copyTo(imgMat, mask);
}


@implementation CVHelper

+ (UIImage*) makeOverlayMaskOfImage: (UIImage*) image withExtremePoints: (NSArray<NSArray*>*) coords {
    std::vector<int> xcoords;
    std::vector<int> ycoords;
    splitCoords2CVec(coords, xcoords, ycoords);
    
    cv::Mat imgMat;
    UIImageToMat(image, imgMat);
    
    std::vector<int> bbox = getBbox(image, xcoords, ycoords, PAD);
    cv::Mat cropMat = cropFromBbox(imgMat, bbox);
    cv::Mat resizeMat;
    cv::resize(cropMat, resizeMat, cv::Size(RESIZE_HEIGHT, RESIZE_WIDTH), cv::INTER_CUBIC);
    
    int xmin = *std::min_element(xcoords.begin(), xcoords.end());
    int ymin = *std::min_element(ycoords.begin(), ycoords.end());
    for (auto &x : xcoords) {
        x = x - xmin + PAD;
        x = RESIZE_WIDTH * x / cropMat.size[1];
    }
    for (auto &y : ycoords) {
        y = y - ymin + PAD;
        y = RESIZE_HEIGHT * y / cropMat.size[0];
    }
    
    cv::Mat heatmap = makeHeatmap(xcoords, ycoords);
    
    cv::Mat inputs = cv::Mat(RESIZE_HEIGHT, RESIZE_WIDTH, CV_8UC4);
    std::vector<cv::Mat> srcChannels;
    std::vector<cv::Mat> dstChannels;
    
    cv::split(resizeMat, srcChannels);
    dstChannels.push_back(srcChannels[0]);
    dstChannels.push_back(srcChannels[1]);
    dstChannels.push_back(srcChannels[2]);
    dstChannels.push_back(heatmap);
    cv::merge(dstChannels, inputs);
    
    DEXTR net(DEXTR_PATH);
    cv::Mat outputs = net.forward(inputs);
    cv::resize(outputs, outputs, cv::Size(RESIZE_HEIGHT, RESIZE_WIDTH));
    
    outputs = -outputs;
    cv::exp(outputs, outputs);
    cv::Mat pred = 1 / (1 + outputs);
    
    cv::Mat mask = crop2FullMask(pred, bbox, image.size.width, image.size.height, PAD);
    getOverlay(imgMat, mask);
    
    UIImage* img = MatToUIImage(imgMat);
    
    return img;
}

@end
