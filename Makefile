svg: clean
	ruby svg.rb src_icons 

show: 
	unzip fontello.zip
	iceweasel fontello-*/demo.html


clean: 
	rm -rf fontello-*
	rm -rf .fontello
	rm -rf fontello.zip
	rm -rf config.json
	rm -rf src_icons/not-*
