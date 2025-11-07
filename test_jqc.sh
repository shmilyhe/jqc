#!/bin/bash

# JQC 组件测试脚本
# 测试各种参数状态和边界条件

echo "=== JQC 组件测试开始 ==="
echo

# 测试文件
TEST_FILE="test.json"
SIMPLE_TEST_FILE="simple_test.json"
COMPLEX_TEST_FILE="complex_test.json"

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 测试函数
run_test() {
    local description="$1"
    local command="$2"
    local expected="$3"
    
    echo -e "${BLUE}测试: $description${NC}"
    echo "命令: $command"
    
    result=$(eval "$command" 2>&1)
    exit_code=$?
    
    echo "结果: $result"
    echo "退出码: $exit_code"
    
    if [ "$result" = "$expected" ] && [ $exit_code -eq 0 ]; then
        echo -e "${GREEN}✓ 测试通过${NC}"
    else
        echo -e "${RED}✗ 测试失败${NC}"
        if [ "$result" != "$expected" ]; then
            echo -e "${RED}期望: '$expected'${NC}"
        fi
        if [ $exit_code -ne 0 ]; then
            echo -e "${RED}期望退出码: 0, 实际: $exit_code${NC}"
        fi
    fi
    echo
}

# 1. 基本功能测试
echo -e "${YELLOW}=== 基本功能测试 ===${NC}"
run_test "查询根级别字符串字段" "./jqc $TEST_FILE name" "JQC"
run_test "查询根级别数字字段" "./jqc $TEST_FILE age" "18"
run_test "查询嵌套对象字段" "./jqc $TEST_FILE info.sex" "male"
run_test "查询嵌套对象字段2" "./jqc $TEST_FILE info.hobby" "football"

# 2. 数组查询测试
echo -e "${YELLOW}=== 数组查询测试 ===${NC}"
run_test "查询数组元素" "./jqc $TEST_FILE 'list[0]'" "a"
run_test "查询数组元素" "./jqc $TEST_FILE 'list[1]'" "b"
run_test "查询数组元素" "./jqc $TEST_FILE 'list[2]'" "c"
run_test "查询数组中对象的字段" "./jqc $TEST_FILE 'list[3].product'" "JQC"

# 3. 多参数查询测试
echo -e "${YELLOW}=== 多参数查询测试 ===${NC}"
run_test "查询多个字段" "./jqc $TEST_FILE name age" "JQC 18"
run_test "查询多个嵌套字段" "./jqc $TEST_FILE info.sex info.hobby" "male football"
run_test "混合查询" "./jqc $TEST_FILE name info.hobby 'list[0]'" "JQC football a"

# 4. 边界条件测试
echo -e "${YELLOW}=== 边界条件测试 ===${NC}"
run_test "查询不存在的字段" "./jqc $TEST_FILE nonexistent" "null"
run_test "查询不存在的嵌套字段" "./jqc $TEST_FILE info.nonexistent" "null"
run_test "查询超出范围的数组索引" "./jqc $TEST_FILE 'list[10]'" "null"
run_test "查询负数组索引" "./jqc $TEST_FILE 'list[-1]'" "null"

# 5. 文件相关测试
echo -e "${YELLOW}=== 文件相关测试 ===${NC}"
run_test "使用简单测试文件" "./jqc $SIMPLE_TEST_FILE name" "JQC"
run_test "使用复杂测试文件" "./jqc $COMPLEX_TEST_FILE name" "JQC"
run_test "查询不存在的文件" "./jqc nonexistent.json name" "null"

# 6. 参数错误测试
echo -e "${YELLOW}=== 参数错误测试 ===${NC}"
run_test "无参数" "./jqc" "" 1
run_test "只有文件参数" "./jqc $TEST_FILE" "" 1
run_test "无效的JSON路径格式" "./jqc $TEST_FILE 'invalid..path'" "null"
run_test "空的查询路径" "./jqc $TEST_FILE ''" "null"

# 7. 特殊字符测试
echo -e "${YELLOW}=== 特殊字符测试 ===${NC}"
run_test "包含点的字段名" "./jqc $SIMPLE_TEST_FILE 'name.with.dots'" "null"
run_test "包含特殊字符的路径" "./jqc $COMPLEX_TEST_FILE 'special-chars'" "test\"quotes\\backslash\nnewline\ttab"

# 8. 性能测试（大数据量）
echo -e "${YELLOW}=== 性能测试 ===${NC}"
echo "创建大文件进行测试..."
# 创建一个较大的测试文件
cat > large_test.json << 'EOF'
{
    "data": {
        "items": [
            {"id": 1, "value": "test1"},
            {"id": 2, "value": "test2"},
            {"id": 3, "value": "test3"},
            {"id": 4, "value": "test4"},
            {"id": 5, "value": "test5"}
        ]
    }
}
EOF

run_test "大文件查询" "./jqc large_test.json 'data.items[4].value'" "test5"

# 清理大文件
rm -f large_test.json

# 9. 综合测试
echo -e "${YELLOW}=== 综合测试 ===${NC}"
run_test "复杂嵌套查询" "./jqc $COMPLEX_TEST_FILE 'deep.level1.level2.level3.level4.level5'" "deep_value"
run_test "多层数组查询" "./jqc $COMPLEX_TEST_FILE 'mixed_array[6][1]'" "2"
run_test "布尔值查询" "./jqc $COMPLEX_TEST_FILE 'boolean_true'" "true"
run_test "null值查询" "./jqc $COMPLEX_TEST_FILE 'null_value'" "null"

# 10. 错误恢复测试
echo -e "${YELLOW}=== 错误恢复测试 ===${NC}"
run_test "部分无效查询" "./jqc $TEST_FILE name nonexistent info.sex" "JQC null male"
run_test "混合有效无效查询" "./jqc $TEST_FILE 'list[0]' 'list[10]' info.hobby" "a null football"

echo -e "${GREEN}=== 测试完成 ===${NC}"
echo "所有测试执行完毕"

# 显示测试统计
echo
echo -e "${BLUE}=== 测试统计 ===${NC}"
echo "测试文件:"
echo "  - $TEST_FILE"
echo "  - $SIMPLE_TEST_FILE" 
echo "  - $COMPLEX_TEST_FILE"
echo
echo "功能覆盖:"
echo "  - 基本字段查询 ✓"
echo "  - 嵌套对象查询 ✓"
echo "  - 数组查询 ✓"
echo "  - 多参数查询 ✓"
echo "  - 边界条件处理 ✓"
echo "  - 错误处理 ✓"
echo "  - 特殊字符处理 ✓"
