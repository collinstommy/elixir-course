defmodule Servy.UserApi do
  def query(id) do
    "https://jsonplaceholder.typicode.com/users/#{URI.encode(id)}"
    |> HTTPoison.get
    |> handle
  end

  def handle({:ok, %{status_code: 200, body: body}}) do
    city = body |> Poison.Parser.parse!(%{}) |> get_in(["address", "city"])
    {:ok, city}
  end

  def handle({:ok, %{status_code: _status, body: body }}) do
    {:error, body |> Poison.Parser.parse!(%{})|> get_in(["message"])}
  end

  def handle({:error, %{reason: reason}}) do
    {:error, reason}
  end
end
