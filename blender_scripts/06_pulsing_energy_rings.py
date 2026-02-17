"""
Blender script: Pulsing Energy Rings
Expanding concentric rings of neon light pulsing outward from center
Purple and teal gradient, 9:16, 8 seconds, seamless loop
"""
import bpy
import math

# Clear scene
bpy.ops.object.select_all(action='SELECT')
bpy.ops.object.delete(use_global=False)

# Scene setup
scene = bpy.context.scene
scene.render.engine = 'CYCLES'
scene.cycles.samples = 32  # Reduced for faster rendering
scene.render.resolution_x = 1080
scene.render.resolution_y = 1920
scene.render.fps = 30
scene.frame_start = 1
scene.frame_end = 240

# Camera (looking down the tunnel)
bpy.ops.object.camera_add(location=(0, -15, 0), rotation=(math.radians(90), 0, 0))
camera = bpy.context.object
scene.camera = camera

# World background - dark gradient
world = bpy.data.worlds.new("World")
scene.world = world
world.use_nodes = True
world_nodes = world.node_tree.nodes
world_nodes.clear()

bg = world_nodes.new('ShaderNodeBackground')
grad = world_nodes.new('ShaderNodeTexGradient')
color_ramp = world_nodes.new('ShaderNodeValToRGB')
mapping = world_nodes.new('ShaderNodeMapping')
coord = world_nodes.new('ShaderNodeTexCoord')

color_ramp.color_ramp.elements[0].color = (0.1, 0.05, 0.15, 1.0)  # Dark purple
color_ramp.color_ramp.elements[1].color = (0.05, 0.15, 0.15, 1.0)  # Dark teal

world.node_tree.links.new(coord.outputs['Generated'], mapping.inputs['Vector'])
world.node_tree.links.new(mapping.outputs['Vector'], grad.inputs['Vector'])
world.node_tree.links.new(grad.outputs['Color'], color_ramp.inputs['Fac'])
world.node_tree.links.new(color_ramp.outputs['Color'], bg.inputs['Color'])
world_output = world_nodes.new('ShaderNodeOutputWorld')
world.node_tree.links.new(bg.outputs['Background'], world_output.inputs['Surface'])

# Create glowing ring material with gradient
mat = bpy.data.materials.new(name="EnergyRing")
mat.use_nodes = True
nodes = mat.node_tree.nodes
links = mat.node_tree.links
nodes.clear()

emission = nodes.new('ShaderNodeEmission')
output = nodes.new('ShaderNodeOutputMaterial')
color_ramp_ring = nodes.new('ShaderNodeValToRGB')
gradient_tex = nodes.new('ShaderNodeTexGradient')
mapping_ring = nodes.new('ShaderNodeMapping')
coord_ring = nodes.new('ShaderNodeTexCoord')

# Purple to teal gradient
color_ramp_ring.color_ramp.elements[0].color = (0.6, 0.2, 0.9, 1.0)  # Purple
color_ramp_ring.color_ramp.elements[1].color = (0.2, 0.8, 0.8, 1.0)  # Teal

links.new(coord_ring.outputs['Object'], mapping_ring.inputs['Vector'])
links.new(mapping_ring.outputs['Vector'], gradient_tex.inputs['Vector'])
links.new(gradient_tex.outputs['Color'], color_ramp_ring.inputs['Fac'])
links.new(color_ramp_ring.outputs['Color'], emission.inputs['Color'])
links.new(emission.outputs['Emission'], output.inputs['Surface'])

emission.inputs['Strength'].default_value = 4.0

# Create pulsing rings (reduced for faster rendering)
num_rings = 10  # Fewer rings = faster render
ring_spacing = 2.0

for i in range(num_rings):
    # Create torus ring
    bpy.ops.mesh.primitive_torus_add(
        major_radius=2.0,
        minor_radius=0.1,
        location=(0, 0, 0)
    )
    ring = bpy.context.object
    ring.data.materials.append(mat)
    
    # Initial position offset
    initial_y = i * ring_spacing
    ring.location.y = initial_y
    
    # Phase offset for wave effect
    phase = i * 0.4
    
    # Animate expansion and position
    for frame in range(1, 241):
        t = frame / 30.0  # Time in seconds
        
        # Pulsing scale
        pulse = 1.0 + math.sin(t * 2 * math.pi + phase) * 0.3
        ring.scale = (pulse, pulse, pulse)
        ring.keyframe_insert(data_path="scale", frame=frame)
        
        # Move rings outward and loop
        y_pos = (initial_y + t * 3) % (ring_spacing * num_rings)
        ring.location.y = y_pos
        ring.keyframe_insert(data_path="location", index=1, frame=frame)
        
        # Subtle rotation
        ring.rotation_euler.z = t * 0.5
        ring.keyframe_insert(data_path="rotation_euler", index=2, frame=frame)

# Smooth keyframes
for obj in bpy.data.objects:
    if obj.animation_data and obj.animation_data.action:
        for fcurve in obj.animation_data.action.fcurves:
            for kf in fcurve.keyframe_points:
                kf.interpolation = 'BEZIER'
                kf.handle_left_type = 'AUTO'
                kf.handle_right_type = 'AUTO'

# Lighting
bpy.ops.object.light_add(type='POINT', location=(0, 0, 0))
point_light = bpy.context.object
point_light.data.energy = 100
point_light.data.color = (0.5, 0.5, 1.0)

# Render settings
scene.render.filepath = '/Users/quasaur/Developer/social-effects/output/backgrounds/06_pulsing_energy_rings.mp4'
scene.render.image_settings.file_format = 'FFMPEG'
scene.render.ffmpeg.format = 'MPEG4'
scene.render.ffmpeg.codec = 'H264'
scene.render.ffmpeg.constant_rate_factor = 'HIGH'

print("✅ Pulsing energy rings setup complete")
