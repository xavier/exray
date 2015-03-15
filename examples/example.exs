
scene = %Exray.Scene{
  camera: %Exray.Camera{
    position: {4000, 5000, -4000},
    look_at: {0, 0, 0},
    roll: 0,
  },
  light: {1000, 1000, 0},
  models: [],
  shadows: true,
  reflections: true,
}

planes = [
  %Exray.Plane{
      normal: {0, -1, 0},
      distance: -200,
      material:  %Exray.Material{color: {0.25, 0.25, 0.25}}
  },
  %Exray.Plane{
    normal: {0, 0, 1},
    distance: -3000,
    material:  %Exray.Material{color: {0.5, 0.5, 0.25}}
  },
  %Exray.Plane{
    normal: {-1, 0, 0},
    distance: -3000,
    material:  %Exray.Material{color: {0.5, 0.5, 0.25}}
  }
]

num_spheres = 36
circle_radius = 2300
spheres = Enum.map(0..num_spheres, fn (n) ->
  a = Exray.Math.rad(n, num_spheres)
  %Exray.Sphere{
    position: {:math.cos(a) * circle_radius, 0, :math.sin(a) * circle_radius},
    radius: 200,
    material: %Exray.Material{color: Exray.Color.hsv(n / num_spheres, 1, 1)}
  }
end)

big_sphere =  %Exray.Sphere{
  position: {0, 0, 0},
  radius: 1000,
  material: %Exray.Material{color: Exray.Color.grayscale(0.75), reflection: 0.75}
}

scene = %{scene | models: [big_sphere|planes ++ spheres]}

IO.inspect scene

viewport = %Exray.Viewport{width: 640, height: 480, viewer_distance: 600}

IO.puts "Rendering..."

{time_ns, output} = :timer.tc(fn ->
  Exray.Renderer.render(scene, viewport)
end)

time_s = Float.round(time_ns / 1_000_000, 3)
IO.puts "Completed in #{time_s}s"

output
|> Exray.Image.to_png(viewport.width, viewport.height)
|> ExPNG.write("scene.png")