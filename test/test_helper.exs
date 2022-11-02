Mox.defmock(Wanda.Messaging.Adapters.Mock, for: Wanda.Messaging.Adapters.Behaviour)
Application.put_env(:wanda, :messaging, adapter: Wanda.Messaging.Adapters.Mock)

Mox.defmock(Wanda.Executions.ServerMock, for: Wanda.Executions.ServerBehaviour)
Application.put_env(:wanda, Wanda.Policy, execution_server_impl: Wanda.Executions.ServerMock)

Mox.defmock(GenRMQ.Processor.Mock, for: GenRMQ.Processor)

ExUnit.start(capture_log: true)
Faker.start()

Ecto.Adapters.SQL.Sandbox.mode(Wanda.Repo, :manual)
