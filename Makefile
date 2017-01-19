# Makefile for man-tokenizer project.

.PHONY: all clean

TARGET := man.js
SOURCE := $(TARGET:.js=.jison)

all: $(TARGET)

$(TARGET): $(SOURCE)
	jison $<

clean:
	rm -rf man-pages-tokens/ man-pages-manual/ $(TARGET)
