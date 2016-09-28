########
#
#  ig2fbx.rb
#
#  <olykken@gmail.com>
#  based on ig2skp.rb by
#  Thomas McCauley <thomas.mccauley@cern.ch>
#
#  Ruby script designed to be imported into SketchUp
#  You specify a directory containing CMS JSON event files in the ig format
#  Each file is processed in turn, producing a 3D event display exported as fbx files,
#  with xml files that contain event info
#
#  The output has separate pairs of .fbx and .xml files for each of the following physics objects:
#  one pair for the calo part of the event (xml contains nothing FIX THIS)
#  one pair for each muon (xml contains pt, eta, phi, and charge)
#  one pair for each electron (xml contains pt, eta, phi, and charge)
#  one pair for each additional track (xml contains pt, eta, phi, and charge)
#
#  The output files are suitable for importing in Unity3D for, e.g. use with Oculus Rift
#

require 'sketchup.rb'
require 'bezier.rb'

########
##  Mac or PC?
Macflag = true

#########
# YOU NEED TO SPECIFY HERE the absolute path to the directory
# with the JSON files that you want to process

json_directory = "/Users/lykken/Desktop/Unity/ruby-v3/Test_events"

##########################

SKETCHUP_CONSOLE.show

UI.menu("Plugins").add_item("Draw event") {
  UI.messagebox("About to draw an event")
}

# The event displays are very small unless you blow them up using this scale change
$scaleFactor = 100.0

$scale = 1.0
$rt = Geom::Transformation.rotation [0,0,0], [0,1,0], Math::PI/2.0
$st = Geom::Transformation.scaling $scale

# You might want to apply some cuts:
$Tracks_V2_pt_min = 0.0 
$GsfElectrons_V1_pt_min = 5.0

# Where various info is stored in the CMS JSON format:
$Tracks_V2_pos_index = 0 
$Tracks_V2_dir_index = 1 
$Tracks_V2_pt_index = 2 
$Tracks_V2_phi_index = 3
$Tracks_V2_eta_index = 4
$Tracks_V2_charge_index = 5 

$GsfElectrons_V1_pos_index = 4
$GsfElectrons_V1_dir_index = 5
$GsfElectrons_V1_pt_index = 0
$GsfElectrons_V1_eta_index = 1
$GsfElectrons_V1_phi_index = 2
$GsfElectrons_V1_charge_index = 3 

$GlobalMuons_V1_pt_index = 0
$GlobalMuons_V1_charge_index = 1
$GlobalMuons_V1_rp_index = 2
$GlobalMuons_V1_phi_index = 3
$GlobalMuons_V1_eta_index = 4
$GlobalMuons_V1_calo_energy_index = 5

$PFJets_V1_et_index = 0
$PFJets_V1_eta_index = 1
$PFJets_V1_theta_index = 2
$PFJets_V1_phi_index = 3

$PFMETs_V1_phi_index = 0
$PFMETs_V1_pt_index = 1
$PFMETs_V1_px_index = 2
$PFMETs_V1_py_index = 3
$PFMETs_V1_pz_index = 4

$Photons_V1_energy_index = 0
$Photons_V1_et_index = 1
$Photons_V1_eta_index = 2
$Photons_V1_phi_index = 3
$Photons_V1_pos_index = 4
$Photons_V1_hadronicOverEm_index = 5



def draw_as_wireframe(entities, collection, material)
  collection.each do |d|
    front_1 = d[1]      
    front_2 = d[2]
    front_3 = d[3]
    front_4 = d[4]

    back_1 = d[5]
    back_2 = d[6]
    back_3 = d[7]
    back_4 = d[8]

    corners = [front_1, front_2, front_3, front_4, back_1, back_2, back_3, back_4]

    corners.each do |corner|
      corner.transform! $st
      corner.transform! $rt
    end
     
    # front
    entities.add_line corners[0], corners[1]
    entities.add_line corners[1], corners[2]
    entities.add_line corners[2], corners[3]
    entities.add_line corners[3], corners[0]

    # back
    entities.add_line corners[4], corners[5]
    entities.add_line corners[5], corners[6]
    entities.add_line corners[6], corners[7]
    entities.add_line corners[7], corners[4]

    # connect the corners 
    entities.add_line corners[0], corners[4]
    entities.add_line corners[1], corners[5]
    entities.add_line corners[2], corners[6]
    entities.add_line corners[3], corners[7] 
   end
end

def draw_as_hybrid(entities, collection, material)
  collection.each do |d|
    front_1 = d[1]      
    front_2 = d[2]
    front_3 = d[3]
    front_4 = d[4]

    back_1 = d[5]
    back_2 = d[6]
    back_3 = d[7]
    back_4 = d[8]

    corners = [front_1, front_2, front_3, front_4, back_1, back_2, back_3, back_4]

    corners.each do |corner|
      corner.transform! $st
      corner.transform! $rt
    end
  
    begin
    # draw front and back as faces
    # and connect with lines
    # front
    e01 = entities.add_line corners[0], corners[1]
    e12 = entities.add_line corners[1], corners[2]
    e23 = entities.add_line corners[2], corners[3]
    e30 = entities.add_line corners[3], corners[0]

    front = entities.add_face [e01,e12,e23,e30]
    front.material = material
    front.back_material = material
  
    # back
    e45 = entities.add_line corners[4], corners[5]
    e56 = entities.add_line corners[5], corners[6]
    e67 = entities.add_line corners[6], corners[7]
    e74 = entities.add_line corners[7], corners[4]

    back = entities.add_face [e45,e56,e67,e74]
    back.material = material
    back.back_material = material
   
    entities.add_line corners[0], corners[4]
    entities.add_line corners[1], corners[5]
    entities.add_line corners[2], corners[6]
    entities.add_line corners[3], corners[7]
  rescue => e
    puts e
  end
  end
end

def draw_as_faces_v2(entities, collection, material)
  collection.each do |d|
    front_1 = d[1]      
    front_2 = d[2]
    front_3 = d[3]
    front_4 = d[4]

    back_1 = d[5]
    back_2 = d[6]
    back_3 = d[7]
    back_4 = d[8]

    corners = [front_1, front_2, front_3, front_4, back_1, back_2, back_3, back_4]

    corners.each do |corner|
      corner.transform! $st
      corner.transform! $rt
    end  
    
    # front
    e01 = entities.add_line corners[0], corners[1]
    e12 = entities.add_line corners[1], corners[2]
    e23 = entities.add_line corners[2], corners[3]
    e30 = entities.add_line corners[3], corners[0]

    front = entities.add_face [e01,e12,e23,e30]
    front.material = material
    front.back_material = material

    # back
    e45 = entities.add_line corners[4], corners[5]
    e56 = entities.add_line corners[5], corners[6]
    e67 = entities.add_line corners[6], corners[7]
    e74 = entities.add_line corners[7], corners[4]

    back = entities.add_face [e45,e56,e67,e74]
    back.material = material
    back.back_material = material

    # connect the corners 
    e04 = entities.add_line corners[0], corners[4]
    e15 = entities.add_line corners[1], corners[5]
    e26 = entities.add_line corners[2], corners[6]
    e37 = entities.add_line corners[3], corners[7]
  
    top = entities.add_face [e04,e01,e15,e45]
    top.material = material
    top.back_material = material
  
    bottom = entities.add_face [e37,e23,e26,e67]
    bottom.material = material
    bottom.back_material = material
  
    side1 = entities.add_face [e12,e26,e56,e15]
    side1.material = material
    side1.back_material = material
  
    side2 = entities.add_face [e30,e37,e74,e04]
    side2.material = material
    side2.back_material = material
  end
end

def draw_as_faces(entities, collection, material)
  collection.each do |d|
    front_1 = d[1]      
    front_2 = d[2]
    front_3 = d[3]
    front_4 = d[4]

    back_1 = d[5]
    back_2 = d[6]
    back_3 = d[7]
    back_4 = d[8]

    corners = [front_1, front_2, front_3, front_4, back_1, back_2, back_3, back_4]

    corners.each do |corner|
      corner.transform! $st
      corner.transform! $rt
    end

    # front
    front = entities.add_face corners[0], corners[1], corners[2], corners[3]
    front.material = material
    front.back_material = material
 
    # back
    back = entities.add_face corners[4], corners[5], corners[6], corners[7]
    back.material = material
    back.back_material = material
 
    # 4 sides
    side1 = entities.add_face corners[0], corners[4], corners[7], corners[3]
    side1.material = material
    side1.back_material = material
  
    side2 = entities.add_face corners[1], corners[5], corners[6], corners[2]
    side2.material = material
    side2.back_material = material
  
    top = entities.add_face corners[0], corners[4], corners[5], corners[1]
    top.material = material
    top.back_material = material
  
    bottom = entities.add_face corners[3], corners[7], corners[6], corners[2]
    bottom.material = material
    bottom.back_material = material
  end
end

def draw_as_front_face(entities, collection, material)
  collection.each do |d|
    front_1 = d[1]
    front_2 = d[2]  
    front_3 = d[3]
    front_4 = d[4]
    
    corners = [front_1, front_2, front_3, front_4]

    corners.each do |corner|
      corner.transform! $st
      corner.transform! $rt
    end
    
    face = entities.add_face corners[0], corners[1], corners[2], corners[3]
    face.material = material
    face.back_material = material
  end
end

def draw_as_back_face(entities, collection, material)
  collection.each do |d|
    back_1 = d[5]
    back_2 = d[6]
    back_3 = d[7]
    back_4 = d[8]

    corners = [back_1, back_2, back_3, back_4]

    corners.each do |corner|
      corner.transform! $st
      corner.transform! $rt
    end
    
    e1 = entities.add_line corners[0], corners[1] 
    e2 = entities.add_line corners[1], corners[2]
    e3 = entities.add_line corners[2], corners[3]
    e4 = entities.add_line corners[3], corners[0]
      
    face = entities.add_face [e1,e2,e3,e4]
    face.material = material
    face.back_material = material
  end
end
    
def draw_front_and_back(entities, collection, material)
  collection.each do |d|
    corners = [d[1], d[2], d[3], d[4], d[5], d[6], d[7], d[8]]
    
    corners.each do |corner|
      corner.transform! $st
      corner.transform! $rt
    end
    
    e1 = entities.add_line d[1], d[2]
    e2 = entities.add_line d[2], d[3]
    e3 = entities.add_line d[3], d[4]
    e4 = entities.add_line d[4], d[1]
    
    face = entities.add_face [e1,e2,e3,e4]
    face.material = material
    face.back_material = material
    
    e1 = entities.add_line d[5], d[6]
    e2 = entities.add_line d[6], d[7]
    e3 = entities.add_line d[7], d[8]
    e4 = entities.add_line d[8], d[5]
    
    back = entities.add_face [e1,e2,e3,e4]
    back.material = material
    back.back_material = material
  end
end

def draw_rechits(entities, collection, material, min_energy, energy_scale) 

  collection.each do |rh|
    energy = rh[0]

    if energy > min_energy

      f1 = Geom::Point3d.new rh[5]
      f2 = Geom::Point3d.new rh[6]
      f3 = Geom::Point3d.new rh[7]
      f4 = Geom::Point3d.new rh[8]

      b1 = Geom::Point3d.new rh[9]
      b2 = Geom::Point3d.new rh[10]
      b3 = Geom::Point3d.new rh[11]
      b4 = Geom::Point3d.new rh[12]

      diff1 = b1-f1
      diff2 = b2-f2
      diff3 = b3-f3
      diff4 = b4-f4

      diff1.normalize!
      diff2.normalize!
      diff3.normalize!
      diff4.normalize!

      energyScale = Geom::Transformation.scaling energy*energy_scale

      diff1.transform! energyScale  
      diff2.transform! energyScale
      diff3.transform! energyScale
      diff4.transform! energyScale

      corners = [f1, f2, f3, f4, f1+diff1, f2+diff2, f3+diff3, f4+diff4]

      corners.each do |corner|
        corner.transform! $rt
      end

      # front
      e01 = entities.add_line corners[0], corners[1]
      e12 = entities.add_line corners[1], corners[2]
      e23 = entities.add_line corners[2], corners[3]
      e30 = entities.add_line corners[3], corners[0]

      front = entities.add_face [e01,e12,e23,e30]
      if front
        front.material = material
        front.back_material = material
      end

      # back
      e45 = entities.add_line corners[4], corners[5]
      e56 = entities.add_line corners[5], corners[6]
      e67 = entities.add_line corners[6], corners[7]
      e74 = entities.add_line corners[7], corners[4]

      back = entities.add_face [e45,e56,e67,e74]
      if back
        back.material = material
        back.back_material = material
      end

      # connect the corners 
      e04 = entities.add_line corners[0], corners[4]
      e15 = entities.add_line corners[1], corners[5]
      e26 = entities.add_line corners[2], corners[6]
      e37 = entities.add_line corners[3], corners[7]
  
      top = entities.add_face [e04,e01,e15,e45]
      if top  
       top.material = material
        top.back_material = material
      end

      bottom = entities.add_face [e37,e23,e26,e67]
      if bottom
        bottom.material = material
        bottom.back_material = material
      end

      side1 = entities.add_face [e12,e26,e56,e15]
      if side1
        side1.material = material
        side1.back_material = material
      end

      side2 = entities.add_face [e30,e37,e74,e04]
      if side2
        side2.material = material
        side2.back_material = material
      end
    end
  end
end

def draw_tracks(model, tracks, extras, assocs, pt_index, eta_index, phi_index, charge_index, min_pt, label, trackcount, trackmaterial)

  trackcount = 0

  assocs.each do |asc|    
     
    ti = asc[0][1]
    ei = asc[1][1] 

    begin
      track_pt = tracks[ti][pt_index]
      track_eta = tracks[ti][eta_index]
      track_phi = tracks[ti][phi_index]
      track_charge = tracks[ti][charge_index]

    rescue RangeError
      puts "array out of bounds: " + $!
      raise
    end

    puts "pt = #{track_pt}"
    puts "eta = #{track_eta}"
    puts "phi = #{track_phi}"
    puts "charge = #{track_charge}"

    if track_pt > min_pt

      trackcount += 1

      p1 = extras[ei][0]  
      d1 = extras[ei][1]
      p2 = extras[ei][2]
      d2 = extras[ei][3]
    
      p1.transform! $rt
      d1.transform! $rt
      p2.transform! $rt
      d2.transform! $rt
    
      v1 = Geom::Vector3d.new d1
      v2 = Geom::Vector3d.new d2
      
      v1.normalize!
      v2.normalize!  
    
      distance = (p2[0]-p1[0])*(p2[0]-p1[0])+((p2[1]-p1[1])*(p2[1]-p1[1]))+((p2[2]-p2[1])*(p2[2]-p2[1]))
      distance = Math.sqrt(distance)

      scale0 = distance*0.25
      scale1 = distance*0.25
     
      p3 = [p1[0]+ scale0*v1[0], p1[1]+ scale0*v1[1], p1[2]+ scale0*v1[2]]
      p4 = [p2[0]- scale1*v2[0], p2[1]- scale1*v2[1], p2[2]- scale1*v2[2]]
    
      pts = Bezier.points([p1,p3,p4,p2],16) 

      entities = model.active_entities
      #  Erase all the entities in the model
      status = entities.clear!

      # Use group here so that the rescaling will work later
      group = entities.add_group
      group.name = label
      group.entities.add_curve pts
      #entities.add_curve pts

      # this is a straightline connecting the 
      # innermost and outermost states
      pts2 = [p1,p2]
      #entities.add_curve pts2

      # these are the line connecting the control points
      # to the first and last points
      pts3 = [p1,p3]
      pts4 = [p2,p4]
      #entities.add_curve pts3
      #entities.add_curve pts4

      is_file = false

      if label == "track"
        tracknum = trackcount - 1
        $f = File.open($xml_file, "a")
        $f.puts %{    <Item name="} + "track_" + (tracknum).to_s + %{">}
        $f.puts %{       <pt>} + (track_pt).to_s + %{</pt>}
        $f.puts %{       <eta>} + (track_eta).to_s + %{</eta>}
        $f.puts %{       <phi>} + (track_phi).to_s + %{</phi>}
        $f.puts %{       <charge>} + (track_charge).to_s + %{</charge>}
        $f.puts %{    </Item>}
        $f.close
        convert_tracks_to_tubes(model, trackmaterial)
        ###  You can change this
        output_file = $out_name + "/" + $out_name_short + "_track_#{tracknum}.fbx"
        is_file = true
      end

      if label == "electron"
        tracknum = trackcount - 1
        $f = File.open($xml_file, "a")
        $f.puts %{    <Item name="} + "electron_" + (tracknum).to_s + %{">}
        $f.puts %{       <pt>} + (track_pt).to_s + %{</pt>}
        $f.puts %{       <eta>} + (track_eta).to_s + %{</eta>}
        $f.puts %{       <phi>} + (track_phi).to_s + %{</phi>}
        $f.puts %{       <charge>} + (track_charge).to_s + %{</charge>}
        $f.puts %{    </Item>}
        $f.close
        convert_tracks_to_tubes(model, trackmaterial)
        ###  You can change this
        output_file = $out_name + "/" + $out_name_short + "_electron_#{tracknum}.fbx"
        is_file = true
      end

      # default options (but you can change them)
      if is_file
        # On a Mac:
        if Macflag == true 
          status = model.export output_file
        else
          status = model.export 'c:/my_export.fbx'
        end
      end


    end
  end
end

#############

def convert_tracks_to_tubes(model, trackmaterial)

  ### converts curved lines into tubes

  puts "Converting tracks to tubes:"

  ##--------------------------------------------------------------------------------
  #      This part of the code is adapted from TubeAlongPath
  #
  #      Author : TIG (c) 7/2005
  #		based on an original wall making idea by Didier Bur
  #		and using some vertex array ideas from Rick Wilson

  entities = model.entities
  radius = 20.mm
  curves=[]
  typename=""
  entities.each {|item| curves.push(item) if item.typename=="Group"}
  puts "Found #{curves.count} curves"
  puts "Found #{entities.count} entities"

  j = 0
  entities.each {|ent|
    j+=1
    group2 = ent
    typename = group2.typename
    if typename=="Group"
      label = group2.name
    else
      next
    end
    #puts "working on j = #{j}, typename = #{group2.typename}"
    #puts "label = #{group2.name}" if typename=="Group"
    #attrdicts = group2.attribute_dictionaries
    #attrdict = attrdicts["properties"]
    entities2 = group2.entities
    if $scaleFactor > 0
      transform = Geom::Transformation.new($scaleFactor)
      entities2.transform_entities(transform, entities2.to_a)
    end
    model.selection.clear
    model.selection.add entities2.to_a
    model.start_operation "tube_along_path"
    ss = model.selection


  ### this next bit is thanks to Rick Wilson's weld.rb

	model=Sketchup.active_model
	ents=model.active_entities
	sel=model.selection
	sl=sel.length
        puts "Found #{sl} selections for j = #{j}"
	verts=[]
	edges=[]
	newVerts=[]
	startEdge=startVert=nil


  #DELETE NON-EDGES, GET THE VERTICES

	sel.each {|item| edges.push(item) if item.typename=="Edge"}
	edges.each {|edge| verts.push(edge.vertices)}
	verts.flatten!
        puts "Found #{edges.count} edges and #{verts.count} vertices"

  #FIND AN END VERTEX

	vertsShort=[]
	vertsLong=[]
	verts.each do |v|
		if vertsLong.include?(v)
			vertsShort.push(v)
		else
			vertsLong.push(v)
		end
	end
	if (startVert=(vertsLong-vertsShort).first)==nil
		startVert=vertsLong.first
		closed=true
		startEdge = startVert.edges.first
	else
		closed=false
		startEdge = (edges & startVert.edges).first
	end
	sel.clear


  #SORT VERTICES, LIMITING TO THOSE IN THE SELECTION SET

	if startVert==startEdge.start
		newVerts=[startVert]
		counter=0
		while newVerts.length < verts.length
			edges.each do |edge|
				if edge.end==newVerts.last
					newVerts.push(edge.start)
				elsif edge.start==newVerts.last
					newVerts.push(edge.end)
				end
			end
			counter+=1
			if counter > verts.length
				newVerts.reverse!
				reversed=true
			end
		end
	else
		newVerts=[startVert]
		counter=0
		while newVerts.length < verts.length
			edges.each do |edge|
				if edge.end==newVerts.last
					newVerts.push(edge.start)
				elsif edge.start==newVerts.last
					newVerts.push(edge.end)
				end
			end
			counter+=1
			if counter > verts.length
				newVerts.reverse!
				reversed=true
			end
		end
	end
	###newVerts.uniq! ### allow IF closed
	newVerts.reverse! if reversed


  #CONVERT VERTICES TO POINT3Ds

	newVerts.collect!{|x| x.position}
	###newVerts.push(newVerts[0])

  ### now have an array of vertices in order with NO forced closed loop ...


  ### - do stuff - ###

  pt1 = newVerts[0]
  pt2 = newVerts[1]
  vec = pt1.vector_to pt2

  theCircle = ents.add_circle pt1, vec, radius
  theFace = ents.add_face theCircle
  if (theFace)
    puts "Found id = #{theFace.entityID} with label = #{label}"
    theFace.material = trackmaterial

    i = 0
    @@theEdges= []

    0.upto(newVerts.length - 2) do |something|
      @@theEdges[i] = ents.add_line(newVerts[i],newVerts[i+1])  ### make vertices into edges
      i = i + 1
    end

 ### follow me along selected edges

    theFace.reverse!.followme @@theEdges ###

    model.commit_operation

 ### restore selection set of edges and display them
    #i = 0
    #theEdgeX = []
    #0.upto(newVerts.length - 2) do |something|
      #theEdgeX[i] = ents.add_line(newVerts[i],newVerts[i+1])  ### make vertices into edges
      #i = i + 1
    #end
    #model.selection.clear
    #model.selection.add theEdgeX

  end
  }

end

#############

def process_json(input)
  if ! input.valid_encoding?
    input = input.encode("UTF-16be", :invalid=>:replace, :replace=>"?").encode('UTF-8')
  end
  input.gsub!(/\s+/, "")
  input.gsub!(":", "=>")
  input.gsub!("\'", "\"")
  input.gsub!("(", "[")
  input.gsub!(")", "]")
  input.gsub!("nan", "0")
  input
end

##############


##   define a bunch of materials

model = Sketchup.active_model
materials = model.materials
alpha = 0.5

ecal_rechit_material = materials.add "EcalRecHit"
ecal_rechit_material.alpha = alpha
ecal_rechit_material.color = [1.0,0.2,0.0]

hcal_rechit_material = materials.add "HcalRecHit"
hcal_rechit_material.alpha = 0.9
hcal_rechit_material.color = [0.4,0.8,1.0]

tracker_material = materials.add "Tracker"
tracker_material.alpha = alpha
tracker_material.color = [0.7,0.7,0.0]

muon_chamber_material = materials.add "MuonChamber"
muon_chamber_material.alpha = 0.1
muon_chamber_material.color = [1.0,0.0,0.0]

ecal_material = materials.add "ECAL"
ecal_material.alpha = alpha
ecal_material.color = [0.5,0.8,1.0]

hcal_material = materials.add "HCAL"
hcal_material.alpha = 0.1
hcal_material.color = [0.7,0.7,0.0]

dt_material = materials.add "DT"
dt_material.alpha = alpha
dt_material.color = [0.8,0.4,0.0]

csc_material = materials.add "CSC"
csc_material.alpha = alpha
csc_material.color = [0.6,0.7,0.1]
 
rpc_material = materials.add "RPC"
rpc_material.alpha = alpha
rpc_material.color = [0.6,0.8,0.0]

electron_material = materials.add "electron"
electron_material.alpha = alpha
electron_material.color = "magenta"

muon_material = materials.add "muon"
muon_material.alpha = alpha
muon_material.color = "red"

track_material = materials.add "track"
track_material.alpha = alpha
track_material.color = "gold"

##########

Sketchup.send_action "showRubyPanel:"

##########
#
#  The basic processing loop over JSON files starts here

Dir.glob(json_directory + "/*.json") do |json_file|
  # do work on files ending in .json in the desired directory

puts "In JSON directory " + json_directory
ein = File.open(json_file,"r")
event = eval(process_json(ein.read()))
puts "Event file read"
ein.close
puts "Processing file " + json_file
$out_name = json_file.chomp(".json")
puts "Making directory " + $out_name
Dir.mkdir($out_name)
out_split = $out_name.split("/")
$out_name_short = out_split[out_split.size - 1]
puts $out_name_short

model = Sketchup.active_model
entities = model.active_entities
#  Erase all the entities in the model
status = entities.clear!
puts entities.count

t = event["Types"]
c = event["Collections"]
a = event["Associations"]

types = {}

count = 0
t.each_key do |k|
  types[k] = count
  count = count + 1
end

ec0 = entities.count
puts "Drawing HCAL Barrel RecHits"
draw_rechits(entities, c["HBRecHits_V2"], hcal_rechit_material, 0.5, 0.5)
ecount = entities.count - ec0
ec0 = entities.count
puts "Found #{ecount}"
puts "Drawing HCAL Endcap RecHits"
draw_rechits(entities, c["HERecHits_V2"], hcal_rechit_material, 0.5, 0.05)
ecount = entities.count - ec0
ec0 = entities.count
puts "Found #{ecount}"
puts "Drawing ECAL Barrel RecHits"
draw_rechits(entities, c["EBRecHits_V2"], ecal_rechit_material, 0.25, 0.5)
ecount = entities.count - ec0
ec0 = entities.count
puts "Found #{ecount}"
puts "Drawing ECAL Endcap RecHits"
draw_rechits(entities, c["EERecHits_V2"], ecal_rechit_material, 0.5, 0.5)
ecount = entities.count - ec0
ec0 = entities.count
puts "Found #{ecount}"
ecount = ec0

##  rescale everything bigger
if $scaleFactor > 0
      transform = Geom::Transformation.new($scaleFactor)
      entities.transform_entities(transform, entities.to_a)
end

#############

# Save the calorimetric part of the event as a separate model, exported as a .fbx file:
model = Sketchup.active_model

# Write an xml file for each event that contains data indexed by names of objects in the event:
xml_header = %{<?xml version="1.0" encoding="UTF-8"?>}
$xml_file = $out_name + "/" + $out_name_short + ".xml"
$f = File.open($xml_file, "w")
$f.puts xml_header
$f.puts "<ItemCollection>"
$f.puts "  <Items>"
$f.close 

### This next bit is a fake placeholder since calo info is not implemented:
calo_pt = 0
calo_eta = 0
calo_phi = 0
calo_charge = 0
$f = File.open($xml_file, "a")
$f.puts %{    <Item name="calo">}
$f.puts %{       <pt>} + (calo_pt).to_s + %{</pt>}
$f.puts %{       <eta>} + (calo_eta).to_s + %{</eta>}
$f.puts %{       <phi>} + (calo_phi).to_s + %{</phi>}
$f.puts %{       <charge>} + (calo_charge).to_s + %{</charge>}
$f.puts %{    </Item>}
$f.close

###  You can change this
output_file = $out_name + "/" + $out_name_short + "_calo.fbx"
# default options (but you can change them)
options_hash = { :triangulated_faces => true,
                  :doublesided_faces => true,
                  :edges => false,
                  :author_attribution => false,
                  :texture_maps => true,
                  :selectionset_only => false,
                  :preserve_instancing => true }
# On a Mac:
if Macflag == true 
  status = model.export output_file
else
  status = model.export 'c:/my_export.fbx'
end

#############
##
## now start over with a model that contains just the muons, electrons, and tracks:

ecount = 0

puts "Drawing Muons"
  muons = c["GlobalMuons_V1"]
  points = c["Points_V1"]
  assoc = a["MuonGlobalPoints_V1"]

  curve_points0 = []
  curve_points1 = []
  curve_points2 = []
  muoncount = 0
  muon1 = false
  muon2 = false
  muon3 = false

  # warning, this is a hack. we assume that there are no more than 3 global muons!

  puts "muons.count = #{muons.count}"
  if muons.count > 0
    puts "assoc.count = #{assoc.count}"
    assoc.each do |asc|
      mi = asc[0][1]
      pi = asc[1][1]
      points[pi][0].transform! $rt

      if mi == 0
        curve_points0.push(points[pi][0])
        muon1 = true
      end

      if mi == 1 
        curve_points1.push(points[pi][0])
        muon2 = true
      end

      if mi == 2 
        curve_points2.push(points[pi][0])
        muon3 = true
      end

    end

    muoncount+=1 if muon1
    muoncount+=1 if muon2
    muoncount+=1 if muon3
    if muoncount > 0
      entities = model.active_entities
      #  Erase all the entities in the model
      status = entities.clear!
      group0 = entities.add_group
      group0.name = "muon"
      group0.entities.add_curve curve_points0
      muon_pt = muons[0][$GlobalMuons_V1_pt_index]
      muon_eta = muons[0][$GlobalMuons_V1_eta_index]
      muon_phi = muons[0][$GlobalMuons_V1_phi_index]
      muon_charge = muons[0][$GlobalMuons_V1_charge_index]
      $f = File.open($xml_file, "a")
      $f.puts %{    <Item name="muon_0">}
      $f.puts %{       <pt>} + (muon_pt).to_s + %{</pt>}
      $f.puts %{       <eta>} + (muon_eta).to_s + %{</eta>}
      $f.puts %{       <phi>} + (muon_phi).to_s + %{</phi>}
      $f.puts %{       <charge>} + (muon_charge).to_s + %{</charge>}
      $f.puts %{    </Item>}
      $f.close
      ecount += 1
      puts "Added muon as entity #{ecount} with #{curve_points0.count} curve points"
      #puts "typename = #{entities[ecount-1].typename}"
      convert_tracks_to_tubes(model, muon_material)
      ###  You can change this
      output_file = $out_name + "/" + $out_name_short + "_muon_0.fbx"
      # default options (but you can change them)
      # On a Mac:
      if Macflag == true 
        status = model.export output_file
      else
        status = model.export 'c:/my_export.fbx'
      end
    end
    if muoncount > 1
      entities = model.active_entities
      #  Erase all the entities in the model
      status = entities.clear!
      group1 = entities.add_group
      group1.name = "muon"
      group1.entities.add_curve curve_points1
      muon_pt = muons[1][$GlobalMuons_V1_pt_index]
      muon_eta = muons[1][$GlobalMuons_V1_eta_index]
      muon_phi = muons[1][$GlobalMuons_V1_phi_index]
      muon_charge = muons[1][$GlobalMuons_V1_charge_index]
      $f = File.open($xml_file, "a")
      $f.puts %{    <Item name="muon_1">}
      $f.puts %{       <pt>} + (muon_pt).to_s + %{</pt>}
      $f.puts %{       <eta>} + (muon_eta).to_s + %{</eta>}
      $f.puts %{       <phi>} + (muon_phi).to_s + %{</phi>}
      $f.puts %{       <charge>} + (muon_charge).to_s + %{</charge>}
      $f.puts %{    </Item>}
      $f.close
      ecount += 1
      puts "Added muon as entity #{ecount} with #{curve_points1.count} curve points"
      #puts "typename = #{entities[ecount-1].typename}"
      convert_tracks_to_tubes(model, muon_material)
      ###  You can change this
      output_file = $out_name + "/" + $out_name_short + "_muon_1.fbx"
      # default options (but you can change them)
      # On a Mac:
      if Macflag == true 
        status = model.export output_file
      else
        status = model.export 'c:/my_export.fbx'
      end
    end
    if muoncount > 2
      entities = model.active_entities
      #  Erase all the entities in the model
      status = entities.clear!
      group2 = entities.add_group
      group2.name = "muon"
      group2.entities.add_curve curve_points2
      muon_pt = muons[2][$GlobalMuons_V1_pt_index]
      muon_eta = muons[2][$GlobalMuons_V1_eta_index]
      muon_phi = muons[2][$GlobalMuons_V1_phi_index]
      muon_charge = muons[2][$GlobalMuons_V1_charge_index]
      $f = File.open($xml_file, "a")
      $f.puts %{    <Item name="muon_2">}
      $f.puts %{       <pt>} + (muon_pt).to_s + %{</pt>}
      $f.puts %{       <eta>} + (muon_eta).to_s + %{</eta>}
      $f.puts %{       <phi>} + (muon_phi).to_s + %{</phi>}
      $f.puts %{       <charge>} + (muon_charge).to_s + %{</charge>}
      $f.puts %{    </Item>}
      $f.close
      ecount += 1
      puts "Added muon as entity #{ecount} with #{curve_points2.count} curve points"
      #puts "typename = #{entities[ecount-1].typename}"
      convert_tracks_to_tubes(model, muon_material)
      ###  You can change this
      output_file = $out_name + "/" + $out_name_short + "_muon_2.fbx"
      # default options (but you can change them)
      # On a Mac:
      if Macflag == true 
        status = model.export output_file
      else
        status = model.export 'c:/my_export.fbx'
      end
    end
 
    ec0 = ecount
    puts "Found #{ecount}, muoncount = #{muoncount}"
end

puts "Drawing Electrons"
electroncount = 0
draw_tracks(model,c["GsfElectrons_V1"],c["Extras_V1"],a["GsfElectronExtras_V1"], $GsfElectrons_V1_pt_index, $GsfElectrons_V1_eta_index, $GsfElectrons_V1_phi_index, $GsfElectrons_V1_charge_index, $GsfElectrons_V1_pt_min, "electron", electroncount, electron_material)
ecount = entities.count - ec0
ec0 = entities.count
puts "Found #{electroncount}"

puts "Drawing Tracks"
trackcount = 0
draw_tracks(model,c["Tracks_V2"],c["Extras_V1"], a["TrackExtras_V1"], $Tracks_V2_pt_index, $Tracks_V2_eta_index, $Tracks_V2_phi_index, $Tracks_V2_charge_index, $Tracks_V2_pt_min, "track", trackcount, track_material)
ecount = entities.count - ec0
ec0 = entities.count
trackseg_count = ecount
puts "Found #{trackcount}"



##########


##  Clean up
##  Reset the scale to 1
if $scale > 0
  transform = Geom::Transformation.new($scale)
  entities.transform_entities(transform, entities.to_a)
end

## Wrap up the xml file for this event:
$f = File.open($xml_file, "a")
$f.puts "  </Items>"
$f.puts "</ItemCollection>"
$f.close

end

###  end of the file processing loop

