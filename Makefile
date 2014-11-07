PROJECT := harry_merge


all: $(PROJECT)

$(PROJECT): $(PROJECT).ml
	corebuild $(PROJECT).native

