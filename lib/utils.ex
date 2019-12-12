defmodule Utils do
  @doc """
  A shorthand for the most common thing you want to do with a recon trace.
  """
  def trace(module_or_modules, max_calls \\ 10, opts \\ [])

  def trace(module, max_calls, opts) when is_atom(module),
    do: trace([module], max_calls, opts)

  def trace(modules, max_calls, opts) when is_list(modules) do
    things_to_trace = for module <- modules, do: {module, :_, :return_trace}

    :recon_trace.calls(things_to_trace, max_calls, [{:scope, :local} | opts])
  end
end
