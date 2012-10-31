# Collection of constants and methods used to create a MIPS architecture
# assembler. The specific instruction set can be found in the book:
# Computer Organization and Design, 4th ed.

module MIPS

  #-----------------------------------------------------------------------------
  #                              LOOKUP TABLES
  #-----------------------------------------------------------------------------

  # Hash of all available opcodes in this MIPS architecture, with associated
  # values
  MNEMONICS = { 
    "add"   => { opcode: 0x00, optype: :R, funct: 0x20,
                 format: [:mnemonic, :register, :register, :register] },
    "addi"  => { opcode: 0x08, optype: :I, funct: nil,
                 format: [:mnemonic, :register, :register, :immediate] },
    "addiu" => { opcode: 0x09, optype: :I, funct: nil,
                 format: [:mnemonic, :register, :register, :immediate] },
    "addu"  => { opcode: 0x00, optype: :R, funct: 0x21,
                 format: [:mnemonic, :register, :register, :register] },
    "and"   => { opcode: 0x00, optype: :R, funct: 0x24,
                 format: [:mnemonic, :register, :register, :register] },
    "andi"  => { opcode: 0x0C, optype: :I, funct: nil,
                 format: [:mnemonic, :register, :register, :immediate] },
    "beq"   => { opcode: 0x04, optype: :I, funct: nil,
                 format: [:mnemonic, :register, :register, :immediate] },
    "bne"   => { opcode: 0x05, optype: :I, funct: nil,
                 format: [:mnemonic, :register, :register, :immediate] },
    "j"     => { opcode: 0x02, optype: :J, funct: nil,  
                 format: [:mnemonic, :immediate] },
    "jal"   => { opcode: 0x03, optype: :J, funct: nil,
                 format: [:mnemonic, :immediate] },
    "jr"    => { opcode: 0x00, optype: :R, funct: 0x08 ,
                 format: [:mnemonic, :register] },
    "lbu"   => { opcode: 0x24, optype: :I, funct: nil,
                 format: [:mnemonic, :register, :register, :immediate] },
    "lhu"   => { opcode: 0x25, optype: :I, funct: nil,
                 format: [:mnemonic, :register, :register, :immediate] },
    "ll"    => { opcode: 0x30, optype: :I, funct: nil,
                 format: [:mnemonic, :register, :register, :immediate]  },
    "lui"   => { opcode: 0x0F, optype: :I, funct: nil,
                 format: [:mnemonic, :register, :immediate ] },
    "lw"    => { opcode: 0x23, optype: :I, funct: nil,
                 format: [:mnemonic, :register, :register, :immediate] }, 
    "nor"   => { opcode: 0x00, optype: :R, funct: 0x27,
                 format: [:mnemonic, :register, :register, :register] },
    "or"    => { opcode: 0x00, optype: :R, funct: 0x25,
                 format: [:mnemonic, :register, :register, :register] },
    "ori"   => { opcode: 0x0D, optype: :I, funct: nil,
                 format: [:mnemonic, :register, :register, :immediate] },
    "slt"   => { opcode: 0x00, optype: :R, funct: 0x2A,
                 format: [:mnemonic, :register, :register, :register] },
    "slti"  => { opcode: 0x0A, optype: :I, funct: nil,
                 format: [:mnemonic, :register, :register, :register] },
    "sltiu" => { opcode: 0x0B, optype: :I, funct: nil,
                 format: [:mnemonic, :register, :register, :register] },
    "sltu"  => { opcode: 0x00, optype: :R, funct: 0x2B,
                 format: [:mnemonic, :register, :register, :register] },
    "sll"   => { opcode: 0x00, optype: :R, funct: 0x00,
                 format: [:mnemonic, :register, :register, :immediate] },
    "srl"   => { opcode: 0x00, optype: :R, funct: 0x02,
                 format: [:mnemonic, :register, :register, :immediate] },
    "sb"    => { opcode: 0x28, optype: :I, funct: nil,
                 format: [:mnemonic, :register, :register, :immediate] },
    "sc"    => { opcode: 0x38, optype: :I, funct: nil,
                 format: [:mnemonic, :register, :register, :immediate] },
    "sh"    => { opcode: 0x29, optype: :I, funct: nil,
                 format: [:mnemonic, :register, :register, :immediate] },
    "sw"    => { opcode: 0x2B, optype: :I, funct: nil,
                 format: [:mnemonic, :register, :register, :immediate] },
    "sub"   => { opcode: 0x00, optype: :R, funct: 0x22,
                 format: [:mnemonic, :register, :register, :register] },
    "subu"  => { opcode: 0x00, optype: :R, funct: 0x23,
                 format: [:mnemonic, :register, :register, :register] } 
  }

  # Hash of supported pseudo operations, with associated number of expanded
  # opcodes after processing
  PSEUDOS = {  
    "blt"   => { codes: 2, optype: :I,
                 format: [:pseudo, :register, :register, :immediate] }, 
    "bgt"   => { codes: 2, optype: :I,
                 format: [:pseudo, :register, :register, :immediate] },
    "ble"   => { codes: 2, optype: :I,
                 format: [:pseudo, :register, :register, :immediate] },
    "bge"   => { codes: 2, optype: :I,
                 format: [:pseudo, :register, :register, :immediate] },
    "li"    => { codes: 1, optype: :I,
                 format: [:pseudo, :register, :immediate] },
    "move"  => { codes: 1, optype: :R,
                 format: [:pseudo, :register, :register] },  
    "clear" => { codes: 1, optype: :I,
                 format: [:pseudo, :register] },
  }

  # Hash of assembler directives and associated methods 
  DIRECTIVES = {  
    "ORG"  => { format: [:directive, :immediate] }, 
    ".ORG"  => { format: [:directive, :immediate] }, 
    "DC.B" => { per_word: 4.0, dirtype: :dir_const,
                format: [:directive, :immediate, :immediate] },
    "DS.B" => { per_word: 4.0, dirtype: :dir_var,
                format: [:directive, :immediate] },
    ".BYTE"=> { per_word: 4.0, dirtype: :byte_list,
                format: [:directive, :imm_list] },
    "DC.H" => { per_word: 2.0, dirtype: :dir_const,
                format: [:directive, :immediate, :immediate] },
    "DS.H" => { per_word: 2.0, dirtype: :dir_var,
                format: [:directive, :immediate] },
    "DC.W" => { per_word: 1.0, dirtype: :dir_const,
                format: [:directive, :immediate, :immediate] },
    "DS.W" => { per_word: 1.0, dirtype: :dir_var,
                format: [:directive, :immediate] },
    "END"  => { format: [:directive] },
    ".END" => { format: [:directive] }
  }

  # Hash of all available registers in this MIPS architecture
  REGISTERS = { 
    "$zero" => 0,  "$at" => 1,  "$v0" => 2,  "$v1" => 3,
    "$a0"   => 4,  "$a1" => 5,  "$a2" => 6,  "$a3" => 7,
    "$t0"   => 8,  "$t1" => 9,  "$t2" => 10, "$t3" => 11,
    "$t4"   => 12, "$t5" => 13, "$t6" => 14, "$t7" => 15,
    "$s0"   => 16, "$s1" => 17, "$s2" => 18, "$s3" => 19,
    "$s4"   => 20, "$s5" => 21, "$s6" => 22, "$s7" => 23,
    "$t8"   => 24, "$t9" => 25, "$k0" => 26, "$k1" => 27,
    "$gp"   => 28, "$sp" => 29, "$fp" => 30, "$ra" => 31
  }

  # Dynamically constructed Hash of all symbol values, keys = 
  @@labels = {};

  # Start section of machine code in memory (default is 0x0040_0000)
  @@start_addr = 0x0040_0000


  #----------------------------------------------------------------------------
  #                                 METHODS
  #----------------------------------------------------------------------------

  # Assemble the input file represented by string infile
  def self.assemble(infile)

    self.resolve_labels(infile)

    # derive outfile name based on the input name
    if infile.match(/\..*/).to_s.empty?
      outfile = "#{infile}.lst"
    else
      outfile = infile.sub(/\..*/, '.lst')
    end

    # Assemble each line of the source file and output string to outfile
    File.open(outfile, "w") do |output|
      File.open(infile, "r") do |input|

        line_num = 0
        offset = 0

        start_str = padstr(@@start_addr.to_s(16),8)
        output.puts "# Starting ASM program at 0x#{start_str}"

        input.each do |line|

          line_num += 1
          lhash = hashline(line,line_num)
          next if lhash[:tokens].empty? #skip blank lines
          offset += self.line_memory(lhash)

          # check to see if END directive found
          break if self.check_end? lhash
          
          output.puts ""
          output.puts "# #{lhash[:line]}"
          self.assemble_line(lhash, offset).each { |code| output.puts code }
          output.puts "# Mem Addr: 0x#{padstr((@@start_addr + offset).to_s(16),8)}"
        end
        
        end_str = padstr((@@start_addr + offset).to_s(16),8)
        output.puts "# Ending ASM program at 0x#{end_str}"
      end

      output.puts ""
      output.puts "# SYMBOL TABLE"
      output.puts "#--------------"
      @@labels.to_a.each do
        |pair| output.puts "# #{pair[0]}, 0x#{pair[1].to_s(16)}"
      end

      puts "Assembled #{infile} into #{outfile}"
    end
    
    # return outfile name
    outfile
  end


  private

  # resolve the value for all labels present in the assembly code
  def self.resolve_labels(infile)

    # reset defaults (if not already set)
    @@labels = {}
    @@start_addr = 0x0040_0000

    offset = 0 #initial offset
    
    # begin reading in file
    File.open infile do |input|

      line_num = 0 # line number count in infile
      offset = 0   # initial offset of current position in memory

      input.each do |line|

        line_num += 1

        # break line into individual tokens
        lhash = self.hashline(line,line_num)
        next if lhash[:tokens].empty? #skip blank lines

        # add new symbols, set org if needed
        if lhash[:tokens][0][:type] == :unknown
          # remove : suffix if exists
          label = lhash[:tokens][0][:field].sub(/\:/, '')
          @@labels[label]= offset 
        # update start_addr if ORG directive encountered
        elsif lhash[:tokens][0][:field].match(/\A\.?ORG\Z/).to_s.empty? == false
          unless @@start_addr == 0x0040_0000
            asm_err(lhash,"Second ORG assignment")
          end
          @@start_addr = lhash[:tokens][1][:field]
        elsif self.check_end? lhash
          break
        end

        break if self.check_end? lhash

        # increment offset
        offset += self.line_memory(lhash)
      end
    end
  end


  # returns an array of 32 bit machine code values
  def self.assemble_line(lhash, offset)

    self.check_line_format lhash

    # get the array tokens from the line hash, skiping the initial label 
    tokens = lhash[:tokens]
    if tokens[0][:type] == :label 
      tokens = tokens[1...tokens.size]
    end

    # return directive result, if line represents directive
    if tokens[0][:type] == :directive

      # ORG assembles to nothing
      return [] unless tokens[0][:field].match(/\A\.?ORG\Z/).to_s.empty?

      dir_hash = { dirtype: tokens[0][:info][:dirtype],
                   imm1: tokens[1][:field], bytes: tokens[0][:info][:per_word] }
      dir_hash[:imm2] = tokens[2][:field] if tokens[2]
      return self.process_directive(lhash, dir_hash)
    end
      
    # setup local data to parse token array
    registers = if tokens[0][:info][:optype] == :R
      [:rd, :rs, :rt]
    else
      [:rt, :rs]
    end
    i = 0
    args = {}


    tokens.each do |token|
      case token[:type] 
      when :mnemonic
        args[:opcode] = token[:info][:opcode]
        args[:funct] = token[:info][:funct]
        args[:optype] = token[:info][:optype]
      when :pseudo
        args[:pseudo] = token[:field]
        args[:mnemonics] = token[:info][:mnemonics]
        args[:optype] = token[:info][:optype]
      when :register
        args[registers[i]] = token[:info]
        i += 1
      when :immediate
        args[:imm] = token[:info]
        args[:imm_abs] = token[:info]
      when :label
        args[:imm] = token[:info] - offset
        args[:imm_abs] = token[:info] + @@start_addr
      end
    end

    # expand any pseudo instructions into normal instructions, returns an array
    # of hashes, one for each mnemonic
    mnemonic_hashes = self.expand_pseudos args

    # create the array of "machine code" strings from each mnemonic hash
    mnemonic_hashes.map do |mnemonic_hash|
      case mnemonic_hash[:optype]
      when :R
        self.assemble_type_R mnemonic_hash
      when :I
        self.assemble_type_I mnemonic_hash
      else
        self.assemble_type_J mnemonic_hash
      end
    end
  end


  # return an array of string values representing directive
  def self.process_directive(lhash, dir_hash)

    # Process .byte style directive first
    if dir_hash[:dirtype] == :byte_list

      immdata = lhash[:tokens][1..-1]
      immdata = lhash[:tokens][1..-1] if immdata[0][:type] == :directive

      # create output strings from groups of 4 bytes
      output_array = []
      immdata.each_with_index do |field, i; nextstr|
        output_array[i/4] = "" if i%4 == 0
        nextstr = (immdata[i][:field]&0xFFFFFFFF).to_s(2)
        output_array[i/4] << self.padstr(nextstr, 32/dir_hash[:bytes])
      end

      # pad final string, which may not be complete if byte number is not a
      # multiple of 4
      output_array[-1] = self.padstr(output_array[-1], 32)
      output_array
    elsif dir_hash[:imm2] 
      element = self.padstr(dir_hash[:imm2].to_s(2),32/dir_hash[:bytes])
      constant = element * dir_hash[:bytes] 
      out_array = Array.new(dir_hash[:imm1].div(dir_hash[:bytes]), constant)

      last_word = element * dir_hash[:imm1].modulo(dir_hash[:bytes])
      out_array<<self.padstr(last_word, 32)
      out_array
    else
      output_val = "----- RESERVED FOR STORAGE -----"
      Array.new(dir_hash[:imm1], output_val)
    end
  end


  # expand any pseudo instruction in args into multiple arg hashes, on for
  # each contained mnemonic. Lots of edge cases, messy code
  def self.expand_pseudos args

    # if there are no pseudo operations, return an array with a single
    # element
    return [args] unless args[:pseudo]

    case args[:pseudo]
    when "blt"
      first = {  opcode: MNEMONICS["slt"][:opcode], rd: REGISTERS["$at"], 
                 rs: args[:rt], rt: args[:rs], optype: :R }
      second = { opcode: MNEMONICS["beq"][:opcode], rt: REGISTERS["$at"], 
                 rs: REGISTERS["$zero"], imm: args[:imm], optype: :I }
      [first,second]
    when "bgt"
      first = {  opcode: MNEMONICS["slt"][:opcode], rd: REGISTERS["$at"], 
                 rs: args[:rs], rt: args[:rt], optype: :R }
      second = { opcode: MNEMONICS["beq"][:opcode], rt: REGISTERS["$at"], 
                 rs: REGISTERS["$zero"], imm: args[:imm], optype: :I }
      [first,second]
    when "ble"
      first = {  opcode: MNEMONICS["slt"][:opcode], rd: REGISTERS["$at"], 
                 rs: args[:rs], rt: args[:rt], optype: :R }
      second = { opcode: MNEMONICS["bne"][:opcode], rt: REGISTERS["$at"], 
                 rs: REGISTERS["$zero"], imm: args[:imm], optype: :I }
      [first,second]
    when "bge"
      first = {  opcode: MNEMONICS["slt"][:opcode], rd: REGISTERS["$at"], 
                 rs: args[:rt], rt: args[:rs], optype: :R }
      second = { opcode: MNEMONICS["bne"][:opcode], rt: REGISTERS["$at"], 
                 rs: REGISTERS["$zero"], imm: args[:imm], optype: :I }
      [first,second]
    when "li"
      [ { opcode: MNEMONICS["addi"][:opcode], rt: args[:rt],
          rs: REGISTERS["$zero"], imm: args[:imm], optype: :I } ]
    when "move"
      [ { opcode: MNEMONICS["addi"][:opcode], rt: args[:rt], rt: args[:rs],
          imm: 0, optype: :I } ]
    when "clear"  
      [ { opcode: MNEMONICS["andi"][:opcode], rt: args[:rt],
          rs: REGISTERS["$zero"], optype: :I } ]
    end
  end


  # assemble R type instruction with associated args
  def self.assemble_type_R args
    output = ""
    output = output << padstr((args[:opcode] || 0).to_s(2), 6)
    output = output << padstr((args[:rs] || 0).to_s(2), 5)
    output = output << padstr((args[:rt] || 0).to_s(2), 5)
    output = output << padstr((args[:rd] || 0).to_s(2), 5)
    output = output << padstr((args[:imm] || 0).to_s(2), 5)
    output = output << padstr((args[:funct] || 0).to_s(2), 6)
  end

  # assemble I type instruction with associated args
  def self.assemble_type_I args
    output = ""
    output = output << padstr((args[:opcode] || 0).to_s(2), 6)
    output = output << padstr((args[:rs] || 0).to_s(2), 5)
    output = output << padstr((args[:rt] || 0).to_s(2), 5)
    output = output << padstr((args[:imm] || 0).to_s(2), 16)
  end

  # assemble J type instruction with associated args
  def self.assemble_type_J args
    output = ""
    output = output << padstr((args[:opcode] || 0).to_s(2), 6)
    output = output << padstr((args[:imm_abs] || 0).to_s(2), 26)
  end


  # break line into token array, dealing with special immediate indexing
  # syntax if needed. Returns array of tokens
  def self.hashline(line, line_num)

    #initialize hash with value of line and number
    lhash = { line: line, number: line_num }
    
    #split line, substituting commas and removing comments
    tokens = line.gsub(/,/, ' ').gsub(/;.*/, '').gsub(/\/\/.*/, '').split

    #search for and handle first occurance of immediate data syntax
    tokens.each_with_index do | word, idx |
      
      #search for patterm matching immediate data and break matching token
      #into two tokens, one for the register and one for the offset
      unless word.match(/0x[0-9A-F]+\(.*\)/).to_s.empty? &&
             word.match(/[0-9]+\(.*\)/).to_s.empty?
        #break up immediate data syntax into a :register and :immediate array
        chunks = word.sub(/\)/, '').split('(')
        tokens[idx] = chunks[0]; # substitute current element with :register
        tokens.insert(idx, chunks[1])
        break
      end
    end

    # generate tokens hash, converting immediate data to integer values
    lhash[:tokens] = tokens.map do | word |
      word_hash = {}
      word_hash[:type] = self.token_type word
      word_hash[:field] = self.format_field(word, word_hash[:type])
      word_hash[:info] = self.field_info(word_hash[:field], word_hash[:type])
      word_hash
    end

    lhash
  end
        

  # returns the token type in assembly terms as a symbol
  def self.token_type(token)
    if MNEMONICS[token.downcase]
      :mnemonic
    elsif PSEUDOS[token.downcase]
      :pseudo
    elsif DIRECTIVES[token.upcase]
      :directive
    elsif REGISTERS[token.downcase]
      :register
    elsif @@labels[token.sub(/\:/, '')]
      :label
    elsif token.match(/\A0x[A-F0-9]+\Z/).to_s.empty? == false ||
          token.match(/\A[0-9]+\Z/).to_s.empty? == false ||
          token.match(/\A[0-1]+B\Z/).to_s.empty? == false ||
          token.match(/\A[A-F0-9]+H\Z/).to_s.empty? == false
      :immediate
    else
      :unknown
    end
  end


  # formats the given field into the expected representation for its type
  def self.format_field(field, type)
    case type
    when :mnemonic, :pseudo, :register
      field.downcase
    when :directive
      field.upcase
    when :immediate
      if field.match(/\A0x[0-9A-F]+\Z/).to_s.empty? == false
        field.to_i(16)
      elsif field.match(/\A[0-9A-F]+H\Z/).to_s.empty? == false
        field[0...(field.size-1)].to_i(16)
      elsif field.match(/\A[0,1]+B\Z/).to_s.empty? == false
        field[0...(field.size-1)].to_i(2)
      else
        field.to_i
      end
    else
      field
    end
  end


  # method returns the value of the token with given type in the many tables
  def self.field_info(field, type)
    case type
    when :mnemonic
      MNEMONICS[field.downcase]
    when :pseudo
      PSEUDOS[field.downcase]
    when :directive
      DIRECTIVES[field.upcase]
    when :register
      REGISTERS[field.downcase]
    when :label
      @@labels[field]
    when :immediate
      field
    else
      nil
    end
  end


  # returns the the amount of memory that a line reserves
  def self.line_memory(lhash)

    tokens = lhash[:tokens]

    # skip over label in the line
    if tokens[0][:type] == :label || tokens[0][:type] == :unknown 
      tokens = tokens[1...tokens.size] 
    end
    
    case tokens[0][:type]
    when :mnemonic
      4
    when :pseudo
      4*tokens[0][:info][:codes]
    when :directive

      # catch directives that use no memory
      unless tokens[0][:field].match(/\A\.?ORG\Z/).to_s.empty? &&
             tokens[0][:field].match(/\A\.?END\Z/).to_s.empty?
        return 0
      end

      # BYTE assignments use variable memory
      if tokens[0][:info][:dirtype] == :byte_list
        return ((tokens.size-1).fdiv(tokens[0][:info][:per_word]).ceil)*4
      end

      retval = (tokens[1][:field].to_f.fdiv(tokens[0][:info][:per_word])).ceil
      retval *= 4
      unless retval > 0 
        asm_err(lhash, "Reserved 0 storage with assembler directive '#{tokens[0][:field]}'")
      end
      retval
    else
      asm_err(lhash, "Cannot lead a statement with unknown: '#{tokens[0][:field]}'")
    end
  end


  # function checks the line's format for proper formatting. Throws a runtime
  # exception if there is a formatting error. If method returns then line is
  # properly formatted
  def self.check_line_format(lhash)
    
    tokens = lhash[:tokens]

    # check for unknown values
    tokens.each do |token|
      if token[:type] == :unknown
        asm_err(lhash, "Unknown keyword '#{token[:field]}'")
      end
    end

    # skip over labels in the line
    if tokens[0][:type] == :label 
      tokens = tokens[1...tokens.size] 
    end

    # check that line begins with a mnemonic, pseudo instruction, or directive
    # by checking to see if first token has a format array
    unless tokens[0][:info][:format]
      asm_err(lhash, "Statement does not begin with mnemonic or assembler directive")
    end

    # Process .byte directive on its own
    if tokens[0][:info][:dirtype] == :byte_list

      #drop directive token, only interested in immedate data arguments
      tokens = tokens[1...tokens.size]
      types = tokens.map { |token| token[:type] }
      types.uniq!
      if types.size != 1 && types[0] != :immediate
        asm_err(lhash, "Types passed to '#{tokens[0][:field]}' should only be immediate data")
      end
      return nil
    end

    # check proper number of arguments to keyword
    unless tokens.size == tokens[0][:info][:format].size
      asm_err(lhash,"Unexpected number of arguments to assembler keyword '#{tokens[0][:field]}'")
    end
    
    # check that token types match with token format
    types = tokens.map do |token| 
      kind = token[:type]
      kind = :immediate if token[:type] == :label
      kind
    end

    unless tokens[0][:info][:format] == types
      asm_err(lhash, "Unexpected argument types for assembler keyword '#{tokens[0][:field]}'")
    end

    nil
  end


  #function returns true if lhash represents END directive, false if not
  def self.check_end?(lhash)

    # get tokens, skipping first label
    tokens = lhash[:tokens]
    if tokens[0][:type] == :label || tokens[0][:type] == :unknown
      tokens = tokens[1...tokens.size]
    end

    if !tokens[0][:field].match(/\A\.?END\Z/).to_s.empty?
      true
    else
      false
    end
  end
    

  # pads the string of numbers with 0's or remove digits until it is equal to 
  # length
  def self.padstr(num_str, length)
    if num_str.to_i < 0
      num_str = ((num_str.to_i)&0xFFFFFFF).to_s(2)
    end
    return ("0"*(length-num_str.length))<<num_str if num_str.length < length
    num_str[0...length]
  end
    

  # returns an error string corresponding to line represented by lhash with
  # additional message err_str
  def self.asm_err(lhash, err_str)
    abort("ASSEMBLER ERROR: #{err_str}\nline #{lhash[:number]}: #{lhash[:line]}")
  end
end
