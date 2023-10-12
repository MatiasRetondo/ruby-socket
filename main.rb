require_relative 'websocket_client'

@cont = 0
def handle_message(data)
  response = data['data']
  if response
    @cont += 1
    p @cont
    p "Symbol: #{response['symbol']} ,Price: #{response['markPrice']}, 24Hs Change: #{response['price24hPcnt']}"
  end

  if @cont == 10
    @websocket.close_websocket
    EM.stop
  end
end

url = 'wss://stream.bybit.com/v5/public/linear'
symbol = 'BTCUSDT'  #ver si esto puede ser una lista

# Initialize and start the WebSocket client
@websocket = WebSocketClient.new(url, symbol, method(:handle_message))
@websocket.start

# Esto lo deja en loop
Thread.new { EM.run }
