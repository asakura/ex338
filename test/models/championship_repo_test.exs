defmodule Ex338.ChampionshipRepoTest do
  use Ex338.ModelCase
  alias Ex338.{Championship}
  describe "earliest_first/1" do
    test "return championships with earliest date first" do
      insert(:championship,
        title: "A",
        championship_at: Ecto.DateTime.cast!(
          %{day: 17, hour: 0, min: 0, month: 6, sec: 0, year: 2017}
        )
      )
      insert(:championship,
        title: "B",
        championship_at: Ecto.DateTime.cast!(
          %{day: 17, hour: 0, min: 0, month: 5, sec: 0, year: 2017}
        )
      )

      query = Championship
              |> Championship.earliest_first
              |> select([c], c.title)

      assert Repo.all(query) == ~w(B A)
    end
  end

  describe "preload_assocs/1" do
    test "returns any associated sports leagues" do
      league = insert(:sports_league)
      championship = insert(:championship, sports_league: league)
      player = insert(:fantasy_player, sports_league: league)
      champ_result = insert(:championship_result, championship: championship,
                                                  fantasy_player: player)

      result = Championship
               |> Championship.preload_assocs
               |> Repo.one

      assert result.sports_league.id == league.id
      assert Enum.at(result.championship_results, 0).id == champ_result.id
    end
  end

  describe "get_championship/2" do
    test "returns a championship with assocs" do
      championship = insert(:championship)

      result = Championship |> Championship.get_championship(championship.id)

      assert result.id == championship.id
    end
  end

  describe "get all/1" do
    test "returns all championships" do
      insert_list(3, :championship)

      result = Championship |> Championship.get_all

      assert Enum.count(result) == 3
    end
  end
end
