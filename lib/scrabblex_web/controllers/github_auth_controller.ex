defmodule ScrabblexWeb.GithubAuthController do
  use ScrabblexWeb, :controller
  alias ScrabblexWeb.GithubAuth

  def request(conn, _params) do
    GithubAuth.request(conn)
  end

  def callback(conn, _params) do
    GithubAuth.callback(conn)
  end
end
