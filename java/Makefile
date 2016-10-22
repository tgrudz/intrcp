all :

build :

	@if [ `uname` = Linux ] ; then \
	./build.sh; \
	fi

inst :
	@[ -d ../INST/main-app/silp-dir/app-dir/bin ] || mkdir -p ../INST/main-app/silp-dir/app-dir/bin/
	@cp rcpsilp-1.0.jar  ../INST/main-app/silp-dir/app-dir/bin

clean :

	rm -fR build
