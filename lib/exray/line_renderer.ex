defmodule Exray.LineRenderer do

  use GenServer

  def start_link(_), do: GenServer.start_link(__MODULE__, [])

  def render_line(worker_pid, {scene_renderer, y, scene, mx, transpose_y, viewport_width, ray, vm_u}) do
    GenServer.call(worker_pid, {:render_line, scene_renderer, y, scene, mx, transpose_y, viewport_width, ray, vm_u})
  end

  def handle_call({:render_line, scene_renderer, y, scene, mx, transpose_y, viewport_width, ray, vm_u}, _from, state) do
    rendered_line = Exray.Renderer.timed_render_line(scene, mx, transpose_y, viewport_width, ray, vm_u)

    send(scene_renderer, {y, rendered_line})

    # {:reply, {y, rendered_line}, state}
    {:noreply, state}
  end
end
