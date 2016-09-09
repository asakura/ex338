defmodule Ex338.FantasyPlayer do
  @moduledoc false

  use Ex338.Web, :model

  alias Ex338.{SportsLeague, DraftPick, Waiver, RosterPosition, FantasyTeam}

  schema "fantasy_players" do
    field :player_name, :string
    belongs_to :sports_league, SportsLeague
    has_many :roster_positions, RosterPosition
    has_many :fantasy_teams, through: [:roster_positions, :fantasy_team]
    has_many :draft_picks, DraftPick
    has_many :waiver_adds, Waiver, foreign_key: :add_fantasy_player_id
    has_many :waivers_drops, Waiver, foreign_key: :drop_fantasy_player_id

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:player_name, :sports_league_id])
    |> validate_required([:player_name, :sports_league_id])
  end

  def alphabetical_by_league(query) do
    from f in query,
      join: s in assoc(f, :sports_league),
      order_by: [s.league_name, f.player_name]
  end

  def names_and_ids(query) do
    from f in query, select: {f.player_name, f.id}
  end

  def available_players(fantasy_league_id) do
    from t in FantasyTeam,
    left_join: r in RosterPosition,
    on: r.fantasy_team_id == t.id and t.fantasy_league_id == ^fantasy_league_id,
    right_join: p in assoc(r, :fantasy_player),
    inner_join: s in assoc(p, :sports_league),
    where: is_nil(r.fantasy_team_id),
    select: %{player_name: p.player_name, league_abbrev: s.abbrev, id: p.id},
    order_by: [s.abbrev, p.player_name]
  end

  def format_players_for_select(players) do
    Enum.map(players, &(format_select(&1)))
  end

  defp format_select(%{player_name: name, league_abbrev: abbrev, id: id}) do
    {"#{name}, #{abbrev}", id}
  end
end
