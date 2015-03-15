defmodule Exray.Color do

  @moduledoc """
  Basic RGB color manipulations.

  All color components are in the [0;1] range.
  """

  @doc "Pure black. It goes with everything."
  def black, do: {0, 0, 0}

  @doc "Returns a tint of gray"
  def grayscale(tint), do: {tint, tint, tint}

  @doc "Warning: no clipping"
  def add({r1, g1, b1}, {r2, g2, b2}), do: {r1 + r2, g1 + g2, b1 + b2}

  @doc "Warning: no clipping"
  def mul({r, g, b}, f), do: {r * f, g * f, b * f}

  @doc "Mixes k (a value between 0 and 1) amount of color2 with color1"
  def mix({r1, g1, b1}, {r2, g2, b2}, k) do
    ik = 1 - k
    {
      (r1 * ik) + (r2 * k),
      (g1 * ik) + (g2 * k),
      (b1 * ik) + (b2 * k)
    }
  end

  @doc "Converts a color from HSV to RGB"
  def hsv(_, 0, v), do: grayscale(v)
  def hsv(h, s, v) do

    h6 = h * 6
    i  = Float.floor(h6)
    f  = h6 - i
    p  = v * (1 - s)
    q  = v * (1 - s * f)
    t  = v * (1 - s * (1 - f))

    case rem(round(i), 6) do
      0 -> {v, t, p}
      1 -> {q, v, p}
      2 -> {p, v, t}
      3 -> {p, q, v}
      4 -> {t, p, v}
      5 -> {v, p, q}
    end
  end

end