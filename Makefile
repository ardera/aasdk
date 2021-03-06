PROTO_FILES := $(shell find . -name '*.proto')
C_FILES := $(patsubst %.proto,%.pb-c.c,$(PROTO_FILES))
H_FILES := $(patsubst %.proto,%.pb-c.h,$(PROTO_FILES))
O_FILES := $(patsubst %.proto,%.pb-c.o,$(PROTO_FILES))

all: libaaproto.a headers

$(C_FILES) $(H_FILES) &: $(PROTO_FILES)
	@protoc-c --c_out=. -I. $(PROTO_FILES)

%.o: %.c
	$(CC) -c -O3 $(shell pkg-config --cflags 'libprotobuf-c >= 1.0.0') $< -o $@

headers: $(H_FILES)

libaaproto_unbundled.a: $(O_FILES)
	@$(AR) -rcs libaaproto_unbundled.a $(O_FILES)

libaaproto.a: libaaproto_unbundled.a
	@printf "CREATE libaaproto.a\nADDLIB libaaproto_unbundled.a\nADDLIB $(shell locate libprotobuf-c.a)\nSAVE\nEND" | $(AR) -M

clean:
	@rm -rf $(C_FILES) $(H_FILES) $(O_FILES) libaaproto_unbundled.a libaaproto.a
