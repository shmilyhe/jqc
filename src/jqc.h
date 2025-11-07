#ifndef JQC_H
#define JQC_H

#include <stdint.h>
#include <stdio.h>

#define MAX_PATH_LENGTH 512
#define MAX_SEARCH_PATHS 16

// 调试宏
#ifdef DEBUG
#define DEBUG_PRINT(fmt, ...) printf("[DEBUG] " fmt, ##__VA_ARGS__)
#else
#define DEBUG_PRINT(fmt, ...)
#endif

// JSON类型枚举
typedef enum {
    OBJECT,
    ARRAY
} json_type_t;

// 解析状态枚举
typedef enum {
    READY,
    START_KEY,
    START_VALUE,
    IN_STRING
} parse_state_t;

// 路径结果结构体
typedef struct {
    char *search_path;
    char *value;
    uint8_t found;
} path_result_t;

// JSON解析器上下文
typedef struct {
    char currpath[MAX_PATH_LENGTH];
    json_type_t level_stack[64];
    int level;
    parse_state_t state;
    char key_buffer[256];
    char value_buffer[1024];
    int key_index;
    int value_index;
    int in_string;
    int escape_next;
    path_result_t *results;
    int result_count;
} jqc_parser_t;

// 函数声明
void jqc_init(jqc_parser_t *parser, path_result_t *results, int result_count);
int jqc_parse(jqc_parser_t *parser, const char *json_data, size_t length);
void jqc_cleanup(jqc_parser_t *parser);

// 回调函数声明
void on_object_start(jqc_parser_t *parser);
void on_object_end(jqc_parser_t *parser);
void on_array_start(jqc_parser_t *parser);
void on_array_end(jqc_parser_t *parser);
void on_key_start(jqc_parser_t *parser);
void on_key_end(jqc_parser_t *parser);
void on_value_start(jqc_parser_t *parser);
void on_value_end(jqc_parser_t *parser);
void callback_property(char *currpath, char *value, path_result_t *results, int result_count);
void callback_array(char *currpath, char *value, path_result_t *results, int result_count);

#endif // JQC_H
