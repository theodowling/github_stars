defmodule GithubStars.Tags.CreateTags do
  @moduledoc """
   Defines the CreateTags operation module
  """

  alias GithubStars.Tags.Tag
  alias GithubStars.Repo

  import Ecto.Query
  import Logger

  @doc """
    Creates a tag in the local database. Verifies if the tag already exists in the database.
  """
  def call(%{"repo_id" => repo_id, "name" => name} = params) do
    Logger.debug("Creating tag with params: #{inspect(params)}")

    with false <- tag_exists?(repo_id, name),
         {:ok, %Tag{} = result} <- Tag.changeset(params) |> Repo.insert() do
      {:ok, result}
    else
      true ->
        Logger.debug("Error - Duplicate tag!: #{inspect(params)}")
        {:error, %{result: "Existent tag!", status: :bad_request}}
    end
  end

  def call(params) do
    Logger.debug("Creating tag with params: #{inspect(params)}")
    result = Tag.changeset(params)

    case result.valid? do
      false ->
        {:error, %{result: result, status: :bad_request}}
    end
  end

  defp tag_exists?(repo_id, name) do
    query = from t in Tag, where: t.repo_id == ^repo_id and t.name == ^name, select: t
    Repo.one(query) != nil
  end
end
