IEx.configure(
  colors: [
    enabled: true,
    syntax_colors: [
      number: :light_yellow,
      atom: :light_cyan,
      string: :light_black,
      boolean: :red,
      nil: [:magenta, :bright]
    ],
    ls_directory: :cyan,
    ls_device: :yellow,
    doc_code: :green,
    doc_inline_code: :magenta,
    doc_headings: [:cyan, :underline],
    doc_title: [:cyan, :bright, :underline]
  ],
  inspect: [
    pretty: true,
    limit: :infinity,
    width: 80,
    custom_options: [sort_maps: true]
  ],
  width: 80,
  history_size: 500
)

Code.put_compiler_option(:ignore_module_conflict, true)

if System.get_env("MIX_ENV") == "test" do
  defmodule My do
    def repl do
      input = "-> " |> IO.gets() |> String.trim()
      command = parse_command(input)

      case command do
        {:ok, {:watch, path}} ->
          IexTests.test_watch(path)
          repl()

        {:ok, {:test, path}} ->
          IexTests.test(path)
          repl()

        {:ok, :stop} ->
          IexTests.stop_watch()
          IO.puts("Stopped watching.")
          repl()

        {:ok, :quit} ->
          IO.puts("Bye! 👋")

        {:error, :unknown_command} ->
          IO.puts("Unknown command")
          repl()
      end
    end

    defp parse_command("w mix test " <> path), do: {:ok, {:watch, path}}
    defp parse_command("w " <> path), do: {:ok, {:watch, path}}
    defp parse_command("mix test " <> path), do: {:ok, {:test, path}}
    defp parse_command("t" <> path), do: {:ok, {:test, path}}
    defp parse_command("s"), do: {:ok, :stop}
    defp parse_command("q"), do: {:ok, :quit}
    defp parse_command("Q"), do: {:ok, :quit}
    defp parse_command(_), do: {:error, :unknown_command}
  end

  My.repl()
end
