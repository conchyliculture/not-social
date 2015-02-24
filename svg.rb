#!/usr/bin/ruby

require "nokogiri"
require "pp"
require "json"
require "digest/md5"

def make_not_svg(file)

    $color="ffffff"

    $patch_box=true
    $patch_color="000000"

    cos = Math.cos(Math::PI/4)

    fin = file
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
    return fout
end

def unify_path(file)
    fin = file
    fout = File.join(File.dirname(fin),"u-"+File.basename(fin))
    
    res = IO.popen("inkscape  --verb EditSelectAll --verb ObjectUngroup --verb SelectionUnion --verb SelectionCombine --verb FileVacuum --verb FileSave --verb FileQuit  \"#{fin}\"")
    res.read()
    return fin
end

def xml_to_json(name,xml, code=59392)
    root = Nokogiri.parse(xml)
    path= root.at("svg/path")["d"]
    width= 1200# root.at("svg")["width"]
    res={}
    res[:uid]=Digest::MD5.hexdigest(name)
    res[:css] = name
    res[:code] = code
    res[:src] = "custom_icons"
    res[:selected] = true

    res[:svg] = Hash.new()
    res[:svg][:path] = path
    res[:svg][:width] = width

    return res
end




res_json={}
res_json[:name]="not-social"
res_json[:css_prefix_text]= "icon-"
res_json[:css_use_suffix] = false
res_json[:hinting] = true
res_json[:units_per_em] = 1000
res_json[:ascent] = 850

code=59392
Dir.glob(File.join(ARGV[0],"*")).each do |f|
    puts code
    
    case f
    when /\/not-.*svg/i
        next
    when /.*.svg$/i
        puts "Converting #{f}"
        res_svg=make_not_svg(f)
        u_res_svg=unify_path(res_svg) 
        j =  xml_to_json(File.basename(f, '.svg'),File.read(u_res_svg),code)
        code+=1
        (res_json["glyphs"] ||= [] ) << j
    end

end
config = File.new("config.json","w+")
config.write(JSON.pretty_generate(res_json))
config.close()

IO.popen("curl  -H \"Expect:\" --silent --show-error --fail --output .fontello  --form \"config=@config.json\"      \"http://fontello.com/\"").read()
IO.popen("curl --silent --show-error --fail --output fontello.zip  -H \"Expect:\"   \"http://fontello.com/#{File.read('.fontello')}/get\"").read()




