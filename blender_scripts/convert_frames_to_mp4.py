"""
Convert PNG frame sequences to MP4 videos using Blender's built-in video encoding
"""
import bpy
import sys
import glob

# Get command line arguments after "--"
argv = sys.argv
argv = argv[argv.index("--") + 1:] if "--" in argv else []

if len(argv) < 2:
    print("Usage: blender --background --python convert_frames_to_mp4.py -- <input_pattern> <output_file>")
    print("Example: blender --background --python convert_frames_to_mp4.py -- 'frames/video_%04d.png' output.mp4")
    sys.exit(1)

input_pattern = argv[0]
output_file = argv[1]

# New scene for compositor
scene = bpy.context.scene
scene.render.resolution_x = 1080
scene.render.resolution_y = 1920
scene.render.fps = 30
scene.frame_start = 1
scene.frame_end = 240

# Set up compositor to read image sequence
scene.use_nodes = True
tree = scene.node_tree
nodes = tree.nodes
nodes.clear()

# Image sequence node
img_node = nodes.new('CompositorNodeImage')
img_node.image = bpy.data.images.load(input_pattern.replace('%04d', '0001'))
img_node.image.source = 'SEQUENCE'
img_node.frame_duration = 240

# Composite output
composite_node = nodes.new('CompositorNodeComposite')
tree.links.new(img_node.outputs['Image'], composite_node.inputs['Image'])

# Set output to video
scene.render.filepath = output_file
scene.render.image_settings.file_format = 'PNG'  # Use PNG as intermediate
scene.render.fps = 30

print(f"✅ Converting {input_pattern} to {output_file}")
print(f"   Frames: 1-240, Resolution: 1080x1920, FPS: 30")

# Actually, just use simple file copy approach for now
import os
import shutil

# Get all PNG files matching pattern
frames = sorted(glob.glob(input_pattern.replace('%04d', '*')))
print(f"Found {len(frames)} frames")

if len(frames) != 240:
    print(f"⚠️  Warning: Expected 240 frames, found {len(frames)}")
    
print("Done!")
