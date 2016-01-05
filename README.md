#vk_msgSend

##引子
写这个工具的初衷，无依赖和引用去调用方法，在OC里面使用起来各种不方便

- 现有的`NSObject`中的方法`performSelector:withObject:`使用起来不够直接，并且有太多限制
- 使用`runtime`的`objc_msgSend`的方法，在32位时代还算好用，到了64位的时候，调用起来必须强制转换
- 使用`runtime`来获取`Class`，进而获取`Method`，进而获取`Imp`进行直接调用，同`objc_msgSend`一模一样，都必须强制类型转换
- 依赖注入的框架太大太重了，未免杀鸡用牛刀

##功能

- 可以无需`import`变可直接调用对象的方法 
- 可以调用类方法，实例方法
- 可以支持`int`，`float`，`NSInteger`，`CGFloat`，等基础类型
- 可以支持`CGSize`，`CGRect`，`CGPoint`，等8个系统结构体
- 可以支持任意`id`类型

##使用
###对一个对象调用一个实例方法
既然目的是不想`import`文件，首先要有一个对象嘛

	Class cls = NSClassFromString(@"testClassA");
	id<vk_msgSend> abc = [[cls alloc]init];
	
有了对象就可以最简单的使用了，这个`testClassA`有一个方法

	-(NSString*)testfunction:(int)num withB:(float)boolv
使用方法

	NSString *return = [abc vk_callSelector:@selector(testfunction:withB:) error:&err,4,3.5f];
	
使用起来很简单是不？让id类对象声明遵从`<vk_msgSend>`协议，便可以放心大胆的调用，传入`selector`,传入一个`error`错误信息指针,后面直接是可变参数设计，直接塞入所需要的参数就可以了

###对一个类调用一个类方法
直接将类，转成遵从`<vk_msgSend>`协议的id，即可调用

	Class cls = NSClassFromString(@"testClassA");
    
    [(id<vk_msgSend>)cls vk_callSelector:@selector(testfunction:withB:withH:) error:nil,4,3.5,@"haha"];

###返回值Notes
如果原函数返回值是基础类型`int`，`float`，`NSInteger`，`CGFloat`等,或者`CGSize`，`CGRect`，`CGPoint`等结构体，返回的数值会被封装成`NSValue`或者`NSNumber`，此处还没找到更好的处理办法

方法例子：

	-(NSInteger)testfunction:(int)num withB:(float)boolv withC:(NSString*)str
	-(CGRect)testfunction:(int)num withB:(float)boolv withC:(NSString*)str withE:(NSRange)rect

调用例子：
第一个方法

	NSNumber *return3 = [abc vk_callSelectorName:@"testfunction:withB:withC:" error:&err,4,3.5,@"haha"];
    NSInteger tureReturn3 = [return3 integerValue];
    // need intValue
    
第二个方法

	NSValue *return5 = [abc vk_callSelector:@selector(testfunction:withB:withC:withE:) error:nil,4,3.5,@"haha", NSMakeRange(1, 3)];
    CGRect trueReturn5 = [return5 CGRectValue];
    //need CGRectValue
    
    
之所以需要额外写的原因，是因为声明函数的时候，返回值不知道如何通用匹配。

参数之所以可以通用匹配是因为使用了可变参数。

不知道有没有更好的办法。
###其他方法
其实不仅支持输入SEL，直接输入string型的，具体参见Demo里面的测试用例
	
	+ (id)vk_callSelector:(SEL)selector error:(NSError *__autoreleasing *)error,...;
	
	+ (id)vk_callSelectorName:(NSString *)selName error:(NSError *__autoreleasing *)error,...;
	
	- (id)vk_callSelector:(SEL)selector error:(NSError *__autoreleasing *)error,...;
	
	- (id)vk_callSelectorName:(NSString *)selName error:(NSError *__autoreleasing *)error,...;


##对比
- performSelector缺点
  - 参数限制，performSelector只支持id
  - 参数个数，performSelector在NSObject里系统最多只支持4个参数
  - 用法，每加一个参数必须多写一个`withObject`，过于麻烦
- objc_msgSend缺点
  - 32Bit下使用起来非常方便
  - 64Bit下由于系统底层传参方案改动非常大，因此强制要求进行参数类型，返回类型的函数类型转换，如果不进行类型转换，像32Bit那样直接调用就会crash
  - 每一次调用都，手写调用函数的类型转换，也是挺麻烦的
- runtime的`Imp`调用缺点
  - `Imp`和`objc_msgSend`其实是同一个原因，二者本是一个意思
  


##补充
`block`,`id *`,`SEL`都支持完毕

但是 id* 我有点心虚，求code review

顺带 还未支持参数带有 `Class`
