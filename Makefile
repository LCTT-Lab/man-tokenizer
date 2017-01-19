# Makefile for man-tokenizer project.

.PHONY: all test clean
.PRECIOUS: man-pages-manual/% man-pages-tokens/%

TARGET := man.js
SOURCE := $(TARGET:.js=.jison)

NODE := node

TOKENIZE := $(NODE) $(TARGET)
ASSEMBLE := ./man-assemble
VERIFY   := ./man-verify

MAN_MANUAL := $(patsubst man-pages-source%,\
                         man-pages-manual%,\
                         $(shell find man-pages-source/man?/ -type f))

all: $(TARGET)

test: $(TARGET) $(MAN_MANUAL)
	$(VERIFY)

clean:
	rm -rf man-pages-tokens/ man-pages-manual/ $(TARGET)

$(TARGET): $(SOURCE)
	jison $<

man-pages-manual/%: man-pages-tokens/%.tokens
	@echo Re-assemble manual $(notdir $@) from $(notdir $<)...
	@mkdir -p $(dir $@)
	$(ASSEMBLE) $< > $@

man-pages-tokens/%.tokens: man-pages-source/% $(TARGET)
	@echo Generate tokens $(notdir $@) from $(notdir $<)...
	@mkdir -p $(dir $@)
	$(TOKENIZE) $< > $@
