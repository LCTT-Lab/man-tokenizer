# Makefile for man-tokenizer project.
#
# Copyright (C) 2017  LCTT
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

.PHONY: all test clean
.PRECIOUS: man-pages-manual/% man-pages-tokens/%.tokens

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
	find man-pages-manual/ -empty -type f -exec rm '{}' \;
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
