//
//  ViewController.m
//  ZJHMonitorRegion
//
//  Created by ZhangJingHao48 on 2019/9/25.
//  Copyright © 2019 ZhangJingHao48. All rights reserved.
//

#import "ViewController.h"
#import <MapKit/MapKit.h>
#import "ZJHRegionManager.h"

@interface ViewController () <MKMapViewDelegate>

@property (nonatomic ,strong) MKMapView *mapView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"地理围栏";
    
    [self setupUI];
        
    self.navigationItem.rightBarButtonItem =
    [[UIBarButtonItem alloc] initWithTitle:@"我的位置"
                                     style:UIBarButtonItemStylePlain
                                    target:self
                                    action:@selector(resetLocation)];

}

- (void)setupUI {
    MKMapView *mapView = [[MKMapView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:mapView];
    self.mapView = mapView;
    
    NSArray *locationArr = [ZJHRegionManager shareInstance].locationArr;
    NSDictionary *location = [locationArr firstObject];
    CLLocationDegrees latitude = [location[@"latitude"] doubleValue];
    CLLocationDegrees longitude = [location[@"longitude"] doubleValue];
    CLLocationCoordinate2D gcjPt =
    CLLocationCoordinate2DMake(latitude, longitude);
    MKCoordinateSpan theSpan;
    theSpan.latitudeDelta = 0.01;
    theSpan.longitudeDelta = 0.01;
    // 定义一个区域（用定义的经纬度和范围来定义）
    MKCoordinateRegion theRegion;
    theRegion.center=gcjPt;
    theRegion.span=theSpan;
    
    // 在地图上显示
    [self.mapView setRegion:theRegion];
    self.mapView.showsUserLocation=YES;
    self.mapView.delegate = self;
    
    //设置检测区域
    for (NSDictionary *dict in locationArr) {
        //国际标准坐标转换为火星坐标
        //CLLocationCoordinate2D gcjRegionLocation = [JZLocationConverter wgs84ToGcj02:student.location];
        CLLocationDegrees latitude = [dict[@"latitude"] doubleValue];
        CLLocationDegrees longitude = [dict[@"longitude"] doubleValue];
        CLLocationCoordinate2D gcjPt =
        CLLocationCoordinate2DMake(latitude, longitude);
        MKCircle *circle = [MKCircle circleWithCenterCoordinate:gcjPt radius:200];
        //先添加，在回调方法中创建覆盖物
        [_mapView addOverlay:circle];
    }
}

- (void)resetLocation {
    // 定位到我的位置
    [self.mapView setCenterCoordinate:_mapView.userLocation.coordinate animated:YES];
}

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay {
    //创建圆形覆盖物
    MKCircleRenderer *circleRender =[[MKCircleRenderer alloc] initWithCircle:overlay];
    
    //设置填充色
    circleRender.fillColor=[UIColor colorWithWhite:0.8 alpha:0.8];
    
    //设置边缘颜色
    circleRender.strokeColor=[UIColor blueColor];
    
    //设置边缘宽度
    circleRender.lineWidth = 2;
    
    return circleRender;
}


@end
