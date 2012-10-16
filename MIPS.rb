# Collection of constants and methods used to create a MIPS architecture
# assembler. The specific instruction set can be found in the book:
# Computer Organization and Design, 4th ed.
module MIPS

  # Hash of all available opcodes in this MIPS architecture
  OPCODES = {  "add"   => [0x00, :type_R],
               "addi"  => [0x08, :type_I],
               "addiu" => [0x09, :type_I],
               "addu"  => [0x00, :type_R],
               "and"   => [0x00, :type_R],
               "andi"  => [0x0C, :type_I],
               "beq"   => [0x04, :type_I],
               "bne"   => [0x05, :type_I],
               "j"     => [0x02, :type_J],
               "jal"   => [0x03, :type_J],
               "jr"    => [0x00, :type_R],
               "lbu"   => [0x24, :type_I],
               "lhu"   => [0x25, :type_I],
               "ll"    => [0x30, :type_I],
               "lui"   => [0x0F, :type_I],
               "lw"    => [0x23, :type_I], 
               "nor"   => [0x00, :type_R],
               "or"    => [0x00, :type_R],
               "ori"   => [0x0D, :type_I],
               "slt"   => [0x00, :type_R],
               "slti"  => [0x0A, :type_I],
               "sltiu" => [0x0B, :type_I],
               "sltu"  => [0x00, :type_R],
               "sll"   => [0x00, :type_R],
               "srl"   => [0x00, :type_R],
               "sb"    => [0x28, :type_I],
               "sc"    => [0x38, :type_I],
               "sh"    => [0x29, :type_I],
               "sw"    => [0x2B, :type_I],
               "sub"   => [0x00, :type_R],
               "subu"  => [0x00, :type_R]  }

  # Hash of supported pseudo operations, with associated number of expanded
  # opcodes after processing
  PSEUDO_OPS = {  "blt"  => 2,
                  "bgt"  => 2,
                  "ble"  => 2,
                  "bge"  => 2,
                  "li"   => 2,
                  "move" => 1  }

  # Hash of assembler directives and associated methods 
  ASM_DIRS = {  "ORG"  => 1.0/0.0,
                "DC.B" => 4.0,
                "DC.H" => 2.0,
                "DC.W" => 1.0}

  # Hash of all available registers in this MIPS architecture
  REGISTERS = {  "$zero" => 0,
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
  
  # Dynamically constructed Hash of all symbol values
  @@symtable = {};

  # Start section of machine code in memory (default is 0x0040_0000)
  @@start_addr = 0x0040_0000

  def self.assemble(infile)

    self.construct_symtable(infile)

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

  private

  def construct_symtable(infile)

    # reset defaults (if not already set)
    @@symtable = {}
    @@start_addr = 0x0040_0000

    offset = 0 #initial offset
    set_start = false #boolean indicating whether origin addr set
    
    # begin reading in file
    File.open infile do |input|
      input.each do |line|

        # break line into individual tokens
        tokens = line.gsub(/,/, ' ').gsub(/;.*/, '').split

        # add new symbols, set org if needed
        @@symtable[tokens[0]] = offset if token_type(tokens[0]) == :unknown
        if token[0] == "ORG"
          raise "Multiple ORG assignments" unless @@start_addr == 0x0040_0000
          @@start_addr = token[1].to_i
        end

        # increment offset
        offset += line_memory(tokens)
      end
    end
  end

  # returns an array of 32 bit machine code values
  def assemble_line(line)
    code_ary = [];

    # Break the line up into individual tokens, ignoring the comments
    tokens = line.gsub(/,/, ' ').gsub(/;.*/, '').split
  end

  # returns the token type in assembly terms as a symbol
  def token_type(token)
    if OPCODES[token.downcase]
      :opcode
    elsif PSEUDO_OPS[token.downcase]
      :pseudo_op
    elsif ASM_DIRS[token]
      :asm_dir
    elsif REGISTER[token.downcase]
      :register
    elsif @@symtable[token]
      :label
    else
      :unknown
    end
  end

  # returns the the amount of memory that a line reserves
  def line_memory(tokens)
    case token_type tokens[0]
    when :opcode
      1
    when :pseudo_op
      PSEUDO_OPS[tokens[0]]
    when :asm_dir
      retval = tokens[1].to_f.fdiv(ASM_DIRS[tokens[0]]).ceil
      unless retval > 0 || tokens[0] == "ORG"
        raise "Reserved 0 storage with assembler directive #{tokens[0]}"
      end
      retval
    when :label, :unknown
      line_memory(tokens[1...tokens.size])
    else
      raise "Cannot lead a statement with term: #{tokens[0]}"
    end
  end
end
