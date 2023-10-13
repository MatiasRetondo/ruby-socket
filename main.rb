require_relative 'websocket_client'
require 'rest-client'
require 'json'

def handle_message(data)
  response = data['data']
  if response
    p "Symbol: #{response['symbol']}, Mark Price: #{response['markPrice']}" if response['markPrice']
  end
end

# Función para obtener todos los tickers de Bybit
def get_all_tickers
  url = 'https://api.bybit.com//v5/market/tickers?category=linear'
  response = RestClient.get(url)
  if response.code == 200
    tickers = JSON.parse(response.body)
    tickers = tickers['result']['list'].map { |ticker| ticker['symbol'] }
    tickers = tickers.select { |ticker| ticker.include?('USDT') }
    return tickers
  else
    p "Error al obtener los tickers. Código de respuesta: #{response.code}"
    return nil
  end
end

def format_tickers(tickers)
  tickers.map { |ticker| "tickers.#{ticker}" }
end


all_tickers = format_tickers(get_all_tickers)
url = 'wss://stream.bybit.com/v5/public/linear'


# Initialize and start the WebSocket client
@websocket = WebSocketClient.new(url, method(:handle_message), all_tickers)
@websocket.start
# Esto lo deja en loop
Thread.new { EM.run }
