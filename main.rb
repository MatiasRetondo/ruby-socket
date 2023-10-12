require_relative 'websocket_client'

@cont = 0
@priceBTC = 0
@priceETH = 0
def handle_message(data)
  response = data['data']
  if response
    @cont += 1 if response['markPrice']
    p @cont
    @priceBTC = response['markPrice'] if response['symbol'] == 'BTCUSDT' && response['markPrice']
    @priceETH = response['markPrice'] if response['symbol'] == 'ETHUSDT' && response['markPrice']
    p "BTC: #{@priceBTC}"
    p "ETH: #{@priceETH}"
  end

  if @cont == 10
    @websocket.close_websocket
    EM.stop
  end
end

url = 'wss://stream.bybit.com/v5/public/linear'

# Initialize and start the WebSocket client
@websocket = WebSocketClient.new(url, method(:handle_message))
@websocket.start

# Esto lo deja en loop
Thread.new { EM.run }
