defmodule Exray.Image do

  @doc "Transforms the rendered output into a PNG image ready to be compressed"
  def to_png(render_output, width, height) do
    img = ExPNG.Image.new(width, height)
    %{img | pixels: to_pixels(render_output)}
  end

  @doc "Convers rendered output into pixels usable by the PNG writer"
  def to_pixels(render_output) do
    for {r, g, b} <- render_output, into: <<>> do
      pr = to_8bpp(r)
      pg = to_8bpp(g)
      pb = to_8bpp(b)
      ExPNG.Color.rgb(pr, pg, pb)
    end
  end

  defp to_8bpp(x, scale \\ 255) do
    round(x * scale) |> max(0) |> min(scale)
  end

end
