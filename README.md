# KVO



KVO的实现：

当你观察一个对象（称该对象为「被观察对象」）时，一个新的类会动态被创建。这个类继承自「被观察对象」所对应类的，并重写该被观察属性的setter方法；针对setter方法的重写无非是在赋值语句前后加上相应的通知（或曰方法调用）；最后，把「被观察对象」的isa指针（isa指针告诉Runtime系统这个对象的类是什么）指向这个新创建的中间类，对象就神奇变成了新创建类的实例。



```objective-c
    DYSDog *dog = [DYSDog new];
    dog.name = @"欢欢";
    dog.age = 3;
    self.dog = dog;
    
    [self.dog addObserver:self forKeyPath:NSStringFromSelector(@selector(name)) options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:DYSKVOSuperViewControllerObserverContextName];

```

在添加addObserver前后断点调试isa指针可以发现元类发生了变化。

```
(lldb) po self.dog->isa
DYSDog

(lldb) po self.dog->isa
NSKVONotifying_DYSDog

(lldb) 
```

生成了一个新类



这个类是被观察类的子类

```
(lldb) po ([NSKVONotifying_DYSDog class]).superclass
DYSDog
```







## 使用指南

### `addObserver`和 `removeObserver`要成对出现

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







### 父子类添加了相同的observer,用context区分

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









### keyPath是NSString格式,直接写字符串容易出错，最好写成`NSStringFromSelector(SEL aSelector)`



例如：

```objective-c
//比如属性是firstName 写字符串容易误写为firstname
[self.dog addObserver:self forKeyPath:@"firstname" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:NULL];


//NSStringFromSelector(@selector(firstName)) 比 @"firstname" 好在有编译器检查，出错会提示例如Undeclared selector 'firstname' 出错概率大大降低
[self.dog addObserver:self forKeyPath:NSStringFromSelector(@selector(firstName)) options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:NULL];

```





### 一般会在dealloc中进行removeObserver操作





### 添加监听要在对象实例化之后

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



### 对象添加监听之后对象指针不能再改变



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



### 直接修改成员变量不会触发KVO

不会，KVO的本质是set方法，只有调用了set方法才会触发KVO。

```objective-c
_name = @"大黄"
self.name = @"大黄";
[self setName:@"大黄"];
```



### 手动触发KVO

手动调用willChangeValueForKey和didChangeValueForKey方法。复写set方法后，如果要监听一般需要手动出发KVO。







## delegate

1. 代理一般用weak来防止强引用循环。
2. assign在delegate释放时候不会自动置为nil,易出野指针错误
3. 在dealloc里面讲delegate置为nil是个好习惯，可以有效的防止野指针

实现见demo。



## 参考文档

[国外大神研究](https://www.mikeash.com/pyblog/friday-qa-2009-01-23.html)

https://objccn.io/issue-7-3/





