#include "jqc.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <errno.h>

// 读取文件内容
char* read_file(const char* filename, size_t* length) {
    FILE* file = fopen(filename, "rb");
    if (!file) {
        //fprintf(stderr, "错误: 无法打开文件 '%s': %s\n", filename, strerror(errno));
        return NULL;
    }
    
    fseek(file, 0, SEEK_END);
    *length = ftell(file);
    fseek(file, 0, SEEK_SET);
    
    char* content = (char*)malloc(*length + 1);
    if (!content) {
        fclose(file);
        //fprintf(stderr, "错误: 内存分配失败\n");
        return NULL;
    }
    
    size_t read_bytes = fread(content, 1, *length, file);
    if (read_bytes != *length) {
        free(content);
        fclose(file);
        fprintf(stderr, "错误: 读取文件失败\n");
        return NULL;
    }
    
    content[*length] = '\0';
    fclose(file);
    return content;
}

// 打印使用说明
void print_usage(const char* program_name) {
    printf("用法: %s [文件] 查询参数...\n", program_name);
    printf("\n");
    printf("示例:\n");
    printf("  %s test.json name                    # 查询一级属性\n", program_name);
    printf("  %s test.json info.hobby              # 查询子属性\n", program_name);
    printf("  %s test.json list[0]                 # 查询数组属性\n", program_name);
    printf("  %s test.json list[3].product         # 查询组合属性\n", program_name);
    printf("  %s test.json name age info.hobby     # 查询多个属性\n", program_name);
    printf("\n");
    printf("输出结果: 参数对应的值，多个值用空格分隔\n");
    printf("查不到值时输出: null\n");
}

int main(int argc, char* argv[]) {
    // 检查参数数量
    if (argc < 3) {
        print_usage(argv[0]);
        return 1;
    }
    
    const char* filename = argv[1];
    
    // 读取JSON文件
    size_t file_length;
    char* json_data = read_file(filename, &file_length);
    if (!json_data) {
        return 1;
    }
    
    // 准备查询路径
    int search_count = argc - 2;
    path_result_t results[MAX_SEARCH_PATHS];
    
    // 初始化结果数组
    for (int i = 0; i < search_count && i < MAX_SEARCH_PATHS; i++) {
        results[i].search_path = argv[i + 2];
        results[i].value = NULL;
        results[i].found = 0;
    }
    
    // 初始化解析器
    jqc_parser_t parser;
    jqc_init(&parser, results, search_count);
    
    // 解析JSON
    int parse_result = jqc_parse(&parser, json_data, file_length);
    
    if (parse_result != 0) {
        //fprintf(stderr, "错误: JSON解析失败\n");
        free(json_data);
        jqc_cleanup(&parser);
        return 1;
    }
    
    // 输出结果
    int first_output = 1;
    for (int i = 0; i < search_count && i < MAX_SEARCH_PATHS; i++) {
        if (!first_output) {
            printf(" ");
        }
        
        if (results[i].found && results[i].value) {
            printf("%s", results[i].value);
        } else {
            printf("null");
        }
        
        first_output = 0;
        
        // 释放分配的内存
        if (results[i].value) {
            free(results[i].value);
        }
    }
    printf("\n");
    
    // 清理资源
    free(json_data);
    jqc_cleanup(&parser);
    
    return 0;
}
