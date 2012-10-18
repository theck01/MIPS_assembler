# Collection of constants and methods used to create a MIPS architecture
# assembler. The specific instruction set can be found in the book:
# Computer Organization and Design, 4th ed.
module MIPS

  # Hash of all available opcodes in this MIPS architecture, with associated
  # values
  MNEMONICS = { 
    "add"   => { opcode: 0x00, format: :type_R, funct: 0x20 },
    "addi"  => { opcode: 0x08, format: :type_I, funct: nil  },
    "addiu" => { opcode: 0x09, format: :type_I, funct: nil  },
    "addu"  => { opcode: 0x00, format: :type_R, funct: 0x21 },
    "and"   => { opcode: 0x00, format: :type_R, funct: 0x24 },
    "andi"  => { opcode: 0x0C, format: :type_I, funct: nil  },
    "beq"   => { opcode: 0x04, format: :type_I, funct: nil  },
    "bne"   => { opcode: 0x05, format: :type_I, funct: nil  },
    "j"     => { opcode: 0x02, format: :type_J, funct: nil  },
    "jal"   => { opcode: 0x03, format: :type_J, funct: nil  },
    "jr"    => { opcode: 0x00, format: :type_R, funct: 0x08 },
    "lbu"   => { opcode: 0x24, format: :type_I, funct: nil  },
    "lhu"   => { opcode: 0x25, format: :type_I, funct: nil  },
    "ll"    => { opcode: 0x30, format: :type_I, funct: nil  },
    "lui"   => { opcode: 0x0F, format: :type_I, funct: nil  },
    "lw"    => { opcode: 0x23, format: :type_I, funct: nil  }, 
    "nor"   => { opcode: 0x00, format: :type_R, funct: 0x27 },
    "or"    => { opcode: 0x00, format: :type_R, funct: 0x25 },
    "ori"   => { opcode: 0x0D, format: :type_I, funct: nil  },
    "slt"   => { opcode: 0x00, format: :type_R, funct: 0x2A },
    "slti"  => { opcode: 0x0A, format: :type_I, funct: nil  },
    "sltiu" => { opcode: 0x0B, format: :type_I, funct: nil  },
    "sltu"  => { opcode: 0x00, format: :type_R, funct: 0x2B },
    "sll"   => { opcode: 0x00, format: :type_R, funct: 0x00 },
    "srl"   => { opcode: 0x00, format: :type_R, funct: 0x02 },
    "sb"    => { opcode: 0x28, format: :type_I, funct: nil  },
    "sc"    => { opcode: 0x38, format: :type_I, funct: nil  },
    "sh"    => { opcode: 0x29, format: :type_I, funct: nil  },
    "sw"    => { opcode: 0x2B, format: :type_I, funct: nil  },
    "sub"   => { opcode: 0x00, format: :type_R, funct: 0x22 },
    "subu"  => { opcode: 0x00, format: :type_R, funct: 0x23 } 
  }

  # Hash of supported pseudo operations, with associated number of expanded
  # opcodes after processing
  PSEUDOS = {  
    "blt"  => { mnemonics: ["slt", "bne"], format: :type_R }, 
    "bgt"  => { mnemonics: ["slt", "beq"], format: :type_R },
    "ble"  => { mnemonics: ["slt", "beq"], format: :type_R },
    "bge"  => { mnemonics: ["slt", "bne"], format: :type_R },
    "li"   => { mnemonics: ["addi"],       format: :type_I },
    "move" => { mnemonics: ["addi"],       format: :type_I },  
  }

  # Hash of assembler directives and associated methods 
  DIRECTIVES = {  
    "ORG"  => { storage_per_word: nil },
    "DC.B" => { storage_per_word: 4.0, type: :const },
    "DS.B" => { storage_per_word: 4.0, type: :var   },
    "DC.H" => { storage_per_word: 2.0, type: :const },
    "DS.H" => { storage_per_word: 2.0, type: :var   },
    "DC.W" => { storage_per_word: 1.0, type: :const },
    "DS.W" => { storage_per_word: 1.0  type: :var   }
  }

  # Hash of all available registers in this MIPS architecture
  REGISTERSS = { 
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

  def self.assemble(infile)

    self.resolve_labels(infile)

    # derive outfile name based on the input name
    if infile.match(/\..*/).to_s.empty?
      outfile = "#{infile}.o"
    else
      outfile = infile.sub(/\..*/, '.o')
    end

    # Assemble each line of the source file and output string to outfile
    File.open(outfile, "w") do |output|
      File.open(infile, "r") do |input|
        line_num = 0
        input.each do |line|
          line_num += 1
          next if line.chomp == "" #skip blank lines
          lhash = hash_line line line_num
          self.assemble_line(lhash).each { |code| output.puts code }
        end
      end
    end
    
    # return outfile name
    outfile
  end

  def self.resolve_labels(infile)

    # reset defaults (if not already set)
    @@labels = {}
    @@start_addr = 0x0040_0000

    offset = 0 #initial offset
    set_start = false #boolean indicating whether origin addr set
    
    # begin reading in file
    File.open infile do |input|

      line_num = 0

      input.each do |line|

        line_num += 1
        next if line.chomp == "" #skip blank lines

        # break line into individual tokens
        lhash = self.hash_line line line_num

        # add new symbols, set org if needed
        if lhash[:tokens][0][:type] == :unknown
           @@labels[lhash[:tokens][0][:field]] = offset 
        elsif lhash[:tokens][0][:field] == "ORG"
          unless @@start_addr == 0x0040_0000
            raise asm_err "Second ORG assignment"
          end
          @@start_addr = lhash[:tokens][1][:field].to_i
        end

        # increment offset
        offset += self.line_memory(lhash)
      end
    end
  end

  # returns an array of 32 bit machine code values
  def self.assemble_line(lhash)

    # output machine code array, one element per 32bit word
    code_ary = [];

  end

  # break line into token array, dealing with special immediate indexing
  # syntax if needed. Returns array of tokens
  def self.hash_line(line, line_num)

    #initialize hash with value of line and number
    lhash = { line: line, number: line_num }
    
    #split line
    tokens = line.gsub(/,/, ' ').gsub(/;.*/, '').split

    #search for and handle first occurance of immediate data syntax
    tokens.each_with_index do | word, idx |
      unless word.match(/0x[0-9A-F]+\(.*\)/).to_s.empty? &&
             word.match(/[0-9]+\(.*\)/).to_s.empty?
        #break up immeadiate data syntax into a :register and :immediate array
        chunks = word.sub(/\)/, '').split('(')
        tokens[idx] = chunks[1]; # substitute current element with :register
        tokens.insert idx chunks[0]
        return
      end
    end

    # assume that the line is a directive unless notified otherwise
    lhash[:format] = :directive

    lhash[:tokens] = tokens.map do | word |
      word_hash[:field] = word
      # alter the format if the word type is a :mnemonic, while also setting
      # the type to the proper value
      if (word_hash[:type] = self.token_type word) == :mnemonic
        lhash[:format] = MNEMONICS[word][:format]
      end

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
    elsif @@labels[token]
      :label
    elsif token.match(/0x[A-F0-9]+/).to_s.size == token.size ||
          token.match(/[0-9]+/).to_s.size == token.size
      :immediate
    else
      :unknown
    end
  end

  # returns the the amount of memory that a line reserves
  def self.line_memory(lhash)

    tokens = lhash[:tokens]

    # skip over labels in the line
    tokens = tokens[1...tokens.size] while tokens[0][:type] == :label
    
    case tokens[0][:type]
    when :mnemonic
      4
    when :pseudo
      4*PSEUDOS[tokens[0][:field]][:codes].size
    when :directive
      retval = 4*tokens[1].to_f.fdiv(DIRECTIVES[tokens[0][:field]).ceil
      unless retval > 0 || tokens[0][:field] == "ORG"
        raise asm_err "Reserved 0 storage with assembler directive
        #{tokens[0][:field]}"
      end
      retval
    else
      raise asm_err "Cannot lead a statement with unknown: #{tokens[0][:field]}"
    end
  end

  # returns an error string corresponding to line represented by lhash with
  # additional message err_str
  def self.asm_err(lhash, err_str)
    "ERROR: #{err_str}
    line #{lhash[:number]}: #{lhash[:line]}"
  end
end
