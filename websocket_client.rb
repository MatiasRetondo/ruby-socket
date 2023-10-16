require 'faye/websocket'
require 'eventmachine'
require 'json'

class WebSocketClient
  def initialize(url, callback, tickers)
    @url = url
    @callback = callback
    @tickers = tickers
  end

  def start
    EM.run do
      @ws = Faye::WebSocket::Client.new(@url)

      @ws.on :open do   #cuando se abre la conexion
        puts 'WebSocket connection opened.'
        subscription_message = {
          "op": "subscribe",
          "args": @tickers
      }
      @ws.send(JSON.generate(subscription_message)) #envia el mensaje de suscripcion
      end

      @ws.on :message do |event|  #cuando llega un mensaje le pega al callback que esta en main
        data = JSON.parse(event.data)
        @callback.call(data)
      end

      @ws.on :close do |event|  #cierra la conexion
        p 'WebSocket connection closed.'
        @ws = nil
      end
    end
  end

  def close_websocket
    return unless @ws
    @ws.close
  end
end
