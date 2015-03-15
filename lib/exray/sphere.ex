defmodule Exray.Sphere do
  defstruct position: nil, radius: nil, material: nil
end

defimpl Model, for: Exray.Sphere do

  alias Exray.Vec3, as: Vec3
  alias Exray.Math, as: Math

  def intersect(sphere, ray) do
    v = Vec3.sub(ray.origin, sphere.position)
    b = 2.0 * Vec3.dot(ray.direction, v)
    c = Vec3.dot(v, v) - Math.sqr(sphere.radius)
    d = Math.sqr(b) - 4 * c
    if d < 0 do
      Math.infinite
    else
      sd = :math.sqrt(d)
      t = (-b - sd) * 0.5
      if t > 0 do
        t
      else
        Math.infinite
      end
    end
  end

  def normal_at_point(sphere, point) do
    Vec3.sub(sphere.position, point) |> Vec3.scale(1.0 / sphere.radius)
  end

  def color_at_point(sphere, _point) do
    sphere.material.color
  end

end