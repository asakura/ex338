defmodule Ex338.ChampionshipController do
  use Ex338.Web, :controller
  alias Ex338.{Championship, FantasyLeague}

  def index(conn, %{"fantasy_league_id" => league_id}) do
    render(conn, "index.html",
     championships:  Championship.get_all(Championship),
     fantasy_league: FantasyLeague.get_league(league_id)
    )
  end
end
