defmodule Ex338Web.ExAdmin.InSeasonDraftPick do
  @moduledoc false
  use ExAdmin.Register

  register_resource Ex338.InSeasonDraftPicks.InSeasonDraftPick do
    form in_season_draft_pick do
      inputs do
        input(in_season_draft_pick, :position)

        input(
          in_season_draft_pick,
          :draft_pick_asset,
          collection: Ex338.Repo.all(Ex338.RosterPositions.RosterPosition),
          fields: [:id, :fantasy_team_id, :fantasy_player_id]
        )

        input(
          in_season_draft_pick,
          :drafted_player,
          collection: Ex338.Repo.all(Ex338.FantasyPlayers.FantasyPlayer)
        )

        input(in_season_draft_pick, :championship,
          collection: Ex338.Repo.all(Ex338.Championships.Championship)
        )
      end
    end
  end
end
