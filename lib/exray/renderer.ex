defmodule Exray.Renderer do

  alias Exray.Math,   as: Math
  alias Exray.Vec3,   as: Vec3
  alias Exray.Ray,    as: Ray
  alias Exray.Camera, as: Camera
  alias Exray.Color,  as: Color

  @doc "Renders the scene sequentially"
  def render_seq(scene, viewport) do
    mx = viewport.width / 2
    my = viewport.height / 2

    view_matrix = Camera.view_matrix(scene.camera)
    {vm_u, vm_v, vm_n} = view_matrix

    ray = %Ray{origin: Vec3.add(scene.camera.position, Vec3.scale(vm_n, viewport.viewer_distance))}

    for y <- 0..(viewport.height-1),
        x <- 0..(viewport.width-1) do

        yt = y - my
        xt = x - mx

        transpose_y = Vec3.scale(vm_v, yt) |> Vec3.add(scene.camera.position)
        point = Vec3.scale(vm_u, xt) |> Vec3.add(transpose_y)

        trace_ray(scene, Ray.point_to(ray, point))
    end

  end

  @doc "Renders the scene concurrently"
  def render(scene, viewport) do

    # Precalculations
    mx = viewport.width / 2
    my = viewport.height / 2

    # Calculate camera space
    view_matrix = Camera.view_matrix(scene.camera)
    {vm_u, vm_v, vm_n} = view_matrix

    # Set the origin of the ray in the camera space
    ray = %Ray{origin: Vec3.add(scene.camera.position, Vec3.scale(vm_n, viewport.viewer_distance))}

    # Pid which will receive the results of the calculations
    scene_renderer = self()

    num_workers = :erlang.system_info(:logical_processors) - 1

    IO.inspect "concurrent workers: #{num_workers}"

    {:ok, pool} = :poolboy.start(
      worker_module: Exray.LineRenderer,
      size:          num_workers,
      max_overflow:  0
    )

    for y <- 0..(viewport.height-1) do
      # Precalculate line-specific invariants
      yt = y - my
      transpose_y = Vec3.scale(vm_v, yt) |> Vec3.add(scene.camera.position)

      spawn(fn ->
        worker_pid = :poolboy.checkout(
          pool,
          true,         # blocking
          :infinity     # timeout. :infinity is the standard timeout value for OTP.
                        # The default timeout in poolboy is 5 seconds, so we don't want
                        # :poolboy to kill our long and beautiful queue of tasks
        )

        :ok = Exray.LineRenderer.render_line(
          worker_pid,
          {scene_renderer, y, scene, mx, transpose_y, viewport.width, ray, vm_u}
        )
        :poolboy.checkin(pool, worker_pid)

      end)
    end

    # Collect all rendered lines in order
    for y <- 0..(viewport.height-1) do
      receive do
        {^y, line} -> line
      end
    end |> List.flatten

  end


  def timed_render_line(scene, mx, transpose_y, width, ray, vm_u) do
    {time_ns, output} = :timer.tc(fn ->
      render_line(scene, mx, transpose_y, width, ray, vm_u)
    end)
    IO.puts "#{Float.round(time_ns / 1_000_000, 3)}"
    output
  end

  defp render_line(scene, mx, transpose_y, width, ray, vm_u) do
    for x <- 0..(width-1) do
      # Calculate the direction of the ray for the given pixel and trace it
      xt = x - mx
      point = Vec3.scale(vm_u, xt) |> Vec3.add(transpose_y)
      trace_ray(scene, Ray.point_to(ray, point))
    end
  end

  # Returns the color for to the pixel corresponding to the given ray
  defp trace_ray(scene, ray, recursion_level \\ 1) do
    case find_closest_hit_model(scene, ray) do
      {_, nil}
        -> scene.background_color
      {distance, model}
       -> hit_color(scene, ray, distance, model, recursion_level)
    end
  end

  # Returns a {distance, model} pair for the closest object hit by the given ray or {<infinite>, nil} if no models were hit
  defp find_closest_hit_model(scene, ray) do
    Enum.reduce(scene.models, {Math.infinite, nil}, fn (model, current_closest = {closest_distance, _}) ->
      d = Model.intersect(model, ray)
      if d < closest_distance do
        {d, model}
      else
        current_closest
      end
    end)
  end

  # Returns the color of the point hit by the ray on the given model surface
  defp hit_color(scene, ray, hit_distance, hit_model, recursion_level) do

    # Find exactly where the ray intersected with the model surface
    hit_point = Ray.calculate_hit_point(ray, hit_distance)

    # Collect model specific informations
    normal_at_hit_point = Model.normal_at_point(hit_model, hit_point)
    color_at_hit_point  = Model.color_at_point(hit_model, hit_point)

    # Build a ray from the light source to the hit point
    light_ray = %Ray{origin: scene.light} |> Ray.point_to(hit_point)

    # Pass original model color through lighting pipeline
    color_at_hit_point
    |> apply_diffuse_lighting(hit_model, normal_at_hit_point, light_ray)
    |> apply_shadow(scene, light_ray, hit_point)
    |> apply_reflection(scene, ray, hit_model, hit_point, normal_at_hit_point, recursion_level)

  end

  defp apply_diffuse_lighting(color_at_hit_point, hit_model, normal_at_hit_point, light_ray) do
    diffuse = hit_model.material.diffuse
    diffuse_lighting = Vec3.dot(normal_at_hit_point, light_ray.direction) * diffuse
    Color.grayscale(diffuse_lighting) |> Color.add(Color.mul(color_at_hit_point, 1 - diffuse))
  end

  # Calculate shadow by finding out if there are any object in the path of the ray between the
  # lightsource and the hit point
  @shadow_factor 1 / 1.6
  defp apply_shadow(original_color, %{shadows: false}, _, _), do: original_color
  defp apply_shadow(original_color, scene = %{shadows: true}, light_ray, hit_point) do
    # Adjust distance to avoid intersecting with the hit model
    light_distance = (Vec3.sub(light_ray.origin, hit_point) |> Vec3.magnitude) - 0.001
    # Dim color for each intersected object
    Enum.reduce(scene.models, original_color, fn (model, color) ->
      if Model.intersect(model, light_ray) < light_distance do
        Color.mul(color, @shadow_factor)
      else
        color
      end
    end)
  end

  # Calculate
  def apply_reflection(color, %{reflections: false}, _, _, _, _, _), do: color
  def apply_reflection(color, %{reflections: true}, _, _, _, _, 0), do: color
  def apply_reflection(color, %{reflections: true}, _, %{:material => %{reflection: 0.0}}, _, _, _), do: color
  def apply_reflection(color, %{reflections: true} = scene, ray, %{:material => %{reflection: reflection}}, hit_point, normal_at_hit_point, recursion_level) do
    rho = 2 * Vec3.dot(normal_at_hit_point, ray.direction)
    reflected_ray_direction = Vec3.sub(ray.direction, Vec3.scale(normal_at_hit_point, rho))
    reflected_ray = %Ray{
      origin: Vec3.add(hit_point, reflected_ray_direction),
      direction: reflected_ray_direction
    }
    reflected_color = trace_ray(scene, reflected_ray, recursion_level - 1)
    Color.mix(color, reflected_color, reflection)
  end


end