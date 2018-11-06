# KVO









## `addObserver`和 `removeObserver`要成对出现

`addObserver`和 `removeObserver`要成对出现。一个监听如果`removeObserver`多于`addObserver`则会出现crash。这种情况，如果是在一个类里面写了两个 `removeObserver`,比较容易发现。例如：

```objective-c
- (void)dealloc {
//    已经remove过之后再次remove会导致程序crash。
	[self.dog removeObserver:self forKeyPath:NSStringFromSelector(@selector(name))];
//    [self.dog removeObserver:self forKeyPath:NSStringFromSelector(@selector(name))];
}
```



为防止意外可以添加try--catch

```objective-c
- (void)dealloc {
    @try {
        [self.dog removeObserver:self forKeyPath:@"name"];
        [self.dog removeObserver:self forKeyPath:@"name"];
    } @catch (NSException *exception) {
        NSLog(@"%@",exception.reason);
    } @finally {
        
    }   
    NSLog(@"%@释放了",NSStringFromClass([self class]));
}
```

打印结果：

```
2018-11-06 16:44:08.997283+0800 MemoryLeakDemo[7051:2395376] DYSKVOViewController释放了
2018-11-06 16:44:08.998021+0800 MemoryLeakDemo[7051:2395376] Cannot remove an observer <DYSKVOViewController 0x7fd20c511ba0> for the key path "name" from <DYSDog 0x600001130960> because it is not registered as an observer.
2018-11-06 16:44:08.998331+0800 MemoryLeakDemo[7051:2395376] DYSKVOViewController释放了
```







## 父子类添加了相同的observer,用context区分

如果父子类添加了相同的observer，在父子类里面都进行`removeObserver`处理则会因为多次remove相同的observer导致crash。

例如：

父类 `DYSKVOSuperViewController`添加监听：

```objective-c
- (void)viewDidLoad {
    [super viewDidLoad];

	DYSDog *dog = [DYSDog new];
    dog.name = @"欢欢";
    dog.age = 3;
    self.dog = dog;

    [self.dog addObserver:self forKeyPath:NSStringFromSelector(@selector(name)) options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:NULL];
}
```

子类`DYSKVOSuperViewController`添加监听：

```objective-c
- (void)viewDidLoad {
    [super viewDidLoad];

	[self.dog addObserver:self forKeyPath:NSStringFromSelector(@selector(name)) options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:NULL];
}

```

在父子类的dealloc方法里面移除监听：

```objective-c
- (void)dealloc {
//    已经remove过之后再次remove会导致程序crash。
	[self.dog removeObserver:self forKeyPath:NSStringFromSelector(@selector(name))];
//    [self.dog removeObserver:self forKeyPath:@"name"];
}
```

父子类都监听这种情况添加context进行区分处理。

例如：

```objective-c
//子类
static void *DYSKVOViewControllerObserverContextName = &DYSKVOViewControllerObserverContextName;
	[self.dog removeObserver:self forKeyPath:NSStringFromSelector(@selector(name)) context:DYSKVOViewControllerObserverContextName];
    [self.dog addObserver:self forKeyPath:NSStringFromSelector(@selector(name)) options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:DYSKVOViewControllerObserverContextName];

//父类
static void *DYSKVOSuperViewControllerObserverContextName = &DYSKVOSuperViewControllerObserverContextName;
    [self.dog addObserver:self forKeyPath:NSStringFromSelector(@selector(name)) options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:DYSKVOSuperViewControllerObserverContextName];
    [self.dog removeObserver:self forKeyPath:@"name" context:DYSKVOSuperViewControllerObserverContextName];

```









## keyPath是NSString格式,直接写字符串容易出错，最好写成`NSStringFromSelector(SEL aSelector)`



例如：

```objective-c
//比如属性是firstName 写字符串容易误写为firstname
[self.dog addObserver:self forKeyPath:@"firstname" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:NULL];


//NSStringFromSelector(@selector(firstName)) 比 @"firstname" 好在有编译器检查，出错会提示例如Undeclared selector 'firstname' 出错概率大大降低
[self.dog addObserver:self forKeyPath:NSStringFromSelector(@selector(firstName)) options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:NULL];

```





## 一般会在dealloc中进行removeObserver操作





## 添加监听要在对象实例化之后

```objective-c
    DYSDog *dog = [DYSDog new];
    dog.name = @"欢欢";
    dog.age = 3;
    self.dog = dog;

	[self.dog addObserver:self forKeyPath:NSStringFromSelector(@selector(name)) options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:DYSKVOSuperViewControllerObserverContextName];
    
//	  对象监听在对象实例化事前，会导致crash
//    DYSDog *dog = [DYSDog new];
//    dog.name = @"欢欢";
//    dog.age = 3;
//    self.dog = dog;

```



## 对象添加监听之后对象指针不能再改变



````objective-c
    DYSDog *dog = [DYSDog new];
    dog.name = @"欢欢";
    dog.age = 3;
    self.dog = dog;

	[self.dog addObserver:self forKeyPath:NSStringFromSelector(@selector(name)) options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:DYSKVOSuperViewControllerObserverContextName];
    
//	  对象监听添加之后self.dog的指针发生了变化，会导致crash
//    dog = [DYSDog new];
//    dog.name = @"欢欢";
//    dog.age = 3;
//    self.dog = dog;


//同理如果在子类重新给self.dog 指针复制也会导致crash。

````











