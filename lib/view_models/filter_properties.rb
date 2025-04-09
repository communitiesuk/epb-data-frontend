require "csv"

module ViewModels
  class FilterProperties
    def self.page_title(property_type)
      case property_type
      when "domestic"
        I18n.t("filter_properties.domestic_title")
      when "non_domestic"
        I18n.t("filter_properties.non_domestic_title")
      when "public_buildings"
        I18n.t("filter_properties.dec_title")
      else
        ""
      end
    end

    def self.councils
      CSV.new(council_csv).each.to_a.flatten
    end

    def self.parliamentary_constituencies
      [
        "Select all",
        "Bristol Central",
        "Cities of London and Westminster",
        "Manchester Central",
      ]
    end

    def self.years
      (2012..Time.now.year).map(&:to_s)
    end

    def self.months
      I18n.t("date.months")
    end

    def self.start_year
      "2012"
    end

    def self.current_year
      Date.today.year.to_s
    end

    def self.previous_month
      (Date.today << 1).strftime("%B")
    end

    def self.dates_from_inputs(year, month)
      Date.new(year.to_i, Date::MONTHNAMES.index(month) || 0)
    end

    def self.is_valid_date?(params)
      return true if params.empty?

      start_date = dates_from_inputs(params["from-year"], params["from-month"])
      end_date = dates_from_inputs(params["to-year"], params["to-month"])

      start_date < end_date
    end

    def self.council_csv
      <<~HEREDOC
        Aberafan Maesteg
        Adur
        Alyn and Deeside
        Amber Valley
        Arun
        Ashfield
        Ashford
        Babergh
        Bangor Aberconwy
        Barking and Dagenham
        Barnet
        Barnsley
        Basildon
        Basingstoke and Deane
        Bassetlaw
        Bath and North East Somerset
        Bedford
        Bexley
        Birmingham
        Blaby
        Blackburn with Darwen
        Blackpool
        Blaenau Gwent
        Blaenau Gwent and Rhymney
        Bolsover
        Bolton
        Boston
        "Bournemouth, Christchurch and Poole"
        Bracknell Forest
        Bradford
        Braintree
        Breckland
        "Brecon, Radnor and Cwm Tawe"
        Brent
        Brentwood
        Bridgend
        Bridgend
        Brighton and Hove
        "Bristol, City of"
        Broadland
        Bromley
        Bromsgrove
        Broxbourne
        Broxtowe
        Buckinghamshire
        Burnley
        Bury
        Caerfyrddin
        Caerphilly
        Caerphilly
        Calderdale
        Cambridge
        Camden
        Cannock Chase
        Canterbury
        Cardiff
        Cardiff East
        Cardiff North
        Cardiff South and Penarth
        Cardiff West
        Carmarthenshire
        Castle Point
        Central Bedfordshire
        Ceredigion
        Ceredigion Preseli
        Charnwood
        Chelmsford
        Cheltenham
        Cherwell
        Cheshire East
        Cheshire West and Chester
        Chesterfield
        Chichester
        Chorley
        City of London
        Clwyd East
        Clwyd North
        Colchester
        Conwy
        Cornwall
        Cotswold
        County Durham
        Coventry
        Crawley
        Croydon
        Cumberland
        Dacorum
        Darlington
        Dartford
        Denbighshire
        Derby
        Derbyshire Dales
        Doncaster
        Dorset
        Dover
        Dudley
        Dwyfor Meirionnydd
        Ealing
        Eastbourne
        East Cambridgeshire
        East Devon
        East Hampshire
        East Hertfordshire
        Eastleigh
        East Lindsey
        East Riding of Yorkshire
        East Staffordshire
        East Suffolk
        Elmbridge
        Enfield
        Epping Forest
        Epsom and Ewell
        Erewash
        Exeter
        Fareham
        Fenland
        Flintshire
        Folkestone and Hythe
        Forest of Dean
        Fylde
        Gateshead
        Gedling
        Gloucester
        Gosport
        Gower
        Gravesham
        Great Yarmouth
        Greenwich
        Guildford
        Gwynedd
        Hackney
        Halton
        Hammersmith and Fulham
        Harborough
        Haringey
        Harlow
        Harrow
        Hart
        Hartlepool
        Hastings
        Havant
        Havering
        "Herefordshire, County of"
        Hertsmere
        High Peak
        Hillingdon
        Hinckley and Bosworth
        Horsham
        Hounslow
        Huntingdonshire
        Hyndburn
        Ipswich
        Isle of Anglesey
        Isle of Wight
        Isles of Scilly
        Islington
        Kensington and Chelsea
        King's Lynn and West Norfolk
        "Kingston upon Hull, City of"
        Kingston upon Thames
        Kirklees
        Knowsley
        Lambeth
        Lancaster
        Leeds
        Leicester
        Lewes
        Lewisham
        Lichfield
        Lincoln
        Liverpool
        Llanelli
        Luton
        Maidstone
        Maldon
        Malvern Hills
        Manchester
        Mansfield
        Medway
        Melton
        Merthyr Tydfil
        Merthyr Tydfil and Aberdare
        Merton
        Mid and South Pembrokeshire
        Mid Devon
        Middlesbrough
        Mid Suffolk
        Mid Sussex
        Milton Keynes
        Mole Valley
        Monmouthshire
        Monmouthshire
        Montgomeryshire and Glyndwr
        Neath and Swansea East
        Neath Port Talbot
        Newark and Sherwood
        Newcastle-under-Lyme
        Newcastle upon Tyne
        New Forest
        Newham
        Newport
        Newport East
        Newport West and Islwyn
        North Devon
        North East Derbyshire
        North East Lincolnshire
        North Hertfordshire
        North Kesteven
        North Lincolnshire
        North Norfolk
        North Northamptonshire
        North Somerset
        North Tyneside
        Northumberland
        North Warwickshire
        North West Leicestershire
        North Yorkshire
        Norwich
        Nottingham
        Nuneaton and Bedworth
        Oadby and Wigston
        Oldham
        Oxford
        Pembrokeshire
        Pendle
        Peterborough
        Plymouth
        Pontypridd
        Portsmouth
        Powys
        Preston
        Reading
        Redbridge
        Redcar and Cleveland
        Redditch
        Reigate and Banstead
        Rhondda and Ogmore
        Rhondda Cynon Taf
        Ribble Valley
        Richmond upon Thames
        Rochdale
        Rochford
        Rossendale
        Rother
        Rotherham
        Rugby
        Runnymede
        Rushcliffe
        Rushmoor
        Rutland
        Salford
        Sandwell
        Sefton
        Sevenoaks
        Sheffield
        Shropshire
        Slough
        Solihull
        Somerset
        Southampton
        South Cambridgeshire
        South Derbyshire
        Southend-on-Sea
        South Gloucestershire
        South Hams
        South Holland
        South Kesteven
        South Norfolk
        South Oxfordshire
        South Ribble
        South Staffordshire
        South Tyneside
        Southwark
        Spelthorne
        Stafford
        Staffordshire Moorlands
        St Albans
        Stevenage
        St. Helens
        Stockport
        Stockton-on-Tees
        Stoke-on-Trent
        Stratford-on-Avon
        Stroud
        Sunderland
        Surrey Heath
        Sutton
        Swale
        Swansea
        Swansea West
        Swindon
        Tameside
        Tamworth
        Tandridge
        Teignbridge
        Telford and Wrekin
        Tendring
        Test Valley
        Tewkesbury
        Thanet
        Three Rivers
        Thurrock
        Tonbridge and Malling
        Torbay
        Torfaen
        Torfaen
        Torridge
        Tower Hamlets
        Trafford
        Tunbridge Wells
        Uttlesford
        Vale of Glamorgan
        Vale of Glamorgan
        Vale of White Horse
        Wakefield
        Walsall
        Waltham Forest
        Wandsworth
        Warrington
        Warwick
        Watford
        Waverley
        Wealden
        Welwyn Hatfield
        West Berkshire
        West Devon
        West Lancashire
        West Lindsey
        Westminster
        Westmorland and Furness
        West Northamptonshire
        West Oxfordshire
        West Suffolk
        Wigan
        Wiltshire
        Winchester
        Windsor and Maidenhead
        Wirral
        Woking
        Wokingham
        Wolverhampton
        Worcester
        Worthing
        Wrexham
        Wrexham
        Wychavon
        Wyre
        Wyre Forest
        Ynys Môn
        York
      HEREDOC
    end
  end
end
