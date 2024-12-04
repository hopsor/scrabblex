defmodule ScrabblexWeb.GoogleAnalytics do
  import Plug.Conn

  def set_google_analytics_tag(conn, _opts) do
    assign(conn, :google_analytics_tag, Application.get_env(:scrabblex, :google_analytics)[:tag])
  end
end
