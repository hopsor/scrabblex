defmodule Scrabblex.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      ScrabblexWeb.Telemetry,
      Scrabblex.SupervisedSqids,
      Scrabblex.Repo,
      {DNSCluster, query: Application.get_env(:scrabblex, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Scrabblex.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: Scrabblex.Finch},
      # Start a worker by calling: Scrabblex.Worker.start_link(arg)
      # {Scrabblex.Worker, arg},
      ScrabblexWeb.Presence,
      # Start to serve requests, typically the last entry
      ScrabblexWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Scrabblex.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    ScrabblexWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
