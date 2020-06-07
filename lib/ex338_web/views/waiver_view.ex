defmodule Ex338Web.WaiverView do
  use Ex338Web, :view

  def after_now?(date_time) do
    case DateTime.compare(date_time, DateTime.utc_now()) do
      :gt -> true
      :eq -> true
      :lt -> false
    end
  end

  def sort_most_recent(query) do
    Enum.sort(query, &before_other_date?(&1.process_at, &2.process_at))
  end

  def display_name(%{sports_league: %{hide_waivers: true}}), do: "*****"

  def display_name(%{player_name: name} = _player), do: name

  def within_two_hours_of_submittal?(waiver) do
    submitted_at = waiver.inserted_at
    now = NaiveDateTime.utc_now()
    two_hours = 60 * 60 * 2
    age_of_waiver = NaiveDateTime.diff(now, submitted_at, :second)

    age_of_waiver < two_hours
  end

  # Helpers

  # sort_most_recent

  defp before_other_date?(date1, date2) do
    case DateTime.compare(date1, date2) do
      :gt -> true
      :eq -> true
      :lt -> false
    end
  end
end
