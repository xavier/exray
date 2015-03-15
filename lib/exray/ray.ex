defmodule Exray.Ray do

  @moduledoc """
  A ray is defined by two vectors:

  - its origin (a point in space)
  - its direction (a normal vector)
  """

  defstruct origin: nil, direction: nil

  alias Exray.Vec3, as: Vec3

  @doc "Point the ray to the given point"
  def point_to(ray, point) do
    %{ray | direction: Vec3.sub(point, ray.origin) |> Vec3.normalize}
  end

  @doc "Find the point situated at `distance` units on the ray"
  def calculate_hit_point(ray, distance) do
    ray.origin |> Vec3.add(Vec3.scale(ray.direction, distance))
  end

end