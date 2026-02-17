"""
Blender script: Origami Fold Cycle
Abstract 3D planes that fold and unfold like digital origami
Lavender and cream palette, 9:16, 8 seconds, seamless loop
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

# Camera
bpy.ops.object.camera_add(location=(0, -10, 0), rotation=(math.radians(90), 0, 0))
camera = bpy.context.object
scene.camera = camera

# World background
world = bpy.data.worlds.new("World")
scene.world = world
world.use_nodes = True
world_nodes = world.node_tree.nodes
world_nodes.clear()

bg = world_nodes.new('ShaderNodeBackground')
bg.inputs['Color'].default_value = (0.97, 0.95, 0.93, 1.0)  # Cream
bg.inputs['Strength'].default_value = 1.0
world_output = world_nodes.new('ShaderNodeOutputWorld')
world.node_tree.links.new(bg.outputs['Background'], world_output.inputs['Surface'])

# Origami material - lavender with subtle gradient
mat = bpy.data.materials.new(name="OrigamiMaterial")
mat.use_nodes = True
nodes = mat.node_tree.nodes
links = mat.node_tree.links
nodes.clear()

output = nodes.new('ShaderNodeOutputMaterial')
bsdf = nodes.new('ShaderNodeBsdfPrincipled')
emission = nodes.new('ShaderNodeEmission')
mix = nodes.new('ShaderNodeMixShader')

lavender = (0.7, 0.6, 0.85, 1.0)
bsdf.inputs['Base Color'].default_value = lavender
emission.inputs['Color'].default_value = lavender
emission.inputs['Strength'].default_value = 0.2

bsdf.inputs['Metallic'].default_value = 0.1
bsdf.inputs['Roughness'].default_value = 0.3
bsdf.inputs['Specular'].default_value = 0.5

links.new(bsdf.outputs['BSDF'], mix.inputs[1])
links.new(emission.outputs['Emission'], mix.inputs[2])
links.new(mix.outputs['Shader'], output.inputs['Surface'])
mix.inputs['Fac'].default_value = 0.2

# Create origami structure using multiple planes (reduced for speed)
num_planes = 6  # Fewer planes = faster render
angle_step = 360 / num_planes

for i in range(num_planes):
    angle = math.radians(i * angle_step)
    
    # Create plane
    bpy.ops.mesh.primitive_plane_add(size=3, location=(0, 0, 0))
    plane = bpy.context.object
    plane.data.materials.append(mat)
    
    # Initial rotation
    plane.rotation_euler = (0, 0, angle)
    
    # Add array modifier for segments
    array_mod = plane.modifiers.new(name="Array", type='ARRAY')
    array_mod.count = 2  # Reduced for faster rendering
    array_mod.relative_offset_displace = (0, 0.7, 0)
    
    # Add solidify for depth
    solidify = plane.modifiers.new(name="Solidify", type='SOLIDIFY')
    solidify.thickness = 0.05
    
    # Animate folding - create a wave of rotation
    for frame in range(1, 241):
        t = frame / 30.0
        fold_angle = math.sin(t * 2 * math.pi + i * 0.5) * math.radians(45)
        plane.rotation_euler.x = fold_angle
        plane.keyframe_insert(data_path="rotation_euler", index=0, frame=frame)
        
        # Subtle scale pulse
        scale = 1.0 + math.sin(t * 2 * math.pi + i * 0.5) * 0.1
        plane.scale = (scale, scale, 1.0)
        plane.keyframe_insert(data_path="scale", frame=frame)

# Smooth all keyframes
for obj in bpy.data.objects:
    if obj.animation_data and obj.animation_data.action:
        for fcurve in obj.animation_data.action.fcurves:
            for kf in fcurve.keyframe_points:
                kf.interpolation = 'BEZIER'
                kf.handle_left_type = 'AUTO'
                kf.handle_right_type = 'AUTO'

# Lighting
bpy.ops.object.light_add(type='SUN', location=(3, -5, 5))
sun = bpy.context.object
sun.data.energy = 1.5
sun.data.angle = math.radians(5)

bpy.ops.object.light_add(type='AREA', location=(-3, -5, 3))
fill = bpy.context.object
fill.data.energy = 50
fill.data.size = 5

# Render settings - output as PNG sequence
scene.render.filepath = '/Users/quasaur/Developer/social-effects/output/backgrounds/03_origami/frame_'
scene.render.image_settings.file_format = 'PNG'

print("✅ Origami fold cycle setup complete")
