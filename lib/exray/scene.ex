defmodule Exray.Scene do

  defstruct camera: nil,
            light: nil,
            models: [],
            background_color: {0, 0, 0},
            shadows: true,
            reflections: true

end