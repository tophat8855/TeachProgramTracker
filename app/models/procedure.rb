class Procedure < ActiveRecord::Base
  CLINIC_LOCATIONS = [
      'Walnut Creek',
      'San Jose',
      'Fairfield',
      'Santa Rosa',
      'Valencia',
      'San Mateo',
      'Santa Cruz',
      'Coliseum',
      'Mt. Zion WOC',
      '6G',
      'CCRMC TAB',
      'Vista TAB',
      'other',
      'away rotation'
    ]

  NAMES = ['MVA', 'IUD', 'MAB', 'U/S', 'Implant', 'Options', 'Contraceptive']
end
