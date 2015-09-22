require 'simple_xlsx_reader'
require 'geocoder'
require 'pg'
require 'time'
require 'active_support'

DB_NAME = "pstage_development"
SRC_XLS = "/Users/segfault/Downloads/ELENCO CONVENZIONI DI  TIROCINIO..  aggiornato al 28.07.15.xlsx"
# FIELDS_ = ["DENOMINAZIONE ENTI /AZIENDE/STUDI PROF.LI", "SEDE LEGALE", "REFERENTI", "TEL", "FAX", "E- MAIL", "ATTIVITA' ESPLETATA", "DATA STIPULA CONVENZIONE", "PARTITA  IVA / C.F.", nil]

P_TYPES = {
  "([.]*S[.]*R[.]*L[.]*)$" => "SRL",
  "([.]*S[.]*P[.]*A[.]*)$" => "SPA",
  "([.]*S[.]*N[.]*C[.]*)$" => "SNC",
  "([.]*S[.]*A[.]*S[.]*)$" => "SAS",
  "STUDIO" => "STUD"  
}

class String
  def clean_spaces
    self.squeeze(' ').strip
  end
  def clean_other
    self.gsub(/(-|,\\\/)/, '').strip.clean_spaces
  end
  def extract_range(from, to)
    self[from, to]
  end
  def escape_apices
    #self.gsub('\'', '\\\'')
    self..gsub("'"){""} # http://stackoverflow.com/questions/12700218/how-do-i-escape-a-single-quote-in-ruby
  end
end

class ExcelToDB
  def initialize(db_name, src_xls)
    @db_name = db_name
    @conn = nil
    @geocoder = nil
    @partners = []
    init_db_conn
    init_reader(src_xls)    
  end
  
  def init_db_conn
    @conn = PG.connect( dbname: @db_name )
  end
  
  def init_reader(src_xls)
    @reader = SimpleXlsxReader.open(src_xls)
  end
  
  def first_sheet
    @reader.sheets.first
  end
  
  def extract_p_type(p_name)
    extracted_p_type = nil
    P_TYPES.keys.each_with_index { |p_type_regex,i|
      if !p_name.match(/#{p_type_regex}/).nil?
        extracted_p_type = P_TYPES.values[i]
        break
      end
      }
    extracted_p_type
  end
  
  def extract_data_from(sheet)
    sheet.rows.each { |row|
      partner = make_partner_from(row)
      office = make_office_from(row)
      representative = make_representative_from(row)
      if !partner.nil?
        partner.merge!({ office: office })
        partner.merge!({ representative: representative })
        @partners << partner
      end
    }
  end
  
  def ork
     extract_data_from(first_sheet)
     @partners[1..-2].each { |p| 
       puts "***"
       p p
       puts
     }
     #puts "#{@partners.size-2} Partners."
     populate_db
  end
  
  def populate_db
    @partners[1..-2].each { |partner|
      print "Adding #{partner[:name]}.. "
      now = DateTime.now
      partner_query = nil
      if partner[:note].nil?
        partner_query = "INSERT INTO partners (name, p_type, website, vat, activities, created_at, updated_at) VALUES ('#{@conn.escape(partner[:name])}', '#{partner[:type]}', '#{partner[:website]}', '#{partner[:vat]}', '#{@conn.escape(partner[:activities])}', '#{now}', '#{now}') RETURNING id"
      else
        partner_query = "INSERT INTO partners (name, note, p_type, website, vat, created_at, updated_at) VALUES ('#{@conn.escape(partner[:name])}', '#{@conn.escape(partner[:note])}', '#{partner[:type]}', '#{partner[:website]}', '#{partner[:vat]}', '#{now}', '#{now}') RETURNING id"
      end
      partner_id = @conn.exec(partner_query)[0]["id"]
      print "with ID #{partner_id}.. "
      office_query = nil
      if partner[:office][:addr].nil?
        office_query = "INSERT INTO offices (partner_id, created_at, updated_at) VALUES ('#{partner_id}', '#{now}', '#{now}') RETURNING id"
      else
        office_query = "INSERT INTO offices (address, partner_id, created_at, updated_at) VALUES ('#{@conn.escape(partner[:office][:addr])}', '#{partner_id}', '#{now}', '#{now}') RETURNING id"
      end
      office_id = @conn.exec(office_query)[0]["id"]
      print "office ID #{office_id}.. "
      partnership_query = nil
      if partner[:office][:signing].nil?
        partnership_query = "INSERT INTO partnerships (partner_id, office_id, created_at, updated_at) VALUES ('#{partner_id}', '#{office_id}', '#{now}', '#{now}') RETURNING id"
      else
        partnership_query = "INSERT INTO partnerships (signing_date, partner_id, office_id, created_at, updated_at) VALUES ('#{partner[:office][:signing]}', '#{partner_id}', '#{office_id}', '#{now}', '#{now}') RETURNING id"
      end
      partnership_id = @conn.exec(partnership_query)[0]["id"]
      print "partnership ID #{partnership_id}.. "
      partner[:representative].each { |repr|
        repr_name = "#{repr[:title]}  #{repr[:name]}".clean_spaces
        #p repr_name
        repr_query = "INSERT INTO representatives (name, tel, fax, email, partnership_id, created_at, updated_at) VALUES ('#{@conn.escape(repr_name)}', '#{@conn.escape(repr[:tel])}', '#{@conn.escape(repr[:fax])}', '#{@conn.escape(repr[:email])}', '#{partnership_id}', '#{now}}', '#{now}') RETURNING id"
        repr_id = @conn.exec(repr_query)[0]["id"]
        #print "repr ID #{repr_id}.. "
        #repr_contact_query = "INSERT INTO representative_contacts (tel, fax, email, representative_id, created_at, updated_at) VALUES ('#{repr[:tel]}', '#{repr[:fax]}', '#{repr[:email]}', '#{repr_id}', '#{now}', '#{now}') RETURNING id"
        #contact_id = @conn.exec(repr_contact_query)[0]["id"]
        #print "contact ID #{contact_id}.. "
      }
      #act_descr = "#{partner[:office][:activities]}"
      #act_query = "INSERT INTO activities (descr, partnership_id, created_at, updated_at) VALUES ('#{act_descr.gsub('\'','\\')}', '#{partnership_id}', '#{now}}', '#{now}') RETURNING id"
      #act_id = @conn.exec(act_query)[0]["id"]
      #print "activities ID #{act_id}.. "
      puts "DONE!"
    }
#    keys = boat_data.keys[0]
#    vals = boat_data.values[0]
#
#    query = "INSERT INTO #{@db_ame}(#{keys.join(", ")}) VALUES (#{vals.map { |el| el.insert(0, "'"); el.insert(-1, "'")}.join(", ")})"
    #p query
#    @conn.exec( query )
  end
  
  
  #### Extracting notes from names (...) ####
  def separate_note_from(p_name)
    
    ## Finding notes, attempt 1 (monkey!)
    p_note = p_name.match(/([(].*[)](.*(vedi).*)*$)/i) #([(].*[)]$)/)
    if !p_note.nil?
      p_note = p_note[0]
      p_name = p_name.extract_range(0, p_name.index(/([(].*[)](.*(vedi).*)*$)/i)-1)
    end
    
    ## Finding notes, attempt 2 (monkey, monkey!)
    if p_name.include?('REGIONE') or p_name.include?('COMUNE')
      p_name_separator = p_name.index('-')
      if !p_name_separator.nil? and p_name_separator > 5
        p_name_splitted = p_name.split('-')
        if p_name_splitted.size > 1
          p_name = p_name_splitted[0].clean_spaces
          p_note = ( p_note.nil? ? "" : p_note + " - " ) + p_name_splitted[1].clean_spaces
        end
      end
    end
        
    ## Building intermediate result
    { name: p_name, note: p_note }
  end

  def remove_type_from(p_name, p_type)
    p_type_regex = P_TYPES.key(p_type)
    p_name = p_name.extract_range(0, p_name.index(/#{p_type_regex}/)-1)
    #p p_name
    p_name.clean_spaces
  end
  
  def extract_repr(round, from_str, acc, contact)
    m = from_str.clean_spaces.match(/((avv|sig(g)?|dr|mr|dott|ing|prof|arch|geom|per|rag)[.-](ra|ssa)?(\s){1}?((avv|sig|dr|dott|ing|prof|arch|geom|rag)[.]?)*(\s)*)/i)
    if m.nil?
      if round == 0
        split_test = from_str.clean_spaces.split('-')
        if split_test.size < 2
          repr = { title: nil, name: from_str.clean_other }
          repr.merge!(contact)
          acc.push(repr)
          return
        else
          repr = { title: nil, name: split_test[0].clean_other }
          repr.merge!(contact)
          acc.push(repr)
          extract_repr(round, split_test[1], acc, contact) 
        end
      end
      return
    end
    i = from_str.clean_spaces.index(/((avv|sig(g)?|dr|mr|dott|ing|prof|arch|geom|per|rag)[.-](ra|ssa)?(\s){1}?((avv|sig|dr|dott|ing|prof|arch|geom|rag)[.]?)*(\s)*)/i)
    j = from_str.clean_spaces.index(/((avv|sig(g)?|dr|mr|dott|ing|prof|arch|geom|per|rag)[.-](ra|ssa)?(\s){1}?((avv|sig|dr|dott|ing|prof|arch|geom|rag)[.]?)*(\s)*)/i, m[0].size+i)
    k = j.nil? ? 0 : j
    j = j.nil? ? i : j
    repr = { title: m[0].clean_spaces, name: from_str[(i+m[0].size)..k-1].clean_other }
    repr.merge!(contact)
    acc.push(repr)
    round += 1
    extract_repr(round, from_str.clean_spaces[(i+m[0].size)..-1], acc, contact) 
  end               
  
  def extract_website_from(extracted_email)
    domain = extracted_email.match(/@[a-zA-Z0-9]+[.](.+)/i)
    if !domain.nil? and extracted_email.match(/(hotmail|gmail|live|libero|me|iol|alice|virgilio|me|wind|tim|tin|fastwebnet|yahoo|tiscali|tiscalinet|email|191|inwind|interfree|infinito|virgiio|media|aruba|(.*pec.*))[.]/i).nil?
      domain[0].gsub('@', '').downcase
    else
      nil
    end
  end
  
  def make_representative_from(extracted_row)
    
    repr = extracted_row[2].to_s.clean_spaces
    acc = []
    tel = extracted_row[3].to_s.clean_spaces
    fax = extracted_row[4].to_s.clean_spaces
    email = extracted_row[5].to_s.clean_spaces
    contact = { tel: tel, fax: fax, email: email }
    extract_repr(0, repr, acc, contact)
    acc
        
  end
    
    ## Monkey-skipping void lines (...)
    #if representative["repr"] == ""
    #  nil
    #else
    #  representative
    #end
    
  
  def make_office_from(extracted_row)
    
    addr = extracted_row[1].to_s.clean_spaces
    if !addr.nil?
      addr = addr.scan(/^[^\(]*/)[0].clean_spaces
    end
    if addr.start_with?("SP")
      addr = addr.gsub("SP", "STRADA PROVINCIALE ").clean_spaces
    end
    if addr.start_with?("SS")
      addr = addr.gsub("SS", "STRADA STATALE ").clean_spaces
    end
    signing = nil
    begin
      signing = Time.parse(extracted_row[7].to_s.clean_spaces).strftime("%m/%d/%Y")
    rescue ArgumentError => e
    end
    #activities = extracted_row[6].to_s.clean_spaces.split(',').map { |act| act.downcase.clean_spaces }
      
    office = {
      addr: addr,
      signing: signing
    }
  
  end
  
  #### Crafting partner hash ####
  def make_partner_from(extracted_row)
    
    ## Extracting name and note
    name = extracted_row[0].to_s.clean_spaces
    name_and_note = separate_note_from(name)
    name = name_and_note[:name].upcase
    note = name_and_note[:note]
    
    ## Extracting vat
    vat = extracted_row[8].to_s.clean_spaces
    
    ## Extracting type
    type = extract_p_type(name)
    
    #name = remove_type_from(name, type) if !type.nil? and type != "STUD"
    #puts "#{name} || #{type}" if type.nil?
    
    website = extract_website_from(extracted_row[5].to_s.clean_spaces)
    
    activities = extracted_row[6].to_s.downcase.clean_spaces
    
    ## Building hash
    partner = {
      name: name,
      type: type,
      website: website,
      vat: vat,
      note: note,
      activities: activities
    }
    
    ## Monkey-skipping void lines (...)
    if partner[:name] == ""
      nil
    else
      partner
    end
    
  end
  
end

w = ExcelToDB.new(DB_NAME, SRC_XLS)
w.ork