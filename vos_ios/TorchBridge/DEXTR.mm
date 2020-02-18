#import <opencv2/opencv.hpp>

#import "DEXTR.h"

#define IN_SIZE 512
#define OUT_SIZE 64


DEXTR::DEXTR(std::string path) {
    auto qengines = at::globalContext().supportedQEngines();
    if (std::find(qengines.begin(), qengines.end(), at::QEngine::QNNPACK) != qengines.end()) {
        at::globalContext().setQEngine(at::QEngine::QNNPACK);
    }
    model = torch::jit::load(path);
    model.eval();
}

cv::Mat DEXTR::forward(cv::Mat inMat) {
    inMat.convertTo(inMat, CV_32FC4);
    auto input = torch::from_blob(inMat.data, {1, IN_SIZE, IN_SIZE, 4}, torch::kF32);
    input = input.permute({0, 3, 1, 2});
    torch::autograd::AutoGradMode guard(false);
    at::AutoNonVariableTypeMode non_var_type_mode(true);
    auto output = model.forward({input}).toTensor();
    output = output.view({OUT_SIZE, OUT_SIZE});
    cv::Mat outMat = cv::Mat::zeros(OUT_SIZE, OUT_SIZE, CV_32F);
    std::memcpy(outMat.data, output.data_ptr(), sizeof(float) * output.numel());
    return outMat;
}

