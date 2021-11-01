fx_version 'cerulean'
game 'gta5'

author 'Brime'
version '1.3.0'

shared_script 'config.lua'

client_scripts {
  'typescript/build/client.js',
  'client.lua',
}

server_script 'server.lua'

ui_page 'ui/build/index.html'

files {
  'ui/build/index.html',
  'ui/build/static/js/*.js',
  'locales/*.json',
  'peds.json',
}