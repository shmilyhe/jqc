#!/bin/bash

echo "=== 测试 jqc 管道输入功能 ==="
echo

echo "1. 传统文件输入方式:"
echo "命令: ./jqc test.json name age info.hobby"
./jqc test.json name age info.hobby
echo

echo "2. 管道输入方式:"
echo "命令: cat test.json | ./jqc name age info.hobby"
cat test.json | ./jqc name age info.hobby
echo

echo "3. 重定向输入方式:"
echo "命令: ./jqc name age info.hobby < test.json"
./jqc name age info.hobby < test.json
echo

echo "4. 数组查询（管道方式）:"
echo "命令: cat test.json | ./jqc \"list[0]\" \"list[1].product\""
cat test.json | ./jqc "list[0]" "list[1].product"
echo

echo "5. 数组查询（文件方式）:"
echo "命令: ./jqc test.json \"list[0]\" \"list[1].product\""
./jqc test.json "list[0]" "list[1].product"
echo

echo "=== 所有测试完成 ==="
