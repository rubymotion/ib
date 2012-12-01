class IB::Generator
  def write files, dest
    files = IB::Parser.new.find_all(files)

    FileUtils.mkpath dest

    File.open("#{dest}/Stubs.h", 'w') do |f|
      f.write <<-OBJC
// Generated by IB v#{IB::VERSION} gem. Do not edit it manually
// Run `rake ib:open` to refresh

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import <UIKit/UIKit.h>

#{generate_objc(files)}
OBJC
    end

    File.open("#{dest}/Stubs.m", 'w') do |f|
      f.write <<-OBJC
// Generated by IB v#{IB::VERSION} gem. Do not edit it manually
// Run `rake ib:open` to refresh

#import "Stubs.h"

#{generate_objc_impl(files)}
OBJC
    end
    
  end

  def generate_objc files
    src = files.map do |path, info|
<<-OBJC
@interface #{info[:class][0][0]} : #{info[:class][0][1]}

#{info[:outlets].map {|name, type| "@property IBOutlet #{generate_type(type)} #{name};" }.join("\n")}

#{info[:outlet_collections].map {|name, type| "@property IBOutletCollection(#{type}) NSArray * #{name};" }.join("\n")}

#{info[:actions].map {|action| "-(IBAction) #{generate_action(action)};" }.join("\n")}

@end
OBJC
    end.join("\n" * 2)
  end

  def generate_objc_impl files
    src = files.map do |path, info|
      <<-OBJC
@implementation #{info[:class][0][0]}

@end
OBJC
    end.join("\n" * 2)
  end

  def generate_type type
    type == "id" ? type : "#{type} *"
  end

  def generate_action action
    action[1] ? "#{action[0]}:(id) #{action[1]}" : "#{action[0]}"
  end
end
