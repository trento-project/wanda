Mox.defmock(Wanda.Messaging.Adapters.Mock, for: Wanda.Messaging.Adapters.Behaviour)
Application.put_env(:wanda, :messaging, adapter: Wanda.Messaging.Adapters.Mock)

Mox.defmock(Wanda.Execution.Mock, for: Wanda.Execution.Behaviour)
Application.put_env(:wanda, Wanda.Policy, execution_impl: Wanda.Execution.Mock)

ExUnit.start(capture_log: true)
Faker.start()
