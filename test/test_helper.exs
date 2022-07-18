Mox.defmock(Wanda.Messaging.Adapters.Mock, for: Wanda.Messaging.Adapters.Behaviour)

Application.put_env(:wanda, Wanda.Messaging.Publisher, adapter: Wanda.Messaging.Adapters.Mock)

ExUnit.start(capture_log: true)
Faker.start()
