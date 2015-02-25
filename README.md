# not-social

Create "not" font-face "icons" for social websites

## About

Nowadays, resisting peer pressure and trying to join as little as possible any kind of social network is very hard.

You need to be proud of resisting, and display your anarchism on your blog/webpage/whatever.

Yet you're curious about how the web is made and want to be (kinda) part of it.

That's why you want anti-@font-faces like those:

![not-facebook](https://raw.githubusercontent.com/conchyliculture/not-social/master/build/png/not-facebooksvg.png)
![not-blogger](https://raw.githubusercontent.com/conchyliculture/not-social/master/build/png/not-blogger.png)
![not-youtube](https://raw.githubusercontent.com/conchyliculture/not-social/master/build/png/not-youtube.png)
![not-linkedin](https://raw.githubusercontent.com/conchyliculture/not-social/master/build/png/not-linkedin.png)
![not-instagram](https://raw.githubusercontent.com/conchyliculture/not-social/master/build/png/not-instagram-empty.png)
![not-twitter](https://raw.githubusercontent.com/conchyliculture/not-social/master/build/png/not-twitter-bird.png)

## Using

This repo comes with some SVG icons already "not"-ified. You can fetch a nice, ready to use bundle with the font-faces this way:

    make fontello

Everything you need is going to be in the `fontello.zip` archive. You can display it in your browser with :

    make show

Just hack html/css/everything from the `demo.html` page source that opened into your socialnetworks-free website.

If you want to rebuild everything, because it's your thing, or because you modified/added to the `src_icons̀` folder:

    make svg
    make show


## Add more fonts

Copy SVG files of the icon you want to cross out in `src_icons` folder and run

    make svg

The SVG has to be as simple as possible, with just a `path` defined.

## Requirements

Required : 

    apt-get install ruby-nokogiri inkscape 

Optional :

    apt-get install librsvg2-bin  # to convert from svg to png

## Code

It's very ugly. Please yell at it.
