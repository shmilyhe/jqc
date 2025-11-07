#!/bin/bash

echo "=== JQC 快速功能测试 ==="
echo

# 测试基本功能
echo "1. 基本功能测试:"
echo "   查询字符串: $(./jqc test.json name)"
echo "   查询数字: $(./jqc test.json age)"
echo "   查询嵌套: $(./jqc test.json info.sex)"
echo "   查询数组: $(./jqc test.json 'list[0]')"
echo

# 测试多参数
echo "2. 多参数测试:"
./jqc test.json name age info.sex
echo

# 测试边界条件
echo "3. 边界条件测试:"
echo "   不存在的字段: $(./jqc test.json nonexistent)"
echo "   超出数组范围: $(./jqc test.json 'list[10]')"
echo

# 测试复杂文件
echo "4. 复杂文件测试:"
echo "   根级别字段: $(./jqc complex_test.json name)"
echo "   布尔值: $(./jqc complex_test.json boolean_true)"
echo "   null值: $(./jqc complex_test.json null_value)"
echo "   特殊字符: $(./jqc complex_test.json special-chars)"
echo

# 测试错误处理
echo "5. 错误处理测试:"
echo "   无参数:"
./jqc
echo "   只有文件:"
./jqc test.json
echo

echo "=== 测试完成 ==="
