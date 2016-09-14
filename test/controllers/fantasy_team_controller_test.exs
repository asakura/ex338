defmodule Ex338.FantasyTeamControllerTest do
  use Ex338.ConnCase

  setup %{conn: conn} do
    user = %Ex338.User{name: "test", email: "test@example.com", id: 1}
    {:ok, conn: assign(conn, :current_user, user), user: user}
  end

  describe "index/2" do
    test "lists all fantasy teams in a league", %{conn: conn} do
      league = insert(:fantasy_league)
      other_league = insert(:fantasy_league)
      team = insert(:fantasy_team, team_name: "Brown", fantasy_league: league)
      other_team = insert(:fantasy_team, team_name: "Another Team",
                                         fantasy_league: other_league)
      position = insert(:roster_position, position: "Any", fantasy_team: team)

      conn = get conn, fantasy_league_fantasy_team_path(conn, :index, league.id)

      assert html_response(conn, 200) =~ ~r/Fantasy Teams/
      assert String.contains?(conn.resp_body, team.team_name)
      assert String.contains?(conn.resp_body, position.position)
      refute String.contains?(conn.resp_body, other_team.team_name)
    end
  end

  describe "show/2" do
    test "shows fantasy team info and players' table", %{conn: conn} do
      league = insert(:fantasy_league)
      team = insert(:fantasy_team, team_name: "Brown", fantasy_league: league)
      insert(:owner, user: conn.assigns.current_user, fantasy_team: team)
      player = insert(:fantasy_player)
      insert(:roster_position, position: "Any", fantasy_team: team,
                                          fantasy_player: player)

      conn = get conn, fantasy_team_path(conn, :show, team.id)

      assert html_response(conn, 200) =~ ~r/Brown/
      assert String.contains?(conn.resp_body, team.team_name)
      assert String.contains?(conn.resp_body, conn.assigns.current_user.name)
      assert String.contains?(conn.resp_body, player.player_name)
    end
  end
end
