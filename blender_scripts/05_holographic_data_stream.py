"""
Blender script: Holographic Data Stream
Vertical streams of glowing particles flowing upward like futuristic data visualization
Electric cyan and magenta, 9:16, 8 seconds, seamless loop
"""
import bpy
import math
import random

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

# Camera
bpy.ops.object.camera_add(location=(0, -12, 0), rotation=(math.radians(90), 0, 0))
camera = bpy.context.object
scene.camera = camera

# World background - dark
world = bpy.data.worlds.new("World")
scene.world = world
world.use_nodes = True
world_nodes = world.node_tree.nodes
world_nodes.clear()

bg = world_nodes.new('ShaderNodeBackground')
bg.inputs['Color'].default_value = (0.02, 0.02, 0.05, 1.0)  # Dark background
bg.inputs['Strength'].default_value = 0.1
world_output = world_nodes.new('ShaderNodeOutputWorld')
world.node_tree.links.new(bg.outputs['Background'], world_output.inputs['Surface'])

# Create cyan material
mat_cyan = bpy.data.materials.new(name="CyanGlow")
mat_cyan.use_nodes = True
nodes_c = mat_cyan.node_tree.nodes
links_c = mat_cyan.node_tree.links
nodes_c.clear()

emission_c = nodes_c.new('ShaderNodeEmission')
output_c = nodes_c.new('ShaderNodeOutputMaterial')
emission_c.inputs['Color'].default_value = (0.0, 0.9, 1.0, 1.0)  # Electric cyan
emission_c.inputs['Strength'].default_value = 3.0
links_c.new(emission_c.outputs['Emission'], output_c.inputs['Surface'])

# Create magenta material
mat_magenta = bpy.data.materials.new(name="MagentaGlow")
mat_magenta.use_nodes = True
nodes_m = mat_magenta.node_tree.nodes
links_m = mat_magenta.node_tree.links
nodes_m.clear()

emission_m = nodes_m.new('ShaderNodeEmission')
output_m = nodes_m.new('ShaderNodeOutputMaterial')
emission_m.inputs['Color'].default_value = (1.0, 0.0, 0.8, 1.0)  # Magenta
emission_m.inputs['Strength'].default_value = 3.0
links_m.new(emission_m.outputs['Emission'], output_m.inputs['Surface'])

# Create data streams (reduced for faster rendering)
num_streams = 8  # Fewer streams = faster render
random.seed(42)

for stream_idx in range(num_streams):
    # Stream position
    x = random.uniform(-6, 6)
    z = random.uniform(-6, 6)
    
    # Choose material (alternate cyan and magenta)
    mat = mat_cyan if stream_idx % 2 == 0 else mat_magenta
    
    # Create particles in stream (reduced for faster rendering)
    num_particles = 12  # Fewer particles = faster render
    for p in range(num_particles):
        # Create small geometric shape (cube or icosphere)
        if random.random() > 0.5:
            bpy.ops.mesh.primitive_cube_add(size=0.15, location=(x, 0, z))
        else:
            bpy.ops.mesh.primitive_ico_sphere_add(subdivisions=1, radius=0.08, location=(x, 0, z))
        
        particle = bpy.context.object
        particle.data.materials.append(mat)
        
        # Initial offset in stream
        y_start = -10 + (p * 1.0)
        particle.location.y = y_start
        
        # Animate upward movement (loop from bottom to top)
        height_range = 20
        speed = 0.5 + random.random() * 0.5
        
        for frame in range(1, 241):
            t = frame / 30.0
            y_pos = (y_start + t * speed * 10) % height_range - 10
            particle.location.y = y_pos
            particle.keyframe_insert(data_path="location", index=1, frame=frame)
            
            # Rotation for visual interest
            rot = t * speed * 2 * math.pi
            particle.rotation_euler = (rot, rot * 0.7, rot * 0.5)
            particle.keyframe_insert(data_path="rotation_euler", frame=frame)
        
        # Make keyframes linear for smooth continuous motion
        if particle.animation_data and particle.animation_data.action:
            for fcurve in particle.animation_data.action.fcurves:
                for kf in fcurve.keyframe_points:
                    kf.interpolation = 'LINEAR'

# Add volumetric glow
scene.eevee.use_bloom = True
scene.eevee.bloom_intensity = 0.5

# Render settings - output as PNG sequence
scene.render.filepath = '/Users/quasaur/Developer/social-effects/output/backgrounds/05_data_stream/frame_'
scene.render.image_settings.file_format = 'PNG'

print("✅ Holographic data stream setup complete")
