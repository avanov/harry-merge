PROJECT := harry_merge
LINK_PKG := str

all: $(PROJECT)

$(PROJECT): $(PROJECT).ml
	corebuild -cflags -safe-string -pkg $(LINK_PKG) $(PROJECT).native

