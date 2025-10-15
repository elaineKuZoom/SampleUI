
#import <UIKit/UIKit.h>


typedef NS_ENUM(NSInteger, DrawingShapeEventType) {
    DrawingShapeEventTypeBegin,
    DrawingShapeEventTypeContent,
    DrawingShapeEventTypeEnd,
    DrawingShapeEventTypeClear
};

@interface DrawingViewDataHelper : NSObject

+ (NSString *)stringForDrawingShapeEvent:(DrawingShapeEventType)eventType content:(NSString * _Nullable)content;

//@"eventType": @(DrawingShapeEventTypeContent),
//@"content": content
+ (NSDictionary *)parseDrawingShapeString:(NSString *)input;
@end

@interface MessageAssembler : NSObject
- (BOOL)addPart:(NSString *)part;
- (BOOL)isComplete;
- (NSString *)assembledMessage;

@end

@protocol DrawingViewDelegate <NSObject>
@optional

- (void)drawingShapeWithJSONString:(NSString *)jsonString;
- (void)drawingShapeBegin;
- (void)drawingShapeEnd;
- (void)drawingShapeClear;
@end

@interface DrawingView : UIView
@property (nonatomic, weak) id<DrawingViewDelegate> delegate;

- (void)addShapeFromJSONString:(NSString *)jsonString;

- (void)claerView;

@end
