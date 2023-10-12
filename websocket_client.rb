require 'faye/websocket'
require 'eventmachine'

def initialize_websocket(url, callback)
  EM.run do
    ws = Faye::WebSocket::Client.new(url)

    ws.on :open do |event|
      p 'WebSocket connection opened.'
    end

    ws.on :message do |event|
      data = JSON.parse(event.data)
      callback.call(data)
    end

    ws.on :close do |event|
      p 'WebSocket connection closed.'
    end
  end
end

# Callback para manejar los datos del WebSocket
def callback(data)
  p data
end
