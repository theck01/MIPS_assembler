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
    "blt"  => { codes: ["slt", "bne"], format: :type_R }, 
    "bgt"  => { codes: ["slt", "beq"], format: :type_R },
    "ble"  => { codes: ["slt", "beq"], format: :type_R },
    "bge"  => { codes: ["slt", "bne"], format: :type_R },
    "li"   => { codes: ["addi"],       format: :type_I },
    "move" => { codes: ["addi"],       format: :type_I },  
  }

  # Hash of assembler directives and associated methods 
  DIRECTIVES = {  "ORG"  => 1.0/0.0,
                  "DC.B" => 4.0,
                  "DC.H" => 2.0,
                  "DC.W" => 1.0  }

  # Hash of all available registers in this MIPS architecture
  REGISTERSS = {  "$zero" => 0,
                  "$at"   => 1,
                  "$v0"   => 2,
                  "$v1"   => 3,
                  "$a0"   => 4,
                  "$a1"   => 5,
                  "$a2"   => 6,
                  "$a3"   => 7,
                  "$t0"   => 8,
                  "$t1"   => 9,
                  "$t2"   => 10,
                  "$t3"   => 11,
                  "$t4"   => 12,
                  "$t5"   => 13,
                  "$t6"   => 14,
                  "$t7"   => 15,
                  "$s0"   => 16,
                  "$s1"   => 17,
                  "$s2"   => 18,
                  "$s3"   => 19,
                  "$s4"   => 20,
                  "$s5"   => 21,
                  "$s6"   => 22,
                  "$s7"   => 23,
                  "$t8"   => 24,
                  "$t9"   => 25,
                  "$k0"   => 26,
                  "$k1"   => 27,
                  "$gp"   => 28,
                  "$sp"   => 29,
                  "$fp"   => 30,
                  "$ra"   => 31  }
  
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
        input.each do |line|
          self.assemble_line(line).each { |code| output.puts code }
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
      input.each do |line|

        # break line into individual tokens
        lhash = self.hash_line line

        # add new symbols, set org if needed
        if self.token_type(lhash[:tokens][0])== :unknown
           @@labels[lhash[:tokens][0]] = offset 
        elsif lhash[:tokens][0] == "ORG"
          raise "Multiple ORG assignments" unless @@start_addr == 0x0040_0000
          @@start_addr = lhash[:immediate] 
        end

        # increment offset
        offset += self.line_memory(lhash[:tokens])
      end
    end
  end

  # returns an array of 32 bit machine code values
  def self.assemble_line(line)

    # output machine code array, one element per 32bit word
    code_ary = [];

    # Break the line up into individual tokens
    tokens = self.hash_line line
  end

  # break line into token array, dealing with special immediate indexing
  # syntax if needed. Returns array of tokens
  def self.hash_line(line)

    #initialize hash with value of line
    lhash = { line: line }
    
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
    
    # set the tokens properly within the line
    lhash[:tokens] = tokens

    self.fill_hash_fields lhash
  end

  # Fills the fields of hash corresponding to the machine code fields
  def self.fill_hash_fields(lhash)
    lhash[:tokens].each do |token|
      
  end

  # returns the token type in assembly terms as a symbol
  def self.token_type(token)
    if MNEMONICS[token.downcase]
      :mnemonic
    elsif PSEUDOS[token.downcase]
      :pseudo
    elsif DIRECTIVES[token]
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
  # OUTDATED
  def self.line_memory(tokens)
    case self.token_type tokens[0]
    when :mnemonic
      4
    when :pseudo
      4*PSEUDOS[tokens[0]][:codes].size
    when :directive
      retval = 4*tokens[1].to_f.fdiv(DIRECTIVES[tokens[0]]).ceil
      unless retval > 0 || tokens[0] == "ORG"
        raise "Reserved 0 storage with assembler directive #{tokens[0]}"
      end
      retval
    when :label
      self.line_memory(tokens[1...tokens.size])
    else
      raise "Cannot lead a statement with term: #{tokens[0]}"
    end
  end
end
