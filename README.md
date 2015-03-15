# Exray

A simple raytracer written in Elixir for fun.

![An image rendered with Exray](examples/scene.png?raw=true)

## Features

* Supports planes and sphere
* Single ambient light source
* Diffuse lighting
* Shadows
* Reflections
* Free camera
* Parallel rendering

## Installation

```
$ git clone git@github.com:xavier/exray.git
$ mix deps.get
$ mix compile
```

To see the results:

```
$ mix run examples/example.exs && open scene.png
```

## Dependencies

It depends on my still experimental [ExPNG](https://github.com/xavier/ex_png) library for writing the output to files.

## Licence

This is Public Domain software. Just have fun with it!