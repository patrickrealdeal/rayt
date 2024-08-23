SRC_DIR = src
EXECUTABLE = rtiow
OUTPUT_DIR = output
IMAGE_FILE = $(OUTPUT_DIR)/image.ppm
FLAGS = -o:none -debug -microarch:native -disable-assert -no-bounds-check -minimum-os-version:10.13
SPEED = -o:speed -microarch:native -disable-assert -no-bounds-check -minimum-os-version:10.13

.PHONY: all build run time clean speed

all: build

build:
	@odin build $(SRC_DIR) $(FLAGS) -out:$(EXECUTABLE)

run: build
	@mkdir -p $(OUTPUT_DIR)
	@./$(EXECUTABLE) > $(IMAGE_FILE)

speed:
	@odin build $(SRC_DIR) $(SPEED) -out:$(EXECUTABLE)
	@time ./$(EXECUTABLE) > $(IMAGE_FILE)
	

time:
	@mkdir -p $(OUTPUT_DIR)
	@time ./$(EXECUTABLE) > $(IMAGE_FILE)

clean:
	@rm -f ./$(EXECUTABLE)
	@rm -rf rtiow.dSYM
	@rm -rf $(OUTPUT_DIR)
