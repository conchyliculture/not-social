svg: clean
	ruby svg.rb src_icons 

show: 
	unzip -q fontello.zip
	echo Show your fonts to your friends : http://fontello.com/`cat .fontello`
	x-www-browser fontello-*/demo.html

png:
	rm -rf build/png
	mkdir -p build/png
	for svg in build/svg/*.svg ; do \
		out_png=`basename "$$svg"` ; \
		convert -resize 10% "$$svg" "build/png/$${out_png%svg}png" ; \
	done

clean: 
	rm -rf fontello-*
	rm -rf .fontello
	rm -rf fontello.zip
	rm -rf config.json
	rm -rf build
