# JQC Makefile
CC ?= gcc
CFLAGS = -Wall -Wextra -std=c99 -O2
TARGET = jqc
SRCDIR = src
OBJDIR = obj
SOURCES = $(wildcard $(SRCDIR)/*.c)
OBJECTS = $(SOURCES:$(SRCDIR)/%.c=$(OBJDIR)/%.o)

# 默认目标
all: $(TARGET)

# 创建目标可执行文件
$(TARGET): $(OBJECTS)
	$(CC) $(OBJECTS) -o $(TARGET)

# 编译源文件到对象文件
$(OBJDIR)/%.o: $(SRCDIR)/%.c | $(OBJDIR)
	$(CC) $(CFLAGS) -c $< -o $@

# 创建对象文件目录
$(OBJDIR):
	mkdir -p $(OBJDIR)

# 清理构建文件
clean:
	rm -rf $(OBJDIR) $(TARGET)

# 安装到系统路径 (需要sudo权限)
install: $(TARGET)
	cp $(TARGET) /usr/local/bin/

# 卸载
uninstall:
	rm -f /usr/local/bin/$(TARGET)

# 调试构建
debug: CFLAGS += -g -DDEBUG
debug: $(TARGET)

# 显示帮助信息
help:
	@echo "JQC Makefile 目标:"
	@echo "  all      - 构建 jqc (默认)"
	@echo "  clean    - 清理构建文件"
	@echo "  install  - 安装到系统路径"
	@echo "  uninstall- 卸载"
	@echo "  debug    - 构建调试版本"
	@echo "  help     - 显示此帮助信息"

.PHONY: all clean install uninstall debug help
