include '::cups'

cups_queue { 'MinimalClass':
   ensure  => 'class',
   members => ['Office', 'Warehouse']
}

# ... will autorequire the following resources:

cups_queue { ['Office', 'Warehouse']:
  ensure => 'printer'
}
