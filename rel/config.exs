use Mix.Releases.Config,
  default_release: :purchasebot,
  default_environment: Mix.env()

environment :prod do
  set(include_erts: false)
  set(include_src: false)
  set(cookie: :"*=PXx;.5Sj^f|t4{X,>.wnM0m{O~wq~<VuX^Z^bt^Dg@a{~M$_7<}8[a&r|W>;96")

  set(
    overlays: [
      {:copy, "rel/etc/config.exs", "etc/config.exs"}
    ]
  )

  set(
    config_providers: [
      {Mix.Releases.Config.Providers.Elixir, ["${RELEASE_ROOT_DIR}/etc/config.exs"]}
    ]
  )
end

release :purchasebot do
  set(version: "0.1.0")

  set(
    applications: [
      :runtime_tools,
      _storage: :permanent,
      core: :permanent,
      tgbot: :permanent,
      web: :permanent
    ]
  )
end
