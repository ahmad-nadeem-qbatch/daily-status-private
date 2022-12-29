module Response
  def send_json_response(message, status_code)
    render json: { data: { message: message } }, status: status_code
  end
end