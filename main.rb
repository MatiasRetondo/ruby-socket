require_relative 'websocket_client'

url = 'wss://stream-testnet.bybit.com/v5/public/linear'

# Callback para manejar los datos del WebSocket
def callback(data)
  p data
end

# Inicializa el WebSocket
initialize_websocket(url, method(:callback))
