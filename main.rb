require_relative 'websocket_client'
require 'rest-client'
require 'json'
require 'pg'

@ticker_data = []
def handle_message(data)
  response = data['data']
  if response
    # Actualiza los valores de last_price en el array de hash ticker_data
    symbol = response['symbol']
    last_price = response['markPrice']
    @ticker_data.each do |ticker|
      if ticker[:ticker] == symbol
        ticker[:old_price] = ticker[:last_price] if ticker[:last_price] != 0 || ticker[:last_price] != nil
        ticker[:last_price] = last_price if last_price != nil
      end
    end
  end
end

# Función para obtener todos los tickers de Bybit
def get_all_tickers
  url = 'https://api.bybit.com/v5/market/tickers?category=linear'
  response = RestClient.get(url)
  if response.code == 200
    tickers = JSON.parse(response.body)
    tickers = tickers['result']['list'].map { |ticker| ticker['symbol'] }
    tickers = tickers.select { |ticker| ticker.include?('USDT') }

    # Crea el array de hash con los datos iniciales
    @ticker_data = tickers.map { |ticker| { ticker: ticker, old_price: 0, last_price: 0 } }
    tickers.map { |ticker| "tickers.#{ticker}" }
  else
    p "Error al obtener los tickers. Código de respuesta: #{response.code}"
    return nil
  end
end

def show_modified_tickers
  loop do
    sleep(5)  # espera 5 segundos
    modified_tickers = @ticker_data.select { |ticker| ticker[:old_price] != ticker[:last_price] }
    if modified_tickers.any?
      p "------------------------------------------------"
      p "Tickers modificados:"
      modified_tickers.each do |ticker| # generalmente muestra caaasi todos, aca podemos poner lo de la db pero no se si nos jode en cuanto a la infra
        p "Ticker: #{ticker[:ticker]}, Precio Anterior: #{ticker[:old_price]}, Precio Actual: #{ticker[:last_price]}"
        #conn.exec_params('UPDATE coins SET price = $1 WHERE ticker = $2', [ticker[:last_price], ticker[:ticker]]) #revisar esto, mi sql esta medio oxidado
      end
      p "tickers modificados: #{modified_tickers.count}/#{@ticker_data.count}"
    end
  end
end

#se me corto internet y no me acuerdo si esto estaba bien aca o tenia que ponerlo en el show

conn = PG.connect(
  dbname: 'db_socket', 
  user: 'mati',        
  password: '123456789',  
  host: 'localhost',          
  port: 5432                 # Creo que es el puerto por defecto, revisar
)



url = 'wss://stream.bybit.com/v5/public/linear'

#arranca un hilo que checkea los tickers modificados
Thread.new { show_modified_tickers }

# crea el websocket
@websocket = WebSocketClient.new(url, method(:handle_message), get_all_tickers)
@websocket.start

# crea el hilo principal y mantiene vivo el coso, pero al no usar mas el EM.run no se si es necesario, ahora uso solo el thread de arriba
#Thread.new { EM.run }