defmodule Shell do
    def escape_value(value), do: escape_value(value, "")
    defp escape_value("", res), do: "\"#{res}\""
    defp escape_value("\"" <> value, res), do: escape_value(value, res <> "\\\"")
    defp escape_value("\\" <> value, res), do: escape_value(value, res <> "\\\\")
    defp escape_value(<<char :: utf8, rest :: binary>>, res),
     do: escape_value(rest, res <> <<char>>)
  end