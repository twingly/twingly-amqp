require_relative "../lib/twingly/amqp/pinger"

pinger = Twingly::AMQP::Pinger.new(
  queue_name:      "ping",
  ping_expiration: 2_000,
)

pinger.default_ping_options do |options|
  options.provider_name = "TestProvider"
  options.source_ip     = "1.3.3.7"
  options.priority      = 1
end

urls = [
  "https://blog.twingly.com",
]

pinger.ping(urls) do |pinged_url|
  puts "Pinged: #{pinged_url}!"
end
