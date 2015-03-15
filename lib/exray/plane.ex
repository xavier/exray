defmodule Exray.Plane do
  defstruct normal: nil, distance: nil, material: nil
end

defimpl Model, for: Exray.Plane do

  alias Exray.Math, as: Math
  alias Exray.Vec3, as: Vec3

  def intersect(plane, ray) do
    v1 = Vec3.dot(plane.normal, ray.direction)
    if Math.zero?(v1) do
      Math.infinite
    else
      {nx, ny, nz} = plane.normal
      {ox, oy, oz} = ray.origin
      v = - plane.distance - (nx * ox) - (ny * oy) - (nz * oz)
      k = v / v1
      if k > 0 do
        k
      else
        Math.infinite
      end
    end
  end

  def normal_at_point(plane, _point) do
    plane.normal
  end

  def color_at_point(plane, _point) do
    plane.material.color
  end

end