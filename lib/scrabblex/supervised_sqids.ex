defmodule Scrabblex.SupervisedSqids do
  use Sqids

  @impl true
  def child_spec() do
    child_spec(
      alphabet: Application.get_env(:scrabblex, __MODULE__)[:alphabet],
      min_length: Application.get_env(:scrabblex, __MODULE__)[:min_length]
    )
  end
end
