require 'webrick'

root = File.expand_path '.'
server = WEBrick::HTTPServer.new :Port => 8000, :DocumentRoot => root
trap 'INT' do server.shutdown end

server.mount_proc '/stroke' do |req, res|
  system('osascript', 'keystroke.scpt', req.query['key'])
  res.body = 'ok'
end

server.start
