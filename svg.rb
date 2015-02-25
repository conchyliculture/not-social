#!/usr/bin/ruby

require "nokogiri"
require "fileutils"
require "pp"
require "json"
require "digest/md5"

$color="ffffff"
$patch_color="000000"
$output_dir="build"

def make_not_svg(file,overwrite=false)

    cos = Math.cos(Math::PI/4)

    fin = file
    FileUtils.mkdir_p(File.join($output_dir,"svg")) 
    fout = File.join($output_dir,"svg","not-"+File.basename(fin))


    if File.exists?(fout) and not overwrite
        return fout
    end

    input_file = File.read(fin).gsub(/viewbox=/i,"viewBox=")
    input_file.gsub!(/#....../,"##{$patch_color}") if $patch_color

    xml = Nokogiri::XML(input_file)
    svg_node = xml.at("svg")

    width = svg_node["width"].to_i
    height = svg_node["height"].to_i

    hd= 0
    wd=0

    max= [width,height].max
    factor = 1.1

    if (max == width)
        wd= width*(1-1/factor)
        hd= height*(1-1/factor) +(width - height)
        height=width
    else
        wd= width*(1-1/factor) + (height - width)
        hd= height*(1-1/factor) 
    end
    orig_path = xml.at("path")
    orig_path["transform"]="scale(#{1000.0/width}) translate(#{wd/2},#{hd/2}) scale(#{1/factor})"


    svg_node["width"] = 1000 
    svg_node["height"] = 1000 
    svg_node["viewBox"]=nil

    width=1000
    height=1000

    $rec_width=width/10

    l= (width / cos) - $rec_width

    rec1 = Nokogiri::XML::Node.new "rect", xml
    rec1["width"]= $rec_width
    rec1["height"] = (width / cos) - $rec_width
    rec1["transform"] = "translate(0, #{ (height/2) - (cos *l/2) + (cos * $rec_width/2) }) matrix(#{cos} , -#{cos}, #{cos}, #{cos} , 0, 0)"
    rec1["style"] = "fill:#{$color}"
    svg_node.add_child(rec1)

    rec2 = Nokogiri::XML::Node.new "rect", xml
    rec2["width"]= $rec_width
    rec2["height"] = (width / cos) - $rec_width
    rec2["transform"] = "translate(#{width - $rec_width*cos }, #{ (height/2) - (cos *l/2) - (cos * $rec_width/2) } ) matrix(#{cos} , #{cos}, -#{cos}, #{cos} , 0, 0)"
    rec2["style"] = "fill:#{$color}"
    svg_node.add_child(rec2)


    f= File.open(fout,'w')
    f.write(xml.to_xml)
    f.close
    return fout
end

def unify_path(file,overwrite=false)
    fin = file
    fout = File.join(File.dirname(fin),"u-"+File.basename(fin))

    if File.exists?(fout) and not overwrite
        return fout
    end
    
    res = IO.popen("inkscape  --verb EditSelectAll --verb ObjectUngroup --verb SelectionUnion --verb SelectionCombine --verb FileVacuum --verb FileSave --verb FileQuit  \"#{fin}\"")
    res.read()
    return fin
end

def xml_to_json(name,xml, code=59392)
    root = Nokogiri.parse(xml)
    path= root.at("svg/path")["d"]
    width= root.at("svg")["width"]
    res={}
    res[:uid]=Digest::MD5.hexdigest(name+rand(123456789).to_s)
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
    case f
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

