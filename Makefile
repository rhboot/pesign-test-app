VERSION = 0.3
ARCH            = $(shell uname -m | sed s,i[3456789]86,ia32,)
DATADIR := /usr/share
LIBDIR := /usr/lib64
CC = gcc
CFLAGS = -O2 -fpic -Wall -fshort-wchar -fno-strict-aliasing -fno-merge-constants -mno-red-zone -DCONFIG_$(ARCH) -DGNU_EFI_USE_MS_ABI -maccumulate-outgoing-args --std=c99 -I/usr/include/efi -I/usr/include/efi/$(ARCH) -I/usr/include/efi/protocol
LD = ld
LDFLAGS = -nostdlib -T $(LIBDIR)/gnuefi/elf_$(ARCH)_efi.lds -shared -Bsymbolic -L$(LIBDIR) $(LIBDIR)/gnuefi/crt0-efi-$(ARCH).o
OBJCOPY = objcopy

all : pesign-test-app.efi

%.efi : %.so
	$(OBJCOPY) -j .text -j .sdata -j .data -j .dynamic -j .dynsym -j .rel \
		   -j .rela -j .reloc --target=efi-app-$(ARCH) $^ $@

%.so : %.o
	$(LD) $(LDFLAGS) -o $@ $^ -lefi -lgnuefi

%.o : %.c
	$(CC) $(CFLAGS) -c -o $@ $^

clean :
	@rm -vf *.o *.so *.efi

install :
	install -D -d -m 0755 $(INSTALLROOT)/$(DATADIR)/pesign-test-app-$(VERSION)
	install -m 0644 pesign-test-app.efi $(INSTALLROOT)/$(DATADIR)/pesign-test-app-$(VERSION)/pesign-test-app.efi

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
