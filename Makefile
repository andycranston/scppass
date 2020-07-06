userinstall:
	cp scppass.exp    $(HOME)/bin/scppass
	chmod u=rwx,go=rx $(HOME)/bin/scppass
	
