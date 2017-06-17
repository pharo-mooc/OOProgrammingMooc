SOURCEDIRECTORY = Slides
OUTPUTDIRECTORY = book-result
LATEXTEMPLATE = support/templates/slides.pharobeamerdesign.template
HTMLTEMPLATE = support/templates/presentation.deckjs.template

#include ./support/makefiles/copySupport.mk

PILLAR_FILES    := $(shell find $(SOURCEDIRECTORY) -name '*.pillar')
PILLAR_FILES_DIRS := $(shell find $(SOURCEDIRECTORY) -name '*.pillar' -exec dirname {} \; | uniq)

PDF_FILES := $(addprefix $(OUTPUTDIRECTORY)/,$(PILLAR_FILES:%.pillar=%.pdf))
PDF_FILES_DIRS := $(addprefix $(OUTPUTDIRECTORY)/,$(PILLAR_FILES_DIRS))

NO_COLOR=\033[0m
# OK_COLOR=\033[32;01m
# ERROR_COLOR=\033[31;01m
YELLOW_COLOR=\033[33;01m
 
MSG=$(YELLOW_COLOR)++ Compile $(@:%.tex.json=%.pdf)$(NO_COLOR)
PRINT_MSG = printf "$(MSG)\n"
	
all: initDir $(PDF_FILES)

test: initDir book-result/Slides/01-Welcome/W1S05-PharoSyntaxInANutshell.pdf
	open book-result/Slides/01-Welcome/W1S05-PharoSyntaxInANutshell.pdf

initDir:
	@mkdir -p $(OUTPUTDIRECTORY)
	@cp -r support ${OUTPUTDIRECTORY}
	@mkdir -p ${PDF_FILES_DIRS}
	@test -h ${OUTPUTDIRECTORY}/figures || ln -s ../${SOURCEDIRECTORY}/figures ${OUTPUTDIRECTORY}/figures
	
$(OUTPUTDIRECTORY)/%.tex.json: %.pillar
	@$(PRINT_MSG)
	./pillar export --to="Beamer" --outputDirectory=${OUTPUTDIRECTORY} --outputFile=$(<:%.pillar=%.tex.json) $<

$(OUTPUTDIRECTORY)/%.tex: $(OUTPUTDIRECTORY)/%.tex.json
	./mustache --data=$< --template=${LATEXTEMPLATE} > $@ 

$(OUTPUTDIRECTORY)/%.pdf: $(OUTPUTDIRECTORY)/%.tex $(LATEXTEMPLATE)
	latexmk -silent -outdir=`dirname $@` -aux-directory=`dirname $@` -pdf $< 
	@rm -f `dirname $@`/*.aux `dirname $@`/*.fls `dirname $@`/*.log `dirname $@`/*.fdb_latexmk `dirname $@`/*.listing `dirname $@`/*.nav `dirname $@`/*.out `dirname $@`/*.snm `dirname $@`/*.toc `dirname $@`/*.vrb `dirname $@`/*.json `dirname $@`/*.tex 

$(OUTPUTDIRECTORY)/%.html.json: %.pillar copySupport
	./pillar export --to="DeckJS" --outputDirectory=$(OUTPUTDIRECTORY) $<

$(OUTPUTDIRECTORY)/%.html: $(OUTPUTDIRECTORY)/%.html.json
	./mustache --data=$< --template=${HTMLTEMPLATE} > $@

clean:
	rm -fr ${OUTPUTDIRECTORY}

# .PRECIOUS: %.tex

.SECONDARY:
