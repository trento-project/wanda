Mox.defmock(Wanda.Messaging.Adapters.Mock, for: Wanda.Messaging.Adapters.Behaviour)

Application.put_env(:wanda, :messaging, adapter: Wanda.Messaging.Adapters.Mock)

ExUnit.start(capture_log: true)
Faker.start()
