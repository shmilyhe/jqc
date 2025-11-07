#include "jqc.h"
#include <string.h>
#include <stdlib.h>
#include <ctype.h>

// 初始化解析器
void jqc_init(jqc_parser_t *parser, path_result_t *results, int result_count) {
    memset(parser, 0, sizeof(jqc_parser_t));
    parser->currpath[0] = '\0';
    parser->level = 0;
    parser->state = READY;
    parser->key_index = 0;
    parser->value_index = 0;
    parser->in_string = 0;
    parser->escape_next = 0;
    parser->results = results;
    parser->result_count = result_count;
}

// 清理解析器
void jqc_cleanup(jqc_parser_t *parser) {
    // 目前没有需要清理的动态资源
}

// 对象开始回调
void on_object_start(jqc_parser_t *parser) {
    if (parser->level < 64) {
        parser->level_stack[parser->level] = OBJECT;
        parser->level++;
        DEBUG_PRINT("对象开始, level=%d, currpath='%s'\n", parser->level, parser->currpath);
    }
}

// 对象结束回调
void on_object_end(jqc_parser_t *parser) {
    if (parser->level > 0) {
        parser->level--;
        
        // 更新当前路径
        char *last_dot = strrchr(parser->currpath, '.');
        if (last_dot) {
            *last_dot = '\0';
        } else {
            parser->currpath[0] = '\0';
        }
        DEBUG_PRINT("对象结束, level=%d, currpath='%s'\n", parser->level, parser->currpath);
    }
}

// 数组开始回调
void on_array_start(jqc_parser_t *parser) {
    parser->value_index = 0;
    if (parser->level < 64) {
        parser->level_stack[parser->level] = ARRAY;
        parser->level++;
        
        // 添加数组索引
        if (parser->currpath[0] != '\0') {
            strcat(parser->currpath, "[0]");
        }
        DEBUG_PRINT("数组开始, level=%d, currpath='%s'\n", parser->level, parser->currpath);
    }
}

// 数组结束回调
void on_array_end(jqc_parser_t *parser) {
    DEBUG_PRINT("数组结束, level=%d, currpath='%s'\n", parser->level, parser->currpath);
    if (parser->level > 0) {
        parser->level--;
        
        // 更新当前路径
        char *last_bracket = strrchr(parser->currpath, '[');
        if (last_bracket) {
            // 保存当前位置
            char *save_pos = last_bracket;
            
            // 找到最后一个 '[' 的位置并截断
            *last_bracket = '\0';
            
            // 检查是否有嵌套数组
            char *prev_bracket = strrchr(parser->currpath, '[');
            if (prev_bracket) {
                // 有嵌套数组，如 "x[a][b][c]" -> 回退到 "x[a][b]" 并更新索引
                // 找到前一个数组的 ']'
                char *prev_closing = strchr(prev_bracket, ']');
                if (prev_closing) {
                    // 更新前一个数组的索引
                    int index = atoi(prev_bracket + 1);
                    index++;
                    sprintf(prev_bracket, "[%d]", index);
                }
            } else {
                // 没有嵌套数组，检查是否有前缀路径
                if (save_pos > parser->currpath && *(save_pos - 1) == '.') {
                    // 有前缀路径，如 "a.x[0]" -> 回退到 "a"
                    *(save_pos - 1) = '\0';
                } else {
                    // 没有前缀路径，如 "x[0]" -> 回退到 ""
                    parser->currpath[0] = '\0';
                }
            }
        } else {
            // 如果没有找到 '['，说明是根级别的数组，清空路径
            parser->currpath[0] = '\0';
        }
        DEBUG_PRINT("数组结束路径回退, level=%d, currpath='%s'\n", parser->level, parser->currpath);
    }
}

// 键开始回调
void on_key_start(jqc_parser_t *parser) {
    parser->key_index = 0;
    parser->key_buffer[0] = '\0';
    
}

// 键结束回调
void on_key_end(jqc_parser_t *parser) {
    parser->value_index = 0;
    parser->key_buffer[parser->key_index] = '\0';
    
    // 更新当前路径
    if (parser->currpath[0] != '\0') {
        strcat(parser->currpath, ".");
    }
    strcat(parser->currpath, parser->key_buffer);
    DEBUG_PRINT("键结束, key='%s', currpath='%s'\n", parser->key_buffer, parser->currpath);
}

// 值开始回调
void on_value_start(jqc_parser_t *parser) {
    parser->value_index = 0;
    parser->value_buffer[0] = '\0';
    DEBUG_PRINT("值开始, 清空缓冲区\n");
}

// 值结束回调
void on_value_end(jqc_parser_t *parser) {

    parser->value_buffer[parser->value_index] = '\0';
    
    DEBUG_PRINT("值结束, currpath='%s', value='%s'\n", parser->currpath, parser->value_buffer);
    
    // 调用相应的回调函数
    if (parser->level > 0 && parser->level_stack[parser->level-1] == OBJECT) {
        callback_property(parser->currpath, parser->value_buffer, parser->results, parser->result_count);
        
        // 更新路径：去掉最后的键
        char *last_dot = strrchr(parser->currpath, '.');
        if (last_dot) {
            *last_dot = '\0';
        } else {
            // 如果没有点，说明是根级别的属性，清空路径
            parser->currpath[0] = '\0';
        }
    } else if (parser->level > 0 && parser->level_stack[parser->level-1] == ARRAY) {
        callback_array(parser->currpath, parser->value_buffer, parser->results, parser->result_count);
        
        // 更新数组索引
        char *last_bracket = strrchr(parser->currpath, '[');
        if (last_bracket) {
            char *closing_bracket = strchr(last_bracket, ']');
            if (closing_bracket) {
                int index = atoi(last_bracket + 1);
                index++;
                sprintf(last_bracket, "[%d]", index);
            }
        }
    }
    parser->value_index=0;
}

// 属性回调函数
void callback_property(char *currpath, char *value, path_result_t *results, int result_count) {
    DEBUG_PRINT("属性回调: currpath='%s', value='%s'\n", currpath, value);
    for (int i = 0; i < result_count; i++) {
        DEBUG_PRINT("  比较: '%s' vs '%s'\n", currpath, results[i].search_path);
        if (strcmp(currpath, results[i].search_path) == 0) {
            DEBUG_PRINT("  匹配成功!\n");
            if (results[i].value) {
                free(results[i].value);
            }
            results[i].value = strdup(value);
            results[i].found = 1;
        }
    }
}

// 数组回调函数
void callback_array(char *currpath, char *value, path_result_t *results, int result_count) {
    for (int i = 0; i < result_count; i++) {
        if (strcmp(currpath, results[i].search_path) == 0) {
            if (results[i].value) {
                free(results[i].value);
            }
            results[i].value = strdup(value);
            results[i].found = 1;
        }
    }
}

// 主解析函数
int jqc_parse(jqc_parser_t *parser, const char *json_data, size_t length) {
    for (size_t i = 0; i < length; i++) {
        char c = json_data[i];
        
        //printf("char: %c\n", c);
        // 处理转义字符
        if (parser->escape_next) {
            if (parser->in_string) {
                if (parser->key_index < 255) {
                    parser->key_buffer[parser->key_index++] = c;
                }
                if (parser->value_index < 1023) {
                    parser->value_buffer[parser->value_index++] = c;
                }
            }
            parser->escape_next = 0;
            continue;
        }
        
        if (c == '\\') {
            parser->escape_next = 1;
            continue;
        }
        
        // 处理字符串
        if (parser->in_string) {
            if (c == '"') {
                parser->in_string = 0;
                if (parser->state == START_KEY) {
                    on_key_end(parser);
                    parser->state = START_VALUE;
                } else if (parser->state == START_VALUE) {
                    on_value_end(parser);
                    parser->state = READY;
                }
            } else {
                if (parser->state == START_KEY && parser->key_index < 255) {
                    parser->key_buffer[parser->key_index++] = c;
                }
                if (parser->state == START_VALUE && parser->value_index < 1023) {
                    parser->value_buffer[parser->value_index++] = c;
                }
            }
            continue;
        }
        
        // 处理其他字符
        switch (c) {
            case '{':
                on_object_start(parser);
                parser->state = READY;
                break;
                
            case '}':
                on_object_end(parser);
                // 处理非字符串值的结束
                if (parser->state == START_VALUE && parser->value_index > 0) {
                    on_value_end(parser);
                }
                parser->state = READY;
                break;
                
            case '[':
                on_array_start(parser);
                parser->state = READY;
                break;
                
            case ']':
                if(parser->state==START_VALUE){
                    on_value_end(parser);
                }
                
                on_array_end(parser);
                parser->state = READY;
                break;
                
            case ':':
                if(parser->state==START_VALUE)break;
                parser->state = START_VALUE;
                // 对于非字符串值，立即开始值读取
                if (!parser->in_string) {
                    on_value_start(parser);
                }
                break;
                
            case '"':
                if (parser->in_string) {
                    // 字符串结束
                    parser->in_string = 0;
                    if (parser->state == START_KEY) {
                        on_key_end(parser);
                        parser->state = START_VALUE;
                    } else if (parser->state == START_VALUE) {
                        on_value_end(parser);
                        parser->state = READY;
                    }
                } else {
                    // 字符串开始
                    parser->in_string = 1;
                    if (parser->state == READY) {
                        if (parser->level > 0 && parser->level_stack[parser->level-1] == OBJECT) {
                            parser->state = START_KEY;
                            on_key_start(parser);
                        } else {
                            parser->state = START_VALUE;
                            on_value_start(parser);
                        }
                    } else if (parser->state == START_VALUE) {
                        // 在START_VALUE状态下遇到字符串开始，说明是字符串值
                        on_value_start(parser);
                    }
                }
                break;
                
            case ',':
                //printf("level %d type:%d parser->state:%d \n",parser->level,parser->level_stack[parser->level-1],parser->state );
                // 处理非字符串值的结束
                if (parser->state == START_VALUE && parser->value_index >= 0) {
                    on_value_end(parser);
                    parser->state = READY;
                }
                if (parser->level > 0) {
                    if (parser->level_stack[parser->level-1] == OBJECT) {
                        parser->state = READY;
                    } else if (parser->level_stack[parser->level-1] == ARRAY) {
                        parser->state = START_VALUE;
                    }
                }
                
                break;
                
            default:
                // 处理非字符串值（数字、布尔值、null）
                if(parser->level_stack[parser->level-1] == ARRAY&&parser->state != START_VALUE){
                    parser->state = START_VALUE;
                    parser->value_index = 0;
                }
                if (parser->state == START_VALUE && !isspace(c)) {
                    // 如果还没有开始值读取，先开始
                    if (parser->value_index == 0) {
                        on_value_start(parser);
                    }
                    if (parser->value_index < 1023) {
                         //printf("value: %c \n",c);
                        parser->value_buffer[parser->value_index++] = c;
                    }
                }else{
                    //printf("skip char %c \n",c);
                }
                break;
        }
    }
    
    return 0;
}
