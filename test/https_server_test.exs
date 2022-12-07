defmodule HttpsServerTest do
  use ExUnit.Case

  alias Servy.HttpServer

  test "accepts multiple requests on a socket and sends back a responses" do
    spawn(HttpServer, :start, [4000])

    parent = self()

    ["http://localhost:4000/wildthings", "http://localhost:4000/about"]
      |> Enum.map(&Task.async(fn -> HTTPoison.get(&1) end))
      |> Enum.map(&Task.await/1)
      |> Enum.map(&assert_successful_response/1)
  end

  defp assert_successful_response({:ok, response}) do
    assert response.status_code == 200
  end
end
