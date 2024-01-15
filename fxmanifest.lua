fx_version 'cerulean'
game 'gta5'

description 'pengu_gruppe6delivery'
version '1.0.2'

shared_scripts {
	'config.lua',
	'@ox_lib/init.lua', -- If you use OX Dialog uncomment this.

}

client_script {

	'@PolyZone/client.lua',
	'@PolyZone/BoxZone.lua',
	'@PolyZone/EntityZone.lua',
	'@PolyZone/CircleZone.lua',
	'@PolyZone/ComboZone.lua',
	'client/delivery.lua',
	'client/organize.lua',
	'client/robbery.lua'
}
server_script 'server/main.lua'

lua54 'yes'
