# Start script to assemble a file using the MIPS.rb library and the given 
# filename

load 'MIPS.rb'

unless ARGV.size == 1
  puts "USAGE:\n#{File.basename($0)} <assembly_file>\n"
  abort("Single filename not supplied as an argument")
end

unless File.exists?(ARGV[0])
  abort("#{ARGV[0]} does not exist")
end

MIPS.assemble(ARGV[0])
