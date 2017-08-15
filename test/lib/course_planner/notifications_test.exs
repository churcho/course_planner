defmodule CoursePlanner.NotificationsTest do
  use CoursePlanner.ModelCase
  doctest CoursePlanner.Notifications

  import CoursePlanner.Factory

  alias CoursePlanner.{User, Notification, Notifications}

  test "send notification when it has past at least one day" do
    now = ~N[2017-08-15 10:00:00]

    user1 = insert(:user, %{notified_at: Timex.shift(now, days: -1), notification_period_days: 1})
    insert(:notification, %{user_id: user1.id})

    user2 = insert(:user, %{notified_at: Timex.shift(now, days: -1), notification_period_days: 2})
    insert(:notification, %{user_id: user2.id})

    user3 = insert(:user, %{notified_at: nil})
    insert(:notification, %{user_id: user3.id})

    user4 = insert(:user, %{notified_at: Timex.shift(now, hours: -12), notification_period_days: 1})
    insert(:notification, %{user_id: user4.id})

    users_to_notify = Notifications.get_notifiable_users(now) |> Enum.map(&(&1.id))

    assert user1.id in users_to_notify
    refute user2.id in users_to_notify
    assert user3.id in users_to_notify
    refute user4.id in users_to_notify
  end

  test "do not send notification when disabled" do
    insert(:system_variable, %{key: "ENABLE_NOTIFICATION", value: "false", type: "boolean"})
    user = insert(:user)
    notification = insert(:notification, %{user_id: user.id})

    Notifications.send_all_notifications()

    notifications = Repo.all(Notification)
    assert length(notifications) == 1

    saved_user = Repo.get(User, user.id) |> Repo.preload(:notifications)
    assert saved_user.notified_at == nil
    assert saved_user.notifications == [notification]
  end

end
