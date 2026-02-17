"""
Blender script: Expanding Hexagon Grid
Hypnotic field of hexagonal tiles that wave and pulse in coordinated patterns
Soft mint and peach gradient, 9:16, 8 seconds, seamless loop
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
scene.frame_end = 240  # 8 seconds

# Camera
bpy.ops.object.camera_add(location=(0, 0, 15), rotation=(0, 0, 0))
camera = bpy.context.object
scene.camera = camera

# World background - soft gradient
world = bpy.data.worlds.new("World")
scene.world = world
world.use_nodes = True
world_nodes = world.node_tree.nodes
world_nodes.clear()

bg = world_nodes.new('ShaderNodeBackground')
grad_tex = world_nodes.new('ShaderNodeTexGradient')
color_ramp = world_nodes.new('ShaderNodeValToRGB')
mapping = world_nodes.new('ShaderNodeMapping')
coord = world_nodes.new('ShaderNodeTexCoord')

color_ramp.color_ramp.elements[0].color = (0.7, 0.95, 0.85, 1.0)  # Mint
color_ramp.color_ramp.elements[1].color = (1.0, 0.85, 0.75, 1.0)  # Peach

world.node_tree.links.new(coord.outputs['Generated'], mapping.inputs['Vector'])
world.node_tree.links.new(mapping.outputs['Vector'], grad_tex.inputs['Vector'])
world.node_tree.links.new(grad_tex.outputs['Color'], color_ramp.inputs['Fac'])
world.node_tree.links.new(color_ramp.outputs['Color'], bg.inputs['Color'])
world_output = world_nodes.new('ShaderNodeOutputWorld')
world.node_tree.links.new(bg.outputs['Background'], world_output.inputs['Surface'])

# Create hexagon material
mat = bpy.data.materials.new(name="HexMaterial")
mat.use_nodes = True
nodes = mat.node_tree.nodes
links = mat.node_tree.links
nodes.clear()

output = nodes.new('ShaderNodeOutputMaterial')
bsdf = nodes.new('ShaderNodeBsdfPrincipled')
emission = nodes.new('ShaderNodeEmission')
mix = nodes.new('ShaderNodeMixShader')
color_ramp_hex = nodes.new('ShaderNodeValToRGB')

color_ramp_hex.color_ramp.elements[0].color = (0.8, 1.0, 0.9, 1.0)  # Light mint
color_ramp_hex.color_ramp.elements[1].color = (1.0, 0.9, 0.8, 1.0)  # Light peach

links.new(color_ramp_hex.outputs['Color'], bsdf.inputs['Base Color'])
links.new(color_ramp_hex.outputs['Color'], emission.inputs['Color'])
links.new(bsdf.outputs['BSDF'], mix.inputs[1])
links.new(emission.outputs['Emission'], mix.inputs[2])
links.new(mix.outputs['Shader'], output.inputs['Surface'])

bsdf.inputs['Metallic'].default_value = 0.3
bsdf.inputs['Roughness'].default_value = 0.2
emission.inputs['Strength'].default_value = 0.5
mix.inputs['Fac'].default_value = 0.3

# Create hexagonal grid (reduced size for faster rendering)
hex_radius = 0.8
grid_size = 3  # Smaller grid = faster render

for row in range(-grid_size, grid_size + 1):
    for col in range(-grid_size, grid_size + 1):
        # Hexagonal grid offset
        x_offset = col * hex_radius * 1.73
        y_offset = row * hex_radius * 1.5
        if col % 2 != 0:
            y_offset += hex_radius * 0.75
        
        # Create hexagon
        bpy.ops.mesh.primitive_cylinder_add(
            vertices=6,
            radius=hex_radius * 0.9,
            depth=0.2,
            location=(x_offset, y_offset, 0)
        )
        hex_obj = bpy.context.object
        hex_obj.data.materials.append(mat)
        
        # Distance from center for wave pattern
        dist = math.sqrt(x_offset**2 + y_offset**2)
        phase = dist * 0.3
        
        # Animate Z position (wave effect)
        for frame in range(1, 241):
            t = frame / 30.0  # Time in seconds
            wave = math.sin(t * 3.14 + phase) * 0.3
            hex_obj.location.z = wave
            hex_obj.keyframe_insert(data_path="location", index=2, frame=frame)
            
            # Animate scale (pulse effect)
            scale = 1.0 + math.sin(t * 3.14 + phase) * 0.15
            hex_obj.scale = (scale, scale, 1.0)
            hex_obj.keyframe_insert(data_path="scale", frame=frame)

# Lighting
bpy.ops.object.light_add(type='SUN', location=(5, 5, 10))
sun = bpy.context.object
sun.data.energy = 2.0
sun.rotation_euler = (math.radians(45), 0, math.radians(45))

# Render settings
scene.render.filepath = '/Users/quasaur/Developer/social-effects/output/backgrounds/01_expanding_hexagon_grid.mp4'
scene.render.image_settings.file_format = 'FFMPEG'
scene.render.ffmpeg.format = 'MPEG4'
scene.render.ffmpeg.codec = 'H264'
scene.render.ffmpeg.constant_rate_factor = 'HIGH'

print("✅ Hexagon grid setup complete")
