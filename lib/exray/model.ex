defprotocol Model do
  @moduledoc """
  In order to be renderable a model must be able to calculate:

  - the distance at which it intersects with the given ray (or Math.infinite if it does not)
  - the normal vector at the given point of its surface
  - the color at the given point of its surface

  """

  def intersect(model, ray)
  def normal_at_point(model, point)
  def color_at_point(model, point)
end
