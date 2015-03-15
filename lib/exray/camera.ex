  defmodule Exray.Camera do

    @moduledoc """
    The camera is defined by 3 parameters:

    - a `position` vector which is the point of the observer
    - a `look_at` vector which is the point the observer is looking at
    - a `roll` angle (in degrees) which allows the image to be tilted
    """

    defstruct position: nil, look_at: nil, roll: nil

    alias Exray.Vec3, as: Vec3
    alias Exray.Math, as: Math

    @doc """
    Returns a 3x3 UVN matrix which defined the camera space
    """
    def view_matrix(camera) do
      vup = view_up_vector(camera)
      n = camera.position |> Vec3.sub(camera.look_at) |> Vec3.normalize
      u = Vec3.cross(n, vup)
      v = Vec3.cross(n, u)
      {u, v, n}
    end

    defp view_up_vector(camera) do
      a  = Math.rad(camera.roll - 45, 360)
      xt = :math.cos(a)
      yt = :math.sin(a)
      Vec3.new(xt + yt, xt - yt, 0)
    end

  end