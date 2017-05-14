muttrulez.1: README.md
	-which pandoc && pandoc --standalone -o muttrulez.1 -t man README.md
install: muttrulez.1
	cp muttrulez $(DESTDIR)/usr/bin
	cp muttrulez.1 $(DESTDIR)/usr/share/man/man1
uninstall:
	rm $(DESTDIR)/usr/bin/muttrulez
	rm $(DESTDIR)/usr/share/man/man1/muttrulez.1
