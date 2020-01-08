//
//  ViewController.m
//  BitmapImageTransform
//
//  Created by lyn on 2020/1/8.
//  Copyright © 2020 lyn. All rights reserved.
//

#import "ViewController.h"
#define KINT(value) (int)(value)
@interface ViewController ()
@property (nonatomic, assign) BOOL first;
@property (nonatomic, assign) CGFloat temp;
@property (nonatomic, strong) UIView *topLeftFinger;
@property (nonatomic, strong) UIView *topRightFinger;
@property (nonatomic, strong) UIView *bottomRightFinger;
@property (nonatomic, strong) UIView *bottomLeftFinger;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIImage *image;
@end

@implementation ViewController
unsigned char* data = nil;
static CGFloat FingerWidth = 30;
- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupWithImageName:@"bg.jpg" frame:CGRectMake(50, 200, 300, 150)];
    
}

- (void)setImage:(UIImage *)image{
    self.first = NO;
    _image = image;
    self.imageView.image = image;
    
}

- (void)setupWithImageName:(NSString *)imageName frame:(CGRect)frame{
    
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:frame];
    self.imageView = imageView;
    self.image = [UIImage imageNamed:imageName];
    [self.view addSubview:imageView];
    self.imageView.frame = frame;
    CGFloat x = frame.origin.x;
    CGFloat y = frame.origin.y;
    CGFloat maxX = CGRectGetMaxX(frame);
    CGFloat maxY = CGRectGetMaxY(frame);
    self.topLeftFinger = [[UIView alloc]initWithFrame:CGRectMake(x-FingerWidth*0.5, y-FingerWidth*0.5, FingerWidth, FingerWidth)];
    self.topRightFinger = [[UIView alloc]initWithFrame:CGRectMake(maxX-FingerWidth*0.5, y-FingerWidth*0.5, FingerWidth, FingerWidth)];
    self.bottomRightFinger = [[UIView alloc]initWithFrame:CGRectMake(maxX-FingerWidth*0.5,maxY-FingerWidth*0.5, FingerWidth, FingerWidth)];
    self.bottomLeftFinger = [[UIView alloc]initWithFrame:CGRectMake(x-FingerWidth*0.5, maxY-FingerWidth*0.5, FingerWidth, FingerWidth)];
    UIColor *bgColor = [UIColor lightGrayColor];
    self.topLeftFinger.backgroundColor = bgColor;
    self.topRightFinger.backgroundColor = bgColor;
    self.bottomRightFinger.backgroundColor = bgColor;
    self.bottomLeftFinger.backgroundColor = bgColor;
    [self.view addSubview:self.topLeftFinger];
    [self.view addSubview:self.topRightFinger];
    [self.view addSubview:self.bottomRightFinger];
    [self.view addSubview:self.bottomLeftFinger];
    UIPanGestureRecognizer *panGestureOne = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(panGestureAction:)];
    UIPanGestureRecognizer *panGestureTwo = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(panGestureAction:)];
    UIPanGestureRecognizer *panGestureThree = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(panGestureAction:)];
    UIPanGestureRecognizer *panGestureFour = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(panGestureAction:)];
    [self.topLeftFinger addGestureRecognizer:panGestureOne];
    [self.topRightFinger addGestureRecognizer:panGestureTwo];
    [self.bottomRightFinger addGestureRecognizer:panGestureThree];
    [self.bottomLeftFinger addGestureRecognizer:panGestureFour];
}

- (void)panGestureAction:(UIPanGestureRecognizer *)gesture{
    
    CGPoint translatePoint = [gesture translationInView:self.view];
     CGPoint center = CGPointMake(gesture.view.center.x + translatePoint.x, gesture.view.center.y + translatePoint.y);
    //边界处理
    if(gesture.view == self.topLeftFinger || gesture.view == self.topRightFinger){
        if (center.y >= CGRectGetMaxY(self.imageView.frame)) {
            return;
        }
    }
    gesture.view.center = center;
    [gesture setTranslation:CGPointZero inView:self.view];
    
    if (gesture.state == UIGestureRecognizerStatePossible)
    {
        NSLog(@"possible");
    }
    else if (gesture.state == UIGestureRecognizerStateBegan)
    {
        NSLog(@"began");
    }
    else if (gesture.state == UIGestureRecognizerStateChanged)
    {
        NSLog(@"changed");
        NSValue *topLeft        = [NSValue valueWithCGPoint:self.topLeftFinger.center];
        NSValue *topRight       = [NSValue valueWithCGPoint:self.topRightFinger.center];
        NSValue *bottomRight    = [NSValue valueWithCGPoint:self.bottomRightFinger.center];
        NSValue *bottomLeft     = [NSValue valueWithCGPoint:self.bottomLeftFinger.center];
        [self changeImageByPoints:@[topLeft,topRight,bottomRight,bottomLeft]];
        
    }
    else if (gesture.state == UIGestureRecognizerStateEnded)
    {
        NSLog(@"ended");
    }
}

- (void)changeImageByPoints:(NSArray *)pointArray{
    UIImage * image = _image; //全局需要变换的图片
    float width = CGImageGetWidth(image.CGImage);
    float height = CGImageGetHeight(image.CGImage);
    
    CGPoint p0 = [pointArray[0]CGPointValue];
    CGPoint p1 = [pointArray[1]CGPointValue];
    CGPoint p2 = [pointArray[2]CGPointValue];
    CGPoint p3 = [pointArray[3]CGPointValue];
    
    //统计相对于父视图的绝对4个顶点计算出新的宽度和高度
    float minLeft = MIN(MIN(p0.x, p1.x), MIN(p2.x, p3.x));
    float minTop = MIN(MIN(p0.y, p1.y), MIN(p2.y, p3.y));
    float shapW = KINT((MAX(MAX(p0.x, p1.x), MAX(p2.x, p3.x)) - minLeft));
    float shapH = KINT((MAX(MAX(p0.y, p1.y), MAX(p2.y, p3.y)) - minTop));
    
    //change point relative to image not superview
    p0.x = p0.x - minLeft;
    p1.x = p1.x - minLeft;
    p2.x = p2.x - minLeft;
    p3.x = p3.x - minLeft;
    p0.y = p0.y - minTop;
    p1.y = p1.y - minTop;
    p2.y = p2.y - minTop;
    p3.y = p3.y - minTop;
    
    //创建一个bitmapcontext
    if (!_first) {
        unsigned char* needData = malloc(KINT(width)* KINT(height) * 4);
        CGContextRef imageContext = CGBitmapContextCreate(needData, width, height, 8, width * 4, CGImageGetColorSpace(image.CGImage), CGImageGetAlphaInfo(image.CGImage));
        CGContextDrawImage(imageContext, CGRectMake(0, 0, width, height), image.CGImage);
        data = malloc(KINT(width) * KINT(height) * 4);
        data = CGBitmapContextGetData(imageContext);
        _first = YES;
    }
    
    //初始化新的图片需要的data
    unsigned char* shapeData = malloc(shapW * shapH * 4);
    for (int i = 0; i < shapH -1; i ++) {
        for (int j = 0; j < shapW -1; j++) {
            int offset = (i * shapW + j) * 4;
            shapeData[offset] = 255;
            shapeData[offset + 1] = 255;
            shapeData[offset + 2] = 255;
            shapeData[offset + 3] = 255;
        }
    }
 
    //给data添加对应的像素值
    for (int i = 0; i < height -1; i++) {
        for (int j = 0; j < width -1; j++) {
            CGPoint originPoint = CGPointMake(j, i);
            int originOffset = (i * width + j) * 4;
            
            // 计算原图每个点在新图中的位置
            float xFunc = (float)originPoint.x / (float)width;
            float yFunc = (float)originPoint.y / (float)height;
                   
            float delx = (p1.x - p0.x) * xFunc;
            float dely = (p1.y - p0.y) * xFunc;
            CGPoint topPoint = CGPointMake(p0.x + delx, p0.y + dely);
            
            delx = (p2.x - p3.x) * xFunc;
            dely = (p2.y - p3.y) * xFunc;
            CGPoint bottomPoint = CGPointMake(p3.x + delx, p3.y + dely);
            
            delx = (bottomPoint.x - topPoint.x) * yFunc;
            dely = (bottomPoint.y - topPoint.y) * yFunc;
            
            CGPoint newPoint = CGPointMake(topPoint.x + delx, topPoint.y + dely);
            
            int newOffset = ((KINT(newPoint.y) * shapW + KINT(newPoint.x))) * 4;
            
            shapeData[newOffset] = data[originOffset];
            shapeData[newOffset + 1] = data[originOffset + 1];
            shapeData[newOffset + 2] = data[originOffset + 2];
            shapeData[newOffset + 3] = data[originOffset + 3];
            
            //give shapeView new value
        }
    }
    //创建新图片
    CGContextRef newContext = CGBitmapContextCreate(shapeData, shapW, shapH, 8, shapW * 4, CGImageGetColorSpace(image.CGImage), CGImageGetAlphaInfo(image.CGImage));
    
    CGImageRef cgImage = CGBitmapContextCreateImage(newContext);
    _imageView.image = [UIImage imageWithCGImage:cgImage ];  //这个_imageView就是贴上viewcontroller上面的UIImageview
    _imageView.frame = CGRectMake(minLeft, minTop, shapW, shapH);
    CGContextRelease(newContext);
    CGImageRelease(cgImage);
    free(shapeData);
}

@end
