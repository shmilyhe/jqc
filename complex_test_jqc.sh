#!/bin/bash

# JQC 组件复杂测试脚本
# 专门针对 complex_test.json 进行边界值测试

echo "=== JQC 组件复杂测试开始 ==="
echo "测试文件: complex_test.json"
echo

# 测试文件
TEST_FILE="complex_test.json"

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 测试统计
TOTAL_TESTS=0
PASSED_TESTS=0

# 测试函数
run_test() {
    local description="$1"
    local command="$2"
    local expected="$3"
    
    ((TOTAL_TESTS++))
    
    echo -e "${BLUE}测试 $TOTAL_TESTS: $description${NC}"
    echo "命令: $command"
    
    result=$(eval "$command" 2>&1)
    exit_code=$?
    
    echo "实际值: '$result'"
    echo "期望值: '$expected'"
    
    if [ "$result" = "$expected" ] && [ $exit_code -eq 0 ]; then
        echo -e "${GREEN}✓ 测试通过${NC}"
        ((PASSED_TESTS++))
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

# 1. 基本字段测试
echo -e "${YELLOW}=== 基本字段测试 ===${NC}"
run_test "查询根级别字符串字段" "./jqc $TEST_FILE name" "JQC"
run_test "查询版本号" "./jqc $TEST_FILE version" "1.0.0"
run_test "查询描述" "./jqc $TEST_FILE description" "JSON Query Component"

# 2. 嵌套对象测试
echo -e "${YELLOW}=== 嵌套对象测试 ===${NC}"
run_test "查询一级嵌套对象" "./jqc $TEST_FILE author.name" "Developer"
run_test "查询二级嵌套对象" "./jqc $TEST_FILE author.contact.phone" "+86-138-0000-0000"
run_test "查询三级嵌套对象" "./jqc $TEST_FILE author.contact.address.city" "Beijing"
run_test "查询四级嵌套对象" "./jqc $TEST_FILE author.contact.address.street" "Tech Street 123"

# 3. 数组测试
echo -e "${YELLOW}=== 数组测试 ===${NC}"
run_test "查询数字数组第一个元素" "./jqc $TEST_FILE numbers[0]" "1"
run_test "查询数字数组中间元素" "./jqc $TEST_FILE numbers[2]" "3"
run_test "查询数字数组最后一个元素" "./jqc $TEST_FILE numbers[4]" "5"
run_test "查询功能数组" "./jqc $TEST_FILE features[0]" "json_parsing"
run_test "查询功能数组第二个元素" "./jqc $TEST_FILE features[1]" "query_engine"

# 4. 混合数组测试
echo -e "${YELLOW}=== 混合数组测试 ===${NC}"
run_test "查询混合数组字符串" "./jqc $TEST_FILE mixed_array[0]" "string"
run_test "查询混合数组数字" "./jqc $TEST_FILE mixed_array[1]" "42"
run_test "查询混合数组布尔true" "./jqc $TEST_FILE mixed_array[2]" "true"
run_test "查询混合数组布尔false" "./jqc $TEST_FILE mixed_array[3]" "false"
run_test "查询混合数组null" "./jqc $TEST_FILE mixed_array[4]" "null"
run_test "查询混合数组中对象的字段" "./jqc $TEST_FILE mixed_array[5].nested" "object"
run_test "查询混合数组中对象的数组" "./jqc $TEST_FILE mixed_array[5].array[1]" "b"
run_test "查询混合数组中的数组" "./jqc $TEST_FILE mixed_array[6][0]" "1"

# 5. 配置对象测试
echo -e "${YELLOW}=== 配置对象测试 ===${NC}"
run_test "查询布尔配置值true" "./jqc $TEST_FILE config.debug" "true"
run_test "查询布尔配置值false" "./jqc $TEST_FILE config.verbose" "false"
run_test "查询数字配置值" "./jqc $TEST_FILE config.timeout" "30"
run_test "查询深度配置值" "./jqc $TEST_FILE config.max_depth" "10"

# 6. 特殊字符测试
echo -e "${YELLOW}=== 特殊字符测试 ===${NC}"
run_test "查询特殊字符字段" "./jqc $TEST_FILE special_chars" "test\"quotes\\backslash\nnewline\ttab"
run_test "查询空字符串" "./jqc $TEST_FILE empty_string" ""
run_test "查询带空格的字符串" "./jqc $TEST_FILE spaces" "  hello world  "
run_test "查询Unicode字符串" "./jqc $TEST_FILE unicode" "中文测试 🚀"

# 7. 数据类型边界测试
echo -e "${YELLOW}=== 数据类型边界测试 ===${NC}"
run_test "查询布尔true" "./jqc $TEST_FILE boolean_true" "true"
run_test "查询布尔false" "./jqc $TEST_FILE boolean_false" "false"
run_test "查询null值" "./jqc $TEST_FILE null_value" "null"
run_test "查询大数字" "./jqc $TEST_FILE large_number" "9999999999"
run_test "查询浮点数" "./jqc $TEST_FILE float_number" "3.14159"
run_test "查询负数" "./jqc $TEST_FILE negative_number" "-42"
run_test "查询零值" "./jqc $TEST_FILE zero" "0"

# 8. 空对象和数组测试
echo -e "${YELLOW}=== 空对象和数组测试 ===${NC}"
run_test "查询空对象" "./jqc $TEST_FILE empty_object" "{}"
run_test "查询空数组" "./jqc $TEST_FILE empty_array" "[]"

# 9. 深度嵌套测试
echo -e "${YELLOW}=== 深度嵌套测试 ===${NC}"
run_test "查询深度嵌套第一层" "./jqc $TEST_FILE deep.level1" "{\"level2\":{\"level3\":{\"level4\":{\"level5\":\"deep_value\"}}}}"
run_test "查询深度嵌套第二层" "./jqc $TEST_FILE deep.level1.level2" "{\"level3\":{\"level4\":{\"level5\":\"deep_value\"}}}"
run_test "查询深度嵌套第三层" "./jqc $TEST_FILE deep.level1.level2.level3" "{\"level4\":{\"level5\":\"deep_value\"}}"
run_test "查询深度嵌套第四层" "./jqc $TEST_FILE deep.level1.level2.level3.level4" "{\"level5\":\"deep_value\"}"
run_test "查询深度嵌套第五层" "./jqc $TEST_FILE deep.level1.level2.level3.level4.level5" "deep_value"

# 10. 边界值测试
echo -e "${YELLOW}=== 边界值测试 ===${NC}"
run_test "查询不存在的根字段" "./jqc $TEST_FILE nonexistent" "null"
run_test "查询不存在的嵌套字段" "./jqc $TEST_FILE author.nonexistent" "null"
run_test "查询超出范围的数组索引" "./jqc $TEST_FILE numbers[10]" "null"
run_test "查询负数组索引" "./jqc $TEST_FILE numbers[-1]" "null"
run_test "查询空数组索引" "./jqc $TEST_FILE empty_array[0]" "null"
run_test "查询空对象的字段" "./jqc $TEST_FILE empty_object.field" "null"

# 11. 多参数查询测试
echo -e "${YELLOW}=== 多参数查询测试 ===${NC}"
run_test "查询多个基本字段" "./jqc $TEST_FILE name version" "JQC 1.0.0"
run_test "查询混合类型字段" "./jqc $TEST_FILE name boolean_true null_value" "JQC true null"
run_test "查询嵌套和数组字段" "./jqc $TEST_FILE author.name numbers[0] config.debug" "Developer 1 true"
run_test "查询部分有效部分无效字段" "./jqc $TEST_FILE name nonexistent version" "JQC null 1.0.0"

# 12. 特殊路径测试
echo -e "${YELLOW}=== 特殊路径测试 ===${NC}"
run_test "查询带点的路径" "./jqc $TEST_FILE 'author.contact.address.country'" "China"
run_test "查询带空格的路径" "./jqc $TEST_FILE 'author.contact.address.street'" "Tech Street 123"
run_test "查询无效路径格式" "./jqc $TEST_FILE 'author..name'" "null"
run_test "查询空路径" "./jqc $TEST_FILE ''" "null"

# 13. 性能边界测试
echo -e "${YELLOW}=== 性能边界测试 ===${NC}"
run_test "查询深度嵌套的叶子节点" "./jqc $TEST_FILE deep.level1.level2.level3.level4.level5" "deep_value"
run_test "查询多层数组嵌套" "./jqc $TEST_FILE mixed_array[5].array[2]" "c"
run_test "查询复杂混合路径" "./jqc $TEST_FILE mixed_array[6][2]" "3"

# 14. 错误恢复测试
echo -e "${YELLOW}=== 错误恢复测试 ===${NC}"
run_test "混合有效无效查询" "./jqc $TEST_FILE name nonexistent version" "JQC null 1.0.0"
run_test "部分无效嵌套查询" "./jqc $TEST_FILE author.name author.nonexistent author.email" "Developer null dev@example.com"
run_test "数组边界混合查询" "./jqc $TEST_FILE numbers[0] numbers[10] numbers[4]" "1 null 5"

# 显示测试统计
echo -e "${GREEN}=== 测试完成 ===${NC}"
echo
echo -e "${BLUE}=== 测试统计 ===${NC}"
echo "测试用例总数: $TOTAL_TESTS"
echo -e "通过测试数: ${GREEN}$PASSED_TESTS${NC}"
echo -e "失败测试数: ${RED}$((TOTAL_TESTS - PASSED_TESTS))${NC}"
echo
echo -e "测试通过率: $((PASSED_TESTS * 100 / TOTAL_TESTS))%"

if [ $PASSED_TESTS -eq $TOTAL_TESTS ]; then
    echo -e "${GREEN}🎉 所有测试通过！${NC}"
else
    echo -e "${RED}⚠️  有测试失败，请检查${NC}"
fi

echo
echo "测试覆盖范围:"
echo "  - 基本字段查询 ✓"
echo "  - 嵌套对象查询 ✓"
echo "  - 数组查询 ✓"
echo "  - 混合类型数组查询 ✓"
echo "  - 多参数查询 ✓"
echo "  - 特殊字符处理 ✓"
echo "  - 数据类型边界 ✓"
echo "  - 空对象/数组处理 ✓"
echo "  - 深度嵌套查询 ✓"
echo "  - 边界值测试 ✓"
echo "  - 错误恢复测试 ✓"
