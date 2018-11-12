defmodule Ex338Web.Router do
  use Ex338Web, :router
  use ExAdmin.Router
  use Coherence.Router
  use Honeybadger.Plug

  pipeline :browser do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:fetch_flash)
    plug(:protect_from_forgery)
    plug(:put_secure_browser_headers)
    plug(Coherence.Authentication.Session)
  end

  pipeline :protected do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:fetch_flash)
    plug(:protect_from_forgery)
    plug(:put_secure_browser_headers)
    plug(Coherence.Authentication.Session, protected: true)
  end

  pipeline :admin do
    plug(:authorize_admin)
  end

  pipeline :load_leagues do
    plug(Ex338Web.LoadLeagues)
  end

  pipeline :api do
    plug(:accepts, ["json"])
  end

  scope "/" do
    pipe_through(:browser)
    coherence_routes()
  end

  scope "/" do
    pipe_through([:protected, :load_leagues])
    coherence_routes(:protected)
  end

  scope "/", Ex338Web do
    pipe_through([:protected, :load_leagues])

    resources "/fantasy_leagues", FantasyLeagueController, only: [:show] do
      resources("/championships", ChampionshipController, only: [:index, :show])
      resources("/fantasy_teams", FantasyTeamController, only: [:index])
      resources("/fantasy_players", FantasyPlayerController, only: [:index])
      resources("/owners", OwnerController, only: [:index])
      resources("/draft_picks", DraftPickController, only: [:index])
      resources("/waivers", WaiverController, only: [:index])
      resources("/trades", TradeController, only: [:index])
      resources("/injured_reserves", InjuredReserveController, only: [:index])
    end

    resources "/fantasy_teams", FantasyTeamController, only: [:show, :edit, :update] do
      resources("/draft_queues", DraftQueueController, only: [:new, :create])
      resources("/trade_votes", TradeVoteController, only: [:create])
      resources("/trades", TradeController, only: [:new, :create])
      resources("/waivers", WaiverController, only: [:new, :create])
    end

    resources("/archived_leagues", ArchivedLeagueController, only: [:index])
    resources("/draft_picks", DraftPickController, only: [:edit, :update])
    resources("/in_season_draft_picks", InSeasonDraftPickController, only: [:edit, :update])
    resources("/waivers", WaiverController, only: [:edit, :update])
    resources("/users", UserController, only: [:edit, :show, :update])

    get("/2017_rules", PageController, :rules_2017)
    get("/2018_rules", PageController, :rules_2018)
    get("/2019_rules", PageController, :rules_2019)
    get("/", PageController, :index)
  end

  scope "/", Ex338Web do
    pipe_through([:protected, :admin, :load_leagues])
    resources("/commish_email", CommishEmailController, only: [:new, :create])
    resources("/table_upload", TableUploadController, only: [:new, :create])
    resources("/waiver_admin", WaiverAdminController, only: [:edit, :update])

    resources "/fantasy_leagues", FantasyLeagueController, only: [] do
      resources("/championship_slot_admin", ChampionshipSlotAdminController, only: [:create])
      resources("/injured_reserve_admin", InjuredReserveAdminController, only: [:update])
      resources("/in_season_draft_order", InSeasonDraftOrderController, only: [:create])
      resources("/trade_admin", TradeAdminController, only: [:update])
    end
  end

  scope "/admin", ExAdmin do
    pipe_through([:protected, :admin])
    admin_routes()
  end

  if Mix.env() == :dev do
    scope "/dev" do
      pipe_through([:browser])

      forward("/mailbox", Plug.Swoosh.MailboxPreview, base_path: "/dev/mailbox")
    end
  end

  # Other scopes may use custom stacks.
  # scope "/api", Ex338Web do
  #   pipe_through :api
  # end
end
