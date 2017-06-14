defmodule CoursePlanner.Users do
  @moduledoc """
    Handle all interactions with Users, create, list, fetch, edit, and delete
  """
  alias CoursePlanner.{Repo, User, Notifier, Notifier.Notification}
  alias Ecto.{Changeset, DateTime}

  def all do
    Repo.all(User)
  end

  def new_user(user, token) do
    %User{}
    |> User.changeset(user)
    |> Changeset.put_change(:reset_password_token, token)
    |> Changeset.put_change(:reset_password_sent_at, DateTime.utc())
    |> Changeset.put_change(:password, "fakepassword")
  end

  def get(id) do
    case Repo.get(User, id) do
      nil -> {:error, :not_found}
      user -> {:ok, user}
    end
  end

  def delete(id) do
    case get(id) do
      {:ok, user} -> Repo.delete(user)
      error -> error
    end
  end

  def notify_user(%{id: id}, %{id: id}, _, _), do: nil
  def notify_user(modified_user, _current_user, notification_type, path) do
    Notification.new()
    |> Notification.type(notification_type)
    |> Notification.resource_path(path)
    |> Notification.to(modified_user)
    |> Notifier.notify_user()
  end
end
