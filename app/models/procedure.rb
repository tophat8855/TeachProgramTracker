class Procedure < ActiveRecord::Base

    filterrific :default_filter_params => { :sorted_by => 'date_desc' },
                :available_filters => %w[
                    sorted_by
                    search_query
                    with_date_gte
                ]

    # default for will_paginate
    self.per_page = 25

    scope :search_query, lambda { |query|
        return nil  if query.blank?
        # condition query, parse into individual keywords
        terms = query.downcase.split(/\s+/)
        # replace "*" with "%" for wildcard searches,
        # append '%', remove duplicate '%'s
        terms = terms.map { |e|
          (e.gsub('*', '%') + '%').gsub(/%+/, '%')
        }
        # configure number of OR conditions for provision
        # of interpolation arguments. Adjust this if you
        # change the number of OR conditions.
        num_or_conditions = 3
        where(
            terms.map {
                or_clauses = [
                    "LOWER(procedures.name) LIKE ?",
                    "LOWER(procedures.clinic_location) LIKE ?",
                    "LOWER(procedures.gestation) LIKE ?"
                ].join(' OR ')
                    "(#{ or_clauses })"
            }.join(' AND '),
            *terms.map { |e| [e] * num_or_conditions }.flatten
        )
    }

    scope :sorted_by, lambda { |sort_option|
    # extract the sort direction from the param value.
    direction = (sort_option =~ /desc$/) ? 'desc' : 'asc'
    case sort_option.to_s
    when /^date_/
      order("procedures.date #{ direction }")
    when /^gestation_/
      order("procedures.gestation #{ direction}")
    when /^name_/
      order("LOWER(procedures.name) #{ direction }, LOWER(procedures.name) #{ direction }")
    when /^clinic_location_/
      order("LOWER(procedures.clinic_location) #{ direction }, LOWER(procedures.clinic_location) #{ direction }")
    when /^resident_name_/
      order("LOWER(procedures.resident_name) #{ direction }, LOWER(procedures.resident_name) #{ direction }")
    when /^trainer_name_/
      order("LOWER(procedures.trainer_name) #{ direction }, LOWER(procedures.trainer_name) #{ direction }")
    else
      raise(ArgumentError, "Invalid sort option: #{ sort_option.inspect }")
    end
    }

    scope :with_date_gte, lambda { |ref_date|
    where('procedures.date >= ?', ref_date)
    }

    def self.options_for_sorted_by
    [
        ['Name (a-z)', 'name_asc'],
        ['Procedure date (newest first)', 'date_desc'],
        ['Procedure date (oldest first)', 'date_asc'],
        ['Country (a-z)', 'country_name_asc']
    ]
    end

    def full_name
    [last_name, first_name].compact.join(', ')
    end

    def decorated_date
    date.to_date.to_s(:long)
    end

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

  NAMES = ['EVA', 'MVA', 'IUD', 'MAB', 'U/S', 'Implant', 'Options', 'Contraceptive']
end
