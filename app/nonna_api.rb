URL = ENV['API_URL'] || 'http://webapp:3000'

class NonnaApi
  def obtener_version
    response = Faraday.get("#{URL}/health")
    body_hash = JSON.parse(response.body)
    body_hash['version']
  end
end
