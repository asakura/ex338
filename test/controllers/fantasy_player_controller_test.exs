defmodule Ex338.FantasyPlayerControllerTest do
  use Ex338.ConnCase

  describe "index/2" do
    test "lists all owned/unowned fantasy players in a league", %{conn: conn} do
      league = insert(:fantasy_league)
      other_league = insert(:fantasy_league)
      team = insert(:fantasy_team, team_name: "Brown", fantasy_league: league)
      other_team = insert(:fantasy_team, team_name: "Another Team", 
                                         fantasy_league: other_league)
      player = insert(:fantasy_player)
      unowned_player = insert(:fantasy_player)
      insert(:roster_position, fantasy_team: team, fantasy_player: player)
      insert(:roster_position, fantasy_team: other_team, fantasy_player: player)
      
      conn = get conn, fantasy_league_fantasy_player_path(conn, :index, league.id)

      assert html_response(conn, 200) =~ ~r/Fantasy Players/
      assert String.contains?(conn.resp_body, player.player_name)
      assert String.contains?(conn.resp_body, unowned_player.player_name)
      assert String.contains?(conn.resp_body, team.team_name)
      refute String.contains?(conn.resp_body, other_team.team_name)
    end
  end
end