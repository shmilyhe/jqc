# JQC - JSON Query Component

[中文](#jqc---json-查询组件)

## JQC - JSON Query Component

A lightweight JSON query tool written in pure C, designed for shell scripting and command-line usage.

### Features

- **Lightweight**: Pure C implementation with no external dependencies
- **Fast**: Efficient JSON parsing with early termination when all results are found
- **Flexible**: Supports multiple input methods (file, pipe, redirection)
- **Powerful**: Query nested objects, arrays, and complex JSON structures
- **Shell-friendly**: Outputs values separated by spaces for easy parsing

### Installation

```bash
make clean && make
```

### Usage

#### File Input (Traditional)
```bash
./jqc test.json name age info.hobby
```

#### Pipe Input
```bash
cat test.json | ./jqc name age info.hobby
```

#### Redirection Input
```bash
./jqc name age info.hobby < test.json
```

### Query Examples

Given `test.json`:
```json
{
    "name": "JQC",
    "age": 18,
    "info": {
        "sex": "male",
        "hobby": "football"
    },
    "list": [
        "a",
        "b",
        "c",
        {
            "product": "JQC"
        }
    ]
}
```

#### Simple Property Query
```bash
./jqc test.json name
# Output: JQC
```

#### Nested Property Query
```bash
./jqc test.json info.hobby
# Output: football
```

#### Array Query
```bash
./jqc test.json "list[0]"
# Output: a
```

#### Complex Property Query
```bash
./jqc test.json "list[3].product"
# Output: JQC
```

#### Multiple Properties Query
```bash
./jqc test.json name age info.hobby
# Output: JQC 18 football
```

#### Non-existent Property
```bash
./jqc test.json nonexistent
# Output: null
```

### Building

```bash
make clean && make
```

### License

MIT License

---

# JQC - JSON 查询组件

## JQC - JSON 查询组件

一个用纯 C 语言编写的轻量级 JSON 查询工具，专为 shell 脚本和命令行使用设计。

### 特性

- **轻量级**: 纯 C 实现，无外部依赖
- **快速**: 高效的 JSON 解析，找到所有结果后提前终止
- **灵活**: 支持多种输入方式（文件、管道、重定向）
- **强大**: 查询嵌套对象、数组和复杂 JSON 结构
- **Shell 友好**: 输出值用空格分隔，便于解析

### 安装

```bash
make clean && make
```

### 使用方法

#### 文件输入（传统方式）
```bash
./jqc test.json name age info.hobby
```

#### 管道输入
```bash
cat test.json | ./jqc name age info.hobby
```

#### 重定向输入
```bash
./jqc name age info.hobby < test.json
```

### 查询示例

假设 `test.json` 内容如下：
```json
{
    "name": "JQC",
    "age": 18,
    "info": {
        "sex": "male",
        "hobby": "football"
    },
    "list": [
        "a",
        "b",
        "c",
        {
            "product": "JQC"
        }
    ]
}
```

#### 一级属性查询
```bash
./jqc test.json name
# 输出: JQC
```

#### 子属性查询
```bash
./jqc test.json info.hobby
# 输出: football
```

#### 数组属性查询
```bash
./jqc test.json "list[0]"
# 输出: a
```

#### 组合属性查询
```bash
./jqc test.json "list[3].product"
# 输出: JQC
```

#### 多个属性查询
```bash
./jqc test.json name age info.hobby
# 输出: JQC 18 football
```

#### 查不到值
```bash
./jqc test.json nonexistent
# 输出: null
```

### 编译

```bash
make clean && make
```

