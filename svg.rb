#!/usr/bin/ruby

require "nokogiri"
require "pp"

$color="ffffff"

$patch_box=true
$patch_color="000000"

cos = Math.cos(Math::PI/4)

fin = ARGV[0]
fout = File.join(File.dirname(fin),"not-"+File.basename(fin))

input_file = File.read(fin).gsub(/viewbox=/i,"viewBox=")
input_file.gsub!(/#....../,"##{$patch_color}") if $patch_color

xml = Nokogiri::XML(input_file)
svg_node = xml.at("svg")

width = svg_node["width"].to_i
height = svg_node["height"].to_i

vbox =  svg_node["viewBox"] 
vbox_x=0
vbox_y=0
vbox_w=0
vbox_h=0
if $patch_box
    vbox_x = - 0.1*width 
    vbox_y = - 0.1*height 
    vbox_h = height - vbox_x *2
    vbox_w = width - vbox_y *2

    svg_node["viewBox"] = [vbox_x,vbox_y, vbox_w, vbox_h].join(" ")
    pp svg_node["viewBox"]
    width = vbox_w
    height = vbox_h
    svg_node["width"]=width
    svg_node["height"]=height
else
    vbox_x,vbox_y,vbox_h,vbox_w = vbox.split(" ").map{|x| x.to_i}
end

$rec_width=width/10

l= (width / cos) - $rec_width

rec1 = Nokogiri::XML::Node.new "rect", xml
rec1["width"]= $rec_width
rec1["height"] = (width / cos) - $rec_width
rec1["transform"] = "translate(#{vbox_x}, #{ (height/2) - (cos *l/2) + (cos * $rec_width/2) + vbox_y}) matrix(#{cos} , -#{cos}, #{cos}, #{cos} , 0, 0)"
rec1["style"] = "fill:#{$color}"
svg_node.add_child(rec1)

rec2 = Nokogiri::XML::Node.new "rect", xml
rec2["width"]= $rec_width
rec2["height"] = (width / cos) - $rec_width
rec2["transform"] = "translate(#{width - $rec_width*cos +vbox_x}, #{ (height/2) - (cos *l/2) - (cos * $rec_width/2) + vbox_y} ) matrix(#{cos} , #{cos}, -#{cos}, #{cos} , 0, 0)"
rec2["style"] = "fill:#{$color}"
svg_node.add_child(rec2)

f= File.open(fout,'w')
f.write(xml.to_xml)
f.close
