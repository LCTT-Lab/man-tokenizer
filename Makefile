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

TARGET := man.rb
SOURCE := $(TARGET:.rb=.y)

RUBY := ruby

TOKENIZE := $(RUBY) $(TARGET)
ASSEMBLE := $(RUBY) man-assemble.rb
VERIFY   := ./man-verify

MAN_SOURCE  := $(shell find man-pages-source/man?/ -type f -name '*.?')
MAN_MANUAL  := $(patsubst man-pages-source%, man-pages-manual%, $(MAN_SOURCE))
MAN_ALL     := $(MAN_SOURCE) $(MAN_MANUAL)
MAN_PREVIEW := $(patsubst %, previews/%.txt, $(MAN_ALL))

.PHONY: all test clean
.PRECIOUS: man-pages-manual/% man-pages-tokens/%.tokens previews/%.txt

all: $(TARGET)

test: $(TARGET) $(MAN_PREVIEW)
	$(VERIFY)

clean:
	rm -rf man-pages-tokens/ man-pages-manual/ previews/ $(TARGET)

$(TARGET): $(SOURCE)
	racc -o $@ $<

previews/%.txt: %
	@echo Render preview $(notdir $@) from $(notdir $<)...
	@mkdir -p $(dir $@)
	env MANWIDTH=80 man -Pcat $< > $@

man-pages-manual/%: man-pages-tokens/%.tokens
	@echo Re-assemble manual $(notdir $@) from $(notdir $<)...
	@mkdir -p $(dir $@)
	$(ASSEMBLE) $< $@

man-pages-tokens/%.tokens: man-pages-source/% $(TARGET)
	@echo Generate tokens $(notdir $@) from $(notdir $<)...
	@mkdir -p $(dir $@)
	$(TOKENIZE) $< > $@
