class TxSecret
  attr_reader :username, :password, :organization

  def initialize(username: 'api', password: '', organization: '')
    @username     = username
    @password     = password
    @organization = organization
  end
end
