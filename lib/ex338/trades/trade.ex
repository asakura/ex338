defmodule Ex338.Trades.Trade do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query, warn: false

  alias Ex338.{Trades.Trade, Trades.TradeLineItem, Trades.TradeVote}

  @status_options ~w(Proposed Pending Approved Disapproved Rejected Canceled)

  schema "trades" do
    field(:status, :string, default: "Proposed")
    field(:additional_terms, :string, default: "")
    field(:yes_votes, :integer, virtual: true, default: 0)
    field(:no_votes, :integer, virtual: true, default: 0)
    belongs_to(:submitted_by_team, Ex338.FantasyTeams.FantasyTeam)
    belongs_to(:submitted_by_user, Ex338.Accounts.User)
    has_many(:trade_line_items, TradeLineItem)
    has_many(:trade_votes, Ex338.Trades.TradeVote)

    timestamps()
  end

  def by_league(query, league_id) do
    from(
      t in query,
      join: l in assoc(t, :trade_line_items),
      join: gt in assoc(l, :gaining_team),
      join: lt in assoc(l, :losing_team),
      where: gt.fantasy_league_id == ^league_id or lt.fantasy_league_id == ^league_id,
      group_by: t.id
    )
  end

  def by_status(query, statuses) when is_list(statuses) do
    from(
      t in query,
      where: t.status in ^statuses
    )
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(trade, params \\ %{}) do
    trade
    |> cast(params, [
      :status,
      :additional_terms,
      :submitted_by_team_id,
      :submitted_by_user_id
    ])
    |> validate_required([:status])
    |> validate_inclusion(:status, @status_options)
  end

  def count_votes(trades) when is_list(trades) do
    Enum.map(trades, &count_votes/1)
  end

  def count_votes(%Trade{trade_votes: []} = trade) do
    %{trade | yes_votes: 0, no_votes: 0}
  end

  def count_votes(%Trade{trade_votes: votes} = trade) do
    yes_votes = count_yes_votes(votes)
    no_votes = count_no_votes(votes)

    %{trade | yes_votes: yes_votes, no_votes: no_votes}
  end

  def get_teams_emails(trade) do
    trade.trade_line_items
    |> extract_emails()
    |> Enum.uniq()
    |> Enum.sort()
  end

  def get_teams_from_trade(trade) do
    Enum.reduce(trade.trade_line_items, [], fn item, acc ->
      teams = [item.gaining_team, item.losing_team]

      teams ++ acc
    end)
    |> Enum.uniq_by(& &1.id)
    |> Enum.sort_by(& &1.id)
  end

  def new_changeset(trade, params \\ %{}) do
    trade
    |> cast(params, [
      :status,
      :additional_terms,
      :submitted_by_team_id,
      :submitted_by_user_id
    ])
    |> validate_required([:status])
    |> validate_inclusion(:status, @status_options)
    |> cast_assoc(
      :trade_line_items,
      required: true,
      with: &TradeLineItem.assoc_changeset/2
    )
    |> cast_assoc(
      :trade_votes,
      required: false,
      with: &TradeVote.assoc_changeset/2
    )
  end

  def newest_first(query) do
    from(t in query, order_by: [desc: t.inserted_at])
  end

  def preload_assocs(query) do
    from(
      t in query,
      preload: [
        :submitted_by_user,
        submitted_by_team: [:fantasy_league],
        trade_votes: [
          :fantasy_team,
          :user
        ],
        trade_line_items: [
          gaining_team: [:fantasy_league, [owners: :user]],
          losing_team: [:fantasy_league, [owners: :user]],
          future_pick: [:original_team, :current_team],
          fantasy_player: :sports_league
        ]
      ]
    )
  end

  def status_options, do: @status_options

  ## Helpers

  ## count_votes

  defp count_yes_votes(votes), do: Enum.count(votes, &(&1.approve == true))

  defp count_no_votes(votes), do: Enum.count(votes, &(&1.approve == false))

  ## get_teams_emails

  defp extract_emails(trade_line_items) do
    Enum.reduce(trade_line_items, [], fn item, acc ->
      owners = item.gaining_team.owners ++ item.losing_team.owners

      emails = Enum.map(owners, &{&1.user.name, &1.user.email})

      emails ++ acc
    end)
  end
end
