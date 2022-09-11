defmodule Servy do
  def hello(name) do
    "hello #{name}"
  end
end

IO.puts Servy.hello("Elixir")
