VERSION = 0.2

PREFIX := /
DATADIR := /usr/share
CC = gcc
CFLAGS = -O2 -fpic -Wall -fshort-wchar -fno-strict-aliasing -fno-merge-constants -mno-red-zone -DCONFIG_x86_64 -DGNU_EFI_USE_MS_ABI -maccumulate-outgoing-args --std=c99 -I/usr/include/efi -I/usr/include/efi/x86_64 -I/usr/include/efi/protocol
LD = ld
LDFLAGS = -nostdlib -T /usr/lib64/gnuefi/elf_x86_64_efi.lds -shared -Bsymbolic -L/usr/lib64 /usr/lib64/gnuefi/crt0-efi-x86_64.o
OBJCOPY = objcopy

all : pesign-test-app.efi

%.efi : %.so
	$(OBJCOPY) -j .text -j .sdata -j .data -j .dynamic -j .dynsym -j .rel \
		   -j .rela -j .reloc --target=efi-app-x86_64 $^ $@

%.so : %.o
	$(LD) $(LDFLAGS) -o $@ $^ -lefi -lgnuefi

%.o : %.c
	$(CC) $(CFLAGS) -c -o $@ $^

clean :
	@rm -vf *.o *.so *.efi

install :
	install -D -d -m 0755 $(PREFIX)/$(DATADIR)/pesign-test-app-$(VERSION)
	install -m 0644 pesign-test-app.efi $(PREFIX)/$(DATADIR)/pesign-test-app-$(VERSION)/pesign-test-app.efi

GITTAG = $(VERSION)

test-archive:
	@rm -rf /tmp/pesign-test-app-$(VERSION) /tmp/pesign-test-app-$(VERSION)-tmp
	@mkdir -p /tmp/pesign-test-app-$(VERSION)-tmp
	@git archive --format=tar $(shell git branch | awk '/^*/ { print $$2 }') | ( cd /tmp/pesign-test-app-$(VERSION)-tmp/ ; tar x )
	@git diff | ( cd /tmp/pesign-test-app-$(VERSION)-tmp/ ; patch -s -p1 -b -z .gitdiff )
	@mv /tmp/pesign-test-app-$(VERSION)-tmp/ /tmp/pesign-test-app-$(VERSION)/
	@dir=$$PWD; cd /tmp; tar -c --bzip2 -f $$dir/pesign-test-app-$(VERSION).tar.bz2 pesign-test-app-$(VERSION)
	@rm -rf /tmp/pesign-test-app-$(VERSION)
	@echo "The archive is in pesign-test-app-$(VERSION).tar.bz2"

archive:
	git tag $(GITTAG) refs/heads/master
	@rm -rf /tmp/pesign-test-app-$(VERSION) /tmp/pesign-test-app-$(VERSION)-tmp
	@mkdir -p /tmp/pesign-test-app-$(VERSION)-tmp
	@git archive --format=tar $(GITTAG) | ( cd /tmp/pesign-test-app-$(VERSION)-tmp/ ; tar x )
	@mv /tmp/pesign-test-app-$(VERSION)-tmp/ /tmp/pesign-test-app-$(VERSION)/
	@dir=$$PWD; cd /tmp; tar -c --bzip2 -f $$dir/pesign-test-app-$(VERSION).tar.bz2 pesign-test-app-$(VERSION)
	@rm -rf /tmp/pesign-test-app-$(VERSION)
	@echo "The archive is in pesign-test-app-$(VERSION).tar.bz2"
