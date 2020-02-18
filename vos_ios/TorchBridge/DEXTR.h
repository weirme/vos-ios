#import <Foundation/Foundation.h>
#import <LibTorch/LibTorch.h>


class DEXTR {
private:
    torch::jit::script::Module model;
    
public:
    DEXTR(std::string path);
    cv::Mat forward(cv::Mat inMat);
};
