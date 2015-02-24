svg: clean
	ruby svg.rb src_icons 

show: 
	unzip -q fontello.zip
	echo Show your fonts to your friends : http://fontello.com/`cat .fontello`
	iceweasel fontello-*/demo.html


clean: 
	rm -rf fontello-*
	rm -rf .fontello
	rm -rf fontello.zip
	rm -rf config.json
	rm -rf src_icons/not-*
