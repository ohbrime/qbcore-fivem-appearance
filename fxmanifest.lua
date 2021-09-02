fx_version "cerulean"
game { "gta5" }

server_scripts {
  'server.lua',
}

client_scripts {
  'typescript/build/client.js',
  'client.lua',
  'config.lua',
}

files {
  'ui/build/index.html',
  'ui/build/static/js/*.js',
  'locales/*.json',
  'peds.json'
}

ui_page 'ui/build/index.html'