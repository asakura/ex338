defmodule Ex338Web.ExAdmin.TradeLineItem do
  @moduledoc false
  use ExAdmin.Register

  alias Ex338.FantasyTeam

  register_resource Ex338.TradeLineItem do
    index do
      selectable_column()

      column(:id)
      column(:trade, fields: [:id], label: "Trade Id")
      column(:losing_team)
      column(:fantasy_player)
      column(:future_pick)
      column(:gaining_team)
      actions()
    end

    form trade_line_item do
      inputs do
        input(
          trade_line_item,
          :trade,
          collection: Ex338.Trades.Trade.all(),
          fields: [:id, :status]
        )

        input(
          trade_line_item,
          :losing_team,
          collection: Ex338.Repo.all(FantasyTeam.alphabetical(FantasyTeam))
        )

        input(
          trade_line_item,
          :fantasy_player,
          collection: Ex338.FantasyPlayers.get_all_players()
        )

        input(
          trade_line_item,
          :future_pick,
          collection: Ex338.Repo.all(Ex338.DraftPicks.FuturePick),
          fields: [:round, :current_team_id]
        )

        input(
          trade_line_item,
          :gaining_team,
          collection: Ex338.Repo.all(FantasyTeam.alphabetical(FantasyTeam))
        )
      end
    end

    show trade_line_item do
      attributes_table do
        row(:trade, fields: [:id], label: "Trade Id")
        row(:losing_team)
        row(:fantasy_player)
        row(:future_pick)
        row(:gaining_team)
      end
    end
  end
end
