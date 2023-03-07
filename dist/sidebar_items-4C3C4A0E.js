sidebarNodes={"extras":[{"group":"","headers":[{"anchor":"modules","id":"Modules"}],"id":"api-reference","title":"API Reference"},{"group":"","headers":[{"anchor":"infrastructure","id":"Infrastructure"},{"anchor":"testing-executions","id":"Testing Executions"},{"anchor":"adding-new-checks","id":"Adding new Checks"}],"id":"readme","title":"Wanda"},{"group":"","headers":[],"id":"changelog","title":"CHANGELOG"},{"group":"","headers":[{"anchor":"opening-issues","id":"Opening issues"},{"anchor":"submitting-changes","id":"Submitting changes"}],"id":"contributing","title":"How to contribute"},{"group":"","headers":[{"anchor":"cheatsheet","id":"Cheatsheet"}],"id":"rhai_expressions_cheat_sheet","title":"Rhai expressions cheatsheet"},{"group":"Checks development","headers":[{"anchor":"introduction","id":"Introduction"},{"anchor":"checks-execution","id":"Checks Execution"},{"anchor":"anatomy-of-a-check","id":"Anatomy of a Check"},{"anchor":"facts","id":"Facts"},{"anchor":"values","id":"Values"},{"anchor":"expectations","id":"Expectations"},{"anchor":"expression-language","id":"Expression Language"},{"anchor":"best-practices-and-conventions","id":"Best practices and conventions"}],"id":"specification","title":"Checks Specification"},{"group":"Checks development","headers":[{"anchor":"introduction","id":"Introduction"},{"anchor":"types","id":"Types"},{"anchor":"logic-operators-and-boolean","id":"Logic Operators and Boolean"},{"anchor":"if-statement","id":"If Statement"},{"anchor":"arrays","id":"Arrays"},{"anchor":"maps","id":"Maps"},{"anchor":"rhai","id":"Rhai"}],"id":"expression_language","title":"Expression Language"},{"group":"Checks development","headers":[{"anchor":"introduction","id":"Introduction"},{"anchor":"available-gatherers","id":"Available Gatherers"}],"id":"gatherers","title":"Gatherers"},{"group":"Hack on Wanda","headers":[{"anchor":"requirements","id":"Requirements"},{"anchor":"development-environment","id":"Development environment"},{"anchor":"setup-wanda","id":"Setup Wanda"},{"anchor":"start-wanda-in-the-repl","id":"Start Wanda in the REPL"},{"anchor":"access-wanda-swaggerui","id":"Access Wanda Swaggerui"}],"id":"hack_on_wanda","title":"Hack on Wanda"}],"modules":[{"group":"","id":"Wanda.DataCase","nodeGroups":[{"key":"functions","name":"Functions","nodes":[{"anchor":"errors_on/1","id":"errors_on/1","title":"errors_on(changeset)"},{"anchor":"setup_sandbox/1","id":"setup_sandbox/1","title":"setup_sandbox(tags)"}]}],"sections":[],"title":"Wanda.DataCase"},{"group":"","id":"Wanda.Policy","nodeGroups":[{"key":"functions","name":"Functions","nodes":[{"anchor":"handle_event/1","id":"handle_event/1","title":"handle_event(event)"}]}],"sections":[],"title":"Wanda.Policy"},{"group":"","id":"Wanda.Release","nodeGroups":[{"key":"functions","name":"Functions","nodes":[{"anchor":"init/0","id":"init/0","title":"init()"},{"anchor":"migrate/0","id":"migrate/0","title":"migrate()"},{"anchor":"rollback/2","id":"rollback/2","title":"rollback(repo, version)"}]}],"sections":[],"title":"Wanda.Release"},{"group":"","id":"Wanda.Repo","nodeGroups":[{"key":"functions","name":"Functions","nodes":[{"anchor":"aggregate/3","id":"aggregate/3","title":"aggregate(queryable, aggregate, opts \\\\ [])"},{"anchor":"aggregate/4","id":"aggregate/4","title":"aggregate(queryable, aggregate, field, opts)"},{"anchor":"all/2","id":"all/2","title":"all(queryable, opts \\\\ [])"},{"anchor":"checked_out?/0","id":"checked_out?/0","title":"checked_out?()"},{"anchor":"checkout/2","id":"checkout/2","title":"checkout(fun, opts \\\\ [])"},{"anchor":"child_spec/1","id":"child_spec/1","title":"child_spec(opts)"},{"anchor":"config/0","id":"config/0","title":"config()"},{"anchor":"default_options/1","id":"default_options/1","title":"default_options(operation)"},{"anchor":"delete/2","id":"delete/2","title":"delete(struct, opts \\\\ [])"},{"anchor":"delete!/2","id":"delete!/2","title":"delete!(struct, opts \\\\ [])"},{"anchor":"delete_all/2","id":"delete_all/2","title":"delete_all(queryable, opts \\\\ [])"},{"anchor":"disconnect_all/2","id":"disconnect_all/2","title":"disconnect_all(interval, opts \\\\ [])"},{"anchor":"exists?/2","id":"exists?/2","title":"exists?(queryable, opts \\\\ [])"},{"anchor":"explain/3","id":"explain/3","title":"explain(operation, queryable, opts \\\\ [])"},{"anchor":"get/3","id":"get/3","title":"get(queryable, id, opts \\\\ [])"},{"anchor":"get!/3","id":"get!/3","title":"get!(queryable, id, opts \\\\ [])"},{"anchor":"get_by/3","id":"get_by/3","title":"get_by(queryable, clauses, opts \\\\ [])"},{"anchor":"get_by!/3","id":"get_by!/3","title":"get_by!(queryable, clauses, opts \\\\ [])"},{"anchor":"get_dynamic_repo/0","id":"get_dynamic_repo/0","title":"get_dynamic_repo()"},{"anchor":"in_transaction?/0","id":"in_transaction?/0","title":"in_transaction?()"},{"anchor":"insert/2","id":"insert/2","title":"insert(struct, opts \\\\ [])"},{"anchor":"insert!/2","id":"insert!/2","title":"insert!(struct, opts \\\\ [])"},{"anchor":"insert_all/3","id":"insert_all/3","title":"insert_all(schema_or_source, entries, opts \\\\ [])"},{"anchor":"insert_or_update/2","id":"insert_or_update/2","title":"insert_or_update(changeset, opts \\\\ [])"},{"anchor":"insert_or_update!/2","id":"insert_or_update!/2","title":"insert_or_update!(changeset, opts \\\\ [])"},{"anchor":"load/2","id":"load/2","title":"load(schema_or_types, data)"},{"anchor":"one/2","id":"one/2","title":"one(queryable, opts \\\\ [])"},{"anchor":"one!/2","id":"one!/2","title":"one!(queryable, opts \\\\ [])"},{"anchor":"preload/3","id":"preload/3","title":"preload(struct_or_structs_or_nil, preloads, opts \\\\ [])"},{"anchor":"prepare_query/3","id":"prepare_query/3","title":"prepare_query(operation, query, opts)"},{"anchor":"put_dynamic_repo/1","id":"put_dynamic_repo/1","title":"put_dynamic_repo(dynamic)"},{"anchor":"query/3","id":"query/3","title":"query(sql, params \\\\ [], opts \\\\ [])"},{"anchor":"query!/3","id":"query!/3","title":"query!(sql, params \\\\ [], opts \\\\ [])"},{"anchor":"query_many/3","id":"query_many/3","title":"query_many(sql, params \\\\ [], opts \\\\ [])"},{"anchor":"query_many!/3","id":"query_many!/3","title":"query_many!(sql, params \\\\ [], opts \\\\ [])"},{"anchor":"reload/2","id":"reload/2","title":"reload(queryable, opts \\\\ [])"},{"anchor":"reload!/2","id":"reload!/2","title":"reload!(queryable, opts \\\\ [])"},{"anchor":"rollback/1","id":"rollback/1","title":"rollback(value)"},{"anchor":"start_link/1","id":"start_link/1","title":"start_link(opts \\\\ [])"},{"anchor":"stop/1","id":"stop/1","title":"stop(timeout \\\\ 5000)"},{"anchor":"stream/2","id":"stream/2","title":"stream(queryable, opts \\\\ [])"},{"anchor":"to_sql/2","id":"to_sql/2","title":"to_sql(operation, queryable)"},{"anchor":"transaction/2","id":"transaction/2","title":"transaction(fun_or_multi, opts \\\\ [])"},{"anchor":"update/2","id":"update/2","title":"update(struct, opts \\\\ [])"},{"anchor":"update!/2","id":"update!/2","title":"update!(struct, opts \\\\ [])"},{"anchor":"update_all/3","id":"update_all/3","title":"update_all(queryable, updates, opts \\\\ [])"}]}],"sections":[],"title":"Wanda.Repo"},{"group":"Executions","id":"Wanda.Executions","nodeGroups":[{"key":"functions","name":"Functions","nodes":[{"anchor":"complete_execution!/2","id":"complete_execution!/2","title":"complete_execution!(execution_id, result)"},{"anchor":"count_executions/1","id":"count_executions/1","title":"count_executions(params)"},{"anchor":"create_execution!/3","id":"create_execution!/3","title":"create_execution!(execution_id, group_id, targets)"},{"anchor":"get_execution!/1","id":"get_execution!/1","title":"get_execution!(execution_id)"},{"anchor":"get_last_execution_by_group_id!/1","id":"get_last_execution_by_group_id!/1","title":"get_last_execution_by_group_id!(group_id)"},{"anchor":"list_executions/1","id":"list_executions/1","title":"list_executions(params \\\\ %{})"}]}],"sections":[],"title":"Wanda.Executions"},{"group":"Executions","id":"Wanda.Executions.AgentCheckError","nested_context":"Wanda.Executions","nested_title":".AgentCheckError","nodeGroups":[{"key":"types","name":"Types","nodes":[{"anchor":"t:t/0","id":"t/0","title":"t()"}]}],"sections":[],"title":"Wanda.Executions.AgentCheckError"},{"group":"Executions","id":"Wanda.Executions.AgentCheckResult","nested_context":"Wanda.Executions","nested_title":".AgentCheckResult","nodeGroups":[{"key":"types","name":"Types","nodes":[{"anchor":"t:t/0","id":"t/0","title":"t()"}]}],"sections":[],"title":"Wanda.Executions.AgentCheckResult"},{"group":"Executions","id":"Wanda.Executions.CheckResult","nested_context":"Wanda.Executions","nested_title":".CheckResult","nodeGroups":[{"key":"types","name":"Types","nodes":[{"anchor":"t:t/0","id":"t/0","title":"t()"}]}],"sections":[],"title":"Wanda.Executions.CheckResult"},{"group":"Executions","id":"Wanda.Executions.Evaluation","nested_context":"Wanda.Executions","nested_title":".Evaluation","nodeGroups":[{"key":"functions","name":"Functions","nodes":[{"anchor":"execute/6","id":"execute/6","title":"execute(execution_id, group_id, checks, gathered_facts, env, timeouts \\\\ [])"},{"anchor":"has_some_fact_gathering_error?/1","id":"has_some_fact_gathering_error?/1","title":"has_some_fact_gathering_error?(facts)"}]}],"sections":[],"title":"Wanda.Executions.Evaluation"},{"group":"Executions","id":"Wanda.Executions.Execution","nested_context":"Wanda.Executions","nested_title":".Execution","nodeGroups":[{"key":"types","name":"Types","nodes":[{"anchor":"t:t/0","id":"t/0","title":"t()"}]},{"key":"functions","name":"Functions","nodes":[{"anchor":"changeset/2","id":"changeset/2","title":"changeset(execution, params)"}]}],"sections":[],"title":"Wanda.Executions.Execution"},{"group":"Executions","id":"Wanda.Executions.Execution.Target","nested_context":"Wanda.Executions","nested_title":".Execution.Target","sections":[],"title":"Wanda.Executions.Execution.Target"},{"group":"Executions","id":"Wanda.Executions.ExpectationEvaluation","nested_context":"Wanda.Executions","nested_title":".ExpectationEvaluation","nodeGroups":[{"key":"types","name":"Types","nodes":[{"anchor":"t:t/0","id":"t/0","title":"t()"}]}],"sections":[],"title":"Wanda.Executions.ExpectationEvaluation"},{"group":"Executions","id":"Wanda.Executions.ExpectationEvaluationError","nested_context":"Wanda.Executions","nested_title":".ExpectationEvaluationError","nodeGroups":[{"key":"types","name":"Types","nodes":[{"anchor":"t:t/0","id":"t/0","title":"t()"}]}],"sections":[],"title":"Wanda.Executions.ExpectationEvaluationError"},{"group":"Executions","id":"Wanda.Executions.ExpectationResult","nested_context":"Wanda.Executions","nested_title":".ExpectationResult","nodeGroups":[{"key":"types","name":"Types","nodes":[{"anchor":"t:t/0","id":"t/0","title":"t()"}]}],"sections":[],"title":"Wanda.Executions.ExpectationResult"},{"group":"Executions","id":"Wanda.Executions.Fact","nested_context":"Wanda.Executions","nested_title":".Fact","nodeGroups":[{"key":"types","name":"Types","nodes":[{"anchor":"t:t/0","id":"t/0","title":"t()"}]}],"sections":[],"title":"Wanda.Executions.Fact"},{"group":"Executions","id":"Wanda.Executions.FactError","nested_context":"Wanda.Executions","nested_title":".FactError","nodeGroups":[{"key":"types","name":"Types","nodes":[{"anchor":"t:t/0","id":"t/0","title":"t()"}]}],"sections":[],"title":"Wanda.Executions.FactError"},{"group":"Executions","id":"Wanda.Executions.FakeEvaluation","nested_context":"Wanda.Executions","nested_title":".FakeEvaluation","nodeGroups":[{"key":"functions","name":"Functions","nodes":[{"anchor":"complete_fake_execution/4","id":"complete_fake_execution/4","title":"complete_fake_execution(execution_id, group_id, targets, checks)"}]}],"sections":[],"title":"Wanda.Executions.FakeEvaluation"},{"group":"Executions","id":"Wanda.Executions.FakeServer","nested_context":"Wanda.Executions","nested_title":".FakeServer","sections":[],"title":"Wanda.Executions.FakeServer"},{"group":"Executions","id":"Wanda.Executions.Gathering","nested_context":"Wanda.Executions","nested_title":".Gathering","nodeGroups":[{"key":"functions","name":"Functions","nodes":[{"anchor":"all_agents_sent_facts?/2","id":"all_agents_sent_facts?/2","title":"all_agents_sent_facts?(agents_gathered, targets)"},{"anchor":"put_gathered_facts/3","id":"put_gathered_facts/3","title":"put_gathered_facts(gathered_facts, agent_id, facts)"},{"anchor":"put_gathering_timeouts/2","id":"put_gathering_timeouts/2","title":"put_gathering_timeouts(gathered_facts, timed_out_agents)"},{"anchor":"target?/2","id":"target?/2","title":"target?(targets, agent_id)"}]}],"sections":[],"title":"Wanda.Executions.Gathering"},{"group":"Executions","id":"Wanda.Executions.Result","nested_context":"Wanda.Executions","nested_title":".Result","nodeGroups":[{"key":"types","name":"Types","nodes":[{"anchor":"t:t/0","id":"t/0","title":"t()"}]}],"sections":[],"title":"Wanda.Executions.Result"},{"group":"Executions","id":"Wanda.Executions.Server","nested_context":"Wanda.Executions","nested_title":".Server","nodeGroups":[{"key":"functions","name":"Functions","nodes":[{"anchor":"child_spec/1","id":"child_spec/1","title":"child_spec(init_arg)"},{"anchor":"start_execution/5","id":"start_execution/5","title":"start_execution(execution_id, group_id, targets, env, config \\\\ [])"},{"anchor":"start_link/1","id":"start_link/1","title":"start_link(opts)"}]}],"sections":[],"title":"Wanda.Executions.Server"},{"group":"Executions","id":"Wanda.Executions.ServerBehaviour","nested_context":"Wanda.Executions","nested_title":".ServerBehaviour","nodeGroups":[{"key":"callbacks","name":"Callbacks","nodes":[{"anchor":"c:receive_facts/4","id":"receive_facts/4","title":"receive_facts(execution_id, group_id, agent_id, facts)"},{"anchor":"c:start_execution/4","id":"start_execution/4","title":"start_execution(execution_id, group_id, targets, env)"},{"anchor":"c:start_execution/5","id":"start_execution/5","title":"start_execution(execution_id, group_id, targets, env, config)"}]}],"sections":[],"title":"Wanda.Executions.ServerBehaviour"},{"group":"Executions","id":"Wanda.Executions.State","nested_context":"Wanda.Executions","nested_title":".State","nodeGroups":[{"key":"types","name":"Types","nodes":[{"anchor":"t:t/0","id":"t/0","title":"t()"}]}],"sections":[],"title":"Wanda.Executions.State"},{"group":"Executions","id":"Wanda.Executions.Target","nested_context":"Wanda.Executions","nested_title":".Target","nodeGroups":[{"key":"types","name":"Types","nodes":[{"anchor":"t:t/0","id":"t/0","title":"t()"}]},{"key":"functions","name":"Functions","nodes":[{"anchor":"get_checks_from_targets/1","id":"get_checks_from_targets/1","title":"get_checks_from_targets(targets)"},{"anchor":"map_targets/1","id":"map_targets/1","title":"map_targets(map_list)"}]}],"sections":[],"title":"Wanda.Executions.Target"},{"group":"Executions","id":"Wanda.Executions.Value","nested_context":"Wanda.Executions","nested_title":".Value","nodeGroups":[{"key":"types","name":"Types","nodes":[{"anchor":"t:t/0","id":"t/0","title":"t()"}]}],"sections":[],"title":"Wanda.Executions.Value"},{"group":"Catalog","id":"Wanda.Catalog","nodeGroups":[{"key":"functions","name":"Functions","nodes":[{"anchor":"get_catalog/1","id":"get_catalog/1","title":"get_catalog(env \\\\ %{})"},{"anchor":"get_check/1","id":"get_check/1","title":"get_check(check_id)"},{"anchor":"get_checks/2","id":"get_checks/2","title":"get_checks(checks_id, env)"}]}],"sections":[],"title":"Wanda.Catalog"},{"group":"Catalog","id":"Wanda.Catalog.Check","nested_context":"Wanda.Catalog","nested_title":".Check","nodeGroups":[{"key":"types","name":"Types","nodes":[{"anchor":"t:t/0","id":"t/0","title":"t()"}]}],"sections":[],"title":"Wanda.Catalog.Check"},{"group":"Catalog","id":"Wanda.Catalog.Condition","nested_context":"Wanda.Catalog","nested_title":".Condition","nodeGroups":[{"key":"types","name":"Types","nodes":[{"anchor":"t:t/0","id":"t/0","title":"t()"}]}],"sections":[],"title":"Wanda.Catalog.Condition"},{"group":"Catalog","id":"Wanda.Catalog.Expectation","nested_context":"Wanda.Catalog","nested_title":".Expectation","nodeGroups":[{"key":"types","name":"Types","nodes":[{"anchor":"t:t/0","id":"t/0","title":"t()"}]}],"sections":[],"title":"Wanda.Catalog.Expectation"},{"group":"Catalog","id":"Wanda.Catalog.Fact","nested_context":"Wanda.Catalog","nested_title":".Fact","nodeGroups":[{"key":"types","name":"Types","nodes":[{"anchor":"t:t/0","id":"t/0","title":"t()"}]}],"sections":[],"title":"Wanda.Catalog.Fact"},{"group":"Catalog","id":"Wanda.Catalog.Value","nested_context":"Wanda.Catalog","nested_title":".Value","nodeGroups":[{"key":"types","name":"Types","nodes":[{"anchor":"t:t/0","id":"t/0","title":"t()"}]}],"sections":[],"title":"Wanda.Catalog.Value"},{"group":"Messaging","id":"Wanda.Messaging","nodeGroups":[{"key":"functions","name":"Functions","nodes":[{"anchor":"publish/2","id":"publish/2","title":"publish(topic, message)"}]}],"sections":[],"title":"Wanda.Messaging"},{"group":"Messaging","id":"Wanda.Messaging.Adapters.AMQP","nested_context":"Wanda.Messaging","nested_title":".Adapters.AMQP","sections":[],"title":"Wanda.Messaging.Adapters.AMQP"},{"group":"Messaging","id":"Wanda.Messaging.Adapters.AMQP.Consumer","nested_context":"Wanda.Messaging","nested_title":".Adapters.AMQP.Consumer","nodeGroups":[{"key":"functions","name":"Functions","nodes":[{"anchor":"child_spec/1","id":"child_spec/1","title":"child_spec(opts)"},{"anchor":"start_link/1","id":"start_link/1","title":"start_link(opts)"}]}],"sections":[],"title":"Wanda.Messaging.Adapters.AMQP.Consumer"},{"group":"Messaging","id":"Wanda.Messaging.Adapters.AMQP.Processor","nested_context":"Wanda.Messaging","nested_title":".Adapters.AMQP.Processor","nodeGroups":[{"key":"functions","name":"Functions","nodes":[{"anchor":"process/1","id":"process/1","title":"process(message)"}]}],"sections":[],"title":"Wanda.Messaging.Adapters.AMQP.Processor"},{"group":"Messaging","id":"Wanda.Messaging.Adapters.AMQP.Publisher","nested_context":"Wanda.Messaging","nested_title":".Adapters.AMQP.Publisher","nodeGroups":[{"key":"functions","name":"Functions","nodes":[{"anchor":"child_spec/1","id":"child_spec/1","title":"child_spec(opts)"},{"anchor":"init/0","id":"init/0","title":"init()"},{"anchor":"publish_message/2","id":"publish_message/2","title":"publish_message(message, routing_key \\\\ \"\")"},{"anchor":"start_link/1","id":"start_link/1","title":"start_link(opts)"}]}],"sections":[],"title":"Wanda.Messaging.Adapters.AMQP.Publisher"},{"group":"Messaging","id":"Wanda.Messaging.Mapper","nested_context":"Wanda.Messaging","nested_title":".Mapper","nodeGroups":[{"key":"functions","name":"Functions","nodes":[{"anchor":"from_execution_requested/1","id":"from_execution_requested/1","title":"from_execution_requested(execution_requested)"},{"anchor":"from_facts_gathererd/1","id":"from_facts_gathererd/1","title":"from_facts_gathererd(facts_gathered)"},{"anchor":"to_execution_completed/1","id":"to_execution_completed/1","title":"to_execution_completed(result)"},{"anchor":"to_execution_started/3","id":"to_execution_started/3","title":"to_execution_started(execution_id, group_id, targets)"},{"anchor":"to_facts_gathering_requested/4","id":"to_facts_gathering_requested/4","title":"to_facts_gathering_requested(execution_id, group_id, targets, checks)"}]}],"sections":[],"title":"Wanda.Messaging.Mapper"},{"group":"Web","id":"WandaWeb","nodeGroups":[{"key":"functions","name":"Functions","nodes":[{"anchor":"__using__/1","id":"__using__/1","title":"__using__(which)"},{"anchor":"channel/0","id":"channel/0","title":"channel()"},{"anchor":"controller/0","id":"controller/0","title":"controller()"},{"anchor":"router/0","id":"router/0","title":"router()"},{"anchor":"view/0","id":"view/0","title":"view()"}]}],"sections":[],"title":"WandaWeb"},{"group":"Web","id":"WandaWeb.Auth.AccessToken","nested_context":"WandaWeb","nested_title":".Auth.AccessToken","nodeGroups":[{"key":"functions","name":"Functions","nodes":[{"anchor":"generate_and_sign/2","id":"generate_and_sign/2","title":"generate_and_sign(extra_claims \\\\ %{}, key \\\\ __default_signer__())"},{"anchor":"generate_and_sign!/2","id":"generate_and_sign!/2","title":"generate_and_sign!(extra_claims \\\\ %{}, key \\\\ __default_signer__())"},{"anchor":"verify_and_validate/3","id":"verify_and_validate/3","title":"verify_and_validate(bearer_token, key \\\\ __default_signer__(), context \\\\ %{})"},{"anchor":"verify_and_validate!/3","id":"verify_and_validate!/3","title":"verify_and_validate!(bearer_token, key \\\\ __default_signer__(), context \\\\ %{})"}]}],"sections":[],"title":"WandaWeb.Auth.AccessToken"},{"group":"Web","id":"WandaWeb.Auth.JWTAuthPlug","nested_context":"WandaWeb","nested_title":".Auth.JWTAuthPlug","nodeGroups":[{"key":"functions","name":"Functions","nodes":[{"anchor":"call/2","id":"call/2","title":"call(conn, _)"},{"anchor":"init/1","id":"init/1","title":"init(opts)"}]}],"sections":[],"title":"WandaWeb.Auth.JWTAuthPlug"},{"group":"Web","id":"WandaWeb.ConnCase","nested_context":"WandaWeb","nested_title":".ConnCase","sections":[],"title":"WandaWeb.ConnCase"},{"group":"Web","id":"WandaWeb.Endpoint","nested_context":"WandaWeb","nested_title":".Endpoint","nodeGroups":[{"key":"functions","name":"Functions","nodes":[{"anchor":"broadcast/3","id":"broadcast/3","title":"broadcast(topic, event, msg)"},{"anchor":"broadcast!/3","id":"broadcast!/3","title":"broadcast!(topic, event, msg)"},{"anchor":"broadcast_from/4","id":"broadcast_from/4","title":"broadcast_from(from, topic, event, msg)"},{"anchor":"broadcast_from!/4","id":"broadcast_from!/4","title":"broadcast_from!(from, topic, event, msg)"},{"anchor":"call/2","id":"call/2","title":"call(conn, opts)"},{"anchor":"child_spec/1","id":"child_spec/1","title":"child_spec(opts)"},{"anchor":"config/2","id":"config/2","title":"config(key, default \\\\ nil)"},{"anchor":"config_change/2","id":"config_change/2","title":"config_change(changed, removed)"},{"anchor":"host/0","id":"host/0","title":"host()"},{"anchor":"init/1","id":"init/1","title":"init(opts)"},{"anchor":"local_broadcast/3","id":"local_broadcast/3","title":"local_broadcast(topic, event, msg)"},{"anchor":"local_broadcast_from/4","id":"local_broadcast_from/4","title":"local_broadcast_from(from, topic, event, msg)"},{"anchor":"path/1","id":"path/1","title":"path(path)"},{"anchor":"script_name/0","id":"script_name/0","title":"script_name()"},{"anchor":"start_link/1","id":"start_link/1","title":"start_link(opts \\\\ [])"},{"anchor":"static_integrity/1","id":"static_integrity/1","title":"static_integrity(path)"},{"anchor":"static_lookup/1","id":"static_lookup/1","title":"static_lookup(path)"},{"anchor":"static_path/1","id":"static_path/1","title":"static_path(path)"},{"anchor":"static_url/0","id":"static_url/0","title":"static_url()"},{"anchor":"struct_url/0","id":"struct_url/0","title":"struct_url()"},{"anchor":"subscribe/2","id":"subscribe/2","title":"subscribe(topic, opts \\\\ [])"},{"anchor":"unsubscribe/1","id":"unsubscribe/1","title":"unsubscribe(topic)"},{"anchor":"url/0","id":"url/0","title":"url()"}]}],"sections":[],"title":"WandaWeb.Endpoint"},{"group":"Web","id":"WandaWeb.ErrorHelpers","nested_context":"WandaWeb","nested_title":".ErrorHelpers","nodeGroups":[{"key":"functions","name":"Functions","nodes":[{"anchor":"translate_error/1","id":"translate_error/1","title":"translate_error(arg)"}]}],"sections":[],"title":"WandaWeb.ErrorHelpers"},{"group":"Web","id":"WandaWeb.ErrorView","nested_context":"WandaWeb","nested_title":".ErrorView","nodeGroups":[{"key":"functions","name":"Functions","nodes":[{"anchor":"__resource__/0","id":"__resource__/0","title":"__resource__()"},{"anchor":"render/2","id":"render/2","title":"render(template, assigns \\\\ %{})"},{"anchor":"template_not_found/2","id":"template_not_found/2","title":"template_not_found(template, assigns)"}]}],"sections":[],"title":"WandaWeb.ErrorView"},{"group":"Web","id":"WandaWeb.Plugs.ApiRedirector","nested_context":"WandaWeb","nested_title":".Plugs.ApiRedirector","sections":[],"title":"WandaWeb.Plugs.ApiRedirector"},{"group":"Web","id":"WandaWeb.Router","nested_context":"WandaWeb","nested_title":".Router","nodeGroups":[{"key":"functions","name":"Functions","nodes":[{"anchor":"api/2","id":"api/2","title":"api(conn, _)"},{"anchor":"call/2","id":"call/2","title":"call(conn, opts)"},{"anchor":"init/1","id":"init/1","title":"init(opts)"},{"anchor":"protected_api/2","id":"protected_api/2","title":"protected_api(conn, _)"}]}],"sections":[],"title":"WandaWeb.Router"},{"group":"Web","id":"WandaWeb.Router.Helpers","nested_context":"WandaWeb","nested_title":".Router.Helpers","nodeGroups":[{"key":"functions","name":"Functions","nodes":[{"anchor":"api_redirector_path/3","id":"api_redirector_path/3","title":"api_redirector_path(conn_or_endpoint, action, path)"},{"anchor":"api_redirector_path/4","id":"api_redirector_path/4","title":"api_redirector_path(conn_or_endpoint, action, path, params)"},{"anchor":"api_redirector_url/3","id":"api_redirector_url/3","title":"api_redirector_url(conn_or_endpoint, action, path)"},{"anchor":"api_redirector_url/4","id":"api_redirector_url/4","title":"api_redirector_url(conn_or_endpoint, action, path, params)"},{"anchor":"catalog_path/2","id":"catalog_path/2","title":"catalog_path(conn_or_endpoint, action)"},{"anchor":"catalog_path/3","id":"catalog_path/3","title":"catalog_path(conn_or_endpoint, action, params)"},{"anchor":"catalog_url/2","id":"catalog_url/2","title":"catalog_url(conn_or_endpoint, action)"},{"anchor":"catalog_url/3","id":"catalog_url/3","title":"catalog_url(conn_or_endpoint, action, params)"},{"anchor":"execution_path/2","id":"execution_path/2","title":"execution_path(conn_or_endpoint, action)"},{"anchor":"execution_path/3","id":"execution_path/3","title":"execution_path(conn_or_endpoint, action, params)"},{"anchor":"execution_path/4","id":"execution_path/4","title":"execution_path(conn_or_endpoint, action, id, params)"},{"anchor":"execution_url/2","id":"execution_url/2","title":"execution_url(conn_or_endpoint, action)"},{"anchor":"execution_url/3","id":"execution_url/3","title":"execution_url(conn_or_endpoint, action, params)"},{"anchor":"execution_url/4","id":"execution_url/4","title":"execution_url(conn_or_endpoint, action, id, params)"},{"anchor":"path/2","id":"path/2","title":"path(data, path)"},{"anchor":"render_spec_path/2","id":"render_spec_path/2","title":"render_spec_path(conn_or_endpoint, action)"},{"anchor":"render_spec_path/3","id":"render_spec_path/3","title":"render_spec_path(conn_or_endpoint, action, params)"},{"anchor":"render_spec_url/2","id":"render_spec_url/2","title":"render_spec_url(conn_or_endpoint, action)"},{"anchor":"render_spec_url/3","id":"render_spec_url/3","title":"render_spec_url(conn_or_endpoint, action, params)"},{"anchor":"static_integrity/2","id":"static_integrity/2","title":"static_integrity(endpoint, path)"},{"anchor":"static_path/2","id":"static_path/2","title":"static_path(conn, path)"},{"anchor":"static_url/2","id":"static_url/2","title":"static_url(conn, path)"},{"anchor":"swagger_ui_path/2","id":"swagger_ui_path/2","title":"swagger_ui_path(conn_or_endpoint, action)"},{"anchor":"swagger_ui_path/3","id":"swagger_ui_path/3","title":"swagger_ui_path(conn_or_endpoint, action, params)"},{"anchor":"swagger_ui_url/2","id":"swagger_ui_url/2","title":"swagger_ui_url(conn_or_endpoint, action)"},{"anchor":"swagger_ui_url/3","id":"swagger_ui_url/3","title":"swagger_ui_url(conn_or_endpoint, action, params)"},{"anchor":"url/1","id":"url/1","title":"url(data)"}]}],"sections":[],"title":"WandaWeb.Router.Helpers"},{"group":"Web","id":"WandaWeb.Schemas.AcceptedExecutionResponse","nested_context":"WandaWeb","nested_title":".Schemas.AcceptedExecutionResponse","nodeGroups":[{"key":"types","name":"Types","nodes":[{"anchor":"t:t/0","id":"t/0","title":"t()"}]},{"key":"functions","name":"Functions","nodes":[{"anchor":"schema/0","id":"schema/0","title":"schema()"}]}],"sections":[],"title":"WandaWeb.Schemas.AcceptedExecutionResponse"},{"group":"Web","id":"WandaWeb.Schemas.CatalogResponse","nested_context":"WandaWeb","nested_title":".Schemas.CatalogResponse","nodeGroups":[{"key":"types","name":"Types","nodes":[{"anchor":"t:t/0","id":"t/0","title":"t()"}]},{"key":"functions","name":"Functions","nodes":[{"anchor":"schema/0","id":"schema/0","title":"schema()"}]}],"sections":[],"title":"WandaWeb.Schemas.CatalogResponse"},{"group":"Web","id":"WandaWeb.Schemas.CatalogResponse.Check","nested_context":"WandaWeb","nested_title":".Schemas.CatalogResponse.Check","nodeGroups":[{"key":"types","name":"Types","nodes":[{"anchor":"t:t/0","id":"t/0","title":"t()"}]},{"key":"functions","name":"Functions","nodes":[{"anchor":"schema/0","id":"schema/0","title":"schema()"}]}],"sections":[],"title":"WandaWeb.Schemas.CatalogResponse.Check"},{"group":"Web","id":"WandaWeb.Schemas.ExecutionResponse","nested_context":"WandaWeb","nested_title":".Schemas.ExecutionResponse","nodeGroups":[{"key":"types","name":"Types","nodes":[{"anchor":"t:t/0","id":"t/0","title":"t()"}]},{"key":"functions","name":"Functions","nodes":[{"anchor":"schema/0","id":"schema/0","title":"schema()"}]}],"sections":[],"title":"WandaWeb.Schemas.ExecutionResponse"},{"group":"Web","id":"WandaWeb.Schemas.ListExecutionsResponse","nested_context":"WandaWeb","nested_title":".Schemas.ListExecutionsResponse","nodeGroups":[{"key":"types","name":"Types","nodes":[{"anchor":"t:t/0","id":"t/0","title":"t()"}]},{"key":"functions","name":"Functions","nodes":[{"anchor":"schema/0","id":"schema/0","title":"schema()"}]}],"sections":[],"title":"WandaWeb.Schemas.ListExecutionsResponse"},{"group":"Web","id":"WandaWeb.Schemas.StartExecutionRequest","nested_context":"WandaWeb","nested_title":".Schemas.StartExecutionRequest","nodeGroups":[{"key":"types","name":"Types","nodes":[{"anchor":"t:t/0","id":"t/0","title":"t()"}]},{"key":"functions","name":"Functions","nodes":[{"anchor":"schema/0","id":"schema/0","title":"schema()"}]}],"sections":[],"title":"WandaWeb.Schemas.StartExecutionRequest"},{"group":"Web","id":"WandaWeb.V1.CatalogController","nested_context":"WandaWeb","nested_title":".V1.CatalogController","nodeGroups":[{"key":"functions","name":"Functions","nodes":[{"anchor":"catalog/2","id":"catalog/2","title":"catalog(conn, params)"},{"anchor":"open_api_operation/1","id":"open_api_operation/1","title":"open_api_operation(action)"},{"anchor":"shared_security/0","id":"shared_security/0","title":"shared_security()"},{"anchor":"shared_tags/0","id":"shared_tags/0","title":"shared_tags()"}]}],"sections":[],"title":"WandaWeb.V1.CatalogController"},{"group":"Web","id":"WandaWeb.V1.CatalogView","nested_context":"WandaWeb","nested_title":".V1.CatalogView","nodeGroups":[{"key":"functions","name":"Functions","nodes":[{"anchor":"__resource__/0","id":"__resource__/0","title":"__resource__()"},{"anchor":"render/2","id":"render/2","title":"render(template, assigns \\\\ %{})"},{"anchor":"template_not_found/2","id":"template_not_found/2","title":"template_not_found(template, assigns)"}]}],"sections":[],"title":"WandaWeb.V1.CatalogView"},{"group":"Web","id":"WandaWeb.V1.ExecutionController","nested_context":"WandaWeb","nested_title":".V1.ExecutionController","nodeGroups":[{"key":"functions","name":"Functions","nodes":[{"anchor":"index/2","id":"index/2","title":"index(conn, params)"},{"anchor":"last/2","id":"last/2","title":"last(conn, map)"},{"anchor":"open_api_operation/1","id":"open_api_operation/1","title":"open_api_operation(action)"},{"anchor":"shared_security/0","id":"shared_security/0","title":"shared_security()"},{"anchor":"shared_tags/0","id":"shared_tags/0","title":"shared_tags()"},{"anchor":"show/2","id":"show/2","title":"show(conn, map)"},{"anchor":"start/2","id":"start/2","title":"start(conn, params)"}]}],"sections":[],"title":"WandaWeb.V1.ExecutionController"},{"group":"Web","id":"WandaWeb.V1.ExecutionView","nested_context":"WandaWeb","nested_title":".V1.ExecutionView","nodeGroups":[{"key":"functions","name":"Functions","nodes":[{"anchor":"__resource__/0","id":"__resource__/0","title":"__resource__()"},{"anchor":"render/2","id":"render/2","title":"render(template, assigns \\\\ %{})"},{"anchor":"template_not_found/2","id":"template_not_found/2","title":"template_not_found(template, assigns)"}]}],"sections":[],"title":"WandaWeb.V1.ExecutionView"}],"tasks":[]}