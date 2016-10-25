defmodule Ex338.FantasyPlayer do
  @moduledoc false

  use Ex338.Web, :model

  alias Ex338.{SportsLeague, DraftPick, Waiver, RosterPosition, FantasyTeam,
               Repo, FantasyPlayer}

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

  def get_available_players(fantasy_league_id) do
    fantasy_league_id
    |> available_players
    |> Repo.all
  end

  def get_overall_waiver_deadline(fantasy_player_id) do
    query = from p in FantasyPlayer,
      inner_join: s in assoc(p, :sports_league),
      inner_join: c in assoc(s, :championships),
      where: p.id == ^fantasy_player_id,
      where: c.category == "overall",
      limit: 1,
      select: c.waiver_deadline_at

    Repo.one(query)
  end

  def available_players(fantasy_league_id) do
    from t in FantasyTeam,
    left_join: r in RosterPosition,
    on: r.fantasy_team_id == t.id and r.status == "active" and
      t.fantasy_league_id == ^fantasy_league_id,
    right_join: p in assoc(r, :fantasy_player),
    inner_join: s in assoc(p, :sports_league),
    where: is_nil(r.fantasy_team_id),
    select: %{player_name: p.player_name, league_abbrev: s.abbrev, id: p.id},
    order_by: [s.abbrev, p.player_name]
  end
end
