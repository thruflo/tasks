defmodule Tasks.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      TasksWeb.Telemetry,
      Tasks.Repo,
      {DNSCluster, query: Application.get_env(:tasks, :dns_cluster_query) || :ignore},
      {Oban, Application.fetch_env!(:tasks, Oban)},
      {Phoenix.PubSub, name: Tasks.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: Tasks.Finch},
      # Start a worker by calling: Tasks.Worker.start_link(arg)
      # {Tasks.Worker, arg},
      # Start to serve requests, typically the last entry
      {TasksWeb.Endpoint, phoenix_sync: Phoenix.Sync.plug_opts()}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Tasks.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    TasksWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
