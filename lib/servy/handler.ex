
defmodule Servy.Handler do
  @moduledoc """
    Handles HTTP Requests
  """

  alias Servy.Conv
  alias Servy.BearController

  @pages_path Path.expand("../../pages", __DIR__)

  import Servy.Plugins
  import Servy.FileHandler
  import Servy.Parser, only: [parse: 1]
  import Servy.FileHandler, only: [handle_file: 2]

  @doc "Transforms the request into a response"
  def handle(request) do
    request
    |> parse
    |> rewrite_path
    |> log
    |> route
    |> track
    |> format_response
  end

  # routing
  def route(%Conv{ method: "GET", path: "/bears/new" } =  conv) do
   route(%{conv | path: "/pages/form"})
  end

  def route(%{ method: "GET", path: "/pages" <> file} = conv) do
   @pages_path
     |> Path.join(file <> ".html")
     |> File.read
     |> handle_file(conv)
  end

  def route(%Conv{ method: "GET", path: "/wildthings" } =  conv) do
    %{conv | status: 200, resp_body: "Bears, Lions, Tigers"}
  end

  def route(%Conv{ method: "GET", path: "/bears"} =  conv) do
    BearController.index(conv)
  end

  def route(%Conv{ method: "GET", path: "/bears/" <> id} = conv) do
    params = Map.put(conv.params, "id", id)
    BearController.show(conv, params)
  end

  def route(%Conv{ method: "POST", path: "/bears"} =  conv) do
    BearController.create(conv, conv.params)
  end

   def route(%Conv{ path: path } = conv) do
    %{conv | status: 404, resp_body: "No #{path} here"}
  end

  def format_response(%Conv{} = conv) do
    """
    HTTP/1.1 #{Conv.full_status(conv)}
    Content-Type: text/html
    Content-Length: #{String.length(conv.resp_body)}

    #{conv.resp_body}
    """
  end

end

request = """
GET /bears HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*
Content-Type: text/html
Content-Length: 21

name=Baloo&type=Brown
"""

response = Servy.Handler.handle(request)

IO.puts response
