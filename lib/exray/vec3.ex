defmodule Exray.Vec3 do

  @moduledoc """
  Simple vector math.
  """

  alias Exray.Math, as: Math

  def new(x),       do: new(x, x, x)
  def new(x, y),    do: new(x, y, 0)
  def new(x, y, z), do: {x, y, z}

  def add({x1, y1, z1}, {x2, y2, z2}) do
    {
      x1 + x2,
      y1 + y2,
      z1 + z2,
    }
  end

  def sub({x1, y1, z1}, {x2, y2, z2}) do
    {
      x1 - x2,
      y1 - y2,
      z1 - z2,
    }
  end

  def scale({x, y, z}, k) do
    {
      x * k,
      y * k,
      z * k,
    }
  end

  def dot({x1, y1, z1}, {x2, y2, z2}) do
    (x1 * x2) + (y1 * y2) + (z1 * z2)
  end

  def cross({x1, y1, z1}, {x2, y2, z2}) do
    {
      (y1 * z2) - (z1 * y2),
      (z1 * x2) - (x1 * z2),
      (x1 * y2) - (y1 * x2),
    }
  end

  def magnitude2({x, y, z}) do
    Math.sqr(x) + Math.sqr(y) + Math.sqr(z)
  end

  def magnitude(v) do
    v |> magnitude2 |> :math.sqrt
  end

  def normalize(v) do
    scale(v, 1 / magnitude(v))
  end

  def magnitude_normalize(v) do
    mag = magnitude(v)
    {mag, scale(v, 1 / mag)}
  end

end