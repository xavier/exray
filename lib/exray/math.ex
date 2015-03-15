defmodule Exray.Math do

  @infinite 10000000.0
  @epsilon  0.00000001

  def infinite(), do: @infinite
  def epsilon(),  do: @epsilon

  def sqr(x),    do: x * x
  def rad(x, s), do: x * :math.pi / (s * 0.5)
  def zero?(x),  do: abs(x) <= @epsilon

end