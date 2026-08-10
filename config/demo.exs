# SPDX-FileCopyrightText: SUSE LLC
# SPDX-License-Identifier: Apache-2.0

import Config

config :wanda, WandaWeb.Endpoint,
  check_origin: :conn,
  cache_static_manifest: "priv/static/cache_manifest.json",
  server: true

config :wanda, Wanda.Executions.Server, facts_gathering_impl: Wanda.Executions.FactsGathering.Fake
config :wanda, Wanda.Executions.FakeGatheredFacts, demo_facts_config: "priv/demo/fake_facts.yaml"
