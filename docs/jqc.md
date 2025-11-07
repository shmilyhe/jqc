# JQC 组件
JQC 纯C 写的JSON SHELL询查询组件（可执行文件）。

## JQC 用法

### 命令：
jqc [文件] 查询参数
输出结果： 参数对应的值

### 参数说明：
以 test.json 文件为例，内容如下：
```
{
    "name": "JQC",
    "age": 18,
    "info": {
        "sex": "male"
        "hobby": "football"
    }
    ,list: [
        "a",
        "b",
        "c",
        {
            "product": "JQC"
        }
            ]
}
```
#### 一级属性询查

命令：
jqc test.json name
输出结果： JQC

#### 子属性询查
命令：
jqc test.json info.hobby
输出结果： football

#### 数组属性询查
命令：
jqc test.json list[0]
输出结果： a

#### 组合属性询查
命令：
jqc test.json list[3].product
输出结果： JQC

#### 多个属性查询
命令：
jqc test.json name age info.hobby
输出结果： JQC 18 football

#### 查不到值
jqc test.json test
输出结果： null